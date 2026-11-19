# state を S3 に保存する（バケットは bootstrap/ の terraform apply で先に作っておく。名前は bootstrap/terraform.tfvars の state_bucket_name と同じにする）
# ※ backend には変数(variabel)が使えないため、バケット名とリージョンは直接書く

terraform {
  backend "s3" {
    bucket       = "research-tfstate-2026"
    key          = "cicd-research/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
