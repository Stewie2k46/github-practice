# Create EBS Volume in Mumbai region
resource "aws_ebs_volume" "arc_volume" {
    availability_zone = "ap-south-1a"
    size = 1

    tags = {
      Name = "arc_volume"
    }
}

# Create SNS Topic
resource "aws_sns_topic" "arc_sns_topic" {
    name = "arc_sns_topic"
}

# Create Subscription for SNS Topic
resource "aws_sns_topic_subscription" "arc_subsciption" {
    for_each = toset(var.email_ids)

    topic_arn = aws_sns_topic.arc_sns_topic.arn
    protocol = "email"
    endpoint = each.value
}

resource "aws_cloudwatch_event_rule" "arc_volume_creation_rule" {
  name        = "arc-volume-creation-rule"
  description = "Capture EBS volume creation events"
  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ec2.amazonaws.com"],
    "eventName": ["CreateVolume"]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "arc_volume_deletion_rule" {
  name        = "arc-volume-deletion-rule"
  description = "Capture EBS volume deletion events"
  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["ec2.amazonaws.com"],
    "eventName": ["DeleteVolume"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "creation_target" {
  rule      = aws_cloudwatch_event_rule.arc_volume_creation_rule.name
  target_id = "send_creation_notification"
  arn       = aws_sns_topic.arc_sns_topic.arn
}

resource "aws_cloudwatch_event_target" "deletion_target" {
  rule      = aws_cloudwatch_event_rule.arc_volume_creation_rule.name
  target_id = "send_deletion_notification"
  arn       = aws_sns_topic.arc_sns_topic.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_sns_creation" {
  statement_id  = "AllowCloudWatchToInvokeSNSCreation"
  action        = "lambda:InvokeFunction"
  function_name = aws_sns_topic.arc_sns_topic.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.arc_volume_creation_rule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_sns_deletion" {
  statement_id  = "AllowCloudWatchToInvokeSNSDeletion"
  action        = "lambda:InvokeFunction"
  function_name = aws_sns_topic.arc_sns_topic.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.arc_volume_deletion_rule.arn
}

