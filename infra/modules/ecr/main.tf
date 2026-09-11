
# ECR

resource "aws_ecr_repository" "gatus" {
  name = "gatus-terraform"
  force_delete = true

}

