locals {
  # IAM Role Name: formatted as TitleCase without dashes
  name = "${title(replace(var.environment, "-", ""))}${title(replace(var.project_name, "-", ""))}${title(replace(var.role_name, "-", ""))}"

  # IAM Policy Name: same logic
  policy_name = "${title(replace(var.environment, "-", ""))}${title(replace(var.project_name, "-", ""))}${title(replace(var.policy_name, "-", ""))}"
}

resource "aws_iam_role" "this" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = merge(
    var.common_tags,
    {
      Name = local.name
    }
  )
}

resource "aws_iam_instance_profile" "backend_profile" {
  name = local.name
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy" "inline_policy" {
  name   = local.policy_name
  role   = aws_iam_role.this.id
  policy = file(var.policy_file)
}


