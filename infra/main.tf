module "networking" {
  source   = "./modules/networking"
  region   = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
}

module "backend_cluster" {
  source              = "./modules/backend_cluster"
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  web_sg_id           = module.webserver.web_sg_id
}

module "webserver" {
  source   = "./modules/webserver"
  vpc_id   = module.networking.vpc_id
  subnet_id = module.networking.public_subnet_ids[0]  # use 1st public subnet
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  vpc_id              = module.networking.vpc_id
  alb_listener_arn    = module.backend_cluster.backend_alb_listener_arn
  private_subnet_ids  = module.networking.private_subnet_ids  # ✅ Add this line
}
module "s3_and_lambda" {
  source              = "./modules/s3_and_lambda"
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
}
module "database" {
  source              = "./modules/database"
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  lambda_sg_id        = module.s3_and_lambda.lambda_sg_id
}