import csv
import sys
import ast

# Usage: python parse_csv.py input.csv terraform.tfvars

input_file = sys.argv[1]
output_file = sys.argv[2]

resources = []

with open(input_file, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Dynamically handle all keys in the CSV row
        resource = {}
        for key, value in row.items():
            # Check if the value looks like a list (separated by ; or a valid Python list)
            if ';' in value:
                resource[key] = [item.strip() for item in value.split(';')]
            else:
                try:
                    # Attempt to parse as a Python literal (e.g., list, dict, etc.)
                    parsed_value = ast.literal_eval(value)
                    if isinstance(parsed_value, list):
                        resource[key] = parsed_value
                    else:
                        resource[key] = str(parsed_value)
                except (ValueError, SyntaxError):
                    resource[key] = value
        resources.append(resource)

with open(output_file, 'w') as f:
    f.write('resource_definitions = [\n')
    for resource in resources:
        f.write('  {\n')
        for key, value in resource.items():
            if isinstance(value, list):
                # Ensure lists are formatted with double quotes for strings
                formatted_list = ', '.join(f'"{item}"' if isinstance(item, str) else str(item) for item in value)
                f.write(f'    {key} = [{formatted_list}],\n')
            else:
                f.write(f'    {key} = "{value}",\n')
        f.write('  },\n')
    f.write(']\n')

print(f"Successfully parsed {len(resources)} resources from {input_file} into {output_file}.")
