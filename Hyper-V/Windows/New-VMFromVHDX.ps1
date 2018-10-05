#Requires -RunAsAdministrator

[CmdletBinding()]
param(   
    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [Parameter(Mandatory=$true)]
    [int64]$MemoryStartupBytes,

    [int64]$VMProcessorCount = 4,

    [string]$VMSwitchName = 'vSwitchExternal'
)

$ErrorActionPreference = 'Stop'

# Get default VHD path (requires administrative privileges)
$vmms = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
$vmmsSettings = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData
$vhdxPath = Join-Path $vmmsSettings.DefaultVirtualHardDiskPath "$VMName.vhdx"

if(Test-Path $vhdxPath)
{
    # Create VM
    Write-Verbose 'Creating VM...'
    $vm = New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $MemoryStartupBytes -VHDPath $vhdxPath -SwitchName $VMSwitchName
    $vm | Set-VMProcessor -Count $VMProcessorCount
    $vm | Get-VMIntegrationService -Name "Gastdienstschnittstelle" | Enable-VMIntegrationService -Passthru
    $vm | Start-VM

    # Wait for installation complete
    Write-Verbose 'Waiting for VM integration services...'
    Wait-VM -Name $vmName -For Heartbeat

    # Return the VM created.
    Write-Verbose 'All done!'
    $vm
}