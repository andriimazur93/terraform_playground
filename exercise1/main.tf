provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "prod-vpc" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "Project VPC"
 }
}

resource "aws_subnet" "prod-subnet-public-1" {
	vpc_id = "${aws_vpc.prod-vpc.id}"
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = "true"
	availability_zone = "us-east-1a"
	
	tags = {
		Name = "prod-subnet-public-1"
	}
}

resource "aws_internet_gateway" "prod-igw" {
	vpc_id = "${aws_vpc.prod-vpc.id}"
	tags = {
		Name = "prod-igw"
	}
}

resource "aws_route_table" "prod-public-crt" {
	vpc_id = "${aws_vpc.prod-vpc.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.prod-igw.id}"
	}
	
	tags = {
		Name = "prod-public-crt"
	}
}

resource "aws_route_table_association" "prod-crta-public-subnet-1" {
	subnet_id = "${aws_subnet.prod-subnet-public-1.id}"
	route_table_id = "${aws_route_table.prod-public-crt.id}"
}

resource "aws_security_group" "ssh-allowed" {
	vpc_id = "${aws_vpc.prod-vpc.id}"
	
	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	tags = {
		Name = "ssh-allowed"
	}
}
resource "aws_instance" "web1" {
    ami = "${lookup(var.ami, var.aws_region)}"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
    # the Public SSH key
    key_name = "${aws_key_pair.london-region-key-pair.id}"
    # nginx installation
    provisioner "file" {
        source = "nginx.sh"
        destination = "/tmp/nginx.sh"
    }
    provisioner "remote-exec" {
        inline = [
             "chmod +x /tmp/nginx.sh",
             "sudo /tmp/nginx.sh"
        ]
    }
    connection {
        user = "${var.EC2_USER}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
		host = "self.public_ip"

    }
}
// Sends your public key to the instance
resource "aws_key_pair" "london-region-key-pair" {
    key_name = "london-region-key-pair"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}