resource "aws_lb" "network" {
  name               = "nlb-${module.aws-eks.cluster_name}"
  internal           = true
  load_balancer_type = "network"

  subnets                    = module.aws-vpc.private_subnet_ids
  enable_deletion_protection = false
}

# resource "aws_route53_zone" "local" {
#   name = var.dns_domain
#   vpc {
#     vpc_id = module.aws-vpc.vpc_id
#   }
# }

resource "aws_lb_listener" "tls" {
  load_balancer_arn = aws_lb.network.arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.domain.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_tls.arn
  }
}


resource "aws_lb_target_group" "instance_tls" {
  name     = "nlb-target-tls"
  port     = 443
  protocol = "TLS"
  vpc_id   = module.aws-vpc.vpc_id
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.network.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance_http.arn
  }
}


resource "aws_lb_target_group" "instance_http" {
  name     = "nlb-target-http"
  port     = "80"
  protocol = "TCP"
  vpc_id   = module.aws-vpc.vpc_id
}



resource "aws_acm_certificate" "network" {
  domain_name       = "sandbox.${var.dns_domain}"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048" # "RSA_1024" "RSA_2048" "RSA_3072" "RSA_4096" "EC_prime256v1" "EC_secp384r1" "EC_secp521r1"
  lifecycle {
    create_before_destroy = true
  }
}




# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "www.example.com"
#   type    = "A"
#   ttl     = 300
#   records = [aws_eip.lb.public_ip]
# }