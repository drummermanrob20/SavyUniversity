# uses a series of constructions to generate attributes of a virtual machine, its virtual network, and its credentials
# the attributes are stored together in a VMConfig and then is passed to the VM creation at the end
# time: 3-4 minutes

param (
    [Parameter(Mandatory)]
    [int]$VMNumber
)

$VerbosePreference = 'Continue'

# identify resource group and region
$ResourceGroupName = "DEMO"
$Location = "eastus2"
Write-Verbose "Operating in the Resource Group called $ResourceGroupName in the region $Location."

# identify the subnet to use on the existing virtual network
$VirtualNetwork = Get-AzVirtualNetwork -Name "DEMO_VNET"
$SubnetId = $VirtualNetwork.Subnets.Id

# VM construction
for ($v = 1; $v -le $VMNumber; $v++) {
    # construct network adapter
    $NICName = "DEMO-VM-" + $v + "_NIC"
    $NICSplat = @{
        Name = $NICName
        ResourceGroupName = $ResourceGroupName
        Location = $Location
        SubnetId = $SubnetId
    }
    $NIC = New-AzNetworkInterface @NICSplat

    # construct VM local credentials
    $LocalAdmin = "RStapleton"
    $LocalPass = ConvertTo-SecureString "SomethingB3tt3r!@#" -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential ($LocalAdmin,$LocalPass)

    # construct VM attributes
    $Name = "DEMO-VM-" + $v
    $Size = "Standard_B1ms"

    # construct VM object
    $VM = New-AzVMConfig -VMName $Name -VMSize $Size
    $VM = Set-AzVMOperatingSystem -VM $VM -Windows -ComputerName $Name -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC.Id
    $VM = Set-AzVMSourceImage -VM $VM -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter-Core' -Version latest

    # make VM
    New-AzVM -VM $VM -ResourceGroupName $ResourceGroupName -Location $Location -AsJob
}

do {
    $JobVMBuild = Get-Job | Where-Object {$_.State -eq 'Running'}
    Write-Verbose "Working..."
    Start-Sleep -Seconds 10
} while ($JobVMBuild)
Write-Verbose "Construction completed."