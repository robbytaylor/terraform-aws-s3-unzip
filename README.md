# Terraform AWS S3 Unzip
Terraform module to deploy a Lambda function to automatically extract zip files in an S3 bucket.

By default the Lambda function is run when a file is created in the specified S3 bucket.

## Examples

### Extract all files in the same bucket

```
module s3-unzip {
  source         = "robbytaylor/s3-unzip/aws"
  version        = "0.1.5"

  dest_prefix    = "extracted/"
  dest_key       = "$zipFilename/$filename.$extension"
  src_bucket     = "files.robbytaylor.io"
  src_prefix     = "zip/"
}
```

### Extract .js files from one bucket to another

```
module s3-unzip {
  source         = "robbytaylor/s3-unzip/aws"
  version        = "0.1.5"

  dest_bucket    = "js.robbytaylor.io"
  src_bucket     = "zip.robbytaylor.io"
  match_regex    = "/^[^/]+.js$/"
}
```

### Extract .js files but rename them to match the zip filename

```
module s3-unzip {
  source         = "robbytaylor/s3-unzip/aws"
  version        = "0.1.5"

  dest_key       = "$zipFilename.$extension"
  src_bucket     = "code.robbytaylor.io"
  src_prefix     = "zip/"
  match_regex    = "/^[^/]+.js$/"
}
```
