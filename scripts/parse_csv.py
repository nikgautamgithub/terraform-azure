import csv
import sys

# Usage: python parse_csv.py input.csv terraform.tfvars

input_file = sys.argv[1]
output_file = sys.argv[2]

resources = []

with open(input_file, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Dynamically handle all keys in the CSV row
        resource = {key: value for key, value in row.items()}
        resources.append(resource)

with open(output_file, 'w') as f:
    f.write('resource_definitions = [\n')
    for resource in resources:
        f.write('  {\n')
        for key, value in resource.items():
            f.write(f'    {key} = "{value}",\n')
        f.write('  },\n')
    f.write(']\n')

print(f"Successfully parsed {len(resources)} resources from {input_file} into {output_file}.")
