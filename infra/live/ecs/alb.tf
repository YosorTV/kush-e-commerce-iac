module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = local.name

  load_balancer_type = "application"

  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  enable_deletion_protection = true

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_strapi = {
      from_port   = 1337
      to_port     = 1337
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = data.terraform_remote_state.vpc.outputs.vpc_cidr
    }
  }

listeners = {
  frontend_https = {
    port              = 443
    protocol          = "HTTPS"
    certificate_arn   = var.certifiate_arn
    forward = {
      target_group_key = "backend_ecs"
    }
    rules = {
      frontend_rule = {
        priority = 1000
        actions = [{
          type            = "forward"
          target_group_arn = module.alb.target_groups["frontend_ecs"].id
        }]
        conditions = [{
            host_header = {
              values = [var.frontend_domain]
            }
            
        }]
      }
      backend_rule = {
        priority = 1001
        actions = [{
          type            = "forward"
          target_group_arn = module.alb.target_groups["backend_ecs"].id
        }]
        conditions = [{
            host_header = {
              values = [var.backend_domain]
            }
            
        }]
      }
    }
  }
}


  target_groups = {
    backend_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = var.backend_port
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        path                = "/"
        port                = "1337"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }
      create_attachment = false
    }
    frontend_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = var.frontend_port
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "307"
        path                = "/"
        port                = "3000"
        protocol            = "HTTP"
        certificate_arn     = var.certifiate_arn
        timeout             = 5
        unhealthy_threshold = 2
      }
      create_attachment = false
    }
  }

  tags = local.tags
}
