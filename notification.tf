resource aws_s3_bucket_notification bucket_notification {
  bucket = var.src_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = var.s3_event_triggers
    filter_prefix       = var.src_prefix
  }
}
