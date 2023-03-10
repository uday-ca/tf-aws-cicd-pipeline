resource "aws_iam_role" "trz-tf-codepipeline-role" {
  name = "trz-tf-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "trz-tf-cicd-pipeline-policies" {
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["*"]
        effect = "Allow"
    }
    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codebuild:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "trz-tf-cicd-pipeline-policy" {
    name = "trz-tf-cicd-pipeline-policy"
    path = "/"
    description = "Pipeline policy"
    policy = data.aws_iam_policy_document.trz-tf-cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "trz-tf-cicd-pipeline-attachment" {
    policy_arn = aws_iam_policy.trz-tf-cicd-pipeline-policy.arn
    role = aws_iam_role.trz-tf-codepipeline-role.id
}


resource "aws_iam_role" "trz-tf-codebuild-role" {
  name = "trz-tf-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "trz-tf-cicd-build-policies" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*","iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "trz-tf-cicd-build-policy" {
    name = "trz-tf-cicd-build-policy"
    path = "/"
    description = "Codebuild policy"
    policy = data.aws_iam_policy_document.trz-tf-cicd-build-policies.json
}

resource "aws_iam_role_policy_attachment" "trz-tf-cicd-codebuild-attachment1" {
    policy_arn  = aws_iam_policy.trz-tf-cicd-build-policy.arn
    role        = aws_iam_role.trz-tf-codebuild-role.id
}

resource "aws_iam_role_policy_attachment" "trz-tf-cicd-codebuild-attachment2" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.trz-tf-codebuild-role.id
}
