output "subnet_id" {
  value = aws_subnet.etagere.id
}

output "vpc_id" {
  value = aws_vpc.etagere.id
}

output "security_group_id" {
  value = aws_security_group.etagere_default.id
}

output "instances" {
  value = "${formatlist(
    "%s = %s",
    (aws_instance.etagere_user[*].tags["Trigramme"]),
    (aws_instance.etagere_user[*].public_dns)
  )}"
}