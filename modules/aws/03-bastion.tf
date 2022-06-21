######### INSTANCES #########

resource "aws_eip" "bastion" {
  depends_on = [module.ec2_bastion_host, module.vpc]
  instance = module.ec2_bastion_host.id
  vpc      = true

  tags = {
      Name = "bastion"
  }
}

module "ec2_bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.0.0"

  name = "BastionHost"

  ami                    = var.aws_ec2_instance_image
  instance_type          = var.aws_ec2_instance_type
  key_name               = aws_key_pair.custom_aws_ssh_key.key_name
  vpc_security_group_ids = [module.public_bastion_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name = "BastionHost"
  }
}

output "bastion" {
  value = aws_eip.bastion
}