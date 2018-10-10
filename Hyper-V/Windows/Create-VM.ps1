# Author: Marc Werner
# Date: 05.10.2018
# Description: Create Hyper-V from Windows 10 ISO with autounattend file

##########################
## Variable Declaration ##
##########################

$isoFile = '.\Win10_1809_German_x64.iso'

$ComputerName = $env:computername + "-VM1"
$AdministratorPassword = "UDGvm2018"

$Version = "Windows10Professional"
$Edition = "Windows 10 Pro"
$Locale = "de-DE"

## VM Details ##

$VMProcessorCount = 4
$MemoryStartupBytes = 2GB
$VHDXSizeBytes = 75GB
$switchName = 'vSwitchNAT'

## Network Details ##

$ipAddress = "192.168.222.10"
$prefix = 24
$gateway = "192.168.222.1"
$dns1 = "8.8.8.8"
$dns2 = "8.8.4.4"
$networkCategroy = "Private"

###############################
## Detection Method Variable ##
###############################

$registryPath = "HKLM:\SOFTWARE\UDG"
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
    ## Create new Switch for Internal
    New-VMSwitch -SwitchName $switchName -SwitchType Internal
    
    ## Define IP address for Switch
    New-NetIPAddress -IPAddress 192.168.222.1 -PrefixLength 24 -InterfaceAlias "vEthernet ($switchName)"
    
    ## Activate NAT
    New-NetNat -Name NAT-Network -InternalIPInterfaceAddressPrefix 192.168.222.0/24
}

##################################################
## Create Hyper-V VM from previous created VHDX ##
##################################################

.\New-VMFromVHDX.ps1 -VMName $ComputerName -MemoryStartupBytes $MemoryStartupBytes -VMProcessorCount $VMProcessorCount -VMSwitchName $switchName

Start-Sleep -Seconds 300

##########################
## Create Session to VM ##
##########################

$Session = .\network\New-VMSession.ps1 -VMName $ComputerName -AdministratorPassword $AdministratorPassword

###########################
## Set IP Address for VM ##
###########################

.\network\Set-NetIPAddressViaSession.ps1 -Session $Session -IPAddress $ipAddress -PrefixLength $prefix -DefaultGateway $gateway -DnsAddresses $dns1,$dns2 -NetworkCategory $networkCategroy

#####################################
## Enable Remote Management for VM ##
#####################################

.\network\Enable-RemoteManagementViaSession.ps1 -Session $Session

Remove-PSSession -Session $Session

##########################################
## Set RegKey for SCCM Detection Method ##
##########################################

New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null