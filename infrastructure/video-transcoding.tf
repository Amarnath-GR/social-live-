# Video Transcoding Pipeline
resource "aws_media_convert_queue" "transcoding_queue" {
  name = "social-live-transcoding"
  
  pricing_plan = "ON_DEMAND"
  
  tags = {
    Name = "transcoding-queue"
  }
}

resource "aws_iam_role" "mediaconvert_role" {
  name = "MediaConvertRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "mediaconvert_policy" {
  name = "MediaConvertPolicy"
  role = aws_iam_role.mediaconvert_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.media_bucket.arn}/*",
          "${aws_s3_bucket.source_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "source_bucket" {
  bucket = "social-live-source-${random_string.bucket_suffix.result}"
}

# Lambda for triggering transcoding
resource "aws_lambda_function" "transcoding_trigger" {
  filename         = "transcoding_trigger.zip"
  function_name    = "transcoding-trigger"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      MEDIACONVERT_QUEUE = aws_media_convert_queue.transcoding_queue.arn
      MEDIACONVERT_ROLE  = aws_iam_role.mediaconvert_role.arn
      OUTPUT_BUCKET      = aws_s3_bucket.media_bucket.bucket
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "TranscodingLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "TranscodingLambdaPolicy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "mediaconvert:CreateJob",
          "mediaconvert:GetJob",
          "mediaconvert:ListJobs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.mediaconvert_role.arn
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "transcoding_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transcoding_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".mp4"
  }
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transcoding_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}