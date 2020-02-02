variable src_bucket {
  type        = string
  description = "The source bucket name. Zip files created in this bucket will be automatically uncompressed"
}

variable dest_bucket {
  type        = string
  default     = ""
  description = "The destination bucket for uncompressed files"
}

variable cloudwatch_log_retention {
  type        = number
  default     = 7
  description = "Number of days to retain logs for the Unzip Lambda function"
}

variable dest_key {
  type        = string
  default     = ""
  description = "Key name to use for the unzipped files. Defaults to the filename within the archive. "
}

variable dest_prefix {
  type        = string
  default     = ""
  description = "Prefix to add to filenames within the destination bucket"
}

variable lambda_function_name {
  type        = string
  default     = "S3Unzip"
  description = "The name for the unzip lambda function"
}

variable match_regex {
  type        = string
  default     = ".*"
  description = "Regular expression to match against filenames within the zip file. Use to only extract certain files"
}

variable s3_event_triggers {
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
  description = "Which S3 events to trigger the Lambda function from"
}

variable src_prefix {
  type        = string
  default     = ""
  description = "Prefix for files which will trigger the lambda function. Use to only process a single directory within the source bucket"
}

variable tags {
  type        = map
  default     = {}
  description = "Map of tags to apply to resources"
}

locals {
  dest_bucket = var.dest_bucket != "" ? var.dest_bucket : var.src_bucket
}
