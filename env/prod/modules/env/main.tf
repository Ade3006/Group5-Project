terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


locals {
  tags = {
    Project     = "multi-env-shared-vpc"
    Environment = var.env_name
  }

  s3_path = "s3://${var.bucket_name}/${var.images_prefix}"
}

data "aws_iam_instance_profile" "lab" {
  name = var.iam_instance_profile_name
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_launch_template" "this" {
  name_prefix   = "lt-${var.env_name}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.web_sg_id]

  iam_instance_profile {
    name = data.aws_iam_instance_profile.lab.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd awscli

              mkdir -p /var/www/html/images
              aws s3 sync ${local.s3_path} /var/www/html/images

              cat > /var/www/html/index.html <<'EOPAGE'
              <html>
                <head>
                  <title>${var.env_name} environment</title>
                </head>
                <body>
                  <h1>${var.env_name} Environment Web Server</h1>
                  <p>Served from Auto Scaling Group behind a shared ALB.</p>
              
                  <img src="/images/image1.jpg" width="300" />
                  <img src="/images/image2.jpg" width="300" />
              
                  <h2>Project Team Members</h2>
                  <ul>
                    <li>Adegboyega Aromolaran</li>
                    <li>Chenyu Gao</li>
                    <li>Tony Nnamdi</li>
                    <li>Amrinder Singh</li>
                    <li>Uchechukwu Uzodinma Udechukwu</li>
                  </ul>
                </body>
              </html>
              EOPAGE

              systemctl enable httpd
              systemctl start httpd
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.env_name}-web" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "asg-${var.env_name}"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_size
  health_check_type         = "ELB"
  health_check_grace_period = 120

  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.env_name}-web-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "cpu-${var.env_name}-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 7
  }
}
