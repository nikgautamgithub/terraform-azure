import csv
import os
import sys
import json
import re

# Fields that should always be treated as a list of strings
LIST_FIELDS = ["zones", "data_disk_sizes", "data_disk_types", "ports"]

def parse_csv_file(input_csv, output_folder):
    """
    Parse a single CSV file and generate tfvars files for each unique subscription_id.
    Each tfvars file will contain:
      - A subscription_id variable
      - A resource_definitions list of maps.
    
    The script:
    - Handles 'tags' as a map of strings if found (in the format key;value,key;value).
    - Treats certain fields (LIST_FIELDS) as lists if the CSV column uses comma or semicolon separation.
    - Converts 'public_ip_required' to a lowercase JSON boolean-like string ("true"/"false").
    - Infers a resource 'type' from the CSV filename (e.g., "azure_acr" if the file is named "azure_acr.csv").
    
    This function performs comprehensive error handling, raising or printing errors as necessary.
    """

    try:
        # 1. Check if input CSV exists and is indeed a file
        if not os.path.isfile(input_csv):
            raise FileNotFoundError(f"The input file '{input_csv}' does not exist or is not a file.")

        # 2. Check and/or create the output folder
        if not os.path.exists(output_folder):
            try:
                os.makedirs(output_folder)
            except Exception as e:
                raise PermissionError(f"Unable to create output folder '{output_folder}': {e}")
        else:
            if not os.access(output_folder, os.W_OK):
                raise PermissionError(f"The output folder '{output_folder}' is not writable.")

        # 3. Prepare data structure for grouping resources by subscription
        resources_by_subscription = {}

        # 4. Infer resource type from CSV filename (strip .csv)
        resource_type = os.path.splitext(os.path.basename(input_csv))[0]

        # 5. Read the CSV file
        try:
            with open(input_csv, 'r', newline='', encoding='utf-8') as f:
                reader = csv.DictReader(f)

                # Ensure subscription_id column exists
                if "subscription_id" not in reader.fieldnames:
                    raise KeyError("The CSV file is missing the required 'subscription_id' column.")

                # Process each row
                for row_number, row in enumerate(reader, start=2):  # start=2 because row 1 is headers
                    try:
                        subscription_id = row["subscription_id"].strip()
                        if not subscription_id:
                            raise ValueError(f"Empty 'subscription_id' found at CSV line {row_number}.")

                        # Initialize a new list for this subscription if needed
                        if subscription_id not in resources_by_subscription:
                            resources_by_subscription[subscription_id] = []

                        # Copy the row so we can add 'type' without affecting the original
                        row_with_type = row.copy()
                        row_with_type["type"] = resource_type

                        resources_by_subscription[subscription_id].append(row_with_type)

                    except Exception as e:
                        # We raise a more descriptive error if there's a problem processing a specific row
                        raise ValueError(f"Error processing row {row_number} in the CSV: {e}")

        except csv.Error as e:
            raise ValueError(f"Error parsing the CSV file '{input_csv}': {e}")
        except Exception as e:
            raise ValueError(f"Unexpected error reading the CSV file '{input_csv}': {e}")

        # 6. Create one .tfvars file per subscription
        try:
            if not resources_by_subscription:
                print("Warning: No valid resources found in the CSV. No tfvars files will be created.")
            else:
                for idx, (subscription_id, resources) in enumerate(resources_by_subscription.items(), start=1):
                    workspace = f"workspace_{idx}"
                    output_file = os.path.join(output_folder, f"resources_{workspace}.tfvars")

                    # Attempt to write to the output file
                    try:
                        with open(output_file, 'w', encoding='utf-8') as f:
                            # Write subscription_id
                            f.write(f'subscription_id = "{subscription_id}"\n\n')

                            # Write resource_definitions array
                            f.write('resource_definitions = [\n')
                            for resource in resources:
                                f.write('  {\n')
                                for key, value in resource.items():
                                    # Skip subscription_id inside resource definitions
                                    if key == "subscription_id":
                                        continue

                                    # Handle tags as a map of strings (key;value,key;value)
                                    if key == "tags" and value and value.strip():
                                        try:
                                            # Split by comma first, then each part by semicolon
                                            tag_pairs = [tag.strip() for tag in value.split(',') if tag.strip()]
                                            tags_dict = {}
                                            for pair in tag_pairs:
                                                kv = pair.split(';')
                                                if len(kv) != 2:
                                                    raise ValueError(f"Invalid tag format '{pair}'")
                                                k, v = kv
                                                tags_dict[k.strip()] = v.strip()

                                            formatted_value = json.dumps(tags_dict)
                                            f.write(f'    {key} = {formatted_value},\n')
                                        except Exception as e:
                                            raise ValueError(f"Error parsing tags '{value}': {e}")
                                        continue

                                    # Convert 'public_ip_required' to lowercase JSON bool-like string
                                    if key == "public_ip_required" and isinstance(value, str):
                                        formatted_value = json.dumps(value.lower())
                                        f.write(f'    {key} = {formatted_value},\n')
                                        continue

                                    # Fields in LIST_FIELDS -> treat as list of strings
                                    if key in LIST_FIELDS:
                                        try:
                                            # Split on comma or semicolon, strip whitespace
                                            items = [v.strip() for v in re.split(r"[;,]", str(value)) if v.strip()]
                                            formatted_value = json.dumps(items)
                                            f.write(f'    {key} = {formatted_value},\n')
                                        except Exception as e:
                                            raise ValueError(f"Error parsing list field '{key}': {value} - {e}")
                                        continue

                                    # Otherwise, handle semicolon- or comma-separated lists generically
                                    if ";" in str(value):
                                        try:
                                            parts = [str(v).strip() for v in str(value).split(";")]
                                            formatted_value = json.dumps(parts)
                                        except Exception as e:
                                            raise ValueError(f"Error splitting semicolon list for '{key}': {value} - {e}")
                                    elif "," in str(value):
                                        try:
                                            parts = [str(v).strip() for v in str(value).split(",")]
                                            formatted_value = json.dumps(parts)
                                        except Exception as e:
                                            raise ValueError(f"Error splitting comma list for '{key}': {value} - {e}")
                                    else:
                                        # Treat as a simple string, integer, etc.
                                        formatted_value = json.dumps(value)

                                    f.write(f'    {key} = {formatted_value},\n')
                                f.write('  },\n')
                            f.write(']\n')

                    except IOError as e:
                        raise IOError(f"Error writing to the output file '{output_file}': {e}")

        except Exception as e:
            raise e  # Let any unexpected errors bubble up

        print(f"Successfully processed CSV file '{input_csv}' and generated tfvars files in '{output_folder}'.")

    except Exception as main_error:
        print(f"Error: {main_error}")
        sys.exit(1)  # Exit with a non-zero status to indicate failure

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_csv> <output_folder>")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_folder = sys.argv[2]
    parse_csv_file(input_csv, output_folder)
