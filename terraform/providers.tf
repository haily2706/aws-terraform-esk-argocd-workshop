# terraform/providers.tf
# ─────────────────────────────────────────────────────────────────
# Configures which providers Terraform needs and their versions.
# ─────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.3"        # ← minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"            # ← AWS provider version
    }
  }

  # For a workshop, local state is fine.
  # For production, use S3 backend (see your terraform-aws guide Part 04).
}

provider "aws" {
  region = var.region
}