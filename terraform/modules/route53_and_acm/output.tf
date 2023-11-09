output "route53_record_fqdn" {
  value = module.records-biprodatta.route53_record_fqdn
}

output "route53_record_fqdn_test" {
  value = module.zones-biprodatta.route53_zone_name
}