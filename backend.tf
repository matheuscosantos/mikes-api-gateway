terraform {
  backend "s3" {
    bucket         = "mikes-terraform-state"
    key            = "mikes-gtw.tfstate"
    region         = "us-east-2"
    encrypt        = "true"
  }
}