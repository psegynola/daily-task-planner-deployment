# Daily Task Planner

A practical Flask application for testing Docker, CI/CD, cloud deployment, persistent storage, reverse proxies, monitoring, and managed databases.

## Features

- Weekly planner view
- Add tasks to any day
- Mark tasks complete
- Delete tasks
- Persistent SQLite or PostgreSQL storage
- `/health` endpoint for load balancers and container health checks
- Gunicorn production server
- Docker and Docker Compose
- Pytest test suite

## Run with SQLite

```bash
docker compose up --build
```

Open `http://localhost:8000`.

Data is stored in the named Docker volume `task-data`.

## Run with PostgreSQL

```bash
docker compose -f docker-compose.postgres.yml up --build
```

## Run without Docker

```bash
python -m venv .venv
source .venv/bin/activate  # Windows Git Bash: source .venv/Scripts/activate
pip install -r requirements.txt
mkdir -p /data
export DATABASE_URL=sqlite:///tasks.db
flask --app wsgi:app run --debug
```

## Tests

```bash
pytest -q
```

## Environment variables

| Variable | Purpose | Example |
|---|---|---|
| `DATABASE_URL` | Database connection | `sqlite:////data/tasks.db` |
| `SECRET_KEY` | Flask secret | Use a generated secret in production |

## Deployment practice ideas

1. Build and push the image to Amazon ECR.
2. Deploy to ECS Fargate behind an Application Load Balancer.
3. Map the ALB health check to `/health`.
4. Start with SQLite plus EFS, then migrate to Amazon RDS PostgreSQL.
5. Store `DATABASE_URL` and `SECRET_KEY` in AWS Systems Manager Parameter Store or Secrets Manager.
6. Add HTTPS with ACM and Route 53.
7. Send application logs to CloudWatch Logs.
8. Add a GitHub Actions workflow for tests, image publishing, and deployment.

## Important production note

SQLite works well for local practice and a single application instance. For multiple ECS tasks or Kubernetes replicas, use PostgreSQL rather than sharing a SQLite file between containers.

##testing pull requests
