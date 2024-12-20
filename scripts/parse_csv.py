import csv
import sys

# Usage: python parse_csv.py input.csv terraform.tfvars

input_file = sys.argv[1]
output_file = sys.argv[2]

resources = []

with open(input_file, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Assuming CSV columns: type, subscription_name, name, resource_group, os_type, vm_size, ...
        resources.append({
            "type": row.get("type"),
            "subscription_name": row.get("subscription_name"),
            "name": row.get("name"),
            "os_type": row.get("os_type"),
            "vm_size": row.get("vm_size"),
            "resource_group": row.get("resource_group"),
        })

with open(output_file, 'w') as f:
    f.write('resource_definitions = [\n')
    for r in resources:
        f.write('  {\n')
        for k,v in r.items():
            f.write(f'    {k} = "{v}"\n')
        f.write('  },\n')
    f.write(']\n')
