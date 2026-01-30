provider "google"{
    project = var.project
    region = var.region
}

# Calling vpc module
module "vpc" {
    # the below is for https connection using Personall access token 
    source = "git::https://github.com/rcaws22/terraform-gcp-modules.git//vpc?ref=v1.0.0"

    # the below is for ssh connection, if we are using keys ~/.ssh/id_rsa
    #source = "git@github.com:rcaws22/terraform-gcp-modules.git//vpc?ref=v1.0.0"
    vpc_name = var.vpc_name
}


# Calling Subnet Module
module "subnet" {
  source = "git::https://github.com/rcaws22/terraform-gcp-modules.git//subnet?ref=v1.0.0"
  subnet_name = var.subnet_name
    region = var.region
    vpc_id = module.vpc.vpc_id
    subnet_cidr = var.subnet_cidr
    depends_on = [ module.vpc ]
}


# Calling GCE Module
module "gce" {
  source = "git::https://github.com/rcaws22/terraform-gcp-modules.git//gce?ref=v1.0.0"
  vm_name = var.vm_name
  zone = var.zone
  machine_type = var.machine_type
  subnet_id = module.subnet.subnet_id
  depends_on = [ module.subnet ]
}

