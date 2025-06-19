terraform {
  backend "s3" {
    bucket = "fast-food-terraform-state"
    key    = "hackathon/terraform.tfstate"
    region = "us-east-1"
    profile = "fast_food"
  }
}