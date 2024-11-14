provider "aws" {
  region = "us-east-1"
}

# Create Security Group for EC2 Instances
resource "aws_security_group" "nhom20_security_group" {
  name        = "Nhom20SecurityGroup"
  description = "Allow inbound traffic for Jenkins, SonarQube, and Docker"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere, restrict in production
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SonarQube
  }

  ingress {
    from_port   = 2375
    to_port     = 2375
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Docker
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 AMI in us-east-1, update if using a different region
  instance_type = "t2.micro"
  security_groups = [aws_security_group.nhom20_security_group.name]

  tags = {
    Name = "Nhom20Jenkins"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update packages and install Java
              sudo apt update -y
              sudo apt install -y openjdk-11-jdk

              # Install Jenkins
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt update -y
              sudo apt install -y jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF
}

# Create SonarQube EC2 Instance
resource "aws_instance" "sonarqube" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.nhom20_security_group.name]

  tags = {
    Name = "Nhom20SonarQube"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update packages and install Java
              sudo apt update -y
              sudo apt install -y openjdk-11-jdk

              # Install SonarQube (requires PostgreSQL if a database is needed)
              sudo apt install -y wget unzip
              wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.0.43852.zip
              sudo unzip sonarqube-8.9.0.43852.zip -d /opt
              sudo mv /opt/sonarqube-8.9.0.43852 /opt/sonarqube
              sudo useradd sonar
              sudo chown -R sonar:sonar /opt/sonarqube
              sudo su - sonar -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"
              EOF
}

# Create Docker EC2 Instance
resource "aws_instance" "docker" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.nhom20_security_group.name]

  tags = {
    Name = "Nhom20Docker"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update packages and install Docker
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl enable docker
              sudo systemctl start docker
              EOF
}
