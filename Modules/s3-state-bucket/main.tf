#terraform {
#    backend "s3" {
#        #S3 Config
#        bucket = "btei-tfstate-bucket" #Name of the s3 bucket to use
#        key = "global/s3/terraform.state" #The filepath within the s3 bucket where TF state file should be written.
#        encrypt = true #Encrypt on disk when stored in s3, second layer of protection.
#
#        #DynamoDB Config
#        dynamodb_table = "dynamodb-table-tf-state-lock" #Name of dynamodb table to use for locking
#    }
#}

#S3 bucket resource
resource "aws_s3_bucket" "terraform-state-bucket" {
    #Bucket names in AWS must be globally unique.
    bucket = var.bucket-name

    #Prevent accidental deletion
    lifecycle {
        prevent_destroy = false
    }
}

#S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform-state-bucket-versioning" {
    bucket = aws_s3_bucket.terraform-state-bucket.id
    #Every update to a file creates a new version of that file with versioning
    versioning_configuration {
        status = "Enabled"
    }
}

#This resource turns server-side encryption on by default for all data written to the s3 bucket.
#Ensures that the state file and any secret it might contain are always encrypted on disk when stored in s3.
resource "aws_s3_bucket_server_side_encryption_configuration" "s3-svside-encryption" {
    bucket = aws_s3_bucket.terraform-state-bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

#Resource to block all public access to s3 bucket. Extra layer of protection to ensure none accidentally makes this bucket public.
resource "aws_s3_bucket_public_access_block" "block-public-access" {
    bucket = aws_s3_bucket.terraform-state-bucket.id
    block_public_acls = true #Block public access control lists
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

#DynamoDB table for locking tf state file
resource "aws_dynamodb_table" "dynamodb-table-terraform-lock" {
    name = var.dynamodb-table-name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}


