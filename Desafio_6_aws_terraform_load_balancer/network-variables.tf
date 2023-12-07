# 
variable "aws_us_east_2c" {
  type        = string
  description = "EE.UU. Este (Ohio) 2c"
  default     = "us-east-2c"
}

# 
variable "aws_us_east_2d" {
  type        = string
  description = "EE.UU. Este (Ohio) 2b"
  default     = "us-east-2b"
}

#
variable "vpc_cidr" {
  type        = string
  description = "VPC"  
}

# 
variable "private_network_cidr_1" {
  type        = string
  description = "private_network_cidr_1"
}

# 
variable "private_network_cidr_2" {
  type        = string
  description = "private_network_cidr_2"  
}

# 
variable "public_network_cidr_1" {
  type        = string
  description = "public_network_cidr_1"  
}

# 
variable "public_network_cidr_2" {
  type        = string
  description = "public_network_cidr_2"  
}