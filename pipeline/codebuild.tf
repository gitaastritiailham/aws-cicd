# Codebuildプロジェクトを２つ作る
#   plan  : buildspec.yml        → init / fmt / validate / plan（AWS は変更しない）
#   apply : buildspec-apply.yml  → init / apply

locals {
  buildspecs = {
    plan  = "terraform-cicd/buildspec.yml"
    apply = "terraform-cicd/buildspec-apply.yml"
  }
}
resource "aws_codebuild_project" "this" {
  for_each = local.buildspecs

  name          = "${var.project_name}-${each.key}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 15

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = each.value
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  # ロールに権限が付いてからプロジェクトを作る
  depends_on = [aws_iam_role_policy.codebuild]
}
