########################
# Variable Declaration #
########################

$apiKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjIyZGEzZDhiZmU2ZDEyYjhmMTFlZThkNjE2MTI1N2E0MGYwNmQzZmE3ZTY5MTY1MzEwYzA5YmVhMjg3MTBmNmI4ZWU0ZjBiZDNjMGFjZDM4In0.eyJhdWQiOiIxIiwianRpIjoiMjJkYTNkOGJmZTZkMTJiOGYxMWVlOGQ2MTYxMjU3YTQwZjA2ZDNmYTdlNjkxNjUzMTBjMDliZWEyODcxMGY2YjhlZTRmMGJkM2MwYWNkMzgiLCJpYXQiOjE1MzQxNTkzNzIsIm5iZiI6MTUzNDE1OTM3MiwiZXhwIjoxNTY1Njk1MzcyLCJzdWIiOiI0MDIiLCJzY29wZXMiOltdfQ.GBF4oV5K5eGOpld68PihNq8FlV64XAGayMNojZyzmYlyvZqPIgvrq_Tbx1TPpvqPsxFH-bXlyahrUHqvPSC_rtPHzvYVo_xy4rr1ev8ZOV6cq_dqNBir5PaM4sxEc34x0JcjVHg8emMf4ZZ1Jg2mC_pil9UKjwu5JnxczAUBdpOfujr5t4EpiyfTWZdxslZhdhS1hLnSAYq2JFEy5Ti6LQZ-NAu6L0KvxNR3PPcuNJHfTUKtHhepdHa6kyF-tT6HI0w8q_Kia5oKgzw5Oo6HumwADvSNFTjKg0w43RPksrOqKPG-xBYfqVbtgXiscOL8ClK-YXIVlkuUC9e6qovQPyJ6FgylZYo9uQlF7MLxAHsZeLwLakXvPsqwKdgJq6_kDKYH2FJUutEN7UHeO2pkonOUJ-8AWV3ylm33esyRYZkgvdLuEn9OUJmVLcNxZEYimlYhOk4VSVmfAadwAwWRV5I_I4uH5Wn1gFFaE4IUsCadDQmTOyRiC0stA4h6qKxhjz0bi3mF3tgajW2Vdhss-Sp5x3iOO-9_nfnQI-f-hqJqCgNBTRSbzIcW79BMYqHJbe39Z703XcTJXNzNgPmfPTP6Y-t_-hyvEb4cQKno6dunXNQMz67cfry4yVcKXfW6VFmyMU_saMsj299Uz7D6JapBh3hVSKVmqnABMgTd_0I"

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