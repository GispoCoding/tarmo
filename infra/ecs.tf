# Cluster is a collection of compute resources that can run tasks and services (docker containers in the end)
resource "aws_ecs_cluster" "pg_tileserv" {
  # Separate even the clusters from each other. If we want to deploy and destroy deployments independently,
  # they cannot have common resources.
  name = "${var.prefix}-pg_tileserv"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.default_tags, {Name = "${var.prefix}-cluster"})
}

# Task definition is a description of parameters given to docker daemon, in order to run a container
resource "aws_ecs_task_definition" "pg_tileserv" {
  family                   = "${var.prefix}-pg_tileserv"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # This is the IAM role that the docker daemon will use, e.g. for pulling the image from ECR (AWS's own docker repository)
  execution_role_arn       = aws_iam_role.backend-task-execution.arn
  # If the containers in the task definition need to access AWS services, we'd specify a role via task_role_arn.
  # task_role_arn = ...
  cpu                      = var.pg_tileserv_cpu
  memory                   = var.pg_tileserv_memory
  container_definitions    = jsonencode(
  [
    {
      name         = "pg_tileserv-from-dockerhub"
      image        = var.pg_tileserv_image
      cpu          = var.pg_tileserv_cpu
      memory       = var.pg_tileserv_memory
      mountPoints  = []
      volumesFrom  = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/aws/ecs/${var.prefix}-pg_tileserv"
          awslogs-region = var.AWS_REGION_NAME
          awslogs-stream-prefix = "ecs"
        }
      }
      essential    = true
      portMappings = [
        {
          hostPort = var.pg_tileserv_port
          # This port is the same that the contained application also uses
          containerPort = var.pg_tileserv_port
          protocol      = "tcp"
        }
      ]
      # With Fargate, we use awsvpc networking, which will reserve a ENI (Elastic Network Interface) and attach it to
      # our VPC
      networkMode  = "awsvpc"
      environment  = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://${var.tarmo_r_secrets.username}:${var.tarmo_r_secrets.password}@${aws_db_instance.main_db.address}/${var.tarmo_db_name}"
        },
      ]
    }
  ])
  tags = merge(local.default_tags, {Name = "${var.prefix}-pg_tileserv-definition"})
}

# Service can also be attached to a load balancer for HTTP, TCP or UDP traffic
resource "aws_ecs_service" "pg_tileserv" {
  name            = "${var.prefix}_pg_tileserv"
  cluster         = aws_ecs_cluster.pg_tileserv.id
  task_definition = aws_ecs_task_definition.pg_tileserv.arn
  desired_count   = 1

  # We run containers with the Fargate launch type. The other alternative is EC2, in which case we'd provision EC2
  # instances and attach them to the cluster.
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.tileserver.arn
    container_name   = "pg_tileserv-from-dockerhub"
    container_port   = var.pg_tileserv_port
  }

  network_configuration {
    # Fargate uses awspvc networking, we tell here into what subnets to attach the service
    subnets          = aws_subnet.public.*.id
    # Ditto for security groups
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = true
  }

  tags = merge(local.default_tags, {Name = "${var.prefix}-pg_tileserv-service"})
}
