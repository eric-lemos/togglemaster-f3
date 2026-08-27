resource "aws_db_instance" "this" {
  for_each = var.rds.instances

  identifier     = each.value.db_name
  engine         = each.value.engine
  engine_version = each.value.engine_version
  instance_class = each.value.instance_class

  allocated_storage = each.value.allocated_storage
  storage_encrypted = each.value.storage_encrypted

  db_name  = each.value.db_name
  username = each.value.username
  password = sensitive(each.value.password)

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = concat(
    each.value.security_group_ids,
    [for n in each.value.security_group_names : data.aws_security_group.by_name[n].id]
  )

  multi_az                = each.value.multi_az
  backup_retention_period = each.value.backup_retention_period
  publicly_accessible     = each.value.publicly_accessible
  skip_final_snapshot     = each.value.skip_final_snapshot

  monitoring_interval          = each.value.monitoring_interval
  performance_insights_enabled = each.value.performance_insights_enabled

  tags = merge(var.rds.tags, each.value.tags, {
    Name = each.value.db_name
  })
}
