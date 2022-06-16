# Bu kısımda DigitalOcean provider'ı tanımlayıp ek olarak terminal'e export ettiğimiz DigitalOcean API Key'i paslıyoruz.
provider "digitalocean" {
  token = var.do_token
}