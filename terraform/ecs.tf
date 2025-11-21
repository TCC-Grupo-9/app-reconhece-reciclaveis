# # Clusters
# resource "aws_ecs_cluster" "tcc_reconhecimento" {
#   name = "tcc_reconhecimento"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }

#   tags = {
#     Name        = "ecs-tcc_reconhecimento"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }

# # Task Definitions
# resource "aws_ecs_task_definition" "task-api_reconhecimento" {
#   family                   = "api_reconhecimento"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "512"
#   memory                   = "1024"

#   container_definitions = jsonencode([
#     {
#       name      = "api_reconhecimento",
#       image     = "uken49/api-reconhecimento:latest",
#       cpu       = 0,
#       memory    = 1024,
#       essential = true,
#       portMappings = [
#         {
#           containerPort = 8000
#           hostPort      = 8000
#           protocol      = "tcp"
#           appProtocol   = "http"
#         }
#       ]
#     }
#   ])

#   tags = {
#     Name        = "task-api_reconhecimento"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }

# # Services
# resource "aws_ecs_service" "service-api_reconhecimento" {
#   name            = "api_reconhecimento"
#   cluster         = aws_ecs_cluster.tcc_reconhecimento.id
#   task_definition = aws_ecs_task_definition.task-api_reconhecimento.arn
#   desired_count   = 2
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets = [
#       aws_subnet.public-tcc-east_1a.id,
#       aws_subnet.public-tcc-east_1a.id
#     ]
#     security_groups  = [aws_security_group.sg-backend.id]
#     assign_public_ip = false
#   }

#   tags = {
#     Name        = "service-api_reconhecimento"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }