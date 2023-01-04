# We don't want to create the key in terraform. Otherwise the private key would be saved in terraform state.
# Let's save the key here as ec2 instance user data.

# Just the smallest arm instance available
resource "aws_instance" "bastion-ec2-instance" {
  ami = "ami-0854da2f8540b70a2" # Amazon Linux 2
  instance_type = "t4g.nano"
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-iam-profile.name
  tenancy              = "default"
  user_data     = templatefile(
    "bastion_user_data.tpl",
    {bastion_public_key = "${var.bastion_public_key}"}
    )

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-bastion"
  })
}
