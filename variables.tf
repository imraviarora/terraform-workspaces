variable "resource_prefix" {
  type    = map
  default = {
    dev  = "dev"
    test = "test"
    prod = "prod"
  }
}

variable "resource_group_location" {
  type    = map
  default = {
    dev = "West Europe"
    test = "eastus"
    prod = "Central India"
  }
}

variable "environment_tag" {
  type    = map
  default = {
    dev = "Development"
    test = "Test"
    prod = "Production"
  }
}
