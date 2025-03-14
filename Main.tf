

resource "aws_key_pair" "Docker-keypair" {
  key_name   = "Docker-keypair"
  public_key = var.public_key
}

data "aws_vpc" "default" {
  default = true
}


# Create a security group for Terraform-project
resource "aws_security_group" "Docker-project-sg" {
  name        = "Docker-project-sg"
  description = "sg for Docker-project"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "Allow SSH"
    from_port   = 8000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Docker-project-sg"
  }
}


#Create an EC2 instance
resource "aws_instance" "Docker_instance" {
  ami           = var.ami # Amazon Linux 2 AMI
  instance_type = var.instance_type

  vpc_security_group_ids      = [aws_security_group.Docker-project-sg.id]
  associate_public_ip_address = true
  user_data = file("docker-script.sh")
  key_name = aws_key_pair.Docker-keypair.key_name

  connection {
  type = "ssh"
  user = "ec2-user"
  host = self.public_ip
  private_key = file("private_key.pem")
  }
  provisioner "file" {
  source = "Dockerfile"  
  destination = "/home/ec2-user/Dockerfile"
  }

  provisioner "file" {
  source = "coffeeshop-html"  
  destination = "/home/ec2-user/coffeeshop-html"
  }


  tags = {
    Name = "Docker_instance"
  }

  
}

