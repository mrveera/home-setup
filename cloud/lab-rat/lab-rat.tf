resource "digitalocean_ssh_key" "mrveera" {
  name       = "Mr.Veera TF key"
  public_key = file("~/.ssh/mrveera.pub")
}

resource "digitalocean_droplet" "labrat" {
  image  = "ubuntu-18-04-x64"
  name   = "labrat"
  region = "sfo2"
  size   = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [digitalocean_ssh_key.mrveera.fingerprint]
  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }
}
output "labrat_ipv4" {
  value       = digitalocean_droplet.labrat.ipv4_address
  description = "The private IP address of the labrat instance."
}