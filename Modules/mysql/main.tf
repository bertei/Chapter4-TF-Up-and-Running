resource "aws_db_instance" "example-db" {
    identifier_prefix = var.identifier_prefix
    engine = "mysql"
    allocated_storage = 20
    instance_class = "db.t2.micro"
    skip_final_snapshot = true
    db_name = var.db_name 

    #User config
    username = var.db_username 
    password = var.db_password 
}