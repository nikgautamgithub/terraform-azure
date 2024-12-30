import csv
import os
import sys
import json
import re

# Fields that should always be treated as list of strings
LIST_FIELDS = ["zones", "data_disk_sizes", "data_disk_types", "ports"]

def parse_csv_folder(input_folder, output_folder):
    """
    Parse multiple CSV files from a folder and generate tfvars files for each unique subscription_id.
    Ensures that the fields in LIST_FIELDS are always a list of strings in the generated tfvars.
    """
    try:
        # Check if input folder exists
        if not os.path.isdir(input_folder):
            raise FileNotFoundError(f"The input folder '{input_folder}' does not exist.")

        # Check if output folder is writable (or create it if it doesn't exist)
        if not os.access(output_folder, os.W_OK) and not os.path.exists(output_folder):
            raise PermissionError(f"The output folder '{output_folder}' is not writable or does not exist.")

        if not os.path.exists(output_folder):
            os.makedirs(output_folder)

        resources_by_subscription = {}

        # Process each CSV file in the folder
        for csv_file in os.listdir(input_folder):
            if csv_file.endswith(".csv"):
                file_path = os.path.join(input_folder, csv_file)
                # Extract type from filename (everything before .csv)
                resource_type = os.path.splitext(csv_file)[0]
                
                try:
                    with open(file_path, 'r') as f:
                        reader = csv.DictReader(f)
                        if "subscription_id" not in reader.fieldnames:
                            raise KeyError(f"The file '{csv_file}' is missing the required 'subscription_id' column.")

                        for row in reader:
                            subscription_id = row["subscription_id"]
                            if subscription_id not in resources_by_subscription:
                                resources_by_subscription[subscription_id] = []
                            # Add type to the resource
                            row_with_type = row.copy()
                            row_with_type["type"] = resource_type
                            resources_by_subscription[subscription_id].append(row_with_type)
                except Exception as e:
                    raise ValueError(f"Error reading the CSV file '{csv_file}': {e}")

        # Write a tfvars file for each subscription
        for idx, (subscription_id, resources) in enumerate(resources_by_subscription.items(), start=1):
            try:
                workspace = f"workspace_{idx}"
                output_file = os.path.join(output_folder, f"resources_{workspace}.tfvars")
                with open(output_file, 'w') as f:
                    # Write subscription_id as a separate variable
                    f.write(f'subscription_id = "{subscription_id}"\n\n')
                    # Write resource_definitions
                    f.write('resource_definitions = [\n')
                    for resource in resources:
                        f.write('  {\n')
                        for key, value in resource.items():
                            # Skip subscription_id inside resource definitions
                            if key == "subscription_id":
                                continue
                            
                            # Always convert public_ip_required to lowercase JSON bool-like string
                            if key == "public_ip_required" and isinstance(value, str):
                                formatted_value = json.dumps(value.lower())
                                f.write(f'    {key} = {formatted_value},\n')
                                continue

                            # Check if the key is in our list of list-fields
                            if key in LIST_FIELDS:
                                # Split on comma or semicolon, strip whitespace
                                items = [v.strip() for v in re.split(r"[;,]", str(value)) if v.strip()]
                                formatted_value = json.dumps(items)
                                f.write(f'    {key} = {formatted_value},\n')
                                continue

                            # Otherwise, handle semicolon- or comma-separated lists
                            if ";" in str(value):
                                formatted_value = json.dumps([str(v).strip() for v in str(value).split(";")])
                            elif "," in str(value):
                                formatted_value = json.dumps([str(v).strip() for v in str(value).split(",")])
                            else:
                                # Treat it as a simple string (or integer, etc.)
                                formatted_value = json.dumps(value)
                            
                            f.write(f'    {key} = {formatted_value},\n')
                        f.write('  },\n')
                    f.write(']\n')
            except Exception as e:
                raise IOError(f"Error writing to the output file '{output_file}': {e}")

        print(f"Successfully processed all CSV files and generated tfvars files in '{output_folder}'.")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_folder> <output_folder>")
        sys.exit(1)

    input_folder = sys.argv[1]
    output_folder = sys.argv[2]
    parse_csv_folder(input_folder, output_folder)
