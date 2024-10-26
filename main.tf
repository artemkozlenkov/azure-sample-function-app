resource "azurerm_resource_group" "res-0" {
  location = "westeurope"
  name     = "rg-funcapp-test"
}

resource "azurerm_storage_account" "res-1" {
  account_kind                     = "Storage"
  account_replication_type         = "LRS"
  account_tier                     = "Standard"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  default_to_oauth_authentication  = true
  location                         = "westeurope"
  name                             = "rgfuncapptest80f0" # Consider changing this for uniqueness
  resource_group_name              = azurerm_resource_group.res-0.name
}

resource "azurerm_storage_container" "res-3" {
  name                 = "azure-webjobs-hosts"
  storage_account_name = azurerm_storage_account.res-1.name
  depends_on          = [azurerm_storage_account.res-1]
}

resource "azurerm_storage_container" "res-4" {
  name                 = "azure-webjobs-secrets"
  storage_account_name = azurerm_storage_account.res-1.name
  depends_on          = [azurerm_storage_account.res-1]
}

resource "azurerm_storage_container" "res-5" {
  name                 = "function-releases"
  storage_account_name = azurerm_storage_account.res-1.name
  depends_on          = [azurerm_storage_account.res-1]
}

resource "azurerm_storage_container" "res-6" {
  name                 = "scm-releases"
  storage_account_name = azurerm_storage_account.res-1.name
  depends_on          = [azurerm_storage_account.res-1]
}

resource "azurerm_storage_share" "res-8" {
  name                 = "function-app-kozlenkov-testa790"
  quota                = 102400
  storage_account_name = azurerm_storage_account.res-1.name
}

resource "azurerm_storage_table" "res-11" {
  name                 = "AzureFunctionsDiagnosticEvents202410"
  storage_account_name = azurerm_storage_account.res-1.name
}

resource "azurerm_service_plan" "res-12" {
  location            = "westeurope"
  name                = "ASP-rgfuncapptest-ad89"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.res-0.name
  sku_name            = "Y1"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_linux_function_app" "res-13" {
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "0"
  }
  builtin_logging_enabled                  = false
  client_certificate_mode                  = "Required"
  ftp_publish_basic_authentication_enabled = false
  https_only                               = true
  location                                 = "westeurope"
  name                                     = "function-app-kozlenkov-test"
  resource_group_name                      = azurerm_resource_group.res-0.name
  service_plan_id                          = azurerm_service_plan.res-12.id
  storage_account_access_key               = "<Your_Storage_Account_Key>" # Consider using a more secure method for accessing keys
  storage_account_name                     = azurerm_storage_account.res-1.name
  webdeploy_publish_basic_authentication_enabled = false
  site_config {
    application_insights_connection_string = "InstrumentationKey=..."
    ftps_state                             = "FtpsOnly"
    ip_restriction_default_action          = ""
    scm_ip_restriction_default_action      = ""
    application_stack {
      python_version = "3.11"
    }
    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
  }
  depends_on = [
    azurerm_service_plan.res-12,
  ]
}

resource "azurerm_function_app_function" "res-17" {
  config_json = jsonencode({
    bindings = [{
      authLevel = "FUNCTION"
      direction = "IN"
      name      = "req"
      route     = "HttpFunction"
      type      = "httpTrigger"
      }, {
      direction = "OUT"
      name      = "$return"
      type      = "http"
    }]
    entryPoint        = "HttpFunction"
    functionDirectory = "/home/site/wwwroot"
    language          = "python"
    name              = "HttpFunction"
    scriptFile        = "function_app.py"
  })
  function_app_id = azurerm_linux_function_app.res-13.id
  name            = "HttpFunction"
  depends_on = [
    azurerm_linux_function_app.res-13,
  ]
}

resource "azurerm_app_service_custom_hostname_binding" "res-18" {
  app_service_name    = azurerm_linux_function_app.res-13.name
  hostname            = "${azurerm_linux_function_app.res-13.name}.azurewebsites.net"
  resource_group_name = azurerm_resource_group.res-0.name
  depends_on = [
    azurerm_linux_function_app.res-13,
  ]
}

resource "azurerm_monitor_smart_detector_alert_rule" "res-19" {
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  detector_type       = "FailureAnomaliesDetector"
  frequency           = "PT1M"
  name                = "Failure Anomalies - function-app-kozlenkov-test"
  resource_group_name = azurerm_resource_group.res-0.name
  scope_resource_ids  = ["/subscriptions/.../providers/microsoft.insights/components/function-app-kozlenkov-test"]
  severity            = "Sev3"
  action_group {
    ids = [azurerm_monitor_action_group.res-20.id]
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_monitor_action_group" "res-20" {
  name                = "Application Insights Smart Detection"
  resource_group_name = azurerm_resource_group.res-0.name
  short_name          = "SmartDetect"
  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }
  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_application_insights" "res-21" {
  application_type    = "web"
  location            = "westeurope"
  name                = "function-app-kozlenkov-test"
  resource_group_name = azurerm_resource_group.res-0.name
  sampling_percentage = 0
  workspace_id        = "/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-d597c780-08e7-4409-9b46-ea9f2afc1e1a-WEU"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
