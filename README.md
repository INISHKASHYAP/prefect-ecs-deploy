# Prefect Worker on AWS ECS Fargate – Terraform Deployment

## Introduction

This project sets up a **Prefect 2.0 worker** on **Amazon ECS Fargate** using **Terraform**. It automates the deployment of a scalable and serverless infrastructure to run Prefect workflows, connected to **Prefect Cloud**.

## Tools & Services Used

- **Terraform**
- **Amazon ECS (Fargate)**
- **AWS VPC**
- **AWS Secrets Manager**
- **AWS Cloud Map**
- **Prefect Cloud**

## Prerequisites

- **AWS account** with programmatic access
- **Terraform** (v1.2 or higher)
- **AWS CLI** installed and configured (`aws configure`)
- **Prefect Cloud account** with:
  - **API key**
  - **Account ID**
  - **Workspace ID**
  - A work pool named `ecs-work-pool`

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/INISHKASHYAP/prefect-ecs-iac.git
cd prefect-ecs-iac
```
### 2. Add secrets to terraform.tfvars
#### Create a file terraform.tfvars with your Prefect details:
```
prefect_api_key       = "your-prefect-api-key"
prefect_account_id    = "your-account-id"
prefect_workspace_id  = "your-workspace-id"
```
### 3. Initialize Terraform
```
terraform init
```

### 4. Deploy the infrastructure
```
terraform apply
```
### Verification
#### Go to AWS ECS > Clusters > prefect-cluster to confirm the worker is running.

#### Check Secrets Manager for the prefect-api-key.

#### In Prefect Cloud, verify that the worker is registered in the ecs-work-pool.


### Cleanup
To destroy all resources:

```
terraform destroy
```

#### Feel free to connect:
```

 Author: Inish Kashyap
 GitHub: inishkashyap
 Email: inishkash@gmail.com
```
