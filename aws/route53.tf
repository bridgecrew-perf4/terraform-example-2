data "aws_route53_zone" "main" {
  name         = "example.com."
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "web.example.com"
  type    = "A"
  alias {
    evaluate_target_health = false
    name = aws_lb.alb_front.dns_name
    zone_id = aws_lb.alb_front.zone_id
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.example.com"
  type    = "A"
  alias {
    evaluate_target_health = false
    name = aws_lb.alb_front.dns_name
    zone_id = aws_lb.alb_front.zone_id
  }
}