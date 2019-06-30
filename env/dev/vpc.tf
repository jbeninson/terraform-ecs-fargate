
data "aws_availability_zones" "available" {
    state = "available"
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "1.46.0"

    name = "ecs-vpc"
    cidr = "10.50.0.0/16"

    # slice the list of AZs to the first two elements
    # azs = "${slice("${data.aws_availability_zones.available.names}", 0, 2)}"
    azs = "${slice("${data.aws_availability_zones.available.names}", 0, 2)}"


    public_subnets  = ["10.50.11.0/24", "10.50.12.0/24"]
    private_subnets = ["10.50.21.0/24", "10.50.22.0/24"]

    single_nat_gateway = true

    enable_nat_gateway   = true
    enable_vpn_gateway   = false
    enable_dns_hostnames = true

    tags = "${merge(
        local.common_tags,
        map(
        "Name", "load-balancer-sg",
        )
    )}"
}