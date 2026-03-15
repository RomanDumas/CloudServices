# ==========================================
# GET ALL AUTHORS
# ==========================================
module "label_get_all_authors" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "get-all-authors"
}

resource "aws_iam_role" "get_all_authors" {
  name = "${module.label_get_all_authors.id}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "get_all_authors" {
  name = "${module.label_get_all_authors.id}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = "dynamodb:Scan"
        Resource = module.dynamodb_authors.table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_all_authors" {
  role       = aws_iam_role.get_all_authors.name
  policy_arn = aws_iam_policy.get_all_authors.arn
}

data "archive_file" "get_all_authors" {
  type        = "zip"
  source_file = "${path.module}/src/get-all-authors.js"
  output_path = "${path.module}/builds/get-all-authors.zip"
}

resource "aws_lambda_function" "get_all_authors" {
  filename         = data.archive_file.get_all_authors.output_path
  function_name    = module.label_get_all_authors.id
  role             = aws_iam_role.get_all_authors.arn
  handler          = "get-all-authors.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.get_all_authors.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = module.dynamodb_authors.table_name
    }
  }
}
# ==========================================
# GET ALL COURSES
# ==========================================
module "label_get_all_courses" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "get-all-courses"
}

resource "aws_iam_role" "get_all_courses" {
  name = "${module.label_get_all_courses.id}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "get_all_courses" {
  name = "${module.label_get_all_courses.id}-policy"
  role = aws_iam_role.get_all_courses.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:Scan", Resource = module.dynamodb_courses.table_arn }
    ]
  })
}

data "archive_file" "get_all_courses" {
  type        = "zip"
  source_file = "${path.module}/src/get-all-courses.js"
  output_path = "${path.module}/builds/get-all-courses.zip"
}

resource "aws_lambda_function" "get_all_courses" {
  filename         = data.archive_file.get_all_courses.output_path
  function_name    = module.label_get_all_courses.id
  role             = aws_iam_role.get_all_courses.arn
  handler          = "get-all-courses.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.get_all_courses.output_base64sha256
  environment { variables = { TABLE_NAME = module.dynamodb_courses.table_name } }
}

# ==========================================
# GET COURSE
# ==========================================
module "label_get_course" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "get-course"
}

resource "aws_iam_role" "get_course" {
  name = "${module.label_get_course.id}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "get_course" {
  name = "${module.label_get_course.id}-policy"
  role = aws_iam_role.get_course.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:GetItem", Resource = module.dynamodb_courses.table_arn }
    ]
  })
}

data "archive_file" "get_course" {
  type        = "zip"
  source_file = "${path.module}/src/get-course.js"
  output_path = "${path.module}/builds/get-course.zip"
}

resource "aws_lambda_function" "get_course" {
  filename         = data.archive_file.get_course.output_path
  function_name    = module.label_get_course.id
  role             = aws_iam_role.get_course.arn
  handler          = "get-course.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.get_course.output_base64sha256
  environment { variables = { TABLE_NAME = module.dynamodb_courses.table_name } }
}

# ==========================================
# SAVE COURSE
# ==========================================
module "label_save_course" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "save-course"
}

resource "aws_iam_role" "save_course" {
  name = "${module.label_save_course.id}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "save_course" {
  name = "${module.label_save_course.id}-policy"
  role = aws_iam_role.save_course.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:PutItem", Resource = module.dynamodb_courses.table_arn }
    ]
  })
}

data "archive_file" "save_course" {
  type        = "zip"
  source_file = "${path.module}/src/save-course.js"
  output_path = "${path.module}/builds/save-course.zip"
}

resource "aws_lambda_function" "save_course" {
  filename         = data.archive_file.save_course.output_path
  function_name    = module.label_save_course.id
  role             = aws_iam_role.save_course.arn
  handler          = "save-course.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.save_course.output_base64sha256
  environment { variables = { TABLE_NAME = module.dynamodb_courses.table_name } }
}

# ==========================================
# UPDATE COURSE
# ==========================================
module "label_update_course" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "update-course"
}

resource "aws_iam_role" "update_course" {
  name = "${module.label_update_course.id}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "update_course" {
  name = "${module.label_update_course.id}-policy"
  role = aws_iam_role.update_course.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:PutItem", Resource = module.dynamodb_courses.table_arn }
    ]
  })
}

data "archive_file" "update_course" {
  type        = "zip"
  source_file = "${path.module}/src/update-course.js"
  output_path = "${path.module}/builds/update-course.zip"
}

resource "aws_lambda_function" "update_course" {
  filename         = data.archive_file.update_course.output_path
  function_name    = module.label_update_course.id
  role             = aws_iam_role.update_course.arn
  handler          = "update-course.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.update_course.output_base64sha256
  environment { variables = { TABLE_NAME = module.dynamodb_courses.table_name } }
}

# ==========================================
# DELETE COURSE
# ==========================================
module "label_delete_course" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "university"
  stage     = "dev"
  name      = "delete-course"
}

resource "aws_iam_role" "delete_course" {
  name = "${module.label_delete_course.id}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "delete_course" {
  name = "${module.label_delete_course.id}-policy"
  role = aws_iam_role.delete_course.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = "dynamodb:DeleteItem", Resource = module.dynamodb_courses.table_arn }
    ]
  })
}

data "archive_file" "delete_course" {
  type        = "zip"
  source_file = "${path.module}/src/delete-course.js"
  output_path = "${path.module}/builds/delete-course.zip"
}

resource "aws_lambda_function" "delete_course" {
  filename         = data.archive_file.delete_course.output_path
  function_name    = module.label_delete_course.id
  role             = aws_iam_role.delete_course.arn
  handler          = "delete-course.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.delete_course.output_base64sha256
  environment { variables = { TABLE_NAME = module.dynamodb_courses.table_name } }
}