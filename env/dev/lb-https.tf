# adds an https listener to the load balancer
# (delete this file if you only want http)

# The port to listen on for HTTPS, always use 443
variable "https_port" {
  default = "443"
}

# The ARN for the SSL certificate
# variable "certificate_arn" {
#     default = "arn:aws:acm:us-west-1:552242929734:certificate/e4b20db7-7613-494f-923e-d4adcd0f6384"
# }

variable "route53recordsetname" {
  default = "slackappdevops.navex-dev.com"
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "${var.route53recordsetname}"
#   validation_method = "DNS"

#   tags = {
#     Environment = "test"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

data "aws_acm_certificate" "cert" {
  domain   = "slackappdevops.navex-dev.com"
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "${var.https_port}"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = "${var.https_port}"
#   to_port           = "${var.https_port}"
  to_port           = "${var.https_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nsg_lb.id}"
}