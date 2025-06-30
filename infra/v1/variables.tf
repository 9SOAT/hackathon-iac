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

variable "verified_email" {
    type = string
}

variable "ddb_table_name" {
  description = "Name of the DynamoDB table for job metadata"
  type        = string
  default     = "video-jobs"
}