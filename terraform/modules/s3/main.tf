resource "aws_s3_bucket" "s3_bucket" {
  bucket = "datta-${var.environment}-bucket"
}

resource "aws_s3_bucket_policy" "allow_public_access_for_s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_public_readonly.json
}

data "aws_iam_policy_document" "s3_public_readonly" {
  statement {
    sid    = "s3publicreadonly"
    effect = "Allow"

    resources = [
      "aws_s3_bucket.s3_bucket.arn",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.s3_bucket.id
  acl        = "public-read"
  depends_on = [
    aws_s3_bucket.s3_bucket
  ]
}
