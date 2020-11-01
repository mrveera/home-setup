module "ssh" {
    source = "./ssh"
    providers = {
    digitalocean = digitalocean
  }
}

module "pijump" {
    source = "./pijump"
    providers = {
    digitalocean = digitalocean
  }
}