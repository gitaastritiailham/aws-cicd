# 承認待ち・失敗をメールで知らせる
#トピック名は codestar-notifications- で始める (AWSの推奨。IAMポリシーの範囲がこの名前に合わせてある)
resource "aws_sns_topic" "notify" {
  name = "codestar-notifications-${var.project_name}"
}

#通知機能 (codestar-notifications) がこのトピックにpublishできるようにする
resource "aws_iam_policy_document" "notify" {
    statement {
        sid = "AllowCodestarNotificationsToPublish"
        actions = [
            "sns:Publish"
        ]
        resources = [
            aws_sns_topic.notify.arn
        ]
        principals {
            type        = "Service"
            identifiers = ["codestar-notifications.amazonaws.com"]
        }
        conditions {
            test     = "StringEquals"
            variable = "AWS:SourceAccount"
            values   = [data.aws_caller_identity.current.account_id]
        }
    }
}

resource "aws_sns_topic_policy" "notify" {
    arn    = aws_sns_topic.notify.arn
    policy = data.aws_iam_policy_document.notify.json
}

# メール購読 (Apply 後に届く確認メールの [Confirm subscription] を押すこと)
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.notify.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# 通知メール：Approval 待ちと pipeline 失敗の通知を受け取るようにする
resource "aws_codestarnotifications_notification_rule" "pipeline" {
  name     = "${var.project_name}-pipeline-notify"
  detail_type = "FULL"
  resource  = aws_codepipeline.main.arn
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-manual-approval-needed"
  ]
  targets {
    target_address = aws_sns_topic.notify.arn
    target_type    = "SNS"
  }

  depends_on = [
    aws_sns_topic_policy.notify
    ]
}