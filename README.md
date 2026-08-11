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

## Design Decisions

- **No NAT gateway** — lower cost; tasks reach AWS services through VPC endpoints
- **Private ECS tasks** — only the ALB is public; tasks accept traffic from the ALB security group on port 8000
- **RDS in private subnets** — database is not internet-facing
- **Immutable task definitions** — each new image tag creates a new revision and ECS rolls the service forward
- **Single environment (v1)** — keep scope focused; a later improvement is splitting setup (CD user/keys) from app infrastructure

## Pipeline

```text
push to main
  → test & lint (pytest + terraform validate/fmt)
  → build & push image to ECR (tag = commit SHA)
  → terraform apply (image URI + secrets as TF_VAR_*)
  → ECS service picks up new task definition revision
```

## Local development

Start the app:

```bash
docker compose up --build
```
Open http://localhost:8000

Run tests:
pytest -q

Infrastructure is managed from infrastructure/ with Terraform, or through the GitHub Actions deploy workflow.

