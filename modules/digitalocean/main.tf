terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.18.0"
    }
  }
}

####### SSH KEYS #######

resource "digitalocean_ssh_key" "default" {
  name       = "Droplets SSH Key"
  public_key = file(var.do_ssh_key)
}

####### DROPLETS #######

resource "digitalocean_droplet" "my-droplets" {
  count    = length(var.do_droplet_names)
  image    = var.do_droplet_image
  name     = "${var.do_droplet_names[count.index]}"
  region   = var.do_region
  size     = var.do_droplet_type
  ssh_keys = [digitalocean_ssh_key.default.id]
  vpc_uuid = digitalocean_vpc.do_custom-vpc.id

  # Bazı durumlarda kaynaklar silinip tekrardan yaratılmadan önce ilk önce ikinci bir kopyası yaratılıp herşeyin çalıştığından emin olduktan sonra eski kaynağın silinmesi için kural. 
  lifecycle {
    create_before_destroy = true
  }
}

####### NETWORKING #######

resource "digitalocean_vpc" "do_custom-vpc" {
  name     = var.do_vpc_name
  region   = var.do_region
  ip_range = var.do_vpc_cidr
}

####### FIREWALL #######
# Burada LOKAL olarak tanımladığımız ve işlediğimiz tüm IP'leri kurallara kullanılmak üzere passlıyoruz.

resource "digitalocean_firewall" "custom-firewall" {
  name = "jenkins-and-nexus-firewall"

  droplet_ids = digitalocean_droplet.my-droplets.*.id

  inbound_rule {
    protocol         = "tcp"
    port_range       = "0"
    source_addresses = local.all_ips
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = local.all_ips
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "0"
    source_addresses = local.all_ips
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "0"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "0"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0"]
  }
}

locals {

  # formatlist fonksiyonu ile Private IP listesindeki öğelere /32 eklentisini yapıyoruz.
  do_public_ips = formatlist("%s/32", "${digitalocean_droplet.my-droplets.*.ipv4_address}")

  aws_nat_ips = formatlist("%s/32", "${var.aws_nat_ips}")

  aws_bastion_ip = formatlist("%s/32", "${var.aws_bastion_ip}")

  # HTTP plugini ile çektiğimiz laptop IP'mizi split fonksiyonu kullanarak LIST formatına çeviriyoruz ve aynı zamanda sonuna /32 ekliyoruz.
  personal_ip = split(" ", "${chomp(data.http.myip.body)}/32")

  # Private ve Personal IP'leri tek bir LIST içerisinde topluyoruz. Bu değişkeni sonrasında Firewall konfigürasyonunda kullanıyoruz.
  all_ips = concat(local.do_public_ips, local.personal_ip, local.aws_nat_ips, local.aws_bastion_ip)
}