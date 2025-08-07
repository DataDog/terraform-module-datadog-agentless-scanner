output "asg" {
  description = "The Auto Scaling group of the Agentless Scanner"
  value       = aws_autoscaling_group.asg
}
