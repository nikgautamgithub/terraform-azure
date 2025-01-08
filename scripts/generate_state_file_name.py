import re
import json
import sys

# Function to read the .tfvars file
def read_tfvars_file(file_path):
    try:
        with open(file_path, "r") as file:
            return file.read()
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading the file: {e}")
        sys.exit(1)

# Function to clean and convert tfvars content into JSON-compatible format
def parse_tfvars(tfvars_str):
    lines = tfvars_str.splitlines()
    relevant_lines = []
    
    # Ignore lines containing "tags" or any other unwanted attributes
    for line in lines:
        if "tags" in line:
            continue
        relevant_lines.append(line.strip())

    # Join relevant lines and convert to JSON-compatible format
    cleaned_tfvars = "\n".join(relevant_lines)
    cleaned_tfvars = re.sub(r",\s*([\]\}])", r"\1", cleaned_tfvars)  # Remove trailing commas
    cleaned_tfvars = re.sub(r"([a-zA-Z0-9_]+)\s*=", r'"\1":', cleaned_tfvars)  # Convert keys
    cleaned_tfvars = cleaned_tfvars.replace("[", "[").replace("]", "]")
    cleaned_tfvars = cleaned_tfvars.replace("{", "{").replace("}", "}")
    cleaned_tfvars = cleaned_tfvars.replace('"""', '"').replace("'", '"')
    
    try:
        # Add braces to make it a JSON object
        json_data = "{" + cleaned_tfvars.strip() + "}"
        return json.loads(json_data)
    except json.JSONDecodeError as e:
        print(f"Error parsing tfvars content: {e}")
        sys.exit(1)

# Function to extract concatenated names
def get_concatenated_name(resource_definitions, relevant_keys):
    result = []
    for resource in resource_definitions:
        resource_type = resource.get("type")
        key = relevant_keys.get(resource_type, None)
        if key and key in resource:
            result.append(resource[key])
    return "_".join(result)

# Main logic
def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_tfvars_file>")
        sys.exit(1)

    file_path = sys.argv[1]  # Get the file path from command-line arguments
    tfvars_content = read_tfvars_file(file_path)
    
    # Mapping of relevant keys
    relevant_keys = {
        "vm": "vm_name",
        "aks": "aks_name",
        "acr": "acr_name",
        "kv": "key_vault_name",
        "mi": "identity_name",
        "databricks": "workspace_name",
        "servicebus": "namespace_name",
    }

    # Parse the tfvars content
    parsed_data = parse_tfvars(tfvars_content)
    resource_definitions = parsed_data.get("resource_definitions", [])
    
    # Get concatenated name
    concatenated_name = get_concatenated_name(resource_definitions, relevant_keys)
    print(concatenated_name)

# Run the script
if __name__ == "__main__":
    main()
