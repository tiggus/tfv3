# data "aws_route53_zone" "domain" {
#   name     = var.dns_domain
#   provider = aws.route53
# }

# resource "aws_route53_record" "cname" {
#   provider = aws.route53
#   for_each = {
#     for dvo in aws_acm_certificate.network.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 300
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.domain.zone_id
# }
