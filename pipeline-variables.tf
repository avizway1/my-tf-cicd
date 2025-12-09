variable "github_repo" {
  type        = string
  description = "GitHub repository in format: owner/repo-name"
}

variable "github_branch" {
  type    = string
  default = "main"
}
