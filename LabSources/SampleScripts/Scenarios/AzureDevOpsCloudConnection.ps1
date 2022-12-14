<#

.DESCRIPTION
 This script deploys a Hyper-V VM using nested virtualization and deploys a build agent on it, connected to an Azure DevOps organisation's agent pool.
 This lab includes a reference to Azure DevOps in addition to the build agent

#>
param
(
    # Your user name on Azure DevOps, or an organisation's name
    [Parameter(Mandatory)]
    [string]
    $Organisation,

    # Your Personal Access Token. The user name is irrelevant
    [Parameter(Mandatory)]
    [pscredential]
    $PersonalAccessToken,

    # The desired agent pool name. Defaults to 'default'
    $AgentPoolName = 'default',

    $LabName = 'NestedBuildWorker'
)

New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV
Add-LabVirtualNetworkDefinition -Name $LabName -AddressSpace 192.168.10.0/28
Add-LabVirtualNetworkDefinition -Name 'Default Switch' -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet' }

$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch 'Default Switch' -UseDhcp
Add-LabMachineDefinition -Name BLD01 -Memory ((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 0.75) -Roles HyperV,TfsBuildWorker -OperatingSystem 'Windows Server 2019 Datacenter (Desktop Experience)' -NetworkAdapter $netAdapter

$role = Get-LabMachineRoleDefinition -Role TfsBuildWorker -Properties @{
        Organisation = $Organisation
        PAT          = $PersonalAccessToken.GetNetworkCredential().Password
    }
Add-LabMachineDefinition -Name AzDevOps -Roles $role -SkipDeployment

Install-Lab
