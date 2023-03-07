#TF_remote_state to read outputs from the database's state file.
data "terraform_remote_state" "db-remote-state" {
    backend = "s3"

    config = {
        bucket  = var.db_remote_state_bucket #bucket where it's stored the statefile
        key     = var.db_remote_state_key #location of the state it'll fetch the info
        region  = "us-east-1"
    }
}

#Autoscaling Group
resource "aws_launch_configuration" "test-launch-configuration" {
    image_id        = "ami-09cd747c78a9add63"
    instance_type   = "t2.micro"
    security_groups = [aws_security_group.test-sg.id] 
    
    user_data = templatefile("${path.module}/user-data.sh", {
        server_port = var.server_port
        db_address  = data.terraform_remote_state.db-remote-state.outputs.db_address
        db_port     = data.terraform_remote_state.db-remote-state.outputs.db_port
    })

    #Required when using a launch configuration with an auto scaling group
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "test-asg" {
    #Main configuration
    launch_configuration = aws_launch_configuration.test-launch-configuration.name
    vpc_zone_identifier = data.aws_subnets.default-subnets.ids #pulls the subnet ids out of the aws_subnets data source and tells ASG to use those subnets

    #Target group first-class integration
    target_group_arns = [aws_lb_target_group.lb-targetgroup.arn]
    health_check_type = "ELB" #instructs the ASG to use tg's health check

    min_size = var.min_size
    max_size = var.max_size
    desired_capacity = 2

    tag {
        key     = "Name"
        value   = "${var.env}-asg-ec2"
        propagate_at_launch = true ##Enables propagation of the tag to Amazon EC2 instances launched via this ASG
    }
}

#Security group (ingress rule - allows connections into the ec2)
resource "aws_security_group" "test-sg" {
    name = var.instance_security_group_name

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = local.tcp_protocol
        cidr_blocks = local.all_ips
    }
}

#LoadBalancer
resource "aws_lb" "test-lb" {
    name = "${var.env}-${var.alb_name}"
    load_balancer_type = "application" #Choose of the three types
    subnets = data.aws_subnets.default-subnets.ids #Configures the LB to use all the subnets in Default VPC by using the data source.
    security_groups = [aws_security_group.sg-lb.id] #Tell aws_lb to use 'sg-lb'
}

resource "aws_lb_listener" "lb-http-listener" {
    load_balancer_arn = aws_lb.test-lb.arn
    port = local.http_port
    protocol = "HTTP"
    #By default, return a simple 404 page for requests that don't match any listener rule
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

#Listener rule that sends requests that match any path to the target group that contains the ASG
resource "aws_lb_listener_rule" "lb-listener-rule" {
    listener_arn = aws_lb_listener.lb-http-listener.arn #Ties listener rule to the listener itself
    priority = 100

    condition {
          path_pattern {
            values = ["*"]
        }
    }    
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.lb-targetgroup.arn
    } 
}   

#LB Security Group (allow incoming requests on port 80 and outgoing requests on all ports so lb can perform healthchecks)
resource "aws_security_group" "sg-lb" {
    name = "${var.env}-${var.alb_security_group_name}"

    #Allow inbound HTTP requests
    ingress {
        from_port   = local.http_port
        to_port     = local.http_port
        protocol    = local.tcp_protocol
        cidr_blocks = local.all_ips
    }
    #Allow all outbound requests
    egress {
        from_port   = local.any_port
        to_port     = local.any_port
        protocol    = local.any_protocol
        cidr_blocks = local.all_ips
    }
}

#TargetGroup for ASG (It will health check the EC2s via http requests)
resource "aws_lb_target_group" "lb-targetgroup" {
    name = "${var.env}-lb-targetgroup-asg"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default-vpc.id

    health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200" #If response matches a 200 OK response, it considers the ec2 healthy
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}
