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