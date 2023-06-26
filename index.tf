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
    issuer   = var.issuer
  }
}

data "aws_route53_zone" "zone" {
  count = var.route53_domain != "" ? 1 : 0
  name  = "${var.route53_domain}."
}

resource "aws_route53_record" "sub_domain" {
  name    = var.appsync_domain
  type    = "A"
  zone_id = data.aws_route53_zone.zone[0].zone_id

  alias {
    name                   = aws_appsync_domain_name.instance.appsync_domain_name
    zone_id                = aws_appsync_domain_name.instance.hosted_zone_id
    evaluate_target_health = false
  }
}