# Locals
locals {
  common_name = "${var.environment}-${var.application_name}"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-vpc"
    }
  )
}

# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-igw"
    }

  )
}

# Public Private and DB Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zone[count.index]
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-public-subnet-${split("-", var.availability_zone[count.index])[2]}"
    }
  )
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone[count.index]
  cidr_block        = var.private_subnet_cidr_blocks[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-private-subnet-${split("-", var.availability_zone[count.index])[2]}"
    }
  )
}

resource "aws_subnet" "db_subnets" {
  count             = length(var.db_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone[count.index]
  cidr_block        = var.db_subnet_cidr_blocks[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-db-subnet-${split("-", var.availability_zone[count.index])[2]}"
    }
  )
}

# DB asubnet group
resource "aws_db_subnet_group" "default" {
  name       = "${local.common_name}-db-subnet-group"
  subnet_ids = [for db_subnets in aws_subnet.db_subnets : db_subnets.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-db-subnet-group"
    }

  )
}

# Route Table for Public Private and DB Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-Public-RT"
    }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-Private-RT"
    }
  )
}

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-DB-RT"
    }
  )
}
# Subnet Route Table Associations
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "db_subnet_association" {
  count          = length(aws_subnet.db_subnets)
  subnet_id      = aws_subnet.db_subnets[count.index].id
  route_table_id = aws_route_table.db_rt.id
}

# EIP
resource "aws_eip" "eip_nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-eip"
    }
  )
}
# NatGW
resource "aws_nat_gateway" "example" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.eip_nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.gw]
}

# Routes
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route" "private_nat_route" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[count.index].id
}

resource "aws_route" "db_nat_route" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.db_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[count.index].id
}

# VPC Flow Logs CloudWatch

data "aws_iam_policy_document" "assume_role" {
  count = var.enable_vpc_flow_logs_cw ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  count              = var.enable_vpc_flow_logs_cw ? 1 : 0
  name               = "${local.common_name}-vpc-flow-logs-role-cw"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "example" {
  count = var.enable_vpc_flow_logs_cw ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  count  = var.enable_vpc_flow_logs_cw ? 1 : 0
  name   = "${local.common_name}-vpc-flow-logs-role-cw-policy"
  role   = aws_iam_role.example[0].id
  policy = data.aws_iam_policy_document.example[0].json
}
resource "aws_flow_log" "example" {
  count           = var.enable_vpc_flow_logs_cw ? 1 : 0
  iam_role_arn    = aws_iam_role.example[0].arn
  log_destination = aws_cloudwatch_log_group.example[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    {
      Name = "${local.common_name}-vpc-flow-logs-role-cw"
    }
  )
}

resource "aws_cloudwatch_log_group" "example" {
  count = var.enable_vpc_flow_logs_cw ? 1 : 0
  name  = "${local.common_name}-vpc-flow-logs-role-cw"
   lifecycle {
    prevent_destroy = false
  }
}


