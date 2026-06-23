data "aws_caller_identity" "current" {}

#####################################
# Terraform Execution Role
#####################################

resource "aws_iam_role" "terraform_execution" {

  name = "TerraformExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_admin" {

  role = aws_iam_role.terraform_execution.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#####################################
# Platform Admin Role
#####################################

resource "aws_iam_role" "platform_admin" {

  name = "PlatformAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "platform_admin" {

  role = aws_iam_role.platform_admin.name

  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

#####################################
# ReadOnly Role
#####################################

resource "aws_iam_role" "readonly" {

  name = "ReadOnlyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "readonly" {

  role = aws_iam_role.readonly.name

  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
