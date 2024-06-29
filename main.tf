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

resource "aws_cloudwatch_event_rule" "arc_cw_rule" {
    name = "arc_cronjob"
    description = "Execute every 10 mins"
    schedule_expression = "cron(0/10 * * * ? *)"
}
