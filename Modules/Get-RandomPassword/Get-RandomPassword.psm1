function Get-RandomPassword
{
    Param
        (
             [Parameter(Mandatory=$true, Position=0)]
             [int] $Length,
             [Parameter(Mandatory=$false, Position=1)]
             [switch] $SpecialCharacter
        )

        $characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890"

        if($SpecialCharacter.IsPresent)
        {
            $characters = "a$bcdefghi!klmn#oprst$uvwxyzABCDEFGHKLMNO$PRSTUVWX&YZ12345#67890!$&#"
        }

        for($i=0;$i -lt [int]$length;$i++)
        {
            $password += $characters.ToCharArray() | Get-Random
        }

        return $password
}