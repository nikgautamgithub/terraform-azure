import csv
import os
import sys
import json

def parse_csv_folder(input_folder, output_folder):
    """
    Parse multiple CSV files from a folder and generate tfvars files for each unique subscription_id.
    """
    try:
        # Check if input folder exists
        if not os.path.isdir(input_folder):
            raise FileNotFoundError(f"The input folder '{input_folder}' does not exist.")

        # Check if output folder is writable
        if not os.access(output_folder, os.W_OK) and not os.path.exists(output_folder):
            raise PermissionError(f"The output folder '{output_folder}' is not writable or does not exist.")

        if not os.path.exists(output_folder):
            os.makedirs(output_folder)

        resources_by_subscription = {}

        # Process each CSV file in the folder
        for csv_file in os.listdir(input_folder):
            if csv_file.endswith(".csv"):
                file_path = os.path.join(input_folder, csv_file)
                try:
                    with open(file_path, 'r') as f:
                        reader = csv.DictReader(f)
                        if "subscription_id" not in reader.fieldnames:
                            raise KeyError(f"The file '{csv_file}' is missing the required 'subscription_id' column.")

                        for row in reader:
                            subscription_id = row["subscription_id"]
                            if subscription_id not in resources_by_subscription:
                                resources_by_subscription[subscription_id] = []
                            resources_by_subscription[subscription_id].append(row)
                except Exception as e:
                    raise ValueError(f"Error reading the CSV file '{csv_file}': {e}")

        # Write a tfvars file for each subscription
        for idx, (subscription_id, resources) in enumerate(resources_by_subscription.items(), start=1):
            try:
                workspace = f"workspace_{idx}"
                output_file = os.path.join(output_folder, f"resources_{workspace}.tfvars")
                with open(output_file, 'w') as f:
                    # Write subscription_id as a separate variable
                    f.write(f'subscription_id = "{subscription_id}"\n\n')                    # Write resource_definitions
                    f.write('resource_definitions = [\n')
                    for resource in resources:
                        f.write('  {\n')
                        for key, value in resource.items():
                            if key == "subscription_id":
                                continue  # Skip subscription_id inside resource definitions
                            if key == "zones" or key == "nic_names":  # Ensure zones and nic_names are formatted as a list of strings
                                formatted_value = json.dumps(value.split(";"))  # Properly format as a list
                                f.write(f'    {key} = {formatted_value},\n')
                            elif key == "public_ip_required":  # Ensure public_ip_required is a lowercase string
                                formatted_value = json.dumps(value.lower())
                                f.write(f'    {key} = {formatted_value},\n')
                            elif ";" in value:  # Handle other semicolon-separated lists
                                formatted_value = json.dumps(value.split(";"))  # Properly format as a list
                                f.write(f'    {key} = {formatted_value},\n')
                            else:
                                formatted_value = json.dumps(value)  # Properly format as a string
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
