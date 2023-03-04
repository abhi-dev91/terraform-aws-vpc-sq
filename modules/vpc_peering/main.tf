locals {
  requester_route_tables_ids = data.aws_route_tables.requester.ids
  accepter_route_tables_ids  = data.aws_route_tables.accepter.ids
  enable_cross_account_peering = var.enable_cross_account_peering ? [0] : [] 
}

provider "aws" {
  alias  = "peer"
  region = var.requester_vpc_region
}

provider "aws" {
  alias  = "accepter"
  region = var.accepter_vpc_region
  dynamic assume_role {
    for_each = local.enable_cross_account_peering
    content {
    role_arn = var.accepter_assume_role
    }
  }
}

data "aws_vpc" "accepter" {
  id       = var.accepter_vpc_id
  provider = aws.accepter
}

data "aws_route_tables" "accepter" {
  vpc_id   = var.accepter_vpc_id
  provider = aws.accepter
}

data "aws_vpc" "requester" {
  id       = var.requester_vpc_id
  provider = aws.peer
}

data "aws_route_tables" "requester" {
  vpc_id   = var.requester_vpc_id
  provider = aws.peer
}

resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  peer_region = var.accepter_vpc_region
  auto_accept = false
  provider    = aws.peer
  peer_owner_id = var.enable_cross_account_peering ? var.accepter_account_id : null
}

resource "aws_vpc_peering_connection_accepter" "this" {
  depends_on                = [aws_vpc_peering_connection.this]
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true
}

resource "aws_vpc_peering_connection_options" "this" {
  depends_on                = [aws_vpc_peering_connection_accepter.this]
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  provider = aws.accepter

}


####  route tables ####

resource "aws_route" "requester" {
  count                     = length(local.requester_route_tables_ids)
  route_table_id            = local.requester_route_tables_ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  provider                  = aws.peer
}

resource "aws_route" "accepter" {
  count                     = length(local.accepter_route_tables_ids)
  route_table_id            = local.accepter_route_tables_ids[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  provider                  = aws.accepter
}
