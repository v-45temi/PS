<#
.Synopsis
    This script will reset all mail enabled public folder objects.
.DESCRIPTION
    This script will help you to reset the mail enabled public folder object in all Exchange Server Versions. 
    This will not remove the public folder it self, it is recreating the mail objects in Active Directory.
    All of the smtp address assigned to the Public Folders will be set to the new objects again.
    You have the ability to backup the List of all mail enabled public folders, to disable all of them and to enable all of them again and assign the smtp addresses.
    The Filde should be saved in default PowerShell modules folder under a folder with the same name as the script.

.PARAMETER <CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer and OutVariable. For more information, type,
    "get-help about_commonparameters".

.EXAMPLE
    Reset-mailPF will prompt you for the following options:
    1. Backup-MailPublicFolders
    2. Disable-AllMailPublicFolders
    3. Enable-OldMailPublicFolders
#>


#switch button properties
$caption = "Choose Action";
$message = "Hints: Disable-AllMailPublicFolders or Enable-OldMailPublicFolders";
$Backup=new-Object System.Management.Automation.Host.ChoiceDescription "&Backup-MailPublicFolders","Backup-MailPublicFolders";
$Disable = new-Object System.Management.Automation.Host.ChoiceDescription "&Disable-AllMailPublicFolders","Disable-AllMailPublicFolders";
$Enable = new-Object System.Management.Automation.Host.ChoiceDescription "&Enable-OlddMailPublicFolders","Enable-OldMailPublicFolders";
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($("Backup-MailPublicFolders"),$("Disable-AllMailPublicFolders"),$("Enable-OldMailPublicFolders"));
$answer = $host.ui.PromptForChoice($caption,$message,$choices,0)

Function global:Backup-MailPublicFolders
{
    [cmdletbinding()]
    Param()

 #Load Microsoft Exchange Snappin 
    If ((Get-PSSnapin | where {$_.Name -match "Microsoft.Exchange.Management.PowerShell.*"}) -eq $null) 
            {  
    Write-Host -ForegroundColor Green "`n Loading Microsoft Exchange Management Powershell Snapin."
    Add-PSSnapin *Microsoft.Exchange.Management.PowerShell.* 
    } 
 #Creating Temp folder under C:\
 New-Item -ItemType Directory -Name Temp -Path C:\ -ErrorAction Ignore
 Write-Host -ForegroundColor Green "`n Creating temp folder under C:\ "
 $global:PFs=(Get-PublicFolder -Recurse |? {$_.Mailenabled -like 'true'} |Select Identity, Name) 
 
 #Creating the backup file for all mail PFs with their email addresses
 [System.Collections.ArrayList]$global:collection = New-Object System.Collections.ArrayList($null)
 
    foreach ($pf in $pfs)
    {
    $global:PFsmtp=(Get-mailPublicFolder -Identity ($pf).name |select -ExpandProperty EmailAddresses)
     [Pscustomobject]$global:table = @{            
            Identity = (@($PF.Identity) -join ",") 
            Name = (@($PF.Name) -join ",")         
            EmailAddresses = (@($pfsmtp)  -join ",")
            }
     $global:collection.Add((New-Object PSObject -Property $table)) | Out-Null                                                
    } 
    
    Write-Host -ForegroundColor Green "`n Backuping all mail public folder properties completed. Please copy the file C:\Temp\MailPfs.csv in secure place. Don't delete it! "
    #Exporting the data to "C:\Temp\MailPfs.csv"
    $global:collection | Export-Csv  "C:\Temp\MailPfs.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ','
    sleep -Seconds 5
    
}
 Function global:Disable-AllMailPublicFolders
 {
    [cmdletbinding()]
    Param()

     #Disable all mail Public Folders
     foreach  ($pf1 in $pfs)
     {
     Write-Host -ForegroundColor Green "`n Disable Mail PF with Identity $($pf1.Name)"
     Disable-MailPublicFolder -Identity $pf1.Identity -Confirm:$false -Verbose
     sleep -Seconds 1     
     }

 }

 Function global:Enable-OldMailPublicFolders
 {
    [cmdletbinding()]
    Param()

     #Enable all old mail pf
    Write-Host -ForegroundColor Green "`n Importing data from csv"
    $global:pfIds1=(Import-Csv C:\Temp\mailpfs.csv |select Identity, EmailAddresses)
     
     foreach  ($pfid in $pfids1)
     {
     
     #Enable the old mail PFs
     Write-Host -ForegroundColor Green "`n Enable Mail PF with identity $pfid"
     enable-MailPublicFolder -Identity ($pfid).Identity -Verbose
     sleep -Seconds 2
     
     #Clear all white spaces in the addresses
     $pfid.EmailAddresses=(($pfid).emailaddresses).Trim()
     
     #Adding the email addresses
     Write-Host -ForegroundColor Green "`n Adding to PF with identity $pfid the following SMTP Addresses $($pfid.EmailAddresses)"
     $PFid.EmailAddresses=$PFid.EmailAddresses -split ","
     
     Set-MailPublicFolder -Identity ($pfid).Identity -EmailAddresses $PFid.EmailAddresses -EmailAddressPolicyEnabled $false -Verbose
     sleep -Seconds 2
     }
 }

#Switch buttons for chosing an option
switch ($answer)
{
    0 {Backup-MailPublicFolders
    }
    1 {Disable-AllMailPublicFolders
    }
    2 {Enable-OldMailPublicFolders
    }
}

