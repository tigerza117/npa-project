variable "aws_account_id" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_session_token" {}

variable "region" {
  type = string
  default = "us-east-1"
  description = "aws region selection"
}

variable "branch_prefix" {
  type = string
  default = "Uncategorize"
  description = "Branch prefix"
}

variable "role_name" {
  type = string
  default = "LabRole"
  description = "Role Name"
}
