variable "project" {
  type    = string
  default = "webapp"
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod"
  }
}

variable "location" {
  type    = string
  default = "East US"

}

# Full azure region is too long for a resource name since we are following CAF (cloud Adoption framework)
variable "location_abbr" {
  type    = string
  default = "eus"
}

variable "owner" {
  type    = string
  default = "radhi"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  type = map(object({
    cidr       = string
    delegation = bool
    nsg        = string
  })
  )
  default = {
    snet-agw = {cidr = "10.0.1.0/24",delegation = false , nsg = "agw"}
    snet-app = {cidr = "10.0.2.0/24",delegation = true , nsg = "app"}
    snet-pe  = {cidr = "10.0.3.0/24",delegation = false , nsg = "pe"}
  }
}