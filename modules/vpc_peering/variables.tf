variable "accepter_vpc_id" {
  type        = string
  description = "The ID of Acceptor VPC"
  default     = ""
}

variable "accepter_vpc_region" {
  type        = string
  description = "The region of Acceptor VPC"
  default     = ""
}

variable "requester_vpc_id" {
  type        = string
  description = "The ID of Requester VPC"
  default     = ""
}

variable "requester_vpc_region" {
  type        = string
  description = "The region Requester VPC"
  default     = ""
}

variable "enable_cross_account_peering" {
  type = string
  description = "Set it to true for VPC peering in cross account"
  default = false
}

variable "accepter_account_id" {
  type = string
  description = "Account ID for the Accepter VPC"
  default = ""
}

variable "accepter_assume_role" {
  type = string
  description = "Assume role for the accepter account if enable_cross_account_peering is set to true"
  default = ""
}

