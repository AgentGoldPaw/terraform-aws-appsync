terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }
}

resource "aws_appsync_graphql_api" "instance" {
  name                = var.name
  authentication_type = var.authentication_type
  schema              = file(var.appsync_schema)
  xray_enabled        = var.xray

  dynamic "openid_connect_config" {
    for_each = var.authentication_type == "OPENID_CONNECT" ? [1] : []
    issuer = var.issuer
  }
}