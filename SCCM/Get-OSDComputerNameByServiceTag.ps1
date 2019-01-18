########################
# Variable Declaration #
########################

$apiKey = ""

######################
# Header Declaration #
######################

$header = @{}
$header.Add("Accept","application/json")
$header.Add("Authorization", "Bearer $apiKey")

########################
# Function Delcaration #
########################

function getSerialNumber()
{
    $serialNumber = (Get-WmiObject -Class Win32_BIOS | Select-Object SerialNumber).SerialNumber

    if($serialNumber)
    {
        return $serialNumber
    }
}

function getAssetNameBySerial($serial)
{
    $snipeAPI = "https://snipe.<DOMAIN>.de/api/v1/hardware?search=$serial"

    $result = Invoke-RestMethod -Method Get -Uri $snipeAPI -ContentType 'application/json'-Header $header

    $name = ($result.rows).name

    if($name)
    {
        if(($name.StartsWith("NBW")) -or ($name.StartsWith("WKS")))
        {
            return $name
        }
    }

    return $false
}

function setOSDComputerName($OSDComputerName)
{    
    $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
    $TSEnv.Value("OSDComputerName") = "$OSDComputerName"
}

#############
# Main Code #
#############

$assetSerial = getSerialNumber
$assetName = getAssetNameBySerial($assetSerial)

if(!$assetName)
{
    [Environment]::Exit(1)
}

setOSDComputerName($assetName)
