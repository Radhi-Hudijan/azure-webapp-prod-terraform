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
  # 3 subnets are defined for the vnet, each with a cidr, delegation and nsg (Application Gateway for , App Service, Private Endpoint)
  default = {
    snet-agw = {cidr = "10.0.1.0/24",delegation = false , nsg = "agw"} # for application gateway, and inbound traffic from the internet, delegation is not required for the subnet to be used by the application gateway
    snet-app = {cidr = "10.0.2.0/24",delegation = true , nsg = "app"} # for outbound traffic from the app service, delegation is required for the subnet to be used by the app service plan
    snet-pe  = {cidr = "10.0.3.0/24",delegation = false , nsg = "pe"} # for private endpoints
  }
}