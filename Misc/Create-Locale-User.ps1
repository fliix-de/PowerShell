function Get-UserExists
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [string] $Name
        )
    
    if(Get-LocalUser -Name $Name -ErrorAction SilentlyContinue)
    {
        return $true
    }

    return $false
}

function New-DisabledUser
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [string] $Name,
             [Parameter(Mandatory=$true, Position=1)]
             [string] $Password
        )

    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    New-LocalUser -Name $Name -Description "$Name Admin" -AccountNeverExpires -Disabled -Password $securePassword
}

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

$Username = "alocal"

if( -not (Get-UserExists -Name $Username))
{

    $Password = (Get-RandomPassword -length 16 -specialCharacter $true)

    $Password

    New-DisabledUser -Name $Username -Password $Password
}
