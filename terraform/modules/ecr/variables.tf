variable "ecr" {
  description = "ECR repository configuration."

  type = object({
    repositories = map(object({
      name                 = optional(string)
      image_tag_mutability = optional(string, "IMMUTABLE")
      scan_on_push         = optional(bool, true)
      tags                 = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  })

  validation {
    condition     = alltrue([for k, repository in var.ecr.repositories : contains(["MUTABLE", "IMMUTABLE"], repository.image_tag_mutability)])
    error_message = "ecr.repositories.*.image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}
