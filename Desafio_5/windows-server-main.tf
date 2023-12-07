resource "aws_instance" "windows-server" {
    ami = "ami-09e14f3154e091177" // Instancia EC2 Windows Base (dist), imagen base del S.O
    instance_type = var.windows_instance_type
    source_dest_check = false // Lance la instancia no valida el estado
    vpc_security_group_ids = [aws_security_group.aws-windows-server-sg.id]
	key_name = "aws-windows-server-kp"

	// Disco base
    root_block_device {
        volume_size = var.windows_root_volume_size
        volume_type = var.windows_root_volume_type
        delete_on_termination = true
        encrypted = true
    }

	tags = {
		Name = "${lower(var.app_name)}-${var.app_environment}-windows-server"
		Environment = var.app_environment
	}
}

resource "aws_security_group" "aws-windows-server-sg" {
    name = "aws-windows-server-sg"
    description = "Allow incoming connections"

    ingress{
        from_port   = 80
        to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow incoming HTTP connections"
    } 

    ingress {
		from_port   = 3389
		to_port     = 3389
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Allow incoming RDP connections"
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
		Name = "${lower(var.app_name)}-${var.app_environment}-windows-server"
		Environment = var.app_environment
	}
}
