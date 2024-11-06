locals {
  user_data = <<-EOT
    #!/bin/bash
    echo ${join("\n", var.ssh_keys)} >> ~/.ssh/authorized_keys
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(local.tags)}
    ECS_ENABLE_TASK_IAM_ROLE=true
    EOF
  EOT
}


module "autoscaling" {
  source                     = "terraform-aws-modules/autoscaling/aws"
  version                    = "~> 6.5"
  name                       = local.name
  instance_type              = var.instance_type
  use_mixed_instances_policy = false
  mixed_instances_policy     = {}
  user_data                  = base64encode(local.user_data)


  image_id                        = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  security_groups                 = [module.autoscaling_sg.security_group_id]
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_description        = "ECS role for ${local.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }
  protect_from_scale_in = true
  tags                  = local.tags
}


module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Autoscaling group security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb.security_group_id
    },
    {
      rule = "http-80-tcp"

      source_security_group_id = module.alb.security_group_id
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow ssh"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Allow postgres"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      description = "Allow strapi"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Allow web"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow http"
      cidr_blocks = "0.0.0.0/0"
    }, 
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow https"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = local.tags
}

data "aws_autoscaling_group" "asg" {
  name = module.autoscaling.autoscaling_group_name
}

data "aws_instance" "asg_instance" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [data.aws_autoscaling_group.asg.name]
  }
}

resource "aws_eip" "asg_instance_eip" {
  instance   = data.aws_instance.asg_instance.id
  depends_on = [module.autoscaling]
}

