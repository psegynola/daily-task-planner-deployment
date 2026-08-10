#######################################
# ECS Cluster for running app on Fargate.
########################################

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${var.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow ECS to retrieve images and add to logs."
  policy      = file("./templates/ecs/task-execution-role-policy.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.prefix}-task-execution-role"
  assume_role_policy = file("./templates/ecs/task-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}


resource "aws_iam_role" "app_task" {
  name               = "${var.prefix}-app-task"
  assume_role_policy = file("./templates/ecs/task-assume-role-policy.json")
}

resource "aws_iam_policy" "task_ssm_policy" {
  name        = "${var.prefix}-task-ssm-role-policy"
  path        = "/"
  description = "Policy to allow System Manager to execute in container"
  policy      = file("./templates/ecs/task-ssm-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_ssm_policy" {
  role       = aws_iam_role.app_task.name
  policy_arn = aws_iam_policy.task_ssm_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${var.prefix}-api"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_task.arn

  container_definitions = jsonencode([
  {
    name              = "api"
    image             = var.ecr_app_image
    essential         = true
    memoryReservation = 256
    portMappings = [
      {
        containerPort = 8000
        hostPort      = 8000
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "DATABASE_URL"
        value = "postgresql+psycopg://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:5432/${aws_db_instance.main.db_name}"
      },
      {
        name  = "SECRET_KEY"
        value = var.flask_secret_key  # rename to flask_secret_key if you prefer
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_task_logs.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "api"
      }
    }
  }
])

         
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
