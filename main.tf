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
resource "aws_sns_topic_subscription" "arc_subscription" {
    for_each = toset(var.email_ids)

    topic_arn = aws_sns_topic.arc_sns_topic.arn
    protocol = "email"
    endpoint = each.value
}

resource "aws_cloudwatch_event_rule" "arc_volume_creation_rule" {
  name        = "arc-volume-creation-rule"
  description = "Capture EBS volume creation events"
  event_pattern = jsonencode({
   "source": ["aws.ec2"],
   "detail-type": ["AWS API Call via CloudTrail"],
   "detail": {
     "eventSource": ["ec2.amazonaws.com"],
     "eventName": ["CreateVolume"]
  }
})


resource "aws_cloudwatch_event_rule" "arc_volume_deletion_rule" {
  name        = "arc-volume-deletion-rule"
  description = "Capture EBS volume deletion events"
  event_pattern = jsonencode({
   "source": ["aws.ec2"],
   "detail-type": ["AWS API Call via CloudTrail"],
   "detail": {
     "eventSource": ["ec2.amazonaws.com"],
     "eventName": ["DeleteVolume"]
  }
})

resource "aws_cloudwatch_event_target" "creation_target" {
  rule      = aws_cloudwatch_event_rule.arc_volume_creation_rule.name
  target_id = "send_creation_notification"
  arn       = aws_sns_topic.arc_sns_topic.arn
}

resource "aws_cloudwatch_event_target" "deletion_target" {
  rule      = aws_cloudwatch_event_rule.arc_volume_deletion_rule.name
  target_id = "send_deletion_notification"
  arn       = aws_sns_topic.arc_sns_topic.arn
}

resource "aws_sns_topic_policy" "arc_notifications_policy" {
  arn = aws_sns_topic.arc_sns_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sns:Publish",
        Resource = aws_sns_topic.arc_sns_topic.arn
      }
    ]
  })
}

