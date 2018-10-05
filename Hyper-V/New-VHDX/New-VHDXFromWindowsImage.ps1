#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$Edition,

    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [Parameter(Mandatory=$true)]
    [uint64]$VHDXSizeBytes
)

$ErrorActionPreference = 'Stop'

# Get default VHD path (requires administrative privileges)
#$vmms = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
#$vmmsSettings = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData
#$vhdxPath = Join-Path $vmmsSettings.DefaultVirtualHardDiskPath "$VMName.vhdx"

# Create unattend.xml
$unattendPath = "autounattend.xml"
$vhdxPath = Join-Path "..\New-VM\" "$VMName.vhdx"

# Create VHDX from ISO image
Write-Verbose 'Creating VHDX from image...'
. .\tools\Convert-WindowsImage.ps1
Convert-WindowsImage -SourcePath $SourcePath -Edition $Edition -VHDPath $vhdxPath -SizeBytes $VHDXSizeBytes -VHDFormat VHDX -DiskLayout UEFI -UnattendPath $unattendPath