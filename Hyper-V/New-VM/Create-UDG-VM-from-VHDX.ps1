$vmName = 'Windows 10 1809'
$VMProcessorCount = 4
$MemoryStartupBytes = 4GB
$switchName = 'vSwitchExternal'

$registryPath = "HKLM:\SOFTWARE\UDG"
$name = "Windows 10 1809 Hyper-V VM"
$value = "1.0"

if( -not (Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue))
{
    $networkName = (Get-NetAdapter -Physical | Where status -eq 'Up').Name

    New-VMSwitch -name $switchName -NetAdapterName $networkName -AllowManagementOS $true
}

$vmms = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
$vmmsSettings = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData
$vhdxPath = Join-Path $vmmsSettings.DefaultVirtualHardDiskPath "$vmName.vhdx"

Copy-Item -Path ".\$vmName.vhdx" -Destination $vhdxPath

.\New-VMFromVHDX.ps1 -VMName $vmName -MemoryStartupBytes $MemoryStartupBytes -VMProcessorCount $VMProcessorCount -VMSwitchName $switchName

Start-Sleep -Seconds 30

New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null