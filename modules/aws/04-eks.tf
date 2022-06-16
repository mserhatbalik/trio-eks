####### IAM ROLES CONTROL PLANE ########

# Create IAM Role for the CONTROL PLANE

# ASSUME ROLE POLICY tanımlamamızın sebebi hangi kaynakların bu ROLE'u assume edebileceği konusunda kural belirtmektir.
#EKS Control Plane'in bizim VPC'de gerekli işleri yapabilmesi için ilgili ROLE'u tanımlıyoruz. Tabi bunu tanımlamak tek başına yeterli değil.
# Ek olarak aşağıdaki POLICY'leri de bu ROLE'e attach ediyoruz. Bir bakıma YETKİ GENİŞLETMESİ yapıyoruz. Daha sonra bu ROLE'u muhtemelen ESK Cluster konfigürasyonunda kullanacağız.
resource "aws_iam_role" "eks_master_role" {
  name = "${var.aws_eks_cluster_name}-eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# EKS Control Plane'in Worker Nodelar üzerinde tüm işlemleri yapabilmesi için ihtiyacı olan policyi yukarıda tanımladığımız role'e attach ediyoruz.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

# EKS Control Plane'in bizim VPC'mizde EKS tarafından ihtiyaç duyulan network konfigürasyonunu yapabilmesi için ihtiyacı olan policyi role'e attach ediyoruz.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

############# CREATE EKS CLUSTER #############
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.aws_eks_cluster_name}-${var.aws_environment}"
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.21"

  vpc_config {

    ##### EĞER ÇALIŞMAZ İSE PUBLIC SUBNETI DE DAHIL ET ##### Sanırım EKS Elastic Network Interfaceler bu sayede yaratılıyor ilgili SUBNETTE. Node grupların da SUBNET'ini aynı şekilde belirtmen bu yüzden önemli.
    subnet_ids = module.vpc.private_subnets

    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = false

    # Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
    endpoint_public_access  = true

    # List of CIDR blocks which can access the Amazon EKS public API server endpoint.
    public_access_cidrs     = ["0.0.0.0/0"]  
  }

  kubernetes_network_config {
    # Service ipv4 cidr for the kubernetes cluster
    service_ipv4_cidr = "172.20.0.0/16"
  }
  
  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}