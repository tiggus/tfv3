module "website_s3_bucket" {
  source = "./modules/aws-s3"
  bucket_name = "39393939393-bucket-39"

  tags = {
    terraform   = "true"
    environment = "dev"
  }
}
