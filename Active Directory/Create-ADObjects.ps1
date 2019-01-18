################################

$company = "<COMPANY NAME>"
$logon = "<DOMAIN>"

################################

function Get-RandomPassword()
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [int] $length,
             [Parameter(Mandatory=$true, Position=1)]
             [bool] $specialCharacter
        )

    $characters = "abcdefghkmnoprstuvwxyzACDeEFGHKLMNPRSTUVWXYZ123456789"

    if($specialCharacter)
    {
        $characters = "a$bcdefgh!kmn#oprst$uvwxyzACDeEFGHKLMN$PRSTUVWX&YZ12345#6789!$&#"
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
             [string] $Company,
             [Parameter(Mandatory=$true, Position=4)]
             [string] $Logon,
             [Parameter(Mandatory=$true, Position=5)]
             [string] $Password
        )

    if(!$UserName)
    {
        $UserName = "${firstName}.${lastName}"
    }

    $Name = "$firstName $lastName"

    New-ADUser -Name $name -GivenName $firstName -Surname $lastName -SamAccountName $UserName -UserPrincipalName "${UserName}@mcshape.com" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -DisplayName $Name -PasswordNeverExpires $true -Path "OU=Benutzer,OU=${Company},DC=${Logon},DC=int" -PassThru | Enable-ADAccount
}

function CreateADUser()
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [object] $UserObject
        )

    $Password = Get-RandomPassword -length $UserObject[5] -specialCharacter $UserObject[6]

    Add-ADUserWithPassword -firstName $UserObject[0] -lastName $UserObject[1] -UserName $UserObject[2] -Company $UserObject[3] -Logon $UserObject[4] -Password $Password
   
    return $UserObject[2] + " / " + $Password
}

# Create "<ADMIN USER>" AD User with special characters
$UserObject = @("<ADMIN USER>", "<ADMIN USER>", "<ADMIN USER>", $company, $logon, 14, $true) # FirstName, LastName, [Username], Company, Logon, Password Length, Password Complexity
CreateADUser -UserObject $UserObject

# Create "<ADMIN USER>" AD User without special characters
$UserObject = @("<ADMIN USER>", "<ADMIN USER>", "<ADMIN USER>", $company, $logon, 8, $false) # FirstName, LastName, [Username], Company, Logon, Password Length, Password Complexity
CreateADUser -UserObject $UserObject
