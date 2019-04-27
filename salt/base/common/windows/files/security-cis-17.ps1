$plist =
'/set /subcategory:"Credential Validation" /success:Enable /failure:Enable',
'/set /subcategory:"Application Group Management" /success:Enable /failure:Enable',
'/set /subcategory:"Computer Account Management" /success:Enable /failure:Enable',
'/set /subcategory:"Other Account Management Events" /success:Enable /failure:Enable',
'/set /subcategory:"Security Group Management" /success:Enable /failure:Enable',
'/set /subcategory:"User Account Management" /success:Enable /failure:Enable',
'/set /subcategory:"Process Creation" /success:Enable /failure:Disable',
'/set /subcategory:"Account Lockout" /success:Enable /failure:Disable',
'/set /subcategory:"Logoff" /success:Enable /failure:Disable',
'/set /subcategory:"Logon" /success:Enable /failure:Enable',
'/set /subcategory:"Other Logon/Logoff Events" /success:Enable /failure:Enable',
'/set /subcategory:"Special Logon" /success:Enable /failure:Disable',
'/set /subcategory:"Removable Storage" /success:Enable /failure:Enable',
'/set /subcategory:"Audit Policy Change" /success:Enable /failure:Enable',
'/set /subcategory:"Authentication Policy Change" /success:Enable /failure:Disable',
'/set /subcategory:"Sensitive Privilege Use" /success:Enable /failure:Enable',
'/set /subcategory:"IPsec Driver" /success:Enable /failure:Enable',
'/set /subcategory:"Other System Events" /success:Enable /failure:Enable',
'/set /subcategory:"Security State Change" /success:Enable /failure:Disable',
'/set /subcategory:"Security System Extension" /success:Enable /failure:Enable',
'/set /subcategory:"System Integrity" /success:Enable /failure:Enable'

$cmd = "C:\Windows\System32\auditpol.exe"

foreach ($param in $plist) {
        $p = Start-Process -FilePath $cmd -ArgumentList $param -NoNewWindow -PassThru -Wait
        if ( $p.ExitCode -ne 0) {
                Write-Host "Auditpol.exe failed with code: " $p.ExitCode
                return $p.ExitCode
        }
}
