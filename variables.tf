variable src_bucket {
  type = string
}

variable dest_bucket {
  type = string
}

variable cloudwatch_log_retention {
  type    = number
  default = 7
}

variable dest_key {
  type    = string
  default = ""
}

variable dest_prefix {
  type    = string
  default = ""
}

variable lambda_function_name {
  type    = string
  default = "S3Unzip"
}

variable lambda_handler {
  type    = string
  default = "index.handler"
}

variable lambda_runtime {
  type    = string
  default = "nodejs10.x"
}

variable match_regex {
  type    = string
  default = ".*"
}

variable src_prefix {
  type    = string
  default = ""
}

variable tags {
  type    = map
  default = {}
}
