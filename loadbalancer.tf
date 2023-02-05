# Create an Application Load Balancer

resource "aws_lb" "Project-load-balancer" {
  name               = "Project-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Project-load_balancer_sg.id]
  subnets            = [aws_subnet.Project-public-subnet1.id, aws_subnet.Project-public-subnet2.id]
  #enable_cross_zone_load_balancing = true
  enable_deletion_protection = false
  depends_on                 = [aws_instance.Project1, aws_instance.Project2, aws_instance.Project3]
}

# Create the target group

resource "aws_lb_target_group" "Project-target-group" {
  name     = "Project-target-group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Project_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create the listener

resource "aws_lb_listener" "Project-listener" {
  load_balancer_arn = aws_lb.Project-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Project-target-group.arn
  }
}

# Create the listener rule
resource "aws_lb_listener_rule" "Project-listener-rule" {
  listener_arn = aws_lb_listener.Project-listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Project-target-group.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Attach the target group to the load balancer

resource "aws_lb_target_group_attachment" "Project-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.Project-target-group.arn
  target_id        = aws_instance.Project1.id
  port             = 80
}
 
resource "aws_lb_target_group_attachment" "Project-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.Project-target-group.arn
  target_id        = aws_instance.Project2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "Project-target-group-attachment3" {
  target_group_arn = aws_lb_target_group.Project-target-group.arn
  target_id        = aws_instance.Project3.id
  port             = 80 
  
  }

