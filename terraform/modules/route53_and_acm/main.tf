########## Data Rources ################

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
data "aws_subnet" "all_subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

#### ROUTE 53 zone Module  #####
module "zones-biprodatta" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "${var.environment}.biprodatta.com" = {
      tags = {
        env = var.environment
      }
    }

  }

  tags = {
    ManagedBy = "Terraform"
  }
}


#### ROUTE 53 records Module  #####

module "records-biprodatta" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = keys(module.zones-biprodatta.route53_zone_zone_id)[0]

  records = [
    {
      name = "api"
      type = "CNAME"
      ttl  = 3600
      records = [
        "${module.alb["biprodatta-api-${var.environment}"].lb_dns_name}",
      ]
    },
    {
      name = "xml"
      type = "CNAME"
      ttl  = 3600
      records = [
        "${module.alb["biprodatta-api-${var.environment}"].lb_dns_name}",
      ]
    },
  ]

  depends_on = [module.zones-biprodatta, module.alb]
}


# ###### alb ####

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"

  for_each         = toset(var.lbname)
  name             = each.key  
  load_balancer_type    = "application"
  create_security_group = false

  vpc_id  = var.vpc_id
  subnets = [for s in data.aws_subnet.all_subnet : s.id]
  security_groups = [module.security_group_alb.security_group_id]


  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      # certificate_arn    = var.https_listener_cert
      certificate_arn    = each.key == "biprodatta-xml-${var.environment}" ? module.acm_xml.acm_certificate_arn : ( each.key == "biprodatta-api-${var.environment}" ? module.acm_api.acm_certificate_arn : null )
      ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
      target_group_index = 0
      condition = {
        host_header = {
          values = ["api.${var.environment}.biprodatta.com"]
        }
      }
    },
  ]

  target_groups = [
    {
      for_each         = toset(var.lbname)
      name             = each.key 
      backend_protocol = "HTTP"
      # protocol_version = "HTTP2"
      backend_port = 80
      target_type  = "ip"
      vpc_id =  var.vpc_id
      health_check = {
        # enabled             = true
        interval            = 15
        path                = "/"
        port                = 8085
        healthy_threshold   = 2
        unhealthy_threshold = 10
        timeout             = 10
        # protocol            = "HTTP"

        }
      },
    ]

}


module "security_group_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name   = "${var.environment}-sg"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https port"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}


# moodule for root ACM certificate
module "acm_root" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${var.environment}.biprodatta.com"


  create_route53_records  = false
  validation_method       = "DNS"
}

resource "aws_acm_certificate_validation" "acm_root_validation" {
  certificate_arn         = module.acm_root.acm_certificate_arn
  validation_record_fqdns = [ tostring(keys(module.zones-biprodatta.route53_zone_name)[0]) ]
}

# moodule for api ACM
module "acm_api" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "api.${var.environment}.biprodatta.com"


  create_route53_records  = false
  validation_method       = "DNS"
}

resource "aws_acm_certificate_validation" "acm_api_validation" {
  certificate_arn         = module.acm_api.acm_certificate_arn
  validation_record_fqdns = [ tostring(values(module.records-biprodatta.route53_record_fqdn)["0"]) ]
}

# moodule for xml ACM
module "acm_xml" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "xml.${var.environment}.mobilemanager.heartland.us"


  create_route53_records  = false
  validation_method       = "DNS"
}

resource "aws_acm_certificate_validation" "acm_xml_validation" {
  certificate_arn         = module.acm_xml.acm_certificate_arn
  validation_record_fqdns = [ tostring(values(module.records-biprodatta.route53_record_fqdn)["1"]) ]
}