resource "aws_db_subnet_group" "this" {
  name = var.rds.subnet_group.name

  subnet_ids = concat(
    var.rds.subnet_group.subnet_ids,
    [for n in var.rds.subnet_group.subnet_names : data.aws_subnet.by_name[n].id]
  )

  tags = merge(var.rds.tags, {
    Name = var.rds.subnet_group.name
  })
}
