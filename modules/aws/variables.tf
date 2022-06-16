variable "aws_vpc_name" {}
variable "aws_vpc_cidr" {}
variable "aws_region" {}
variable "aws_az_count" {}
variable "aws_ssh_key" {}
variable "aws_ec2_instance_image" {}
variable "aws_ec2_instance_type" {}
variable "aws_eks_cluster_name" {}
variable "aws_environment" {}
variable "eks_oidc_root_ca_thumbprint" {}
variable "eks_ecr_addon_registry" {}
resource "aws_key_pair" "custom_aws_ssh_key" {
  key_name   = "AWS SSH Key"
  public_key = file(var.aws_ssh_key)
}