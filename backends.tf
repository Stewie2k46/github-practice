terraform {
 backend "s3" {
  bucket = "ap-south-chetan-bucket"
  key = "rohan/project.tfstate"
  region = "ap-south-1"
 }
}