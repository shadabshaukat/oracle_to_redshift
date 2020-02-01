###########
# EC2
###########
module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0.0"

  name                   = "EC2 Bastion Host"
  instance_count         = 1

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = "Eu-West-1-Key"
  monitoring             = true
  vpc_security_group_ids = [module.sg.this_security_group_id]
  subnet_id              = tolist(module.vpc.redshift_subnets)[0]

}
