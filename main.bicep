targetScope = 'resourceGroup'
@description('The name of the Virtual Machine')
param vmName string

@description('The name of the admin user')
param adminUsername string

@description('The password for the admin user')
@secure()
param adminPassword string

@description('The size of the Virtual Machine')
param vmSize string = 'Standard_DS1_v2'

@description('The resource group location')
param location string = resourceGroup().location

@description('The address prefix for the Virtual Network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The address prefix for the Subnet')
param subnetAddressPrefix string = '10.0.0.0/24'

param resourceGroupName string = 'BH-Team'

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
output vmId string = vm.id
output publicIPAddress string = publicIPAddress.properties.publicIPAddressVersion
