resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "LogsKinesisStream"
  shard_count      = 1
  retention_period = 24
}


resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name = "terraform-kinesis-firehose-extended-s3-test-stream"

  extended_s3_configuration {
    role_arn   = aws_iam_role.kinesis_delivery_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn

    buffering_size = 64

    dynamic_partitioning_configuration {
      enabled = true
    }

    prefix              = "data/customer_id=!{partitionKeyFromQuery:customer_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

    processing_configuration {
      enabled = true

      processors {
        type = "RecordDeAggregation"
        parameters {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      }

      processors {
        type = "AppendDelimiterToRecord"
      }

      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{customer_id:.customer_id}"
        }
      }
    }
  }
  destination = ""
}
