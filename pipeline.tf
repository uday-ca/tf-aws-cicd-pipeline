resource "aws_codebuild_project" "trz-tf-plan" {
  name          = "trz-tf-cicd-plan"
  description   = "Plan stage for terraform11"
  service_role  = aws_iam_role.trz-tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    #image                       = "hashicorp/terraform:latest"
    #image                       = "aws/codebuild/standard:2.0"
    image                       = "public.ecr.aws/hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    #image_pull_credentials_type = "SERVICE_ROLE"
    image_pull_credentials_type = "CODEBUILD"
    #registry_credential{
    #    credential = var.dockerhub_credentials
    #    credential_provider = "SECRETS_MANAGER"
    #}
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/plan-buildspec.yml")
 }
}

resource "aws_codebuild_project" "trz-tf-apply" {
  name          = "trz-tf-cicd-apply"
  description   = "Apply stage for terraform"
  service_role  = aws_iam_role.trz-tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    #image                       = "hashicorp/terraform:latest"
    #image                       = "aws/codebuild/standard:2.0"
    image                       = "public.ecr.aws/hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    #image_pull_credentials_type = "SERVICE_ROLE"
    image_pull_credentials_type = "CODEBUILD"
    #registry_credential{
    #    credential = var.dockerhub_credentials
    #    credential_provider = "SECRETS_MANAGER"
    #}
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/apply-buildspec.yml")
 }
}


resource "aws_codepipeline" "trz-cicd_pipeline" {

    name = "trz-tf-cicd"
    role_arn = aws_iam_role.trz-tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.trz-codepipeline-artifacts.id
    }

    stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["trz-tf-code"]
            configuration = {
                FullRepositoryId = "uday-ca/aws-cicd-pipeline"
                BranchName   = "main"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Plan"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["trz-tf-code"]
            configuration = {
                ProjectName = "trz-tf-cicd-plan"
            }
        }
    }

    stage {
        name ="Deploy"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["trz-tf-code"]
            configuration = {
                ProjectName = "trz-tf-cicd-apply"
            }
        }
    }

}