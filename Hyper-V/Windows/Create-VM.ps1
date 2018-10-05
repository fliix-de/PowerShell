# Author: Marc Werner
# Date: 05.10.2018
# Description: Create Hyper-V from Windows 10 ISO with autounattend file


##########################
## Variable Declaration ##
##########################

$isoFile = '.\Win10_1809_German_x64.iso'

$ComputerName = $env:computername + "-VM1"
$AdministratorPassword = "Password"

$Version = "Windows10Professional"
$Edition = "Windows 10 Pro"
$Locale = "de-DE"

$VMProcessorCount = 4
$MemoryStartupBytes = 4GB
$VHDXSizeBytes = 75GB
$switchName = 'vSwitchExternal'

###############################
## Detection Method Variable ##
###############################

$registryPath = "HKLM:\SOFTWARE\Company"
$name = "Windows 10 1809 Hyper-V VM"
$value = "1.0"

##################################
## Create Autounattend.xml file ##
##################################

.\New-AutounattendFile.ps1 -AdministratorPassword $AdministratorPassword -Version $Version -ComputerName $ComputerName -Locale $Locale

##########################################################
## Create VHDX From Windows ISO File + Autounattend.xml ##
##########################################################

.\New-VHDXFromWindowsImage.ps1 -SourcePath $isoFile -Edition $Edition -VMName $ComputerName -VHDXSizeBytes $VHDXSizeBytes

###################################################################################################################

###############################
## Check (and Create) Switch ##
###############################

if( -not (Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue))
{
    $networkName = (Get-NetAdapter -Physical | Where status -eq 'Up').Name

    New-VMSwitch -name $switchName -NetAdapterName $networkName -AllowManagementOS $true
}

##################################################
## Create Hyper-V VM from previous created VHDX ##
##################################################

.\New-VMFromVHDX.ps1 -VMName $ComputerName -MemoryStartupBytes $MemoryStartupBytes -VMProcessorCount $VMProcessorCount -VMSwitchName $switchName

#Start-Sleep -Seconds 60

##########################################
## Set RegKey for SCCM Detection Method ##
##########################################

#New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null