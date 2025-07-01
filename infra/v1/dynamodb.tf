resource "aws_dynamodb_table" "jobs" {
  name         = var.ddb_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "user_uuid"
  range_key = "timestamp"
   attribute {
    name = "user_uuid"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}