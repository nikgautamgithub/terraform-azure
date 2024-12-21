import csv
import sys

def parse_csv(input_csv, output_tfvars):
    resources = []
    with open(input_csv, 'r') as f, open(output_tfvars, 'w') as tfvars_file:
        reader = csv.DictReader(f)
        for row in reader:
            resource = {key: value for key, value in row.items()}
            # Convert list-like fields to actual lists
            if "data_disks" in resource:
                resource["data_disks"] = [int(size) for size in resource["data_disks"].split(";")]
            if "disk_types" in resource:
                resource["disk_types"] = resource["disk_types"].split(";")
            if "allowed_ports" in resource and resource["allowed_ports"]:
                resource["allowed_ports"] = resource["allowed_ports"].split(";")
            else:
                resource["allowed_ports"] = []
            resources.append(resource)

        # Write Terraform-compatible variables
        tfvars_file.write("resource_definitions = [\n")
        for resource in resources:
            tfvars_file.write("  {\n")
            for key, value in resource.items():
                if isinstance(value, list):
                    tfvars_file.write(f'    {key} = {value},\n')
                else:
                    tfvars_file.write(f'    {key} = "{value}",\n')
            tfvars_file.write("  },\n")
        tfvars_file.write("]\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python parse_csv.py <input_csv> <output_tfvars>")
        sys.exit(1)

    parse_csv(sys.argv[1], sys.argv[2])