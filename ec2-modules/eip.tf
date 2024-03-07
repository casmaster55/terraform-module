resource "aws_eip" "nat" {
  count = var.eip_count
  vpc   = true

  tags = merge(var.common_tags, {
    Name = format("%s-%s-%s-vpc-nat-eip-%02d", var.common_tags["id"], var.common_tags["environment"], var.common_tags["project"], count.index + 1)
  })
}