output "vm_windows_server_instance_id" {
  value = aws_instance.windows-server.id
}

output "vm_windows_server_instance_public_dns" {
  value = aws_instance.windows-server.public_dns
}

output "vm_windows_server_instance_public_ip" {
  value = aws_instance.windows-server.public_ip
}