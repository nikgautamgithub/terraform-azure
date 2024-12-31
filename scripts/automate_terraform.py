import os
import shutil
import subprocess
import sys
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

# Path to the parse_csv.py script (which accepts <input_csv> <output_folder>)
CSV_PARSE_SCRIPT = "scripts/parse_csv.py"

# Hardcoded output folder
OUTPUT_FOLDER = "tfvars"

def log(message):
    """Log messages with timestamps."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def run_command(command, error_message):
    """
    Run a system command and handle errors.
    Return the (stdout, stderr) as a tuple so we can log or handle them.
    """
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        stdout = result.stdout.strip()
        stderr = result.stderr.strip()
        if stdout:
            log(stdout)
        return (stdout, stderr)
    except subprocess.CalledProcessError as e:
        log(f"{error_message}\n{e.stderr.strip()}")
        # Raise instead of sys.exit(1) so a single failure doesn't kill the entire process.
        raise

def clear_output_folder():
    """Clear the hardcoded output folder before generating new files."""
    if os.path.exists(OUTPUT_FOLDER):
        log(f"Clearing the contents of '{OUTPUT_FOLDER}'...")
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

def generate_tfvars(input_csv):
    """Use parse_csv.py to generate .tfvars files from a single CSV input."""
    if not os.path.isfile(input_csv):
        log(f"Input file '{input_csv}' does not exist.")
        sys.exit(1)

    clear_output_folder()

    log("Running the Python script to generate .tfvars files...")
    try:
        # Note how we pass the hardcoded OUTPUT_FOLDER here
        run_command(
            f"python3 {CSV_PARSE_SCRIPT} {input_csv} {OUTPUT_FOLDER}",
            "Failed to generate .tfvars files."
        )
    except Exception:
        sys.exit(1)

def initialize_terraform():
    """Initialize Terraform in the current directory."""
    log("Initializing Terraform...")
    try:
        run_command("terraform init", "Terraform initialization failed.")
    except Exception:
        sys.exit(1)

def process_single_tfvars_file(tfvars_file):
    """
    Process a single .tfvars file:
      1. Create or select the workspace
      2. Run 'terraform plan'
      3. Run 'terraform apply'
    """
    workspace_name = os.path.splitext(tfvars_file)[0]
    tfvars_path = os.path.join(OUTPUT_FOLDER, tfvars_file)

    log(f"[{workspace_name}] Creating or selecting Terraform workspace...")
    # If 'workspace new' fails because the workspace exists, we try 'select':
    run_command(
        f"terraform workspace new {workspace_name} || terraform workspace select {workspace_name}",
        f"Failed to create or select workspace {workspace_name}."
    )

    # Run terraform plan
    log(f"[{workspace_name}] Running Terraform plan...")
    run_command(
        f"terraform plan -var-file={tfvars_path}",
        f"Terraform plan failed for workspace {workspace_name}."
    )

    # Run terraform apply
    log(f"[{workspace_name}] Running Terraform apply...")
    run_command(
        f"terraform apply -var-file={tfvars_path} -auto-approve",
        f"Terraform apply failed for workspace {workspace_name}."
    )

def process_tfvars_in_parallel(max_workers=4):
    """
    Process each .tfvars file in parallel using a ThreadPoolExecutor.
    Adjust max_workers as needed.
    """
    tfvars_files = [f for f in os.listdir(OUTPUT_FOLDER) if f.endswith(".tfvars")]
    if not tfvars_files:
        log("No .tfvars files found in the output folder.")
        sys.exit(1)

    log(f"Starting parallel processing with up to {max_workers} workers...")
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_file = {
            executor.submit(process_single_tfvars_file, tfvars_file): tfvars_file
            for tfvars_file in tfvars_files
        }

        for future in as_completed(future_to_file):
            tfvars_file = future_to_file[future]
            try:
                future.result()  # Raises an exception if any occurred
            except Exception as e:
                log(f"[{tfvars_file}] Error in processing: {str(e)}")

def main():
    # Only expecting one argument now: <input_csv>
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <input_csv>")
        sys.exit(1)

    input_csv = "csv/" + sys.argv[1]

    # Ensure Python and Terraform are available
    log("Checking prerequisites...")
    if not shutil.which("python3"):
        log("Python3 is not installed. Please install it.")
        sys.exit(1)
    if not shutil.which("terraform"):
        log("Terraform is not installed. Please install it.")
        sys.exit(1)

    # 1. Generate tfvars from the CSV
    generate_tfvars(input_csv)

    # 2. Initialize Terraform once
    initialize_terraform()

    # 3. Process each .tfvars file in parallel
    process_tfvars_in_parallel(max_workers=4)

    log("All workspaces have been processed successfully.")

if __name__ == "__main__":
    main()
