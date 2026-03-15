module "labels" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  
  namespace = "university"
  stage     = "dev"
  name      = var.table_name
}

resource "aws_dynamodb_table" "this" {
  name         = module.labels.id
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}