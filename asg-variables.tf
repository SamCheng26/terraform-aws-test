variable "asg_names" {
  description = "List of ASG names to monitor"
  type        = list(string)
  default     = ["asg-web", "asg-app"]
}