resource "aws_key_pair" "my_key" {
  key_name = "${var.env}-terra-ansible"
  public_key = file("terra-ansible.pem.pub")
  tags = {
    Environment = var.env
  }
}

resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "my_secgroup" {
  name = "${var.env}-autmate-sg"
  description = "for tf-ansible"
  vpc_id = aws_default_vpc.default.id

  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "ssh open"
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "http open"
  } 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "all access open outbound"
  }
}

resource "aws_instance" "my_instance" {
  for_each = tomap({
    demo1="ami-0b6c6ebed2801a5cb",
    demo2="ami-0ad50334604831820",
    demo3="ami-0c1fe732b5494dc14"

  })

  depends_on = [ aws_security_group.my_secgroup, aws_key_pair.my_key, aws_default_vpc.default ]
  key_name = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_secgroup.name]
  ami = each.value
  instance_type = "t3.micro"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  tags = {
    Name = each.key
    Environment = var.env
  }
}
