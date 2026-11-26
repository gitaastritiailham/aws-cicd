# GitHub → Source → Build(plan) → Approval → Deploy(apply)
resource "aws_codepipeline" "main" {
  name           = "${var.project_name}-pipeline"
  role_arn       = aws_iam_role.pipeline.arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED" #実行が重かったら順番に処理する

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }


  # 1. Source : GitHub からコードを取得
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = var.github_connection_arn
        FullRepositoryId     = var.github_repository
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  # 2. Build(plan) : CodeBuild で plan を実行
  stage {
    name = "Build"

    action {
      name            = "Plan"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.this["plan"].name
      }
    }
  }

  # 3. Approval：plan の結果を人が確認して承認
  stage {
    name = "Approval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "Build ステージの terraform plan のログを確認してから承認してください"
      }
    }
  }

  # 4. Deploy：apply（CodeBuild は Build カテゴリのアクションとして実行する）
  stage {
    name = "Deploy"

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.this["apply"].name
      }
    }
  }
}
