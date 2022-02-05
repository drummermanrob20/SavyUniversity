# this script assumes you are already connected to your Azure account

param (
    [Parameter(Mandatory)]
    [string]$VMName
)

$VM = Get-AzVM -Name $VMName -Status
$PowerState = $VM.PowerState
$Name = $VM.Name

if ($PowerState -eq "VM running") {
    Write-Host "About to shut down virtual machine: $Name"
    Stop-AzVM -Name $Name -ResourceGroupName 'Sandbox'
}