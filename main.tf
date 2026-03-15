module "dynamodb_courses" {
  source     = "./modules/dynamodb"
  table_name = "courses"
}

module "dynamodb_authors" {
  source     = "./modules/dynamodb"
  table_name = "authors"
}