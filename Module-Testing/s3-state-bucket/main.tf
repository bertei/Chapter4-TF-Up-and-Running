provider "aws" {
  region = "us-east-1"
}

module "s3-state-bucket" {
    source = "../../Modules/s3-state-bucket"

    #Variables definition
    bucket-name = "btei-tfstate-bucket"
    dynamodb-table-name = "dynamodb-table-tf-state-lock"
}

terraform {
    backend "s3" {
        #S3 Config
        bucket = "btei-tfstate-bucket" #Name of the s3 bucket to use
        key = "global/s3/terraform.state" #The filepath within the s3 bucket where TF state file should be written.
        encrypt = true #Encrypt on disk when stored in s3, second layer of protection.

        #DynamoDB Config
        dynamodb_table = "dynamodb-table-tf-state-lock" #Name of dynamodb table to use for locking
    }
}