resource "aws_s3_bucket" "trz-codepipeline-artifacts" {
  bucket = "trz-cicd-artifacts-bucket1"
 
}
resource "aws_s3_bucket_acl" "trz-codepipeline-artifacts-acl" {
  bucket = aws_s3_bucket.trz-codepipeline-artifacts.id
  acl    = "private"
}
resource "aws_kms_key" "trz-s3-kms-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}
resource "aws_s3_bucket_server_side_encryption_configuration" "trzmyencription" {
  bucket = aws_s3_bucket.trz-codepipeline-artifacts.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.trz-s3-kms-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}