####### IAM ROLES WORKERS ########

# ASSUME ROLE POLICY tanımlamamızın sebebi hangi kaynakların bu ROLE'u assume edebileceği konusunda kural belirtmektir.
# Burada ise kendi VPC'indeki subnetlerde çalışacak olan WORKER NODELARIN ihtiyacı olan ROLE tanımlaması ve gerekli POLICY attachmentları yapıyoruz.
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.aws_eks_cluster_name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Worker Nodeların EKS Clustera Join edebilmesi için gerekli.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Amazonun kendi Kubernetes Network Pluginini (Amazon VPC CNI) kurarak konfigüre edebilmesi için gerekli izin.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Worker Nodeların içerisindeki Docker daemonların IMAGE pull için kullandığı default registry Amazon ECR'dır. Buna erişim için de izin vermemiz gerekiyor.
resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

####### WORKER NODES ########

# Create AWS EKS Node Group - Private
resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${var.aws_eks_cluster_name}-eks-ng-private"

  # Worker nodelar için yarattığın ROLE'u attach ediyoruz.
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn

  # Worker Nodeların ayağa kalkacağı SUBNET.
  subnet_ids      = module.vpc.private_subnets
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 20
  instance_types = ["t3a.medium"]
  
  
  remote_access {
    ec2_ssh_key = aws_key_pair.custom_aws_ssh_key.key_name   
  }

  scaling_config {
    desired_size = 4
    min_size     = 2    
    max_size     = 7
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1    
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]  
  tags = {
    Name = "Private-Node-Group"
  }
}

######## REQUIRED TO OUTPUT EC2 WORKERS DETAILS ########
data "aws_instances" "workers" {
  instance_tags = {
    "kubernetes.io/cluster/trio-eks-dev" = "owned"
  }
  instance_state_names = ["running"]

  depends_on = [
    aws_eks_node_group.eks_ng_private
  ]
}

output "workers" {
  value = [for i, id in data.aws_instances.workers.ids : { "name" : id, "private_ip" : data.aws_instances.workers.private_ips[i] }]

  depends_on = [
    data.aws_instances.workers
  ]
}