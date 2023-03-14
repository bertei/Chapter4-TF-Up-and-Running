provider "aws" {
    region = "us-east-1"
}

module "webserver-dev" {
    source = "/Users/bernardo.teisceira/Desktop/TerraformUpRunning/Chapter4-TF-Up-and-Running/Modules/services/webserver-cluster"

    server_port = "8080"
    alb_name = "test-lb"
    instance_security_group_name = "test-ec2-sg"
    alb_security_group_name = "test-sg-lb"
    env = "dev"
    db_remote_state_bucket = "btei-tfstate-bucket"
    db_remote_state_key = "dev/data-stores/mysql/terraform.tfstate"
    instance_type = "t2.micro"
    min_size = 1
    max_size = 2
    desired_capacity = 2

    #Defining the map(string). Key = value
    custom_tags= {
        Owner       =   "team-foo"
        ManagedBy   =   "terraform"
    }
}

terraform {
    backend "s3" {
        bucket  = "btei-tfstate-bucket"
        key     = "dev/webserver/terraform.tfstate"
        encrypt = true

        dynamodb_table = "dynamodb-table-tf-state-lock"
    }
}