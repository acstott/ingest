output "athena_table_arn" {
  value = aws_glue_catalog_table.example.arn
}

output "kinesis_stream_arn" {
  value = aws_kinesis_stream.kinesis_stream.arn
}

output "firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}

output "cloudwatch_event_rule_arn" {
  value = aws_cloudwatch_event_rule.partition_update_rule.arn
}

output "cloudwatch_event_target_arn" {
  value = aws_cloudwatch_event_target.partition_update_target.arn
}