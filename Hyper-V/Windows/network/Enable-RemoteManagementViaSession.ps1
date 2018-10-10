[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.Runspaces.PSSession[]]$Session
)

$ErrorActionPreference = 'Stop'

Invoke-Command -Session $Session { 
    # Enable remote administration
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
    Enable-WSManCredSSP -Role server -Force

    # Enable RDP
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0

    # Default rule is for 'Local Subnet' only. Change to 'Any'.
    Set-NetFirewallRule -DisplayName 'Windows-Remoteverwaltung (HTTP eingehend)' -RemoteAddress Any
    
    # Enable RDP and Ping in Firewall
    Enable-NetFirewallRule -DisplayName 'Datei- und Druckerfreigabe (Echoanforderung - ICMPv4 eingehend)'
    Enable-NetFirewallRule -DisplayGroup "Remotedesktop"

    # Enable Authentication for RDP
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1

} | Out-Null
