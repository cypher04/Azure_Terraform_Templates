Azure Terraform Templates
A collection of reusable Terraform templates for deploying Azure infrastructure, with a focus on scalable and secure architectures such as the Hub-and-Spoke network topology.

Table of Contents
Overview
Templates
Getting Started
Usage
Directory Structure
Contributing
License
Overview
This repository provides modular Terraform templates to deploy and manage Azure resources. The templates are designed to simplify the process of implementing best practices in Azure infrastructure, including network segmentation, security, and scalability.

Templates
template_for_hub_and_spoke
Deploys a hub-and-spoke network topology in Azure, enabling centralized management, shared services, and controlled connectivity between network segments.
Additional templates can be added to the repo as needed.

Getting Started
Prerequisites
Terraform (v1.0+ recommended)
Azure CLI (Install Guide)
An active Azure subscription
Setup
Clone the repository:

bash
git clone https://github.com/cypher04/Azure_Terraform_Templates.git
cd Azure_Terraform_Templates
Navigate to your desired template directory (e.g., for hub-and-spoke):

bash
cd template_for_hub_and_spoke
Initialize Terraform:

bash
terraform init
Usage
Review and update the variables.tf file in the template directory to match your environment and requirements.
(Optional) Create a terraform.tfvars file for custom variable values.
Apply the configuration:
bash
terraform apply
Terraform will prompt for confirmation before deploying resources to Azure.
Directory Structure
Code
Azure_Terraform_Templates/
├── template_for_hub_and_spoke/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── ...
└── README.md
Each subdirectory contains a self-contained Terraform template for a specific Azure architecture or service.
Contributing
Contributions, issues, and feature requests are welcome!
Feel free to open an issue or submit a pull request.

License
This project is licensed under the MIT License.