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

       try:
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
                       resources_by_subscription[subscription_id].append(row_with_type)

                   except Exception as e:
                       raise ValueError(f"Error processing row {row_number} in the CSV: {e}")

       except csv.Error as e:
           raise ValueError(f"Error parsing the CSV file '{input_csv}': {e}")
       except Exception as e:
           raise ValueError(f"Unexpected error reading the CSV file '{input_csv}': {e}")

       try:
           if not resources_by_subscription:
               print("Warning: No valid resources found in the CSV. No tfvars files will be created.")
           else:
               for idx, (subscription_id, resources) in enumerate(resources_by_subscription.items(), start=1):
                   workspace = f"workspace_{idx}"
                   output_file = os.path.join(output_folder, f"resources_{workspace}.tfvars")

                   try:
                       with open(output_file, 'w', encoding='utf-8') as f:
                           f.write(f'subscription_id = "{subscription_id}",\n\n')

                           f.write('resource_definitions = [\n')
                           for resource in resources:
                               f.write('  {\n')
                               for key, value in resource.items():
                                   if key == "subscription_id":
                                       continue

                                   if key == "tags" and value and value.strip():
                                       try:
                                           tag_pairs = [tag.strip() for tag in value.split(',') if tag.strip()]
                                           tags_dict = {}
                                           for pair in tag_pairs:
                                               kv = pair.split(':')
                                               if len(kv) != 2:
                                                   raise ValueError(f"Invalid tag format '{pair}'")
                                               k, v = kv
                                               tags_dict[k.strip()] = v.strip()

                                           formatted_value = json.dumps(tags_dict)
                                           f.write(f'    {key} = {formatted_value},\n')
                                       except Exception as e:
                                           raise ValueError(f"Error parsing tags '{value}': {e}")
                                       continue

                                   if key == "public_ip_required" and isinstance(value, str):
                                       formatted_value = json.dumps(value.lower())
                                       f.write(f'    {key} = {formatted_value},\n')
                                       continue

                                   if key in LIST_FIELDS:
                                       try:
                                           items = [v.strip() for v in re.split(r"[;,]", str(value)) if v.strip()]
                                           formatted_value = json.dumps(items)
                                           f.write(f'    {key} = {formatted_value},\n')
                                       except Exception as e:
                                           raise ValueError(f"Error parsing list field '{key}': {value} - {e}")
                                       continue

                                   if ";" in str(value):
                                       try:
                                           parts = [str(v).strip() for v in str(value).split(";")]
                                           formatted_value = json.dumps(parts)
                                       except Exception as e:
                                           raise ValueError(f"Error splitting semicolon list for '{key}': {value} - {e}")
                                   elif "," in str(value):
                                       try:
                                           parts = [str(v).strip() for v in str(value).split(",")]
                                           formatted_value = json.dumps(parts)
                                       except Exception as e:
                                           raise ValueError(f"Error splitting comma list for '{key}': {value} - {e}")
                                   else:
                                       formatted_value = json.dumps(value)

                                   f.write(f'    {key} = {formatted_value},\n')
                               f.write('  },\n')
                           f.write(']\n')

                   except IOError as e:
                       raise IOError(f"Error writing to the output file '{output_file}': {e}")

       except Exception as e:
           raise e

       print(f"Successfully processed CSV file '{input_csv}' and generated tfvars files in '{output_folder}'.")

   except Exception as main_error:
       print(f"Error: {main_error}")
       sys.exit(1)

if __name__ == "__main__":
   if len(sys.argv) != 3:
       print("Usage: python script.py <input_csv> <output_folder>")
       sys.exit(1)

   input_csv = sys.argv[1]
   output_folder = sys.argv[2]
   parse_csv_file(input_csv, output_folder)