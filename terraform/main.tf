provider "aws" {
  //variables a cambiar en vars.tf
  //son las credenciales de acceso a nuestro AWS
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}
resource "aws_vpc" "VPC_IRAC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC_EC2_IRAC"
  }
}

resource "aws_subnet" "subnet_IRAC" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.VPC_IRAC.id}"
  tags = {
    Name = "Subnet_EC2_IRAC"
  }
}

resource "aws_internet_gateway" "IG_IRAC" {
  vpc_id = "${aws_vpc.VPC_IRAC.id}"
  tags = {
    Name = "GW_EC2_IRAC"
  }
}

resource "aws_route_table" "RT_IRAC" {
  vpc_id = "${aws_vpc.VPC_IRAC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IG_IRAC.id}"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = "${aws_subnet.subnet_IRAC.id}"
  route_table_id = "${aws_route_table.RT_IRAC.id}"
}

resource "aws_security_group" "SG_IRAC" {
  vpc_id = "${aws_vpc.VPC_IRAC.id}"
  name = "SecurityGroup_EC2_IRAC"

//puertos a abrir en la EC2
//SSH
  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "22"
    to_port     = "22"
  }
//RDP
  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "3389"
    to_port     = "3389"
  }
//WebRTC
  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8080"
    to_port     = "8080"
  }
//Trafico saliente
  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    to_port     = "0"
  }

}

resource "aws_network_interface" "NI_IRAC" {
   subnet_id       = aws_subnet.subnet_IRAC.id
   private_ips     = ["10.0.1.60"]
   security_groups = [aws_security_group.SG_IRAC.id]

 }

 resource "aws_eip" "EIP_IRAC" {
   vpc                       = true
   network_interface         = aws_network_interface.NI_IRAC.id
   associate_with_private_ip = "10.0.1.60"
   depends_on                = [aws_internet_gateway.IG_IRAC]
 }


resource "aws_instance" "IRAC" {
    
    instance_type = "t2.medium"
    ami = "${var.ami}"
    key_name = "${var.key_pair}"
    network_interface {
     device_index         = 0
     network_interface_id = aws_network_interface.NI_IRAC.id
   }
   //codigo que se ejecutara nada mas crear la instancia
   //para descargarnos las dependencias necesarias
        user_data = <<-EOF
        <powershell>
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        choco install -y git
        choco install -y --force nodejs
        </powershell>
        EOF

    tags = {
        name = "EC2_IRAC"
    }
}