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
  pvt_key = var.pvt_key
}


module "labrat" {
    source = "./lab-rat"
    providers = {
    digitalocean = digitalocean
  }
}