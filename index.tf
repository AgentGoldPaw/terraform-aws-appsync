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
  schema              = file(var.schema)
  xray_enabled        = var.xray

  dynamic "openid_connect_config" {
    for_each = var.authentication_type == "OPENID_CONNECT" ? [1] : []
    content {
      issuer = var.issuer
    }
  }
}

provider "aws" {
  alias  = "UE1"
  region = "us-east-1"
}


resource "aws_acm_certificate" "certificate" {
  count             = var.appsync_certificate_arn != "" ? 0 : 1
  provider          = aws.UE1
  domain_name       = var.appsync_domain
  validation_method = "DNS"
}

resource "aws_appsync_domain_name" "instance" {
  depends_on      = [aws_acm_certificate_validation.cert]
  domain_name     = var.appsync_domain
  certificate_arn = var.appsync_certificate_arn != "" ? var.appsync_certificate_arn : aws_acm_certificate.certificate[0].arn
}

resource "aws_appsync_domain_name_api_association" "instance_connect" {
  depends_on  = [aws_route53_record.sub_domain]
  domain_name = aws_appsync_domain_name.instance.domain_name
  api_id      = aws_appsync_graphql_api.instance.id
}


resource "aws_route53_record" "cert_validation" {
  provider        = aws.UE1
  count           = var.appsync_certificate_arn != "" ? 0 : 1
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.zone[0].zone_id
  ttl             = 60
}

# This tells terraform to cause the route53 validation to happen
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.UE1
  count                   = var.appsync_certificate_arn != "" ? 0 : 1
  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
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