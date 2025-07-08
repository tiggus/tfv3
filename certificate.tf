# resource "aws_acm_certificate_validation" "domain" {
#   certificate_arn         = aws_acm_certificate.network.arn
#   validation_record_fqdns = [for record in aws_route53_record.cname : record.fqdn]
# }
