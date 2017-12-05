<#
.Synopsis
   Recreates all system mailboxes
.DESCRIPTION
   If you execute this script, you will recreate all system mailboxes
.EXAMPLE
    Recreate-SystemMailboxes -Database <Database Name>
#>


function Recreate-SystemMailboxes
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (

        # Database
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $DataBase
    )

    Begin
    {
        If ((Get-WindowsFeature | where {$_.Name -match "Rsat-adds*"}) -eq $null) 
        { 
            Install-WindowsFeature RSAT-ADDS -Verbose
        } 

        If ((Get-PSSnapin | where {$_.Name -match "Microsoft.Exchange.Management.PowerShell.*"}) -eq $null) 
        {  
            Add-PSSnapin *Microsoft.Exchange.Management.PowerShell.* -Verbose
        } 
        
        Set-ADServerSettings -ViewEntireForest:$true -Verbose
        Import-Module ActiveDirectory -Verbose
    }
    
    Process
    {
        If ((Get-Mailbox -Arbitration).count -gt '0') 
        { 
            Get-ADUser -Filter * |? {$_.Name -like '*systemmailbox*'} |Remove-ADUser -Confirm:$false -Verbose
            Get-ADUser -Filter * |? {$_.Name -like '*Migration*'} |Remove-ADUser -Confirm:$false -Verbose
            Get-ADUser -Filter * |? {$_.Name -like '*federated*'} |Remove-ADUser -Confirm:$false -Verbose
            Get-ADUser -Filter * |? {$_.Name -like '*Discovery*'} |Remove-ADUser -Confirm:$false -Verbose

        } 


        $Database=Get-MailboxDatabase -Server (hostname)|select -First 1
        Set-Location $env:ExchangeInstallPath\Bin -Verbose
        .\Setup.exe /PrepareAD /IacceptExchangeServerLicenseTerms 
        
        if (((Get-Process |? {$_.ProcessName -match 'ExSetup'}) -eq $Null) -eq $false) 
        {
            Start-Sleep -Seconds 60 -Verbose
        }
        else
        {
        $users=(Get-ADUser -Filter * |? {$_.name -like '*Systemmailbox*'}).Name
            foreach ($user in $users)
            {
            Enable-Mailbox -Identity $user -Arbitration -Database $DataBase -Verbose
            }
        Enable-Mailbox -Identity (Get-ADUser -Filter * |? {$_.name -like '*Discovery*'}).Name -Discovery -Database $DataBase -Verbose
        Enable-Mailbox -Identity (Get-ADUser -Filter * |? {$_.name -like '*Federated*'}).Name -Arbitration -Database $DataBase -Verbose
        Enable-Mailbox -Identity (Get-ADUser -Filter * |? {$_.name -like '*Migration*'}).Name -Arbitration -Database $DataBase -Verbose
        sleep 5
        Set-Mailbox -Arbitration -Identity *Migration* -Management $true  -Verbose -Confirm:$false -Force
        Set-Mailbox -Arbitration -Identity "SystemMailbox{bb558c35-97f1-4cb9-8ff7-d53741dc928c}" -OABGen $true -Confirm:$false -Force
        Get-OfflineAddressBook |Update-OfflineAddressBook
        }
    }
    End
    {
    Get-Mailbox -Arbitration
    }
}
