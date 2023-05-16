variable "aws_access_key" {
	type = string
	description = "AWS access key"
}

variable "aws_secret_key" {
	type = string
	description = "AWS secret key"
}

variable "aws_region" {
	type = string
	description = "AWS region"
}

variable "PUBLIC_KEY_PATH" {
	type = string
	description = "path to key"
}

variable "EC2_USER" {
	type = string
	description = "ec2 user"
}


variable "PRIVATE_KEY_PATH" {
	type = string
	description = "path to private key"
}
variable "ami" {
	type = map
	
	default = {
		eu-west-2 = "ami-03dea29b0216a1e03"
        us-east-1 = "ami-0c2a1acae6667e438"
	}
}