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

# # Now this is a handful. We need varnish, plus varnish configuration container, plus
# # ssl tunnel containers from varnish to both tarmo and mml tile servers, since
# # varnish doesn't know how to cache https requests.
# resource "aws_ecs_task_definition" "tileserv_cache" {
#   family                   = "${var.prefix}-tileserv_cache"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   # This is the IAM role that the docker daemon will use, e.g. for pulling the image from ECR (AWS's own docker repository)
#   execution_role_arn       = aws_iam_role.backend-task-execution.arn
#   # If the containers in the task definition need to access AWS services, we'd specify a role via task_role_arn.
#   # task_role_arn = ...
#   cpu                      = var.varnish_cpu
#   memory                   = var.varnish_memory
#   # https://kichik.com/2020/09/10/mounting-configuration-files-in-fargate/
#   volume {
#     name = "varnish_configuration"
#   }

#   container_definitions    = jsonencode(
#   [
#     {
#       name         = "tarmo-stunnel-sidecar"
#       image        = "tstrohmeier/stunnel-client"
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group = "/aws/ecs/${var.prefix}-tileserv_cache"
#           awslogs-region = var.AWS_REGION_NAME
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#       portMappings = [
#         {
#           hostPort = 8888
#           # This port is the same that the contained application also uses
#           containerPort = 8888
#           protocol      = "tcp"
#         }
#       ]
#       environment  = [
#         {
#           name = "ACCEPT"
#           value = "8888"
#         },
#         {
#           name = "CONNECT"
#           value = "${local.tileserver_dns_alias}:443"
#         }
#       ]
#     },
#     {
#       name         = "mml-stunnel-sidecar"
#       image        = "tstrohmeier/stunnel-client"
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group = "/aws/ecs/${var.prefix}-tileserv_cache"
#           awslogs-region = var.AWS_REGION_NAME
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#       portMappings = [
#         {
#           hostPort = 8889
#           # This port is the same that the contained application also uses
#           containerPort = 8889
#           protocol      = "tcp"
#         }
#       ]
#       environment  = [
#         {
#           name = "ACCEPT"
#           value = "8889"
#         },
#         {
#           name = "CONNECT"
#           value = "avoin-karttakuva.maanmittauslaitos.fi:443"
#         }
#       ]
#     },
#     {
#       # https://kichik.com/2020/09/10/mounting-configuration-files-in-fargate/
#       name         = "varnish-configuration-sidecar"
#       image        = "bash"
#       DependsOn = [
#         {
#           condition = "START"
#           containerName = "tarmo-stunnel-sidecar"
#         },
#         {
#           condition = "START"
#           containerName = "mml-stunnel-sidecar"
#         }
#       ]
#       mountPoints  = [
#         {
#           containerPath = "/etc/varnish"
#           sourceVolume = "varnish_configuration"
#         }
#       ]
#       essential = false
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group = "/aws/ecs/${var.prefix}-tileserv_cache"
#           awslogs-region = var.AWS_REGION_NAME
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#       command = ["-c", "echo $VARNISH_CONF | base64 -d - | tee /etc/varnish/default.vcl"]
#       environment  = [
#         {
#           name = "VARNISH_CONF"
#           value = base64encode(
#             <<EOF
#             # specify the VCL syntax version to use
#             vcl 4.1;

#             backend tarmo {
#               .host = "localhost";
#               .port = "8888";
#             }

#             backend mml {
#               .host = "localhost";
#               .port = "8889";
#             }

#             sub vcl_recv {
#               # ping endpoint for testing
#               if(req.url ~ "/ping$") {
#                 return(synth(700, "Pong"));
#               }
#               if (req.http.host ~ "${local.tile_cache_dns_alias}") {
#                 set req.backend_hint = tarmo;
#                 set req.http.host = "${local.tileserver_dns_alias}";
#               }
#               if(req.http.host ~ "${local.mml_cache_dns_alias}") {
#                 set req.backend_hint = mml;
#                 set req.http.host = "avoin-karttakuva.maanmittauslaitos.fi";
#               }
#             }

#             sub vcl_synth {
#               # respond HTTP 200
#               if (resp.status == 700) {
#                 set resp.status = 200;
#                 set resp.http.Content-Type = "text/plain";
#                 synthetic({"Pong"});
#                 return (deliver);
#               }
#             }

#             sub vcl_backend_response {
#               set beresp.ttl = 1h;
#               set beresp.grace = 2h;
#             }

#             EOF
#           )
#         }
#       ]
#     },
#     {
#       name         = "varnish-from-dockerhub"
#       image        = var.varnish_image
#       cpu          = var.varnish_cpu
#       memory       = var.varnish_memory
#       DependsOn = [
#         {
#           condition = "COMPLETE"
#           containerName = "varnish-configuration-sidecar"
#         }
#       ]
#       mountPoints  = [
#         {
#           containerPath = "/etc/varnish"
#           sourceVolume = "varnish_configuration"
#           readOnly = true
#         }
#       ]
#       volumesFrom  = []
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group = "/aws/ecs/${var.prefix}-tileserv_cache"
#           awslogs-region = var.AWS_REGION_NAME
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#       essential    = true
#       portMappings = [
#         {
#           hostPort = var.varnish_port
#           # This port is the same that the contained application also uses
#           containerPort = var.varnish_port
#           protocol      = "tcp"
#         }
#       ]
#       # With Fargate, we use awsvpc networking, which will reserve a ENI (Elastic Network Interface) and attach it to
#       # our VPC
#       networkMode  = "awsvpc"
#       environment  = [
#         {
#           name = "VARNISH_SIZE"
#           value = "4G"
#         }
#       ]
#     }
#   ])
#   tags = merge(local.default_tags, {Name = "${var.prefix}-tileserv_cache-definition"})
# }

# Service can also be attached to a load balancer for HTTP, TCP or UDP traffic
resource "aws_ecs_service" "pg_tileserv" {
  name            = "${var.prefix}_pg_tileserv"
  cluster         = aws_ecs_cluster.pg_tileserv.id
  task_definition = aws_ecs_task_definition.pg_tileserv.arn
  desired_count   = 1

  # We run containers with the Fargate launch type. The other alternative is EC2, in which case we'd provision EC2
  # instances and attach them to the cluster.
  launch_type = "FARGATE"
  propagate_tags = "TASK_DEFINITION"

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

# resource "aws_ecs_service" "varnish" {
#   name            = "${var.prefix}_varnish"
#   cluster         = aws_ecs_cluster.pg_tileserv.id
#   task_definition = aws_ecs_task_definition.tileserv_cache.arn
#   desired_count   = 1

#   # We run containers with the Fargate launch type. The other alternative is EC2, in which case we'd provision EC2
#   # instances and attach them to the cluster.
#   launch_type = "FARGATE"
#   propagate_tags = "TASK_DEFINITION"

#   load_balancer {
#     target_group_arn = aws_lb_target_group.tilecache.arn
#     container_name   = "varnish-from-dockerhub"
#     container_port   = var.varnish_port
#   }

#   network_configuration {
#     # Fargate uses awspvc networking, we tell here into what subnets to attach the service
#     subnets          = aws_subnet.public.*.id
#     # Ditto for security groups
#     security_groups  = [aws_security_group.backend.id]
#     assign_public_ip = true
#   }

#   tags = merge(local.default_tags, {Name = "${var.prefix}-varnish-service"})
# }
