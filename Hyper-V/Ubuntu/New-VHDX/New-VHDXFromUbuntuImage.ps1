#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [string]$FQDN = $VMName,

    [Parameter(Mandatory=$true, ParameterSetName='RootPassword')]
    [string]$RootPassword,

    [Parameter(Mandatory=$true, ParameterSetName='RootPublicKey')]
    [string]$RootPublicKey,

    [uint64]$VHDXSizeBytes,

    [string]$NetworkConfig,

    [switch]$InstallDocker
)

$ErrorActionPreference = 'Stop'

function New-MetadataIso($IsoFile) {
    # Creates a NoCloud data source for cloud-init.
    #   More info: http://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html

    $instanceId = [Guid]::NewGuid().ToString()
 
    $metadata = @"
instance-id: $instanceId
local-hostname: $VMName
"@

    $sectionRunCmd = @'
runcmd:
 - 'apt-get update'
 - 'echo "eth0: \134\64{eth0}" >> /etc/issue'
 - 'mv /etc/netplan/50-cloud-init.yaml /etc/netplan/80-static.yaml'
 - 'touch /etc/cloud/cloud-init.disabled'
'@

    if ($RootPassword) {
        $sectionPasswd = @"
password: $RootPassword
chpasswd: { expire: False }
ssh_pwauth: True
"@
    } elseif ($RootPublicKey) {
        $sectionPasswd = @"
ssh_authorized_keys:
  - $RootPublicKey
"@
    }

    if ($InstallDocker) {
        $sectionRunCmd += @'

 - 'apt install -y apt-transport-https ca-certificates curl software-properties-common'
 - 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
 - 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
 - 'apt update'
 - 'apt install -y docker-ce'
 - 'apt install -y docker-compose'
 - 'systemctl enable docker'
'@
    }

    $userdata = @"
#cloud-config
hostname: $FQDN
fqdn: $FQDN

$sectionPasswd
$sectionWriteFiles
$sectionRunCmd

power_state:
  mode: reboot
  timeout: 300
"@

    if (-not $NetworkConfig) {
        $NetworkConfig = & .\New-NetworkConfig.ps1 -Dhcp
    }

    $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) $instanceId
    mkdir $tempPath
    try {
        $metadata | Out-File "$tempPath\meta-data" -Encoding ascii
        $userdata | Out-File "$tempPath\user-data" -Encoding ascii
        $networkConfig | Out-File "$tempPath\network-config" -Encoding ascii

        $oscdimgPath = Join-Path $PSScriptRoot '.\tools\oscdimg.exe'
        echo $oscdimgPath
        & {
            $ErrorActionPreference = 'Continue'
            & $oscdimgPath $tempPath $metadataIso -j2 -lcidata
            if ($LASTEXITCODE -gt 0) {
                throw "oscdimg.exe returned $LASTEXITCODE."
            }
        }
    }
    finally {
        rmdir -Path $tempPath -Recurse -Force
        $ErrorActionPreference = 'Stop'
    }
}

# Get default VHD path (requires administrative privileges)
$vmms = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
$vmmsSettings = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementServiceSettingData
$vhdxPath = Join-Path $vmmsSettings.DefaultVirtualHardDiskPath "$VMName.vhdx"
$metadataIso = Join-Path $vmmsSettings.DefaultVirtualHardDiskPath "$VMName-metadata.iso"

# Create metadata ISO image
Write-Verbose 'Creating metadata ISO image...'
New-MetadataIso -IsoFile $metadataIso

# Convert cloud image to VHDX
Write-Verbose 'Creating VHDX from cloud image...'
$ErrorActionPreference = 'Continue'
& {
    & qemu-img.exe convert -f qcow2 $SourcePath -O vhdx -o subformat=dynamic $vhdxPath
}
$ErrorActionPreference = 'Stop'
if ($VHDXSizeBytes) {
    Resize-VHD -Path $vhdxPath -SizeBytes $VHDXSizeBytes
}