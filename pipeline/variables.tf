variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "project_name" {
  type        = string
  default     = "cicd-research"
  description = "リソース名の接頭辞（cicd-research のままにする：IAMポリシーの範囲がこの名前に合わせてある）"
}

variable "state_bucket_name" {
  type        = string
  description = "bootstrap/ で作った state 用S3バケット名（terraform-cicd/backend.tf の bucket と同じ名前）"
}

variable "github_connection_arn" {
  type        = string
  description = "GitHub の接続 ARN（bootstrap/ で作った GitHub の接続の ARN）"
}

variable "github_repository" {
  type        = string
  description = "GitHub のリポジトリ名（例： yamaguchigakuen/cicd-research）"
}

variable "github_branch" {
  type        = string
  default     = "main"
  description = "pipeline が監視するブランチ"
}

variable "notification_email" {
  type        = string
  description = "承認待ち・失敗の通知を受け取るメールアドレス"
}