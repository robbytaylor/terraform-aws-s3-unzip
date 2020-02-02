data template_file lambda {
  template = "${file("${path.module}/index.js.tpl")}"

  vars = {
    dest_bucket = local.dest_bucket
    dest_key    = var.dest_key
    dest_prefix = var.dest_prefix
    match_regex = var.match_regex
  }
}

resource local_file lambda {
  content  = data.template_file.lambda.rendered
  filename = "${path.module}/src/index.js"
}

resource null_resource npm {
  provisioner "local-exec" {
    command = "cd ${path.module}/src && npm install"
  }
}

data archive_file lambda {
  type        = "zip"
  output_path = "${path.module}/dist/lambda-${sha1(data.template_file.lambda.rendered)}.zip"
  source_dir  = "${path.module}/src"
  depends_on  = [local_file.lambda, null_resource.npm]
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
