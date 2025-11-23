output "alb-dns_name" {    
  value = aws_lb.lb-tcc.dns_name
}

output "s3-original" {
  value = aws_s3_bucket.s3-original.bucket
}

output "s3-tratada" {
  value = aws_s3_bucket.s3-tratada.bucket
}

output "s3-reconhecida" {
  value = aws_s3_bucket.s3-reconhecida.bucket
}