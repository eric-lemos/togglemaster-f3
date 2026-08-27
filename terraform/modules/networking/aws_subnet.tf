resource "aws_subnet" "this" {
  # Subnets without an explicit AZ are distributed round-robin across the available zones
  for_each = {
    for idx, key in keys(var.networking.subnet) : key => var.networking.subnet[key]
  }

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value.cidr_block

  availability_zone = coalesce(
    each.value.availability_zone,
    data.aws_availability_zones.available.names[
      index(
        keys(var.networking.subnet),
        each.key
      ) % length(data.aws_availability_zones.available.names)
    ]
  )

  map_public_ip_on_launch = coalesce(each.value.map_public_ip_on_launch, each.value.type == "public")

  tags = merge(var.networking.vpc.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}
