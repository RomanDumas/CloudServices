provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# email sending
resource "aws_sns_topic" "alerts_eu" {
  name = "university-dev-alerts-eu"
}

resource "aws_sns_topic_subscription" "email_eu" {
  topic_arn = aws_sns_topic.alerts_eu.arn
  protocol  = "email"
  endpoint  = "dumasroman1011@gmail.com"
}

# alarm for lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "university-dev-save-course-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Сповіщення, якщо Лямбда save-course видає помилку"

  alarm_actions       = [aws_sns_topic.alerts_eu.arn]

  dimensions = {
    FunctionName = aws_lambda_function.save_course.function_name
  }
}

# alarm if aws balance is under 10 dollars for our region
resource "aws_sns_topic" "alerts_us" {
  provider = aws.us_east_1 
  name     = "university-dev-alerts-us"
}

resource "aws_sns_topic_subscription" "email_us" {
  provider  = aws.us_east_1
  topic_arn = aws_sns_topic.alerts_us.arn
  protocol  = "email"
  endpoint  = "dumasroman1011@gmail.com"
}

# alarm if aws balance is under 10 dollars for verginia
resource "aws_cloudwatch_metric_alarm" "billing" {
  provider            = aws.us_east_1
  alarm_name          = "university-dev-billing-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600"
  statistic           = "Maximum"
  threshold           = "10.0"
  alarm_description   = "Сповіщення, якщо витрати AWS перевищать $10"

  alarm_actions       = [aws_sns_topic.alerts_us.arn]

  dimensions = {
    Currency = "USD"
  }
}