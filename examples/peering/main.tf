locals {
  requester_vpc_region = "us-east-2"
  accepter_vpc_region  = "us-east-2"
  accepter_vpc_id      = "vpc-034d30be2f4d1skaf"
  requester_vpc_id     = "vpc-0fbdbf97efdf3skaf"
}

module "vpc_peering" {
  source               = "squareops/vpc/aws//modules/vpc-peering"
  requester_vpc_region = local.requester_vpc_region
  accepter_vpc_region  = local.accepter_vpc_region
  accepter_vpc_id      = local.accepter_vpc_id
  requester_vpc_id     = local.requester_vpc_id
}
