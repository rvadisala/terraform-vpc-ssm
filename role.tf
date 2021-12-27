#Instance Role
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ssm-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = "test-ssm-ec2"
    Owner       = "DevSecOps"
    Project     = "terraform"
    environment = "test"
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ssm-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.id
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "ssm_attach1" {
  name       = "ssm-attachment"
  roles      = [aws_iam_role.ec2_ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ssm_attach2" {
  name       = "ssm-attachment"
  roles      = [aws_iam_role.ec2_ssm_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

