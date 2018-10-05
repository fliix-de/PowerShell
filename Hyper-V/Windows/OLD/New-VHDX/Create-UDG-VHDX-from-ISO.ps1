##########################
## Variable Declaration ##
##########################

$isoFile = '.\Win10_1809_German_x64.iso'

$ComputerName = $env:computername + "-Win10"
$AdministratorPassword = "UDGvm2018"

$Version = "Windows10Professional"
$Edition = "Windows 10 Pro"
$Locale = "de-DE"

$VHDXSizeBytes = 75GB

##################################
## Create Autounattend.xml file ##
##################################

.\New-AutounattendFile.ps1 -AdministratorPassword $AdministratorPassword -Version $Version -ComputerName $ComputerName -Locale $Locale

##########################################################
## Create VHDX From Windows ISO File + Autounattend.xml ##
##########################################################

.\New-VHDXFromWindowsImage.ps1 -SourcePath $isoFile -Edition $Edition -VMName $ComputerName -VHDXSizeBytes $VHDXSizeBytes