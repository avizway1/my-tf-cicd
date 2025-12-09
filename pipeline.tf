resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "aviz-tf-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "codepipeline" {
  name = "tf-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = ["${aws_s3_bucket.pipeline_artifacts.arn}/*", aws_s3_bucket.pipeline_artifacts.arn]
      },
      {
        Effect = "Allow"
        Action = ["codebuild:*"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["codeconnections:*", "codestar-connections:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codebuild" {
  name = "tf-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["logs:*", "s3:*", "ec2:*", "iam:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "plan" {
  name          = "tf-plan"
  service_role  = aws_iam_role.codebuild.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-plan.yml"
  }
}

resource "aws_codebuild_project" "apply" {
  name          = "tf-apply"
  service_role  = aws_iam_role.codebuild.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-apply.yml"
  }
}

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "terraform" {
  name     = "terraform-pipeline"
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repo
        BranchName       = var.github_branch
      }
    }
  }
  stage {
    name = "Plan"
    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["plan"]
      configuration = {
        ProjectName = aws_codebuild_project.plan.name
      }
    }
  }
  stage {
    name = "Approve"
    action {
      name     = "Approve"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }
  stage {
    name = "Apply"
    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["plan"]
      configuration = {
        ProjectName = aws_codebuild_project.apply.name
      }
    }
  }
}
