#### DIGITAL OCEAN VARIABLES ####
////////////////////////////////////////////////////
# Default değişkenleri burada tanımlıyoruz. Burada tanımları yapmak zorundayız. Bu sayede kod içerisindeki değişkenler defined edilmişi oluyor. Ayrıca bu yaptığımız tanımlarda .tfvars dosyasındakiler ile eşleşiyor. Köprü gibi düşünebilirsin 3 koldan bağlı. 

# DigitalOcean'a export ile geçtiğimiz API tokenin değişken ismi. Aşağıdaki provider bloğunda da buna referans veriyoruz.. Eğer export yapmazsan her apply-destroy işlemi sırasında konsoldan manuel olarak girmeni istiyor DigitalOcean acces API token'ı terraform.
variable "do_token" {}

# DigitalOcean default regionımız. Hatta bunu droplet isimlendirmesinde prefix olarak kullanıyorsun..
variable "do_region" {
  type    = string
  default = "ams3"
}

# DigitalOcean'da yarattığın droplet tipi..
variable "do_droplet_type" {
  type    = string
  default = "s-1vcpu-1gb"
}

# DigitalOcean'da yarattığın dropletlerin image tipi..
variable "do_droplet_image" {
  type = string
  default = "ubuntu-20-04-x64"
}

# DigitalOcean'da yarattığın dropletlerin listesi. TFVARs ile bu isimleri bir LIST olarak geçiyorsun. Liste ne kadar uzunsa, o kadar miktarda COUNT saydırarak ve herbir listeki elemanın INDEX'i alınarak o kadar miktarda droplet yaratılıyor...
variable "do_droplet_names" {
  type    = list(any)
  default = ["my-droplet"]
}

# DigitalOcean'da yarattığın SUBNET. AWS'deki gibi 2 layer yok burada gördüğüm kadarıyla. O yüzden kafanı karıştırmasın...
variable "do_vpc_cidr" {
  type    = string
  default = "10.0.0.0/8"
}

# DigitalOcean'da yarattığın SUBNET'in ismi..
variable "do_vpc_name" {
  type    = string
  default = "custom-vpc"
}

variable "do_ssh_key" {
  type = string
  default = "/home/serhat/.ssh/id_rsa.pub"
}

#### AWS VARIABLES ####
////////////////////////////////////////////////////
variable "aws_environment" {
  type    = string
  default = "test"
}

variable "aws_vpc_name" {
  type    = string
  default = "custom-vpc"
}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_az_count" {
  type    = number
  default = 1
}

variable "aws_ssh_key" {
  type = string
  default = "/home/serhat/.ssh/id_rsa.pub"
}

variable "aws_ec2_instance_image" {
  type = string
  default = "ami-0d527b8c289b4af7f"
}

variable "aws_ec2_instance_type" {
  type = string
  default = "t2.nano"
}

variable "aws_nat_ips" {
  type = list
  default = ["0.0.0.0"]
}

variable "aws_bastion_ip" {
  type = list
  default = ["0.0.0.0"]
}


##### EKS SPECIFIC ######

variable "aws_eks_cluster_name" {
  type = string
  default = "eks-demo"
}

# EKS OIDC ROOT CA Thumbprint - valid until 2037
variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

# ECR Domain (Changes depending on region)
variable "eks_ecr_addon_registry" {
  type        = string
  default     = "602401143452.dkr.ecr.eu-central-1.amazonaws.com"
}