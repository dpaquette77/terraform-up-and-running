output "public_ip" {
  value = aws_lb.example.dns_name
  description = "DNS name of the load balancer"
}