function Get-RandomPassword
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [int] $Length,
             [Parameter(Mandatory=$false, Position=1)]
             [switch] $SpecialCharacter
        )

        $characters = "abcdefghkmnoprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ123456789"

        if($SpecialCharacter.IsPresent)
        {
            $characters = "a$bcdefgh!kmn#oprst$uvwxyzABCDEFGHKLMN$PRSTUVWX&YZ12345#6789!$&#"
        }

        for($i=0;$i -lt [int]$length;$i++)
        {
            $password += $characters.ToCharArray() | Get-Random
        }

        return $password
}