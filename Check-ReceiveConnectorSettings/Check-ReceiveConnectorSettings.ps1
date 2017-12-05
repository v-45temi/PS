
<#
.Synopsis
   This script checks the receive connectors settings and compare them to the defaults.
.DESCRIPTION
   This script checks the receive connectors settings and compare them to the defaults.

.EXAMPLE
   Check-ReceiveConnectorSettings
.EXAMPLE
   Check-ReceiveConnectorSettings
#>


function Script:Check-ReceiveConnectorSettings
{
    [CmdletBinding()]
    Param
    ()

    #Load Microsoft Exchange Snappin 
    If ((Get-PSSnapin | where {$_.Name -match "Microsoft.Exchange.Management.PowerShell.*"}) -eq $null) 
            {  
    Write-Host -ForegroundColor Green "`n Loading Microsoft Exchange Management Powershell Snapin."
    Add-PSSnapin *Microsoft.Exchange.Management.PowerShell.* 
    } 
    Write-Host -ForegroundColor Green "`n Configuring Active Directory Settings to 'View entire forest'."
    Set-ADServerSettings -ViewEntireForest:$true 
    
    #Loading default setting
    Write-Host -ForegroundColor Green "`n Loading default settings."
    
    New-Item -Name DefaultReceiveConSettings.txt -Path $env:Temp -ItemType "File" -Value ('"TransportRole","Name","Authmechanism","Bindings","Permissiongroups","RemoteIPranges","Enabled"
    "HubTransport","Default ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","0.0.0.0:2525,[::]:2525","ExchangeUsers, ExchangeServers, ExchangeLegacyServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
    "HubTransport","Client Proxy ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","[::]:465,0.0.0.0:465","ExchangeUsers, ExchangeServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
    "FrontendTransport","Default Frontend ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","[::]:25,0.0.0.0:25","AnonymousUsers, ExchangeServers, ExchangeLegacyServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
    "FrontendTransport","Outbound Proxy Frontend ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","[::]:717,0.0.0.0:717","ExchangeServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
    "FrontendTransport","Client Frontend ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS","[::]:587,0.0.0.0:587","AnonymousUsers, ExchangeUsers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
    ') |Out-Null

    Import-csv $env:Temp\DefaultReceiveConSettings.txt |Export-Csv $env:Temp\DefaultReceiveConSettings.csv -NoTypeInformation -Encoding UTF8    
    
    #Loading receive connectors settings
    Write-Host -ForegroundColor Green "`n Loading receive connectors settings."
    
    #Getting receive connector settings
    $script:receiveconnectors=Get-ReceiveConnector
    [System.Collections.ArrayList]$script:collection = New-Object System.Collections.ArrayList($null)
    foreach ($receivecon in $receiveconnectors)
    {
     [Pscustomobject]$script:table = @{            
            Name = (@($receivecon.Name) -join ",")        
            Bindings = (@($receivecon.Bindings)  -join ",")             
            RemoteIPranges = (@($receivecon.RemoteIPranges) -join ",")  
            Authmechanism = (@($receivecon.Authmechanism) -join ",")  
            Permissiongroups = (@($receivecon.Permissiongroups) -join ",")  
            Enabled=(@($receivecon.Enabled) -join ",")  
            TransportRole = (@($receivecon.TransportRole)-join ",")  
             }
     $script:collection.Add((New-Object PSObject -Property $table)) | Out-Null                                                
    } 

    $script:collection | Export-Csv  "$env:temp\ReceiveConSettings.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ','
    $script:file1=Import-Csv $env:Temp\ReceiveConSettings.csv
    $script:file2=Import-Csv $env:Temp\DefaultReceiveConSettings.csv 
    
    #Comparing with default settings
    Write-Host -ForegroundColor Green "`n Comparing with default settings."
    if ((Compare-Object $file1 $file2 -Property TransportRole,Authmechanism,Bindings,RemoteIpRanges,Permissiongroups,Enabled |?{$_.SideIndicator -eq '<='}) -ne $null)
    {
    Write-Host -ForegroundColor Green "`n Receive connector settings, apart from the Defaults:"
    Compare-Object $file1 $file2 -Property TransportRole,Authmechanism,Bindings,RemoteIpRanges,Permissiongroups,Enabled -SyncWindow 100 |?{$_.SideIndicator -eq '<='} |ft -Wrap
    
    Write-Host -ForegroundColor Green "`n Default receive connector settings should be the following:"

    Compare-Object $file1 $file2 -Property TransportRole,Authmechanism,Bindings,RemoteIpRanges,Permissiongroups,Enabled -SyncWindow 100 |?{$_.SideIndicator -eq '=>'} |ft -Wrap
    }
    Else
    {
    Write-Host -ForegroundColor Yellow "`n All receive connector settings are set as default. No changes needed."
    }

    Remove-Item -Path $env:Temp\ReceiveConSettings.csv 
    Remove-Item -Path $env:Temp\DefaultReceiveConSettings.csv 
    Remove-Item -Path $env:Temp\DefaultReceiveConSettings.txt 

}

Check-ReceiveConnectorSettings


