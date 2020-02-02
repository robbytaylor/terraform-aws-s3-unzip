resource aws_s3_bucket_notification bucket_notification {
  bucket = var.src_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.src_prefix
  }
}
