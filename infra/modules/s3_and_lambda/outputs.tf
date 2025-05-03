output "upload_bucket_name" {
  description = "The name of the S3 bucket that triggers the Lambda function"
  value       = aws_s3_bucket.upload_bucket.bucket
}

output "lambda_sg_id" {
  description = "The security group ID for the Lambda function"
  value       = aws_security_group.backend_lambda_sg.id
}