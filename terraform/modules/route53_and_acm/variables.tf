variable "environment" {
  default     = "dev"
  description = "The environment name"
  type        = string
}

variable "lbname" {
  type    = list(string)
  description = "Lb name list has to be given"
  default = [ "biprodatta-xml-dev", "biprodatta-api-dev" ]
}

variable "vpc_id" {
  type = string
}