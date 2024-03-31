provider "aws" {
  region = var.region
}

resource "aws_iam_role" "kinesis_delivery_role" {
  name = "${var.service}-kinesis-role-${var.stage}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "firehose.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.aws_account
          }
        }
      }
    ]
  })

  inline_policy {
    name   = "firehose_delivery_policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.logs_bucket}",
            "arn:aws:s3:::${var.logs_bucket}/*"
          ]
        },
        {
          Effect   = "Allow"
          Action   = "glue:GetTableVersions"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "stream_to_firehose"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "kinesis:PutRecords",
            "kinesis:DescribeStream",
            "kinesis:GetShardIterator",
            "kinesis:GetRecords"
          ]
          Resource = [aws_kinesis_stream.kinesis_stream.arn]
        },
        {
          Effect   = "Allow"
          Action   = "glue:GetTableVersions"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "role_name" {
  name               = "role_name"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "s3_access_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload",
        "s3:CreateBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.logs_bucket}",
        "arn:aws:s3:::${var.logs_bucket}/*"
      ]
    }
  ]
}
EOF
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role_name.name
  policy_arn = aws_iam_policy.policy.arn
}
