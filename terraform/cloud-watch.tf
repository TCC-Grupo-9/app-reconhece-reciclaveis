# # CloudWatch Log Group para API
# resource "aws_cloudwatch_log_group" "log_group_api" {
#   name              = "/ecs/api_reconhecimento"
#   retention_in_days = 7
#   tags = {
#     Name        = "log-group-api_reconhecimento"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }

# # CloudWatch Alarms para CPU e Memória da API
# resource "aws_cloudwatch_metric_alarm" "cpu_high_api" {
#   alarm_name          = "high-cpu-api_reconhecimento"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ECS"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 80
#   alarm_description   = "Alerta quando a utilização de CPU exceder 80%."
#   dimensions = {
#     ClusterName = aws_ecs_cluster.tcc_reconhecimento.name
#     ServiceName = aws_ecs_service.service-api_reconhecimento.name
#   }
#   tags = {
#     Name        = "cpu-high-api"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "memory_high_api" {
#   alarm_name          = "high-memory-api_reconhecimento"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   metric_name         = "MemoryUtilization"
#   namespace           = "AWS/ECS"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 80
#   alarm_description   = "Alerta quando a utilização de memória exceder 80%."
#   dimensions = {
#     ClusterName = aws_ecs_cluster.tcc_reconhecimento.name
#     ServiceName = aws_ecs_service.service-api_reconhecimento.name
#   }
#   tags = {
#     Name        = "memory-high-api"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }

# # CloudWatch Alarms para Status de Tarefa
# resource "aws_cloudwatch_metric_alarm" "running_task_count" {
#   alarm_name          = "low-task-count"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "RunningTaskCount"
#   namespace           = "AWS/ECS"
#   period              = 60
#   statistic           = "Minimum"
#   threshold           = 1
#   alarm_description   = "Alerta quando o número de tarefas em execução for menor que 1."
#   dimensions = {
#     ClusterName = aws_ecs_cluster.tcc_reconhecimento.name
#     ServiceName = aws_ecs_service.service-api_reconhecimento.name
#   }
#   tags = {
#     Name        = "low-task-count"
#     Product     = "tcc"
#     Environment = "prod"
#   }
# }
