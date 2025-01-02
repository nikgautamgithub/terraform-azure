import os
import json

def generate_matrix(output_folder):
    """Generate a matrix for Azure DevOps based on .tfvars files."""
    tfvars_files = [f for f in os.listdir(output_folder) if f.endswith(".tfvars")]
    if not tfvars_files:
        raise ValueError("No .tfvars files found in the output folder.")

    matrix = {os.path.splitext(f)[0]: {"TFVARS_FILE": os.path.splitext(f)[0]} for f in tfvars_files}
    return matrix

if __name__ == "__main__":
    output_folder = "tfvars"
    if not os.path.exists(output_folder):
        raise FileNotFoundError(f"Output folder '{output_folder}' does not exist.")

    matrix = generate_matrix(output_folder)
    print(json.dumps(matrix))
