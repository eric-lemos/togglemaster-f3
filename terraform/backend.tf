terraform {
  backend "s3" {
    bucket       = "bkt-togglemaster-tfstate"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
