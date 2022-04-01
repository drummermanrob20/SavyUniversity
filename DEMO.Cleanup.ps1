$ResourceGroupName = 'DEMO'
$RemoteResourceGroup = 'Sandbox'
$VNET = Get-AzVirtualNetwork -ResourceGroupName $RemoteResourceGroup
$VNETPeer = Get-AzVirtualNetworkPeering -VirtualNetworkName $VNET.Name -ResourceGroupName $RemoteResourceGroup

$Answer = Read-Host "Are you sure you want to remove the resource group $ResourceGroupName and all of its components? [Y/N]"

if ($Answer -eq 'Y') {

    if ($VNETPeer) {
        Write-Verbose "Removing network peer from the remote side in $RemoteResourceGroup..."
        Remove-AzVirtualNetworkPeering -Name $VNETPeer.Name -VirtualNetworkName $VNET.Name -ResourceGroupName $RemoteResourceGroup -Force
        Write-Verbose "Network peer removed from $RemoteResourceGroup."
    }
    else {
        Write-Output "No remote network peer was found in $RemoteResourceGroup."
    }

    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if ($rg) {
        Write-Verbose "Removing resource group $ResourceGroupName.  This may take a few minutes..."
        Remove-AzResourceGroup -Name $ResourceGroupName -Force
        Write-Verbose "Removing resource group $ResourceGroupName completed."
    }
    else {
        Write-Output "No resource group called $ResourceGroupName was found."
    }
}