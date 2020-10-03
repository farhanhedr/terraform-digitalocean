# terraform {
#   required_providers {
#     digitalocean = {
#       source = "digitalocean/digitalocean"
#     }
#   }
# }

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "pvt_key" {}
variable "pub_key" {}

# Configure the DigitalOcean Provider
# This downloads plugin for provider
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "id_root" {
  # this name is matched for public key in Digital Ocean
  name = "id_root"
}

#Create a web server
resource "digitalocean_droplet" "web_server" {
  count = 2
  name = "web-server-${count.index}"
  image = "centos-7-x64" #"ubuntu-18-04-x64"
  region = "blr1"
  size   = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.id_root.id
  ]

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
      # install nginx
      "adduser farhan",
      "cd /home/farhan",
      "mkdir .ssh",
      "echo ${var.pub_key} > .ssh/authorized_keys",
      "chmod 700 .ssh/",
      "chmod 400 .ssh/authorized_keys",
      "chown -R farhan:farhan .ssh/"
    ]
  }
}

