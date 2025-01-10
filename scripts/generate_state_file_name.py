import hcl2
import sys

# Mapping of relevant keys
relevant_keys = {
    "vm": "vm_name",
    "aks": "aks_name",
    "acr": "acr_name",
    "kv": "key_vault_name",
    "mi": "identity_name",
    "databricks": "workspace_name",
    "servicebus": "namespace_name",
    "df": "data_factory_name",
}

# Check if a file path is passed as an argument
if len(sys.argv) != 2:
    print("Usage: python generate_state_file_name.py <path_to_tfvars_file>")
    sys.exit(1)

# Get the file path from the arguments
file_path = sys.argv[1]

# Open and parse the tfvars file
try:
    with open(file_path, "r") as file:
        tfvars = hcl2.load(file)

    # Get the resource definitions
    resource_definitions = tfvars.get("resource_definitions", [])
    if not resource_definitions:
        print("Error: No resource definitions found in the tfvars file.")
        sys.exit(1)

    # Initialize an empty list to hold resource names
    resource_names = []

    # Loop through all resources and concatenate their names
    for resource in resource_definitions:
        resource_type = resource.get("type")
        if not resource_type:
            print("Error: 'type' key not found in one of the resource definitions.")
            sys.exit(1)

        # Get the relevant key for the current resource type
        key_name = relevant_keys.get(resource_type)
        if not key_name:
            print(f"Error: Resource type '{resource_type}' not recognized.")
            sys.exit(1)

        # Get the resource name using the relevant key
        resource_name = resource.get(key_name)
        if not resource_name:
            print(f"Error: Key '{key_name}' not found in the resource definition for type '{resource_type}'.")
            sys.exit(1)

        # Add the resource name to the list
        resource_names.append(resource_name)

    # Concatenate all resource names with hyphens
    concatenated_state_file_name = "_".join(resource_names)
    print(concatenated_state_file_name)  # Print the final state file name

except FileNotFoundError:
    print(f"Error: File not found at {file_path}")
    sys.exit(1)
except Exception as e:
    print(f"Error parsing tfvars file: {e}")
    sys.exit(1)
