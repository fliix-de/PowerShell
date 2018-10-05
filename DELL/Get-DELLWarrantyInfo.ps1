########################
# Variable Declaration #
########################

$apiKey = ""

########################
# Function Delcaration #
########################

function convertServiceTagToExpressCode($serviceTag)
{
    $potenz = $serviceTag.Length - 1

    $expressServiceCode = 0

    for($i=0; $i -lt $serviceTag.Length; $i++)
    {
        if([int][char]$serviceTag[$i] -gt 64)
        {
            $code = [int][char]$serviceTag[$i]-55
        }
        else
        {
            $code = [convert]::ToInt32($serviceTag[$i], 10)
        }

        $potenzValue = [System.Math]::Pow(36,$potenz)
        
        $value = $code * [int64]$potenzValue

        $expressServiceCode = $expressServiceCode + $value

        $potenz--
    }

    return $expressServiceCode    
}

function getSerialNumber()
{
    $serialNumber = (Get-WmiObject -Class Win32_BIOS | Select-Object SerialNumber).SerialNumber

    if($serialNumber)
    {
        return $serialNumber
    }
}

function getWarrantyInfo($serviceTag)
{
    $dellAPI = "https://api.dell.com/support/assetinfo/v4/getassetsummary/${serviceTag}?apikey=${apiKey}"

    $dellAPI

    $response = Invoke-RestMethod -Method Get -Uri $dellAPI -ContentType 'application/xml'
    
    return $response
}

#############
# Main Code #
#############

$serviceTag = getSerialNumber

$asset = getWarrantyInfo($serviceTag)

$asset.AssetSummaryDTO.AssetSummaryResponse.AssetEntitlementData.AssetEntitlement
#$asset.AssetSummaryDTO.AssetSummaryResponse.AssetHeaderData

$startDate = $asset.AssetSummaryDTO.AssetSummaryResponse.AssetEntitlementData.AssetEntitlement.StartDate
$endDate = $asset.AssetSummaryDTO.AssetSummaryResponse.AssetEntitlementData.AssetEntitlement.EndDate

$expressServiceCode = convertServiceTagToExpressCode($serviceTag)

"Service Tag: " + $serviceTag
"Express Service Code: " + $expressServiceCode
"Warranty: " + $startDate[0] + " to " + $endDate[0]