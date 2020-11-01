resource "digitalocean_ssh_key" "mrveera" {
  name       = "Mr.Veera TF key"
  public_key = file("~/.ssh/mrveera.pub")
}

