variable "vpc_id" {
  type = string
}
variable "environment" {
  type = string
}
variable "lbname" {
  type    = list(string)
  description = "Lb name list has to be given"
}