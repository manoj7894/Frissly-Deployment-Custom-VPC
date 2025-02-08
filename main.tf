module "vpc" {
  source = "./module/vpc"

  # Pass variables to VPC module
  vpc_id                  = "172.16.0.0/16"
  instance_tenancy        = "default"
  enable_dns_support      = "true" # If set to true, DNS queries can be resolved within the VPC (e.g., for instances to communicate using private DNS names).
  enable_dns_hostnames    = "true" # If set to true, instances with public IPs will also receive public DNS hostnames
  public_subnet_id_value  = "172.16.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "true" # Enable auto-assign public IP
  private_subnet_id_value = "172.16.2.0/24"
  availability_zone1      = "us-west-2b"
}



module "ec2" {
  source = "./module/ec2_instance"

  # Pass variables to EC2 module
  ami_value                   = "ami-00c257e12d6828491" # data.aws_ami.ubuntu_24_arm.id                            
  instance_type_value         = "t2.large"
  key_name                    = "varma.pem"
  instance_count              = "1"
  public_subnet_id_value      = module.vpc.Public_subnet_id
  associate_public_ip_address = "true" # Enable a public IP
  availability_zone           = "us-west-2a"
  vpc_id                      = module.vpc.vpc_id
  # instance_tenancy       = "dedicated"
  volume_size         = "30"
  volume_type         = "gp3"
  security_group_name = "Frissly-Security-Group"

}


module "ecr" {
  source = "./module/ecr"

  repository_name = "frissly-docker-repo"
  # vpc_id                  = module.vpc.vpc_id
  # public_subnet_id_value  = module.vpc.Public_subnet_id
  # private_subnet_id_value = module.vpc.Private_subnet_id
  # security_group_id       = module.ec2.security_group_id
}

module "app_runner_backend" {
  source = "./module/app_runner/backend"

  app_runner_service_name         = "Frissly-Backend"
  repository_name                 = "frissly-docker-repo" # Replace with your ECR repository name
  image_tag                       = "staging"             # Replace with your specific tag if necessary
  image_repository_type           = "ECR"
  auto_scaling_configuration_name = "Frissly-backend-autoscaling"
  role_name                       = "Frissly-Apprunner-Role-1"
  policy_name                     = "Frissly-Apprunner-Policy-1"
  max_concurrency                 = "100"
  min_size                        = "1" # Minimum number of instances
  max_size                        = "3" # Maximum number of instances
  port                            = 8081
  cpu                             = 256 # 0.25 vCPU
  memory                          = 512 # 0.5 GB RAM
  auto_deployments_enabled        = "true"
  interval                        = "10"  # App Runner sends a health check request every 10 seconds to determine the status of the service instance.
  timeout                         = "5"   # If the service does not respond to a health check request within 5 seconds, the health check will be marked as failed.
  healthy_threshold               = "3"   #  App Runner needs to receive 3 consecutive successful health check responses before marking the instance as healthy.
  unhealthy_threshold             = "3"   # App Runner will mark the instance as unhealthy after 3 consecutive failed health checks.
  protocol                        = "TCP" # App Runner will check if the service instance is reachable on the specified port using a TCP connection. No HTTP requests are sent in this case.
  vpc_id                          = module.vpc.vpc_id
  vpc_cidr_block                  = module.vpc.vpc_cidr_block
  private_subnet_id_value         = module.vpc.Private_subnet_id
  security_group_name             = "Apprunner_Security_group"
}

module "SNS_EventBridge" {
  source = "./module/sns"

  sns_name                     = "SNS_APP_Topic_1"
  display_name                 = "SNS_APPrunner"
  protocol                     = "email"
  endpoint                     = "manojvarmapotthutri@gmail.com"
  eventbridge_name             = "Apprunner_Bridge_SNS"
  eventbridge_to_sns_role_name = "EventBridgeToSNSRole"
  sns_publish_policy_name      = "SNSPublishPolicy"
}



resource "null_resource" "name" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = module.ec2.public_ip[0]
  }

  provisioner "file" {
    source      = "./module/ec2_instance/jenkins.sh"
    destination = "/home/ubuntu/jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export $(grep -v '^#' /home/ubuntu/.env | xargs)",
      "mkdir -p /home/ubuntu/.aws",
      "echo '[default]' > /home/ubuntu/.aws/config",
      "echo 'region = ${var.region}' >> /home/ubuntu/.aws/config",
      "echo '[default]' > /home/ubuntu/.aws/credentials",
      "echo 'aws_access_key_id = ${var.access_key}' >> /home/ubuntu/.aws/credentials",
      "echo 'aws_secret_access_key = ${var.secret_key}' >> /home/ubuntu/.aws/credentials",

      # Optional: Clean up the .env file if not needed
      "rm /home/ubuntu/.env",
      "sudo chmod +x /home/ubuntu/jenkins.sh",
      "sh /home/ubuntu/jenkins.sh"
    ]
  }

  depends_on = [module.ec2]
}

