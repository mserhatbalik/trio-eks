######### VPC #########

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = var.aws_vpc_name
  cidr = var.aws_vpc_cidr

    # Mevcut AZ isimlerinin listesini çekip yalnızca belirttiğimiz AZ count kadarını slice edip liste olarak paslıyoruz.
    #azs = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
    azs = slice(data.aws_availability_zones.available.names,0, var.aws_az_count)
   

    # DAHA SONRASINDA BU KISMIDA CIDRSUBNET ILE DINAMIK HALE GETIR. SIMDI YAPMAMAMIN SEBEBI SECURITY GROUPLAR FILAN GIRECEK ISIN ICINE KARISMASIN.
    private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets      = ["10.0.11.0/24", "10.0.12.0/24"]


  # Öncelikle Public subnetlerde NAT gateway oluşturulmasını istiyoruz. İkinci argümanda ise yalnızca tek bir NAT GATEWAY oluşturulmasını istiyoruz. 
  # Eğer bu parametreyi false geçersen her bir public subnetin kendine ait NAT GATEWAY'i ve ona ait ROUTE TABLE associations tablosu yaratılacak. 
  # High availability için multiple önemli. 
  enable_nat_gateway = true
  single_nat_gateway = true


  # VPC içerisinde öncelikli olarak DNS supportu açıyoruz ve ikinci opsiyonda ise hostlara DNS atamasını aktifleştiriyoruz.
  enable_dns_support = true
  enable_dns_hostnames = true


  # İlgili subnet taglerini veriyoruz. İstediğin gibi isimlendirebilirsin.
  public_subnet_tags = {
      Name = "${var.aws_vpc_name}-public-subnet"
      "kubernetes.io/cluster/${var.aws_eks_cluster_name}-${var.aws_environment}" = "shared"
      "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
      Name = "${var.aws_vpc_name}-private-subnet"
      "kubernetes.io/cluster/${var.aws_eks_cluster_name}-${var.aws_environment}" = "shared"
      "kubernetes.io/role/internal-elb" = 1
  }

  vpc_tags = {
      Name = "test-vpc"
  }

  # Kendinle alakalı custom tagler yaratıyoruz
  tags = {
      Owner = "Serhat Balık"
      Environment = "Development"
  }
}

data "aws_availability_zones" "available" {
    # state = "available"
}

output "azs" {
  value = data.aws_availability_zones.available
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}