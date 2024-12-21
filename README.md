# Terraform Azure Project

This project automates the creation of Azure resources using Terraform, with inputs provided via a CSV file. The project handles the creation of the following resources:

1. Virtual Machines (Linux and Windows)
2. Azure Kubernetes Service (AKS)
3. Storage Accounts
4. Data Factory
5. Azure Databricks Service
6. API Management (APIM)
7. Key Vault
8. App Services
9. Logic Apps
10. Container Apps
11. SQL Server
12. SQL Databases
13. Azure SQL Database Hyperscale
14. Azure Database for MySQL Flexible Server
15. Azure Synapse Analytics
16. Managed Identities
17. Event Hubs
18. SendGrid
19. Service Bus
20. Container Registry

## Key Inputs for Resources

Each resource has specific required inputs. Please refer to the `inputs.md` file for a detailed list of inputs required for each resource.

## Project Structure

- `main.tf`: The main Terraform configuration file.
- `variables.tf`: Contains variable definitions for inputs.
- `outputs.tf`: Defines output variables for the Terraform state.
- `modules/`: Contains reusable Terraform modules for each resource.
- `scripts/`: Contains scripts for CSV parsing and pipeline automation.
- `pipelines/`: CI/CD pipeline configurations.
- `input.csv`: Example CSV file for resource creation.
