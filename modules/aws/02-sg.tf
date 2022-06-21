######### SECURITY GROUPS #########

module "public_bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "public_bastion_security_group"
  description = "SSH ingress and 0.0.0.0/0 egress Security group for the Bastion server provisioned in public subnet"
  vpc_id      = module.vpc.vpc_id

  # Ingress Rules. 22-80-443 Portunu tüm internetten inbound şekilde kabul ediyoruz. Preset rulelar modülün sayfasındaki "inputs" kısmında yazıyor.
  ingress_rules = ["ssh-tcp", "http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # Egress Rules. Bastion hostundan tüm internete ve iç network VPC'ye tüm portlar üzerinden outbound erişim izni veriyoruz.
  egress_rules = [ "all-all" ]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
      Name = "BastionSG"
  }
}