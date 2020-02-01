###########
# Redshift
###########
module "redshift" {
  source = "terraform-aws-modules/redshift/aws"
  version = "~> 2.0.0"
  #depends_on = [
  #"vpc.redshift_subnets"
  #]

  cluster_identifier      = "redshift-demo"
  cluster_node_type       = "dc1.large"
  cluster_number_of_nodes = 1

  cluster_database_name   = "testdb"
  cluster_master_username = "awsuser"
  cluster_master_password = "SomePassw0rd"
  subnets                = module.vpc.redshift_subnets
  vpc_security_group_ids = [module.sg.this_security_group_id]
  redshift_subnet_group_name = module.vpc.redshift_subnet_group
}
