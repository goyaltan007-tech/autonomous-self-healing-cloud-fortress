# =========================================================================
# LAYER 1 & 2: SILENT INFRASTRUCTURE CORE DEFINITION
# =========================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The automated regional deployment boundary
provider "aws" {
  region = "us-east-1"
}

# 1. THE INVISIBLE WALLED GARDEN (Virtual Private Cloud)
resource "aws_vpc" "sil_secure_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "sil-autonomous-network"
    Environment = "Production"
    ManagedBy   = "Terraform-IaC"
  }
}

# 2. THE CHOKEPOINT FIREWALL (Security Group)
resource "aws_security_group" "sil_firewall" {
  name        = "sil-kernel-firewall"
  description = "Enforces silent ingress/egress filtering rules"
  vpc_id      = aws_vpc.sil_secure_network.id

  # Inbound Traffic: Allow secure HTTPS traffic only
  ingress {
    description = "Secure Web Gateway Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Traffic: Allow the server to silently communicate out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. THE CONTAINER RUNTIME COMPUTE FABRIC (ECS Cluster)
resource "aws_ecs_cluster" "sil_compute_fabric" {
  name = "sil-self-healing-engine"

  setting {
    name  = "containerInsights"
    value = "enabled" # Feeds Layer 4 Observability automatically
  }
}
