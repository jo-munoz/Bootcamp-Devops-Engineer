resource "tls_private_key" "key_pair_srv_linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair_srv_linux" {
  key_name   = "key pair of srv_linux"  
  public_key = tls_private_key.key_pair_srv_linux.public_key_openssh
}

resource "local_file" "ssh_key_srv_linux" {
  filename = "${aws_key_pair.key_pair_srv_linux.key_name}.pem"
  content  = tls_private_key.key_pair_srv_linux.private_key_pem
}