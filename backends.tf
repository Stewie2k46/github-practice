terraform {
 backend "s3" {
  bucket = "ap-terraform-bucket-in"
  key = "path/to/project.tfstate"
  region = "ap-south-1"
 }
}