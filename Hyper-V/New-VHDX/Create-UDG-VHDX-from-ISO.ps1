$isoFile = '.\Win10_1809_German_x64.iso'
$Edition = "Windows 10 Pro"
$vmName = 'Windows 10 1809'
$VHDXSizeBytes = 75GB

.\New-VHDXFromWindowsImage.ps1 -SourcePath $isoFile -Edition $Edition -VMName $vmName -VHDXSizeBytes $VHDXSizeBytes