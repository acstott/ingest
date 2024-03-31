resource "aws_s3_bucket" "bucket" {
  bucket = var.logs_bucket
}
