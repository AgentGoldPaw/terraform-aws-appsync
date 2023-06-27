# terraform-aws-appsync
My revision of creating an appsync instance simplified. 

Sets up appsync with a custom domain and authentication (OPENID_CONNECT for now)

## Example Usage
The following example shows how to create a custom appsync with a custom domain and `openid_connect` jwt authentication

```terraform
module "appsync" {
    source = "RedMunroe/terraform-aws-appsync"
    version = "0.0.1"

    name = "my-test-appsync"
    schema = file("./path/to/graphql/schema")
    xray = true

    issuer = "https://auth.service.com" 
    appsync_domain = "graphql.mydomain.com"
    route53_domain = "mydomain.com"
}
```

## Argument Reference

The arguments provided to this module acts as a configuration parameters. `appsync_domain` is the subdomain that will be configured on `route53_domain` and linked to the appsync in your aws account. 

 - `name : string` - (required) name of the appsync instance
 - `schema : string` - (required) the GraphQL schema that will be used 
- `xray: boolean` - (optional) whether or not to activate xray on appsync. Default: false
 - `issuer` - (required) the issuer of the JWT used to authenticate against the graphql instance
 - `appsync_domain` - (optional) what is the subdomain you want to use to mask the aws domain. EX. api
 - `route53_domain` - (optional) the root domain to use to create the subdomain of `appsync_domain`
 - `appsync_cerificate_arn` - (optional) this is used to pass a custom certificate arn.

 ## Attributes Reference
 All attributes are exports that contain references to the live data you will need to map other resources to the appsync instance. 

 The following attributes are exported: 
  - `appsync_id` - the id of the appsync instance. This is used for mapping resolvers
  - `appsync_domain` - the domain of the appsync instance. 
  - `appsync_hosted_zone` - the hosted zone of the appsync instance

## Resources 

| Resource Name | Reference Name | Purpose | 
| ------ | -----| ---- | 
| aws_appsync_graphql_api | instance | the serverless resource that powers your graphql instance | 
| aws_acm_certificate | certificate | the custom SSL generated certificate that will be used *`if no appsync_certificate_arn` is supplied* | 
| aws_appsync_domain_name | instance | registering the custom domain with appsync |
| aws_appsync_domain_name_api_association | instance_connect | map the domain to graphql api | 
| aws_route53_record | cert_validation | the DNS records for the aws SSL cert | 
| aws_acm_certificate_validation | cert | this tells terraform to cause the route53 validation to happen | 
| aws_route53_record | sub_domain | the route53 record of the subdomain | 

## Data Sources
| data name | reference name | purpose | 
| --------- | -------------- | ------- | 
| aws_route53_zone | zone | getting the host zone id without making the user go find it | 