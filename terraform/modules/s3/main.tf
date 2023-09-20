resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.environment == "prod" ? "google-central-search-engine" : "google-${var.environment}-central-search-engine"
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "allow_public_access_for_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_public_readonly.json
  depends_on = [ aws_s3_bucket.s3_bucket ]
}


resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.s3_bucket.id
  acl        = "private"
  depends_on = [
    aws_s3_bucket.s3_bucket,
    aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership
  ]
}

data "aws_iam_policy_document" "s3_public_readonly" {
  statement {
    sid    = "Permissionsonobjectsandbuckets"
    effect = "Allow"

    resources = [
      var.environment == "prod" ? "arn:aws:s3:::google-central-search-engine" : "arn:aws:s3:::google-${var.environment}-central-search-engine",
      var.environment == "prod" ? "arn:aws:s3:::google-central-search-engine/*" : "arn:aws:s3:::google-${var.environment}-central-search-engine/*"
    ]

    actions = [
      "s3:List*",
      "s3:PutBucketVersioning",
      "s3:ReplicateDelete",
      "s3:ReplicateObject"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::227067764165:role/ec2_full_access"]
    }
  }
  statement {
    sid    = "Permissiontooverridebucketowner"
    effect = "Allow"

    resources = [
      var.environment == "prod" ? "arn:aws:s3:::google-central-search-engine" : "arn:aws:s3:::google-${var.environment}-central-search-engine",
      var.environment == "prod" ? "arn:aws:s3:::google-central-search-engine/*" : "arn:aws:s3:::google-${var.environment}-central-search-engine/*"
    ]

    actions = [
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::227067764165:root"]
    }
  }
}