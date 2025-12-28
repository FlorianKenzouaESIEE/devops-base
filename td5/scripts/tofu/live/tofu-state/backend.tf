terraform {
  backend "s3" {
    # TODO: fill in your own bucket name here!
    bucket         = "florian-daryl-fundamentals-of-devops-tofu-state" 
    key            = "td5/scripts/tofu/live/tofu-state"         
    region         = "eu-central-1"                         
    encrypt        = true                                
    # TODO: fill in your own DynamoDB table name here!
    dynamodb_table = "florian-daryl-fundamentals-of-devops-tofu-state" 
  }
}