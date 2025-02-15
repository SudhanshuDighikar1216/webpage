provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_container_app_environment" "example" {
  name                = "example-container-environment"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "example-managed-identity"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_role_assignment" "example" {
  principal_id        = azurerm_user_assigned_identity.example.principal_id
  role_definition_name = "AcrPull"
  scope                = "<YOUR_ACR_ID>"
}
  identity {
    type                = "UserAssigned"
    user_assigned_identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  container {
    name   = "example-container"
    image  = "<firstcontainerappacracr123>/firstcontainerappacracr123:${github.sha}" # Replace with your ACR and image tag
    cpu    = "0.5"  # CPU allocation for the container
    memory = "1Gi"  # Memory allocation for the container
  }