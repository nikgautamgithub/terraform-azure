import os
import shutil
import subprocess
import sys
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock, BoundedSemaphore

# Constants
CSV_PARSE_SCRIPT = "scripts/parse_csv.py"
OUTPUT_FOLDER = "tfvars"
MAX_RETRIES = 3
RETRY_DELAY = 5  # Reduced from 10 to 5 seconds
MAX_PARALLEL_OPERATIONS = 4  # Configurable number of parallel operations

# Global locks
terraform_semaphore = BoundedSemaphore(MAX_PARALLEL_OPERATIONS)
log_lock = Lock()

def log(message):
    """Thread-safe logging with timestamps."""
    with log_lock:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {message}", flush=True)

def run_command(command, error_message, retry_on_lock=False):
    """Run a system command with improved error handling and retries."""
    retries = MAX_RETRIES if retry_on_lock else 1
    
    for attempt in range(retries):
        try:
            with terraform_semaphore:  # Limit concurrent terraform operations
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
            if retry_on_lock and attempt < retries - 1 and (
                "Error acquiring the state lock" in e.stderr or
                "timeout while waiting for plugin" in e.stderr.lower()
            ):
                log(f"State lock error detected. Retrying in {RETRY_DELAY} seconds... (Attempt {attempt + 1}/{retries})")
                time.sleep(RETRY_DELAY)
                continue
            log(f"{error_message}\n{e.stderr.strip()}")
            raise

def clear_output_folder():
    """Clear output folder efficiently."""
    if os.path.exists(OUTPUT_FOLDER):
        shutil.rmtree(OUTPUT_FOLDER)
    os.makedirs(OUTPUT_FOLDER)

def generate_tfvars(input_csv):
    """Generate tfvars files with error handling."""
    if not os.path.isfile(input_csv):
        raise FileNotFoundError(f"Input file '{input_csv}' does not exist.")

    clear_output_folder()
    run_command(
        f"python3 {CSV_PARSE_SCRIPT} {input_csv} {OUTPUT_FOLDER}",
        "Failed to generate .tfvars files."
    )

def initialize_terraform():
    """Initialize Terraform with plugin download."""
    log("Initializing Terraform...")
    run_command(
        "terraform init -upgrade",  # Added -upgrade to ensure latest plugins
        "Terraform initialization failed."
    )

def process_single_tfvars_file(tfvars_file):
    """Process a single tfvars file with optimized commands."""
    workspace_name = os.path.splitext(tfvars_file)[0]
    tfvars_path = os.path.join(OUTPUT_FOLDER, tfvars_file)

    try:
        # Create/select workspace
        run_command(
            f"terraform workspace new {workspace_name} || terraform workspace select {workspace_name}",
            f"Failed to create/select workspace {workspace_name}",
            retry_on_lock=True
        )

        # Run plan and save to file
        plan_file = f"tfplan_{workspace_name}"
        run_command(
            f"terraform plan -var-file={tfvars_path} -out={plan_file} -parallelism=20",
            f"Terraform plan failed for workspace {workspace_name}",
            retry_on_lock=True
        )

        # Apply saved plan
        run_command(
            f"terraform apply -auto-approve -parallelism=20 {plan_file}",
            f"Terraform apply failed for workspace {workspace_name}",
            retry_on_lock=True
        )

        # Cleanup plan file
        if os.path.exists(plan_file):
            os.remove(plan_file)

        return True
    except Exception as e:
        log(f"Error in workspace {workspace_name}: {str(e)}")
        return False

def process_tfvars_parallel():
    """Process tfvars files in parallel with improved error handling."""
    tfvars_files = [f for f in os.listdir(OUTPUT_FOLDER) if f.endswith(".tfvars")]
    if not tfvars_files:
        raise FileNotFoundError("No .tfvars files found in the output folder.")

    log(f"Processing {len(tfvars_files)} workspaces in parallel...")
    
    failed_workspaces = []
    successful_workspaces = []

    with ThreadPoolExecutor(max_workers=MAX_PARALLEL_OPERATIONS) as executor:
        future_to_file = {
            executor.submit(process_single_tfvars_file, tfvars_file): tfvars_file
            for tfvars_file in tfvars_files
        }

        for future in as_completed(future_to_file):
            tfvars_file = future_to_file[future]
            try:
                success = future.result()
                if success:
                    successful_workspaces.append(tfvars_file)
                    log(f"Successfully completed workspace {tfvars_file}")
                else:
                    failed_workspaces.append(tfvars_file)
            except Exception:
                failed_workspaces.append(tfvars_file)

    # Summary report
    log("\nExecution Summary:")
    log(f"Successfully processed: {len(successful_workspaces)} workspaces")
    if failed_workspaces:
        log(f"Failed to process: {len(failed_workspaces)} workspaces")
        log(f"Failed workspaces: {', '.join(failed_workspaces)}")
        raise Exception("Some workspaces failed to process")

def main():
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <input_csv> [max_parallel_operations]")
        sys.exit(1)

    input_csv = "csv/" + sys.argv[1]
    
    # Allow overriding MAX_PARALLEL_OPERATIONS from command line
    global MAX_PARALLEL_OPERATIONS
    if len(sys.argv) > 2:
        MAX_PARALLEL_OPERATIONS = int(sys.argv[2])

    try:
        # Check prerequisites
        for cmd in ["python3", "terraform"]:
            if not shutil.which(cmd):
                raise EnvironmentError(f"{cmd} is not installed")

        start_time = time.time()
        
        generate_tfvars(input_csv)
        initialize_terraform()
        process_tfvars_parallel()
        
        execution_time = time.time() - start_time
        log(f"\nTotal execution time: {execution_time:.2f} seconds")

    except Exception as e:
        log(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()