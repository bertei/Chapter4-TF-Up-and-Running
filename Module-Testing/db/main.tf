provider "aws" {
    region = "us-east-1"
}

module "db-test" {
    source = "../../Modules/mysql"

    #Variables definition
    identifier_prefix = "example-db"
    db_name = "exampleMysqlDB"
    db_username = "test" #hardcoded for testing purposes
    db_password = "testing123" #hardcoded for testing purposes
}

terraform {
    backend "s3" {
        bucket  = "btei-tfstate-bucket"
        key     = "dev/data-stores/mysql/terraform.tfstate"
        encrypt = true

        dynamodb_table = "dynamodb-table-tf-state-lock"
    }
}