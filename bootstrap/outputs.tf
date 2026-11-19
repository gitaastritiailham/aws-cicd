output "state_bucket_name" {
  description = "terraform-cicd/backend.tf の bucket と pipeline/terraform.tfvars の state_bucket_name に入れる名前"
  value       = aws_s3_bucket.state.id
}
