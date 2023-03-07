variable "identifier_prefix" {
    type        =  string
    description = "Creates a unique identifier beginning with the specified prefix"
}

variable "db_name" {
    type = string
    description = "The name of the database to create when the DB instance is created"
}

variable "db_username" {
    type = string
    description = "Username for the master DB user. Cannot be specified for a replica."
}

variable "db_password" {
    type = string
    description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."  
}