function Get-RandomPassword()
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [int] $length,
             [Parameter(Mandatory=$true, Position=1)]
             [bool] $specialCharacter
        )

    $characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890"

    if($specialCharacter)
    {
        $characters = "a$bcdefghi!klmn#oprst$uvwxyzABCDEFGHKLMNO$PRSTUVWX&YZ12345#67890!$&#"
    }

    for($i=0;$i -lt [int]$length;$i++)
    {
        $password += $characters.ToCharArray() | Get-Random
    }

    return $password
}

function Add-ADUserWithPassword()
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [string] $firstName,
             [Parameter(Mandatory=$true, Position=1)]
             [string] $lastName,
             [Parameter(Mandatory=$false, Position=2)]
             [string] $UserName,
             [Parameter(Mandatory=$true, Position=3)]
             [string] $Password
        )

    if(!$UserName)
    {
        $UserName = "${firstName}.${lastName}"
    }

    New-ADUser -Name "$firstName $lastName" -GivenName $firstName -Surname $lastName -SamAccountName $UserName -UserPrincipalName pgibbins@corp.contoso.com -AccountPassword (Read-Host -AsSecureString $Password) -PassThru | Enable-ADAccount
}

## Create mcsAdmin
$password = Get-RandomPassword -length 16 -specialCharacter $true

Add-ADUserWithPassword -firstName "MCS" -lastName "Admin" -UserName "mcsAdmin" -Password $password