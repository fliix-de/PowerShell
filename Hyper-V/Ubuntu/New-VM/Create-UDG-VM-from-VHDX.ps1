$vmName = "Ubuntu 18.04"
$fqdn = "ubuntu-1804"
$rootPassword = "<PASSWORD>"
$VMProcessorCount = 2
$MemoryStartupBytes = 1GB
$VMSwitchName = 'vSwitchExternal'

.\New-VMFromVHDX.ps1 -VMName $vmName -FQDN $fqdn -RootPassword $rootPassword -MemoryStartupBytes $MemoryStartupBytes -VMProcessorCount $VMProcessorCount -VMSwitchName $VMSwitchName
