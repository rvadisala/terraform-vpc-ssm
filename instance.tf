resource "aws_key_pair" "patchdemo" {
  key_name   = "patchdemo"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}


data "aws_ami" "rhel7" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-7.7_HVM*"]
  }

}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.rhel7.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.PublicSubnet1.id
  key_name                    = aws_key_pair.patchdemo.key_name
  vpc_security_group_ids      = [aws_security_group.allow-ssh.id]
  monitoring                  = "true"
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.id

  ebs_block_device {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/bin/bash /tmp/script.sh",
    ]
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tags = {
    Name = "aws_patch_demo"
  }
}

output "PublicIPAddress" {
  value = aws_instance.instance.public_ip
}
