# Terraform CI/CD Pipeline with AWS CodePipeline

This project deploys an EC2 instance using Terraform with automated CI/CD via AWS CodePipeline.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed locally (for initial setup)
3. GitHub repository with this code
4. S3 bucket for Terraform state: `aviz-tf-bucket`
5. Existing AWS resources:
   - Security group named `web-sg`
   - EC2 key pair named `awar06-lnx`

## Architecture

The pipeline consists of:
- **Source Stage**: Pulls code from GitHub
- **Plan Stage**: Runs `terraform plan` via CodeBuild
- **Approval Stage**: Manual approval gate
- **Apply Stage**: Runs `terraform apply` via CodeBuild

## Deployment Steps

### 1. Push Code to GitHub

```bash
cd /Users/avizway/Desktop/tf-code/my-tf-cicd
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. Deploy Pipeline Infrastructure

```bash
terraform init
terraform plan -var="github_repo=YOUR_GITHUB_USERNAME/YOUR_REPO_NAME"
terraform apply -var="github_repo=YOUR_GITHUB_USERNAME/YOUR_REPO_NAME"
```

### 3. Activate GitHub Connection

After deployment:
1. Go to AWS Console → Developer Tools → Connections
2. Find the `github-connection` (status: PENDING)
3. Click "Update pending connection"
4. Authorize AWS to access your GitHub repository

### 4. Pipeline Execution

The pipeline will automatically trigger on code changes to the main branch:
1. **Source**: Fetches code from GitHub
2. **Plan**: Generates Terraform plan
3. **Approval**: Review plan and approve manually
4. **Apply**: Applies infrastructure changes

## Files

- `main.tf` - EC2 instance configuration
- `provider.tf` - AWS provider and backend configuration
- `variables.tf` - Input variables
- `pipeline.tf` - CodePipeline infrastructure
- `buildspec-plan.yml` - Build spec for plan stage
- `buildspec-apply.yml` - Build spec for apply stage

## Customization

Update `variables.tf` or pass variables during deployment:

```bash
terraform apply \
  -var="github_repo=owner/repo" \
  -var="github_branch=main" \
  -var="instance_type=t3.small"
```

## Cleanup

```bash
terraform destroy -var="github_repo=YOUR_GITHUB_USERNAME/YOUR_REPO_NAME"
```
