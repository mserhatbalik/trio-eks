######### BACKEND & MODULES #########

terraform {
  # Remote state özelliğini aktif hale getirmek için bu kısımı yazıyoruz. Daha öncesinde "remote-state-storage-4895135" isimli s3 kaynağını AWS console'dan yaratman gerekiyor ilgili regionda. Belki ek olarak DynamodDB eklenebilir eğer state locking özelliği otomatik olarak konfigüre olmuyor ise sadece bu opsiyonlar ile. 
  backend "s3" {
    bucket = "remote-state-storage-4895135"
    key    = "trio-eks-cluster/state.tfstate"
    region = "eu-central-1"

    # State Locking
    dynamodb_table = "trio-eks-cluster-lock-table"
  }
}

module "digital_ocean" {
    source = "./modules/digitalocean"

    do_region        = "ams3"
    do_droplet_image = "ubuntu-20-04-x64"
    do_droplet_type  = "s-4vcpu-8gb"
    do_droplet_names = ["jenkins", "nexus"]
    do_vpc_cidr      = "10.0.40.0/24"
    do_vpc_name      = "jenkins-nexus-vpc"
    do_token = var.do_token
    do_ssh_key = var.do_ssh_key

    aws_nat_ips = "${module.aws.nat_public_ips}"
    aws_bastion_ip = "${module.aws.bastion.public_ip}"
}

module "aws" {
    source = "./modules/aws"

    aws_vpc_name = "eks-vpc"
    aws_vpc_cidr = "10.0.0.0/16"
    aws_region = "eu-central-1"
    aws_az_count = 2
    aws_ssh_key = var.aws_ssh_key
    aws_ec2_instance_image = var.aws_ec2_instance_image
    aws_ec2_instance_type = "t2.medium"
    aws_eks_cluster_name = "trio-eks"
    aws_environment = "dev"
    eks_oidc_root_ca_thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
    eks_ecr_addon_registry = "602401143452.dkr.ecr.eu-central-1.amazonaws.com"
}