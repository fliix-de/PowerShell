$networkName = (Get-NetAdapter -Physical | Where status -eq 'Up').Name

New-VMSwitch -name "vSwitchExternal" -NetAdapterName $networkName -AllowManagementOS $true