
markdown
Copy
Edit
# Prefect Worker on AWS ECS Fargate – Terraform Deployment

## Introduction

This project sets up a Prefect 2.0 worker on Amazon ECS Fargate using Terraform. The objective was to create a fully automated and serverless infrastructure that could handle workflow orchestration through Prefect Cloud using ECS containers.

The setup provisions networking (custom VPC, subnets, NAT gateway), IAM roles, ECS services, service discovery, and secrets via AWS Secrets Manager — all wired together to allow seamless interaction with Prefect Cloud.

## Tools & Services Used

- Terraform – for Infrastructure as Code (v1.2+)
- Amazon ECS (Fargate) – to run containers without managing servers
- AWS VPC – for isolated networking
- AWS Secrets Manager – for securely storing Prefect credentials
- AWS Cloud Map – for ECS service discovery
- Prefect Cloud – to orchestrate and monitor flows

## Project Structure

prefect-ecs-iac/ ├── main.tf # Core infrastructure setup ├── variables.tf # Input variables ├── outputs.tf # Output values (e.g., ECS cluster ARN) ├── terraform.tfvars # Secret vars (excluded from version control) ├── README.md # Setup and usage guide ├── report.md # Summary and learnings └── screenshots/ # Optional screenshots

markdown
Copy
Edit

## Before You Start

Make sure you have:

- An AWS account with permissions to create VPC, ECS, IAM roles, etc.
- Terraform installed (v1.2 or above)
- AWS CLI installed and configured (`aws configure`)
- A Prefect Cloud account with:
  - API key
  - Account ID
  - Workspace ID
  - A work pool named: `ecs-work-pool`

## Secret Values

Before applying the configuration, create a `terraform.tfvars` file in the root directory with the following:

```hcl
prefect_api_key       = "your-prefect-api-key"
prefect_account_id    = "your-account-id"
prefect_workspace_id  = "your-workspace-id"
This file should not be committed to version control. It’s already ignored in .gitignore.

Deployment Steps
1. Clone the repository
bash
Copy
Edit
git clone https://github.com/your-username/prefect-ecs-iac.git
cd prefect-ecs-iac
2. Initialize Terraform
bash
Copy
Edit
terraform init
3. Preview changes
bash
Copy
Edit
terraform plan
4. Deploy the infrastructure
bash
Copy
Edit
terraform apply
Terraform will provision:

A new VPC with public and private subnets

ECS Cluster named prefect-cluster

NAT Gateway and Internet Gateway

Task execution IAM role

Prefect worker in ECS Fargate (dev-worker)

Secrets Manager entry with your Prefect API key

Verifying the Deployment
In AWS Console
Navigate to ECS > Clusters > prefect-cluster
Ensure that the dev-worker service is running

In Secrets Manager, confirm the prefect-api-key exists

In Cloud Map, check for the namespace default.prefect.local

In Prefect Cloud
Log in to Prefect Cloud

Navigate to your workspace

Open the work pool ecs-work-pool

You should see a worker named dev-worker online and healthy

Optional: Run a Sample Flow
To test the setup, try running a small flow like this:

python
Copy
Edit
from prefect import flow

@flow
def test():
    print("Hello from ECS!")

test()
Schedule it using the ecs-work-pool and it should be picked up by the worker running in ECS.

Cleanup
Once done, you can destroy all the resources with:

bash
Copy
Edit
terraform destroy
If the secret is still in "scheduled for deletion" status, you may need to remove it manually from the AWS console before reapplying.

Possible Improvements
If given more time, the following improvements could be added:

Auto-scaling based on task load

CloudWatch integration for logging and monitoring

Using ALB for API-based flows

Splitting resources into Terraform modules for reusability

CI/CD integration for continuous infrastructure updates

About the Author
Hi, I’m Inish Kashyap. This project was a great opportunity to apply DevOps principles and hands-on experience with IaC tools like Terraform, while also learning how Prefect integrates into cloud-native workflows.

Feel free to connect if you’d like to discuss this project or give feedback.

GitHub: inishkashyap

Email: inish@example.com

Thanks for reading!

yaml
Copy
Edit

---

Let me know if you’d like to include this inside a repo or zip, or if you want me to polish up the **`report.md`** next!