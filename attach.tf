provider "azurerm" {
  alias = "attach"
  features {}
}

resource "azurerm_managed_disk" "disk" {
  name                 = "disk01"
  location             = "central india"
  resource_group_name  = "nishan"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = "/subscriptions/71815b3c-ac05-4504-8f3f-6d7f27ce722f/resourceGroups/nishan/providers/Microsoft.Compute/virtualMachines/demovm-01"
  lun                = 0
  caching            = "ReadWrite"
}
