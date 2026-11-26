# CodePipeline 用　IAM　ロール（最小権限）
data "aws_iam_policy_document" "pipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${var.project_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume.json
}

data "aws_iam_policy_document" "pipeline" {
  # 成果物バケットの読み書き
  statement {
    sid       = "ArtifactObjects"
    actions   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    sid       = "ArtifactBucket"
    actions   = ["s3:GetBucketVersioning", "s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  # CodeBuild の起動（この2つのプロジェクトだけ）
  statement {
    sid       = "RunCodeBuild"
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = [for p in aws_codebuild_project.this : p.arn]
  }

  # GitHub 接続の利用（この接続だけ）
  statement {
    sid = "UseGitHubConnection"
    actions = [
      "codeconnections:UseConnection",
      "codestar-connections:UseConnection",
    ]
    resources = [var.github_connection_arn]
  }
}

resource "aws_iam_role_policy" "pipeline" {
  name   = "${var.project_name}-pipeline-policy"
  role   = aws_iam_role.pipeline.id
  policy = data.aws_iam_policy_document.pipeline.json
}
