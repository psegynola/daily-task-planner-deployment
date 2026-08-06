variable "tf_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "fdivine-recipe-app-tf-state"
}

variable "tf_state_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
  default     = "fdivine-recipe-api-tf-lock"
}

variable "project" {
  description = "The name of the project."
  type        = string
  default     = "daily-task-planner-app"
}

variable "contact" {
  description = "The contact information for the project."
  type        = string
  default     = "philipsegynola@gmail.com"
}

variable "prefix" {
  description = "The prefix to use for resource names."
  type        = string
  default     = "dtp"
}
