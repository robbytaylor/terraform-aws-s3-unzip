resource aws_iam_role lambda {
  name = "LambdaFunctionRole-${var.lambda_function_name}"
  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}


data aws_iam_policy_document lambda {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.logs.arn
    ]
  }

  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.dest_bucket}/${var.dest_prefix}*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.src_bucket}/${var.src_prefix}*"
    ]
  }
}

resource aws_iam_policy lambda {
  name   = "LambdaPolicy-${var.lambda_function_name}"
  policy = data.aws_iam_policy_document.lambda.json
}

resource aws_iam_role_policy_attachment lambda {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
