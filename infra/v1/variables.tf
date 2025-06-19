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
