
module "pijump" {
    source = "./pijump"
    providers = {
    digitalocean = digitalocean
  }
}

module "labrat" {
    source = "./lab-rat"
    providers = {
    digitalocean = digitalocean
  }
}