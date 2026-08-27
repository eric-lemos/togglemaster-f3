resource "aws_ecr_repository" "this" {
  for_each = var.ecr.repositories

  name                 = coalesce(each.value.name, each.key)
  image_tag_mutability = each.value.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  tags = merge(var.ecr.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}
