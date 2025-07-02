variable "projectName" {
    default = "hackathon"
}

variable "tags" {
    type = map(string)
    default = {
        Terraform  = "true"
    }
    description = "Tags to apply to all resources"
}

variable "ddb_table_name" {
  description = "Name of the DynamoDB table for job metadata"
  type        = string
  default     = "hackathon-video-frames"
}

variable "verified_email" {
    type = string
    default     = "matheus.francesquini@gmail.com"
}

variable "input_bucket_name" {
  description = "Base name for the input S3 bucket"
  type        = string
  default     = "hackathon-fiap-soat-input-bucket"
}

variable "output_bucket_name" {
  description = "Base name for the output S3 bucket"
  type        = string
  default     = "hackathon-fiap-soat-output-bucket"
}