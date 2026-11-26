output "pipeline_name" {
  value = aws_codepipeline.main.name
}

output "codebuild_projects" {
  value = { for k, p in aws_codebuild_project.this : k => p.name }
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild.arn
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.notify.arn
}
