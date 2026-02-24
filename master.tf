resource "aws_instance" "jmeter_master" {
   ami                    = "ami-06dd92ecc74fdfb36"
   instance_type          = "t3.2xlarge"
   count                  = var.instance_count
   key_name               = "orbis-pos-prl-jmeter-slaves"
   subnet_id              = "subnet-09714b64ad46a67f5"
   vpc_security_group_ids = ["sg-00b9f713ed68e79ea"]
   user_data              = file("master.sh")

  tags = {
    Name        = "jmeter-master"
    Costcenter  = "pdi-pos"
    Product     = "pos-cicd"
    Environment = "test"
  }
 }

output "master_public_ip" {
    value = aws_instance.jmeter_master[*].private_ip
}
variable "instance_count" {
  description = "Instance Count"
  type 		    = number
  default     = 1
}
