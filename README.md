# Daily Task Planner — AWS Deployment

Production-style deployment of a Flask task planner on AWS using ECS Fargate, RDS PostgreSQL, an Application Load Balancer, Terraform, and GitHub Actions.

![Architecture](documents/Architectural%20Diagram%20-%20Daily%20Planner%20App.jpg)

## Stack

| Layer | Implementation |
|--------|----------------|
| App | Flask + Gunicorn |
| Compute | ECS Fargate (private subnets) |
| Database | RDS PostgreSQL |
| Traffic | Application Load Balancer + ACM (HTTPS) |
| DNS | Route53 |
| Networking | VPC endpoints for ECR, S3, CloudWatch, SSM (no NAT) |
| IaC | Terraform (S3 backend + DynamoDB lock) |
| CI/CD | GitHub Actions → ECR → Terraform apply |
