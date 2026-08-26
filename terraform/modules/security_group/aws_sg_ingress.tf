resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for pair in flatten([
      for sg_key, sg in var.security_groups.groups : [
        for idx, r in sg.ingress : {
          key    = "${sg_key}-ingress-${idx}"
          sg_key = sg_key
          rule   = r
        }
      ]
    ]) : pair.key => pair
  }

  security_group_id = aws_security_group.this[each.value.sg_key].id
  description       = try(each.value.rule.description, null)
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  ip_protocol       = each.value.rule.protocol

  cidr_ipv4      = try(each.value.rule.cidr_ipv4, null)
  cidr_ipv6      = try(each.value.rule.cidr_ipv6, null)
  prefix_list_id = try(each.value.rule.prefix_list_id, null)

  referenced_security_group_id = try(each.value.rule.self, false) ? aws_security_group.this[each.value.sg_key].id : (
    try(each.value.rule.source_security_group_key, null) != null ? aws_security_group.this[each.value.rule.source_security_group_key].id : try(each.value.rule.source_security_group_id, null)
  )
}
