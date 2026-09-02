output "frontend_route53_dns_record" {
  description = "The Route53 DNS name attached to CloudFront."
  value       = element(concat(aws_route53_record.frontend.*.name, [""]), 0)
}

output "tileserver_route53_dns_record" {
  description = "The Route53 DNS name attached to Tileserver LB."
  value       = element(concat(aws_route53_record.tileserver.*.name, [""]), 0)
}

output "cloudfront_dns_record" {
  description = "The CloudFront DNS name"
  value       = aws_cloudfront_distribution.cf_distribution.domain_name
}

output "db_postgres_version" {
  description = "The exact PostgreSQL version of the main db."
  value       = aws_db_instance.main_db.engine_version_actual
}


output "lambda_db_manager" {
  description = "Name of the db_manager Lambda function."
  value       = aws_lambda_function.db_manager.function_name
}

output "lambda_lipas_loader" {
  description = "Name of the lipas Lambda function."
  value       = aws_lambda_function.lipas_loader.function_name
}

output "lambda_osm_loader" {
  description = "Name of the osm Lambda function."
  value       = aws_lambda_function.osm_loader.function_name
}

output "lambda_wfs_loader" {
  description = "Name of the wfs Lambda function."
  value       = aws_lambda_function.wfs_loader.function_name
}
