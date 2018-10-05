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