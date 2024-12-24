import os
import shutil
import subprocess
import sys
from datetime import datetime

# Constants
CSV_PARSE_SCRIPT = "scripts/parse_csv.py"
INPUT_FOLDER = "csv"
OUTPUT_FOLDER = "tfvars"

def log(message):
    """Log messages with timestamps."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def run_command(command, error_message):
    """Run a system command and handle errors."""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        log(result.stdout.strip())
    except subprocess.CalledProcessError as e:
        log(f"{error_message}\n{e.stderr.strip()}")
        sys.exit(1)

def clear_output_folder():
    """Clear the output folder before generating new files."""
    if os.path.exists(OUTPUT_FOLDER):
        log(f"Clearing the contents of the folder '{OUTPUT_FOLDER}'...")
        for filename in os.listdir(OUTPUT_FOLDER):
            file_path = os.path.join(OUTPUT_FOLDER, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                log(f"Failed to delete {file_path}. Reason: {e}")
    else:
        os.makedirs(OUTPUT_FOLDER)

def generate_tfvars():
    """Run the Python script to generate .tfvars files."""
    if not os.path.exists(INPUT_FOLDER):
        log(f"Input folder '{INPUT_FOLDER}' does not exist.")
        sys.exit(1)

    clear_output_folder()

    log("Running the Python script to generate .tfvars files...")
    run_command(f"python3 {CSV_PARSE_SCRIPT} {INPUT_FOLDER} {OUTPUT_FOLDER}", "Failed to generate .tfvars files.")

def initialize_terraform():
    """Initialize Terraform."""
    log("Initializing Terraform...")
    run_command("terraform init", "Terraform initialization failed.")

def process_tfvars():
    """Process each .tfvars file."""
    tfvars_files = [f for f in os.listdir(OUTPUT_FOLDER) if f.endswith(".tfvars")]
    if not tfvars_files:
        log("No .tfvars files found in the output folder.")
        sys.exit(1)

    for tfvars_file in tfvars_files:
        workspace_name = os.path.splitext(tfvars_file)[0]
        tfvars_path = os.path.join(OUTPUT_FOLDER, tfvars_file)

        # Create workspace
        log(f"Creating or selecting Terraform workspace: {workspace_name}...")
        run_command(f"terraform workspace new {workspace_name} || terraform workspace select {workspace_name}",
                    f"Failed to create or select workspace {workspace_name}.")

        # Run terraform plan
        log(f"Running Terraform plan for workspace: {workspace_name}...")
        run_command(f"terraform plan -var-file={tfvars_path}", f"Terraform plan failed for workspace {workspace_name}.")

        # Run terraform apply
        log(f"Running Terraform apply for workspace: {workspace_name}...")
        run_command(f"terraform apply -var-file={tfvars_path} -auto-approve", f"Terraform apply failed for workspace {workspace_name}.")

if __name__ == "__main__":
    # Ensure Python and Terraform are available
    log("Checking prerequisites...")
    if not shutil.which("python3"):
        log("Python3 is not installed. Please install it.")
        sys.exit(1)
    if not shutil.which("terraform"):
        log("Terraform is not installed. Please install it.")
        sys.exit(1)

    # Run all steps
    generate_tfvars()
    initialize_terraform()
    process_tfvars()
    log("All workspaces have been processed successfully.")
