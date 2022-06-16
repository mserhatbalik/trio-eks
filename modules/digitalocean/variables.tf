variable "do_token" {}
variable "do_region" {}
variable "do_droplet_type" {}
variable "do_droplet_image" {}
variable "do_droplet_names" {}
variable "do_vpc_cidr" {}
variable "do_vpc_name" {}
variable "do_ssh_key" {}
variable "aws_nat_ips" {}
variable "aws_bastion_ip" {}
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}