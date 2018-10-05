param(
    [Parameter(Mandatory=$True)]
    [string]$assetSerial
)

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

function getAssetNameBySerial($serial)
{
    $snipeAPI = "https://snipe.udg.de/api/v1/hardware?search=$serial"

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

#############
# Main Code #
#############

$assetName = getAssetNameBySerial($assetSerial)

if(!$assetName)
{
    return "No Asset found"
}
else
{
    return $assetName
}