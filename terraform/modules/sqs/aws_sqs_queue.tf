resource "aws_sqs_queue" "this" {
  for_each = var.sqs.queues

  name                        = coalesce(each.value.name, each.key)
  visibility_timeout_seconds  = each.value.visibility_timeout_seconds
  message_retention_seconds   = each.value.message_retention_seconds
  receive_wait_time_seconds   = each.value.receive_wait_time_seconds
  fifo_queue                  = each.value.fifo_queue
  content_based_deduplication = each.value.content_based_deduplication
  sqs_managed_sse_enabled     = each.value.sqs_managed_sse_enabled

  tags = merge(var.sqs.tags, each.value.tags, {
    Name = coalesce(each.value.name, each.key)
  })
}
