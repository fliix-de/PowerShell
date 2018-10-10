# Author: Marc Werner
# Date: 08.10.2018
# Description: Set IP address to VM and activate Connectivity

##########################
## Variable Declaration ##
##########################

$ComputerName = $env:computername + "-VM1"
$AdministratorPassword = "UDGvm2018"

$ipAddress = "192.168.222.10"
$prefix = 24
$gateway = "192.168.222.1"
$dns1 = "8.8.8.8"
$dns2 = "8.8.4.4"
$networkCategroy = "Private"

##########################
## Create Session to VM ##
##########################

$Session = .\New-VMSession.ps1 -VMName $ComputerName -AdministratorPassword $AdministratorPassword

###########################
## Set IP Address for VM ##
###########################

.\Set-NetIPAddressViaSession.ps1 -Session $Session -IPAddress $ipAddress -PrefixLength $prefix -DefaultGateway $gateway -DnsAddresses $dns1,$dns2 -NetworkCategory $networkCategroy

#####################################
## Enable Remote Management for VM ##
#####################################

.\Enable-RemoteManagementViaSession.ps1 -Session $Session

Remove-PSSession -Session $Session