resource "ibm_is_instance" "instance" {
  count   = var.instance_count
  name    = "consul-${count.index + 1}"
  image   = var.default_image
  profile = var.default_instance_profile

  primary_network_interface {
    subnet = data.ibm_is_vpc.us_east_vpc.subnets[0].id
  }

  resource_group = data.ibm_resource_group.cde_rg.id
  tags           = ["consul"]

  vpc       = data.ibm_is_vpc.us_east_vpc.id
  zone      = "us-east-1"
  keys      = [data.ibm_is_ssh_key.us_east_key.id]
  user_data = file("${path.module}/installer.sh")
}


resource "ibm_dns_resource_record" "test-pdns-resource-record-aaaa" {
  depends_on  = [ibm_is_instance.instance]
  count       = var.instance_count
  instance_id = var.dns_instance_id
  zone_id     = var.zone_id
  type        = "A"
  name        = "consul-${count.index + 1}"
  rdata       = element(ibm_is_instance.instance[*].primary_network_interface[0].primary_ipv4_address, count.index)
}


