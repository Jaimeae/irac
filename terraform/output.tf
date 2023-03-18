output "instance-ip" {
    description = "IP de EC2_IRAC"
    value = "${aws_instance.IRAC.public_ip}"
}

output "instance-dns" {
    description = "DNS de EC2_IRAC"
    value = "${aws_instance.IRAC.public_dns}"
}