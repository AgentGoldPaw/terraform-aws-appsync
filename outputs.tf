output "appsync_id" {
  value = aws_appsync_graphql_api.instance.id
}

output "appsync_domain" {
  value = aws_appsync_domain_name.instance.appsync_domain_name
}

output "appsync_hosted_zone" {
  value = aws_appsync_domain_name.instance.hosted_zone_id
}