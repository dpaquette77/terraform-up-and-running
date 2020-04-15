

output "alb_dns_name" {
    value = module.webserver-cluster.alb_dns_name
    description = "the dns name of the alb"
}