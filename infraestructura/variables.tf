variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "az" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami" {
  type = string
  description = "Ubuntu AMI"
  default  = "ami-0866a3c8686eaeeba"
}

variable "env" {
  type = string
  description = "Environment"
  default = "DEV"
}

variable "db_password" {
  type = string
  description = "Password for rds"
  default = "test_password"
  sensitive = true
}

variable "ssh_key_path" {
  type = string
  description = "Ssh ke to configure the instances"
  default = "~/.ssh/franquicias-manager-key.pub"
}
