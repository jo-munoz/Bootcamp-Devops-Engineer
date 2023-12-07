locals {
  ec2_subnet_list = [aws_subnet.private-network-1.id, aws_subnet.private-network-2.id]
}

resource "aws_instance" "linux-server" {
    count = var.ec2_count
    ami = "ami-0cf0e376c672104d6"
    instance_type = var.linux_instance_type
    subnet_id = element(local.ec2_subnet_list, count.index)
    vpc_security_group_ids      = [aws_security_group.aws-linux-security-group.id]
    associate_public_ip_address = false
    source_dest_check           = false
    key_name                    = aws_key_pair.key_pair_srv_linux.key_name
    user_data                   = file("aws-initialize.sh")

    // Disco base
    root_block_device {
        volume_size           = var.linux_root_volume_size
        volume_type           = var.linux_root_volume_type
        delete_on_termination = true
        encrypted             = true
    }	
}

resource "aws_security_group" "aws-linux-security-group" {
  name        = "linux security group"
  description = "Allow incoming HTTP connections"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "aws-linux-security-group"
    Environment = var.app_environment
  }
}