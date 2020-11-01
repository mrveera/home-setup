
resource "digitalocean_ssh_key" "mrveera" {
  name       = "Mr.Veera TF key"
  public_key = file("~/.ssh/mrveera.pub")
}

resource "digitalocean_droplet" "pijump" {
  image  = "ubuntu-18-04-x64"
  name   = "pijump"
  region = "blr1"
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
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.gpg | sudo apt-key add -",
      "curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.list | sudo tee /etc/apt/sources.list.d/tailscale.list",
      "sudo apt-get update && sudo apt-get install tailscale",
      "sudo tailscale up"
    ]
  }
}
output "pijump_ipv4" {
  value       = digitalocean_droplet.pijump.ipv4_address
  description = "The private IP address of the pijump instance."
}