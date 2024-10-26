provider "azurerm" {
  features {
  }
  subscription_id            = "d597c780-08e7-4409-9b46-ea9f2afc1e1a"
  environment                = "public"
  use_msi                    = false
  use_cli                    = true
  use_oidc                   = false
  skip_provider_registration = true
}
