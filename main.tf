variable "public_subnets" {
  default = [
      "10.0.1.0/24",
      "10.0.2.0/24"
  ]
}

variable "private_subnets" {
  default = [
      "10.0.3.0/24",
      "10.0.4.0/24"
  ]
}

module "vpc" {
  source = "./modules/terraform-aws-vpc"
    public_subnets_list = var.public_subnets
    private_subnets_list = var.private_subnets
}