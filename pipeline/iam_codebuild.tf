# CodeBuild 用 IAMロール　（最小権限：必要な操作だけ一つずつ許可）

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

locals {
    log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}-*"
    state_bucket_arn = "arn:aws:s3:::${var.state_bucket_name}"
}

data "aws_iam_policy_document" "codebuild" {
  #ログ出力（このプロジェクト名のログだけ）
  statement {
    sid = "writebuildlogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      local.log_group_arn,
      "${local.log_group_arn}:*"
    ]
  }

  # S3 State Bucket
  statement {
    sid       = "StateBucketList"
    actions   = ["s3:ListBucket"]
    resources = [local.state_bucket_arn]
  }

  statement {
    sid       = "StateBucketObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.state_bucket_arn}/*"]
  }

  # CodePipeline の成果物バケット（Source ステージで取得したコードを読む）
  statement {
    sid       = "PipelineArtifactsObjects"
    actions   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    sid       = "PipelineArtifactsBucket"
    actions   = ["s3:GetBucketAcl", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  # Terraform で VPC / SG / EC2 を作るための権限
  # ※ 実行して AccessDenied が出たら、エラー文に出た操作を1つ足す
  statement {
    sid = "TerraformEcs"
    actions = [
      "ecs:CreateCluster", "ecs:DeleteCluster", "ecs:DescribeClusters",
      "ecs:CreateService", "ecs:UpdateService", "ecs:DeleteService", "ecs:DescribeServices",
      "ecs:RegisterTaskDefinition", "ecs:DeregisterTaskDefinition",
      "ecs:DeleteTaskDefinitions", "ecs:DescribeTaskDefinition",
      "ecs:TagResource", "ecs:ListTagsForResource",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name   = "${var.project_name}-codebuild-policy"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild.json
}
