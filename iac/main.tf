provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "eacdemo_in" {
  name        = "eacdemo_in"
  description = "Allow HTTP inbound traffic on port 5000 and ssh"
  vpc_id      = "vpc-49a16723"

  ingress {
    from_port   = 22 
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000 
    to_port     = 5000
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
    Name = "sg eac"
  }
}

resource "aws_instance" "websrvs" {
  count         = 2
  ami           = "ami-0cc0a36f626a4fdf5"
  instance_type = "t2.micro"
  key_name      = "mhp_aws_dev"
  user_data     = "${file("spa-init.sh")}"
  vpc_security_group_ids = ["${aws_security_group.eacdemo_in.id}"]

  tags = {
    Name  = "eac-web${count.index}"
    Group = "eac-demo"
  }
}

resource "aws_elb" "eac-lb" {
  name               = "foobar-terraform-elb"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  listener {
    instance_port     = 5000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/0"
    interval            = 30
  }

  instances                   = ["${aws_instance.eac-web0.id}", "${aws_instance.eac-web1.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name  = "eac-lb"
    Group = "eac-demo"
  }
}


#resource "null_resource" "rmfile" {
#  provisioner "local-exec" {
#    command = "rm private_ips.txt"
#  }
#}

#resource "null_resource" "websrvs" {
#  count         = 2
#  provisioner "local-exec" {
#    command = "echo ${aws_instance.websrvs[count.index].private_ip} web${count.index}.add.sa web${count.index} >> private_ips.txt"
#  }
#}

#resource "aws_network_interface_sg_attachment" "sg_attachment-1" {
#  security_group_id    = "${aws_security_group.http_in.id}"
#  network_interface_id = "${aws_instance.web1.primary_network_interface_id}"
#}

#resource "aws_network_interface_sg_attachment" "sg_attachment-2" {
#  security_group_id    = "sg-0734769e8ad88ce52"
#  network_interface_id = "${aws_instance.web1.primary_network_interface_id}"
#}

#resource "null_resource" "web1" {
#  provisioner "file" {
#    source      = "web-init.sh"
#    destination = "/home/ubuntu/web-init.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "sudo chmod +x /home/ubuntu/web-init.sh",
#      "sudo /home/ubuntu/web-init.sh",
#    ]
#  }
#  connection {
#    type     = "ssh"
#    user     = "ubuntu"
#    private_key = file("mhp_aws_dev.pem")
#    host     = "${aws_instance.web1.private_ip}"
#  }
#}