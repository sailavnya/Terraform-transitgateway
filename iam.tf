resource "aws_iam_role" "role_lab_flow_logs" {
  name = "role_lab_flow_logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "IAM_Role_Policy_for_Flow_Log" {
  name = "IAM_Role_Policy_for_Flow_Log"
  role = aws_iam_role.role_lab_flow_logs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_cloudwatch_log_group" "Transit_Gateway_Log_Group" {
  name              = "Transit_Gateway_Log_Group"
}
resource "aws_flow_log" "flow_log_tgw_lab" {
  iam_role_arn    = aws_iam_role.role_lab_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.Transit_Gateway_Log_Group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.VPC_A.id

  tags = {
    Name = "flow_log_tgw_lab"
  }
}
