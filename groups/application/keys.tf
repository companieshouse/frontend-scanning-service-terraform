# ------------------------------------------------------------------------------
# FES Key Pair
# ------------------------------------------------------------------------------

resource "aws_key_pair" "fes_app_keypair" {
  key_name   = var.application
  public_key = local.fes_ec2_data["public-key"]
}
