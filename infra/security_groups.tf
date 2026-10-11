# --- ALB: open to the internet on port 80 ---
resource "aws_security_group" "alb" {
  name        = "conduit-alb-sg"
  description = "Load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "conduit-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

# --- App: only accepts traffic from the ALB ---
resource "aws_security_group" "app" {
  name        = "conduit-app-sg"
  description = "API servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "conduit-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# --- DB: only accepts PostgreSQL from the app ---
resource "aws_security_group" "db" {
  name        = "conduit-db-sg"
  description = "PostgreSQL database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "conduit-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}