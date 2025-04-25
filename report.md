# Prefect Worker on AWS ECS Fargate – Terraform Deployment Report

## Introduction

This project involved setting up a **Prefect 2.0 worker** on **Amazon ECS Fargate** using **Terraform**. The aim was to automate the deployment of a serverless, scalable infrastructure for running Prefect workflows connected to **Prefect Cloud**.

The infrastructure includes the creation of a custom **VPC**, networking resources, ECS cluster and services, IAM roles, and **Secrets Manager** for secure API credential storage.

## Key Objectives

1. **Deploying ECS Fargate Worker**: Set up a scalable ECS Fargate worker that can execute Prefect workflows.
2. **Infrastructure as Code**: Use **Terraform** to automate the entire infrastructure provisioning, ensuring a repeatable and scalable setup.
3. **Integration with Prefect Cloud**: Ensure that the worker is registered in **Prefect Cloud** and connected to a specific **work pool**.

## Tools & Services Used

- **Terraform**: Used to define and manage the infrastructure.
- **Amazon ECS (Fargate)**: Container orchestration platform for running the Prefect worker without managing servers.
- **AWS VPC**: Virtual networking for secure communication between services.
- **AWS Secrets Manager**: Securely stores the Prefect API key for accessing Prefect Cloud.
- **AWS Cloud Map**: Used for service discovery to allow ECS to locate the Prefect worker.
- **Prefect Cloud**: Cloud service for orchestrating and monitoring Prefect workflows.

## Infrastructure Setup

1. **VPC**: A custom VPC was created with public and private subnets.
2. **ECS Cluster**: An ECS cluster named `prefect-cluster` was set up for running containers.
3. **IAM Role**: Created IAM roles for ECS execution with necessary permissions for accessing Secrets Manager.
4. **Secrets Manager**: Stored the Prefect API key securely to be accessed by the worker.
5. **ECS Task**: A Prefect worker container was deployed to run in the ECS cluster using Fargate.
6. **Service Discovery**: Registered the ECS service in **Cloud Map** to allow communication with Prefect Cloud.

## Terraform Configuration

The infrastructure was defined using the following Terraform files:

- `main.tf`: Contains the core Terraform resources like VPC, ECS cluster, IAM roles, etc.
- `variables.tf`: Defines the input variables such as Prefect credentials.
- `outputs.tf`: Defines the output values after the Terraform apply process.
- `terraform.tfvars`: Contains sensitive values like Prefect API key, account ID, and workspace ID (never committed to the repository).

## Process Flow

1. **Repository Clone**: The repository was cloned to the local environment.
2. **Secrets Configuration**: Prefect API details were added to the `terraform.tfvars` file.
3. **Terraform Initialization**: Ran `terraform init` to initialize the Terraform environment.
4. **Plan and Apply**: Used `terraform plan` to check the changes and `terraform apply` to deploy the resources.
5. **Verification**:
   - In AWS Console, the ECS worker service was confirmed to be running.
   - In Prefect Cloud, the worker was verified to be healthy and registered in the `ecs-work-pool`.

## Challenges Faced

1. **Secrets Management**: Ensuring that the Prefect API key was securely stored and managed in AWS Secrets Manager.
2. **Service Discovery**: Setting up ECS service discovery with AWS Cloud Map to allow communication between ECS and Prefect Cloud.
3. **ECS Task Execution**: Ensuring the ECS Fargate task was properly configured and able to connect to the Prefect Cloud workspace.

## Conclusion

This project successfully set up a serverless infrastructure for running Prefect workflows on AWS ECS Fargate using Terraform. By automating the process with Infrastructure as Code, the deployment became scalable, secure, and reproducible. This also enhanced my understanding of integrating various AWS services with Prefect Cloud for workflow orchestration.

## Future Improvements

- **Auto-scaling**: Set up auto-scaling for the ECS service to automatically adjust resources based on workload.
- **CloudWatch Integration**: Set up **CloudWatch Logs** for better monitoring and troubleshooting.
- **CI/CD Integration**: Automate deployment using **GitHub Actions** or **CircleCI** for continuous integration and delivery.
- **Terraform Modules**: Break down the Terraform configuration into reusable modules for better organization and maintainability.

## Author

**Inish Kashyap**

Feel free to connect:
- GitHub: [inishkashyap](https://github.com/inishkashyap)
- Email: [inish@example.com](mailto:inish@example.com)
