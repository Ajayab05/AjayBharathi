data "terraform_remote_state" "vpc" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/network/vpc.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "sg" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/network/security-groups.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "iam" {

  backend = "s3"

  config = {
    bucket = "ajay-platform-076124125794-prod-tfstate"
    key    = "env/prod/platform/eks-iam.tfstate"
    region = "us-east-1"
  }
}
