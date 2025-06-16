resource "aws_s3_bucket" "s3_input_bucket" {
  bucket = "${var.projectName}-fiap-soat-input-bucket"

  tags = var.tags
}