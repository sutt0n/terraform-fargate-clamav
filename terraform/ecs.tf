
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "clamav_fargate_execution_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "clamav_fargate_task_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "s3_task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_ecs_cluster" "cluster" {
  name = "clamav_fargate_cluster"

  capacity_providers = ["FARGATE"]
}

data "template_file" "task_consumer_east" {
  template = file("./templates/clamav_container_definition.json")

  vars = {
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_ecs_task_definition" "definition" {
  family                   = "clamav_fargate_task_definition"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "2048"
  requires_compatibilities = ["FARGATE"]

  container_definitions = data.template_file.task_consumer_east.rendered

  depends_on = [
    aws_iam_role.ecs_task_role,
    aws_iam_role.ecs_task_execution_role
  ]
}

resource "aws_ecs_service" "clamav_service" {
  name            = "clamav_service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false

    subnets = [
      aws_subnet.private.id
    ]

    security_groups = [
      aws_security_group.egress-all.id
    ]
  }
}
