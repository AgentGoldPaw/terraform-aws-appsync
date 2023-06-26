variable "name" {
  type        = string
  description = "the name of the appsync instance"
}

variable "schema" {
  type        = string
  description = "the schema of the appsync instance"
}

variable "xray" {
  type        = bool
  description = "whether to enable xray tracing"
  default     = false
}

variable "authentication_type" {
  type        = string
  description = "Authentication type. Valid values: API_KEY, AWS_IAM, AMAZON_COGNITO_USER_POOLS, OPENID_CONNECT, AWS_LAMBDA"
  default     = "OPENID_CONNECT"
}

variable "issuer" {
  type        = string
  description = "issuer of the OIDC configuration"
}

variable "appsync_domain" {
  type        = string
  description = "domain of the OIDC configuration"
}

variable "route53_domain" {
  type        = string
  description = "the namespace of the route53 record"
}