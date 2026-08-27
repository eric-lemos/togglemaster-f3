output "queue_names" {
  value = { for k, queue in aws_sqs_queue.this : k => queue.name }
}

output "queue_urls" {
  value = { for k, queue in aws_sqs_queue.this : k => queue.url }
}

output "queue_arns" {
  value = { for k, queue in aws_sqs_queue.this : k => queue.arn }
}
