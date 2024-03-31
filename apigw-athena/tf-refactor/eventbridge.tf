resource "aws_sfn_state_machine" "partition_update_state_machine" {
  name     = "partition-update-state-machine"
  role_arn = aws_iam_role.role_name.arn

  definition = <<EOF
{
  "Comment": "A state machine that triggers an Athena partition update query",
  "StartAt": "TriggerAthenaPartitionUpdate",
  "States": {
    "TriggerAthenaPartitionUpdate": {
      "Type": "Task",
      "Resource": "arn:aws:states:::events:putEvents",
      "Parameters": {
        "Entries": [
          {
            "Source": "custom.myApp",
            "DetailType": "AthenaPartitionUpdate",
            "Detail": "{ \"query\": \"ALTER TABLE logs ADD IF NOT EXISTS PARTITION (year='${year}', month='${month}', day='${day}') LOCATION '${logs_bucket_arn}'\" }"
          }
        ]
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "partition_update_rule" {
  name        = "partition-update-rule"
  description = "Rule to trigger Step Function for partition update"
  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutObject"],
    "requestParameters": {
      "bucketName": ["${var.logs_bucket}"]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "partition_update_target" {
  rule      = aws_cloudwatch_event_rule.partition_update_rule.name
  target_id = "trigger-step-function"
  arn       = aws_sfn_state_machine.partition_update_state_machine.arn
}
