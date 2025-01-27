import csv
import os
import sys
import json
import re

LIST_FIELDS = ["zones", "data_disk_sizes", "data_disk_types", "ports"]

def parse_csv_file(input_csv, output_folder):
    try:
        if not os.path.isfile(input_csv):
            raise FileNotFoundError(f"The input file '{input_csv}' does not exist or is not a file.")

        if not os.path.exists(output_folder):
            try:
                os.makedirs(output_folder)
            except Exception as e:
                raise PermissionError(f"Unable to create output folder '{output_folder}': {e}")
        else:
            if not os.access(output_folder, os.W_OK):
                raise PermissionError(f"The output folder '{output_folder}' is not writable.")

        resources_by_subscription = {}
        resource_type = os.path.splitext(os.path.basename(input_csv))[0]

        def parse_key_value_pairs(value):
            if not value or value.lower() in ["none", ""]:
                return {}  # Return empty dictionary for empty or none values
            pairs = value.split(";")
            return {k.strip(): v.strip() for pair in pairs for k, v in [pair.split(":")]}

        def parse_zones(value):
            if not value or value.lower() in ["none", ""]:
                return []  # Return empty list for empty or none values
            return [zone.strip() for zone in value.split(";") if zone.strip()]

        with open(input_csv, 'r', newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            if "subscription_id" not in reader.fieldnames:
                raise KeyError("The CSV file is missing the required 'subscription_id' column.")

            for row_number, row in enumerate(reader, start=2):
                try:
                    subscription_id = row["subscription_id"].strip()
                    if not subscription_id:
                        raise ValueError(f"Empty 'subscription_id' found at CSV line {row_number}.")

                    if subscription_id not in resources_by_subscription:
                        resources_by_subscription[subscription_id] = []

                    row_with_type = row.copy()
                    row_with_type["type"] = resource_type

                    # Ensure zones and tags are processed correctly
                    row_with_type["zones"] = parse_zones(row.get("zones", ""))
                    row_with_type["tags"] = parse_key_value_pairs(row.get("tags", ""))

                    # Apply additional logic only when type is 'aks'
                    if resource_type == "aks":
                        # Add global cluster-level fields
                        row_with_type["vnet_subnet_id"] = row["vnet_subnet_id"].strip()
                        row_with_type["service_cidr"] = row["service_cidr"].strip()
                        row_with_type["dns_service_ip"] = row["dns_service_ip"].strip()

                        # Parsing logic for AKS node pools
                        if "nodes" in row:
                            nodes = row["nodes"].split(",")
                            node_attributes = {
                                "vm_size": row["vm_size"].split(","),
                                "node_count": list(map(int, row["node_count"].split(","))),
                                "min_count": list(map(int, row["min_count"].split(","))),
                                "max_count": list(map(int, row["max_count"].split(","))),
                                "os_disk_size_gb": list(map(int, row["os_disk_size_gb"].split(","))),
                                "node_labels": [parse_key_value_pairs(labels) for labels in row["node_labels"].split(",")],
                                "node_taints": [taints.split(";") for taints in row["node_taints"].split(",")],
                                "zones": [parse_zones(zones) for zones in row["zones"].split(",")],
                                "mode": row["mode"].split(","),
                                "os_sku": row["os_sku"].split(",")
                            }

                            # Default Node Pool
                            row_with_type["default_node_pool"] = {
                                "name": nodes[0],
                                "vm_size": node_attributes["vm_size"][0],
                                "node_count": node_attributes["node_count"][0],
                                "min_count": node_attributes["min_count"][0],
                                "max_count": node_attributes["max_count"][0],
                                "os_disk_size_gb": node_attributes["os_disk_size_gb"][0],
                                "node_labels": node_attributes["node_labels"][0],
                                "node_taints": node_attributes["node_taints"][0],
                                "zones": node_attributes["zones"][0],
                                "mode": node_attributes["mode"][0],
                                "os_sku": node_attributes["os_sku"][0],
                                "vnet_subnet_id": row["vnet_subnet_id"].strip()
                            }

                            # Additional Node Pools
                            additional_pools = {}
                            for i, node in enumerate(nodes[1:], start=1):
                                additional_pools[node] = {
                                    "vm_size": node_attributes["vm_size"][i],
                                    "node_count": node_attributes["node_count"][i],
                                    "min_count": node_attributes["min_count"][i],
                                    "max_count": node_attributes["max_count"][i],
                                    "os_disk_size_gb": node_attributes["os_disk_size_gb"][i],
                                    "node_labels": node_attributes["node_labels"][i],
                                    "node_taints": node_attributes["node_taints"][i],
                                    "zones": node_attributes["zones"][i],
                                    "mode": node_attributes["mode"][i],
                                    "os_sku": node_attributes["os_sku"][i],
                                    "vnet_subnet_id": row["vnet_subnet_id"].strip()
                                }
                            row_with_type["additional_node_pools"] = additional_pools

                    resources_by_subscription[subscription_id].append(row_with_type)

                except Exception as e:
                    raise ValueError(f"Error processing row {row_number} in the CSV: {e}")

        for idx, (subscription_id, resources) in enumerate(resources_by_subscription.items(), start=1):
            workspace = f"workspace_{idx}"
            output_file = os.path.join(output_folder, f"resources_{workspace}.tfvars")

            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(f'subscription_id = "{subscription_id}"\n\n')
                f.write('resource_definitions = [\n')
                for resource in resources:
                    f.write('  {\n')
                    for key, value in resource.items():
                        if key == "subscription_id":
                            continue
                        formatted_value = json.dumps(value, indent=2) if isinstance(value, (dict, list)) else json.dumps(value)
                        f.write(f'    {key} = {formatted_value},\n')
                    f.write('  },\n')
                f.write(']\n')

        print(f"Successfully processed CSV file '{input_csv}' and generated tfvars files in '{output_folder}'.")

    except Exception as main_error:
        print(f"Error: {main_error}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python parse_csv.py <input_csv> <output_folder>")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_folder = sys.argv[2]
    parse_csv_file(input_csv, output_folder)
