# Terraform AWS S3 Unzip
Terraform module to deploy a Lambda function to automatically unzip files in an S3 bucket.

By default the Lambda function is run when a file is created in the specified S3 bucket.

## Examples

### Extract all files in the same bucket

module s3-unzip {
  source         = "github/robbytaylor/terraform-aws-s3-unzip"

  dest_prefix    = "extracted/"
  dest_key       = "$zipFilename/$filename.$extension"
  src_bucket     = "files.robbytaylor.io"
  src_prefix     = "zip/"
}

### Extract .js files from one bucket to another

module s3-unzip {
  source         = "github/robbytaylor/terraform-aws-s3-unzip"

  dest_bucket    = "js.robbytaylor.io"
  src_bucket     = "zip.robbytaylor.io"
  match_regex    = "/^[^/]+.js$/"
}

### Extract .js files from one bucket to another

module s3-unzip {
  source         = "github/robbytaylor/terraform-aws-s3-unzip"

  dest_bucket    = "js.robbytaylor.io"
  src_bucket     = "zip.robbytaylor.io"
  match_regex    = "/^[^/]+.js$/"
}
