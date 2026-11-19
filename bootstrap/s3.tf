# Terraform state の保存先（terraform-cicd/ の state が入る）
# これだけが「先に作らないと他が動かない」もの（state を入れる場所がないと terraform が動かない）

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
}


# 誤って壊しても前の state に戻せる
# untuk mengaktifkan versioning pada bucket S3, kita perlu menambahkan blok versioning di dalam resource aws_s3_bucket_versioning. Berikut adalah contoh konfigurasi yang benar:
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
