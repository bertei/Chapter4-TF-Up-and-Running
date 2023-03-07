variable "bucket-name" {
  type  = string
  description = "Name for the aws s3 bucket"
}

variable "dynamodb-table-name" {
  type  = string
  description = "Name for the aws s3 dynamodb table, to be used for the state lock"
}