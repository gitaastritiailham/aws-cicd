# codePipeline の成果物 (Source で取得したコードなど) の置き場所
# 名前は codepipeline-<region>-* にする (CodePipeline　の標準的な命名に合わせる)
resource "aws_s3_bucket" "artifacts" {
  bucket = "codepipeline-${var.region}-${data.aws_caller_identity.current.account_id}-${var.project_name}"
  force_destroy = true #研究用：destroy のとき中身ごと削除できるようにする
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}