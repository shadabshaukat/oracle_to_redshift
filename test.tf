provider "aws" {
  region     = "us-east-1"
}
resource "aws_redshift_cluster" "default" {
  cluster_identifier = "eero-test"
  database_name      = "testdb"
  master_username    = "awsuser"
  master_password    = "Awsuser1234"
  node_type          = "dc1.8xlarge"
  cluster_type       = "multi-node"
  number_of_nodes    = 2
  iam_roles          = ["arn:aws:iam::775867435088:role/SHADMHAREDSHIFT"]
  cluster_parameter_group_name = "default.redshift-1.0"
  vpc_security_group_ids = ["sg-55c2f911"]
  cluster_subnet_group_name = "default"
  publicly_accessible = true
  skip_final_snapshot = true
}
