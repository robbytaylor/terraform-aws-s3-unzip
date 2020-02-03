resource null_resource npm {
  provisioner "local-exec" {
    command = "cd ${path.module}/src && npm install"
  }
}

data archive_file lambda {
  type        = "zip"
  output_path = "${path.module}/dist/lambda.zip"
  source_dir  = "${path.module}/src"
  depends_on  = [null_resource.npm]
}

resource aws_lambda_function lambda {
  filename      = data.archive_file.lambda.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs10.x"

  lifecycle {
    ignore_changes = [filename]
  }

  environment {
    variables = {
      DEST_BUCKET : local.dest_bucket
      DEST_KEY : var.dest_key
      DEST_PREFIX : var.dest_prefix
      MATCH_REGEX : var.match_regex
    }
  }

  tags = var.tags
}

resource aws_lambda_permission allow_bucket {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.src_bucket}"
}

resource aws_cloudwatch_log_group logs {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.cloudwatch_log_retention
  tags              = var.tags
}
