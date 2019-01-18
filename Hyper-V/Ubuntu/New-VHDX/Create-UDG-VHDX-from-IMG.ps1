$imgFile = ".\ubuntu-18.04-server-cloudimg-amd64.img"
$vmName = "Ubuntu 18.04"
$fqdn = "ubuntu-1804"
$rootPassword = "<PASSWORD>"
$VHDXSizeBytes = 60GB

choco install qemu-img -y

.\New-VHDXFromUbuntuImage.ps1 -SourcePath $imgFile -VMName $vmName -FQDN $fqdn -RootPassword $rootPassword -VHDXSizeBytes $VHDXSizeBytes
