##############################################
# Create ECR repos for storing Docker images #
##############################################

resource "aws_ecr_repository" "app" {
  name                 = "daily-task-planner-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    # NOTE: Update to true for real deployments.
    scan_on_push = false
  }
}
