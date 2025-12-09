output "instance_id" {
  value       = aws_instance.demo.id
  description = "EC2 instance id"
}

output "public_ip" {
  value       = aws_instance.demo.public_ip
  description = "Public IPv4 address"
}

output "ssh_command" {
  value = "ssh -i /path/to/your-private-key ec2-user@${aws_instance.demo.public_ip}"
  description = "Example SSH command (replace /path/to/your-private-key)"
}
