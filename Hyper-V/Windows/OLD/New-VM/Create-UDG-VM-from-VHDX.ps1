$vmName = $env:computername + "-Win10"
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

.\New-VMFromVHDX.ps1 -VMName $vmName -MemoryStartupBytes $MemoryStartupBytes -VMProcessorCount $VMProcessorCount -VMSwitchName $switchName

Start-Sleep -Seconds 30

New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null