resource "digitalocean_ssh_key" "mrveera" {
  name       = "mrveera"
  public_key = file("~/.ssh/mrveera.pub")
}

