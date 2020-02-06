resource null_resource npm {
  triggers = {
    index = "${base64sha256(file("${path.module}/src/package.json"))}"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/src && npm install"
  }
}

data null_data_source wait_for_lambda_exporter {
  inputs = {
    lambda_exporter_id = null_resource.npm.id
    source_dir         = "${path.module}/src/"
  }
}

data archive_file lambda {
  type        = "zip"
  output_path = "${path.module}/dist/lambda.zip"
  source_dir  = data.null_data_source.wait_for_lambda_exporter.outputs["source_dir"]
}

resource aws_lambda_function lambda {
  filename         = data.archive_file.lambda.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs10.x"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      DELETE_SOURCE : var.delete_source
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
