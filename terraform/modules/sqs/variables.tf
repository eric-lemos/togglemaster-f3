variable "sqs" {
  description = "SQS configuration."

  type = object({
    queues = map(object({
      name                        = optional(string)
      visibility_timeout_seconds  = optional(number, 60)
      message_retention_seconds   = optional(number, 86400)
      receive_wait_time_seconds   = optional(number, 0)
      fifo_queue                  = optional(bool, false)
      content_based_deduplication = optional(bool, false)
      sqs_managed_sse_enabled     = optional(bool, true)
      tags                        = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  })

  validation {
    condition = alltrue([
      for k, queue in var.sqs.queues :
      queue.fifo_queue || !queue.content_based_deduplication
    ])
    error_message = "sqs.queues.*.content_based_deduplication requires fifo_queue to be true."
  }
}
