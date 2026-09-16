terraform {
  backend "s3" {
    bucket       = "gatus-ecs-terraform-state"
    key          = "gatus/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}