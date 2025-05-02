resource "aws_s3_bucket" "dev_bucket" {
  bucket        = "nimbur-dev-bucket-${random_id.rand.hex}"
  force_destroy = true
}

resource "random_id" "rand" {
  byte_length = 4
}