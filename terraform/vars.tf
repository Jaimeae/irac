variable "region" {
  description = "Region de la instancia"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "Access Key de la cuenta AWS"
  type        = string
  default     = "AKIAQZUFL7RRFPJ3BP6R"
}

variable "secret_key" {
  description = "Secret Key de la cuenta AWS"
  type        = string
  default     = "EH2nyYSOyG16hmG0A9gcFTpCMbOWwA3iyMeLXGkO" 
}

variable "ami" {
  description = "AMI de la instancia: informa a AWS que instancia queremos levantar"
  type        = string
  default     = "ami-0c2b0d3fb02824d92"//Last release Windows, suele cambiar con el tiempo
}

variable "key_pair" {
  description = "Nombre par de claves para conexión segura a la instancia"
  type        = string
  default     = "clavesIRAC"
}