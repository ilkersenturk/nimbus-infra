nimbus-infra/
├── main.tf                   # Root Terraform entrypoint
├── providers.tf              # AWS provider & region settings
├── variables.tf              # Root-level input variables
├── outputs.tf                # Root-level outputs
├── modules/                  # Modular reusable infrastructure
│   ├── networking/           # VPC, subnets, route tables
│   ├── webserver/            # EC2 + security group + user data
│   ├── backend_cluster/      # ASG + ELB for backend
│   ├── s3_and_lambda/        # S3 bucket + Lambda function
│   ├── api_gateway/          # API Gateway resources
│   └── database/             # RDS or DynamoDB setup