#######################################
# ECS Cluster for running app on Fargate.
########################################

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}
