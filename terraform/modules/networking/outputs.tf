output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "igw_id" {
  value = try(aws_internet_gateway.this[0].id, null)
}

output "subnet_ids" {
  value = { for k, s in aws_subnet.this : k => s.id }
}

output "public_subnet_ids" {
  value = [for k, s in var.networking.subnet : aws_subnet.this[k].id if s.type == "public"]
}

output "private_subnet_ids" {
  value = [for k, s in var.networking.subnet : aws_subnet.this[k].id if s.type == "private"]
}

output "nat_gw_ids" {
  value = { for k, n in aws_nat_gateway.this : k => n.id }
}

output "rtb_ids" {
  value = { for k, r in aws_route_table.this : k => r.id }
}
