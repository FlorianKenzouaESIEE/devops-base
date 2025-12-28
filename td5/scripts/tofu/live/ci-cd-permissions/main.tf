provider "aws" {
  region = "eu-central-1"
}

module "oidc_provider" {
  source = "github.com/brikis98/devops-book//ch5/tofu/modules/github-aws-oidc"

  provider_url = "https://token.actions.githubusercontent.com" 

}

module "iam_roles" {
  source = "github.com/brikis98/devops-book//ch5/tofu/modules/gh-actions-iam-roles"

  name              = "lambda-sample"                           
  oidc_provider_arn = module.oidc_provider.oidc_provider_arn    

  enable_iam_role_for_testing = true                            

  # TODO: fill in your own repo name here!
  github_repo      = "FlorianKenzouaESIEE/devops-base" 
  lambda_base_name = "lambda-sample"                            

  enable_iam_role_for_plan  = true                                
  enable_iam_role_for_apply = true                                

  # TODO: fill in your own bucket and table name here!
  tofu_state_bucket         = "florian-daryl-fundamentals-of-devops-tofu-state" 
  tofu_state_dynamodb_table = "florian-daryl-fundamentals-of-devops-tofu-state" 
}

# 1. On définit la permission
data "aws_iam_policy_document" "api_gateway_access" {
  statement {
    effect    = "Allow"
    actions   = ["apigateway:*"]
    resources = ["*"]
  }
}

# 2. On colle cette permission sur le rôle de PLAN
resource "aws_iam_role_policy" "plan_api_gateway" {
  name   = "api-gateway-permissions-plan"
  role   = "lambda-sample-plan" # Le nom généré par le module
  policy = data.aws_iam_policy_document.api_gateway_access.json
}

# 3. On colle cette permission sur le rôle de APPLY
resource "aws_iam_role_policy" "apply_api_gateway" {
  name   = "api-gateway-permissions-apply"
  role   = "lambda-sample-apply" # Le nom généré par le module
  policy = data.aws_iam_policy_document.api_gateway_access.json
}

# 4. On colle cette permission sur le rôle de TESTS
resource "aws_iam_role_policy" "test_api_gateway" {
  name   = "api-gateway-permissions-test"
  role   = "lambda-sample-tests"  # C'est le nom qui apparaît dans votre erreur
  policy = data.aws_iam_policy_document.api_gateway_access.json
}