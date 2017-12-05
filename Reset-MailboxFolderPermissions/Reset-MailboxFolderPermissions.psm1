<#
.Synopsis
    This script will reset mailbox folder permissions.
.DESCRIPTION
    This script will reset mailbox folder permissions. The script should be run from the server with the newest Exchange version installed.
.PARAMETER -Mailbox <String>

    The Identity parameter specifies the identity of the mailbox. You can use one of the following values:
    * GUID
    * Distinguished name (DN)
    * Display name
    * Domain\Account
    * User principal name (UPN)
    * LegacyExchangeDN
    * SmtpAddress
    * Alias
    
    Required?                    True
    Position?                    1
    Default value                None
    Accept pipeline input?       True (ByPropertyName)
    Accept wildcard characters?  True

.PARAMETER -FolderScope <Calendar | Contacts | DeletedItems | Drafts | Inbox | JunkEmail | Journal | Notes | Outbox | SentItems | Tasks | All | ManagedCustomFolder | RssSubscriptions | 
    SyncIssues | ConversationHistory | Personal | RecoverableItems | NonIpmRoot | LegacyArchiveJournals>
        The FolderScope parameter specifies the scope of the search by folder type. Valid parameter values include:
        
        * All
        * Calendar
        * Contacts
        * ConversationHistory
        * DeletedItems
        * Drafts
        * Inbox
        * JunkEmail
        * Journal
        * LegacyArchiveJournals
        * ManagedCustomFolder
        * NonIpmRoot
        * Notes
        * Outbox
        * Personal
        * RecoverableItems
        * RssSubscriptions
        * SentItems
        * SyncIssues
        * Tasks

.PARAMETER <CommonParameters>
    This cmdlet supports the common parameters: Verbose, Debug,
    ErrorAction, ErrorVariable, WarningAction, WarningVariable,
    OutBuffer and OutVariable. For more information, type,
    "get-help about_commonparameters".

.EXAMPLE
    Reset-MailboxFolderPermissions [-Mailbox <String>] [-FolderScope <String>]
.EXAMPLE
    Reset-MailboxFolderPermissions -Mailbox TestUser@domain.com -FolderScope All
#>

function global:Reset-MailboxFolderPermissions
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        #$VerbosePreference='Continue',
        # User Mailbox ID
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Type the user mailbox identity.',
        Position=0)]
        [Alias('mbx')]
        [string]$Mailbox,
        

        # Folder Scope
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Chose if you need to reset the permissions of the mailbox only on "OneLevel" or entire mailbox folder tree "SubTree"',
        Position=1)]
        [Alias('scope')]
        [ValidateSet("Calendar", "Contacts", "DeletedItems", "Drafts", "Inbox", "JunkEmail","Journal", `
        "Notes", "Outbox", "SentItems", "Tasks", "All", "ManagedCustomFolder", "RssSubscriptions", "SyncIssues", `
        "ConversationHistory", "Personal", "RecoverableItems", "NonIpmRoot", "LegacyArchiveJournals")]
        [string]$FolderScope

    )

    Begin
    {
        #Load Microsoft Exchange Snappin 
        #Requires -PSSnapin "Microsoft.Exchange.Management.PowerShell.Snapin"
		#Requires -RunAsAdministrator
        
        #Setting Active Directory Settings to 'View entire forest'
        Write-Host -ForegroundColor Green "`n Setting Active Directory Settings to 'View entire forest'."
        Set-ADServerSettings -ViewEntireForest:$true 
		$ParameterDefault=
		@{
			'Identity'=$mailbox;
			'User'='Default'
		}
		$ParameterAnonymous=
		@{
			'Identity'=$mailbox;
			'User'='Anonymous'
		}

    }
    Process
    {
        
        if ((Get-MailboxFolderPermission @Parameterdefault).User.Usertype -match 'Default')
            {
			
                # Setting default permissions for Default User under folder '$Mailbox'
                Write-Host -ForegroundColor Green ' Setting default permissions for Default User under folder '$Mailbox''
                Set-MailboxFolderPermission @Parameterdefault -AccessRights "None" 
            }
            else 
            {
                #If there the Default user permissions are missind the script will Add it to the User under folder '$Mailbox'
                Write-Host -ForegroundColor Green ' Adding default permissions for Default User under folder '$Mailbox''
                Add-MailboxFolderPermission @Parameterdefault -AccessRights "None" 
            }
            if ((Get-MailboxFolderPermission @ParameterAnonymous).User.Usertype -match 'Anonymous')
            {
                # Setting default permissions for Anonymous User under folder '$Mailbox'
                Write-Host -ForegroundColor Green ' Setting default permissions for Anonymous User under folder '$Mailbox''
                Set-MailboxFolderPermission @ParameterAnonymous -AccessRights "None" 
            }
            else 
            {
                #If there the Anonymous user permissions are missind the script will Add it to the User under folder '$Mailbox'
                Write-Host -ForegroundColor Green ' Adding default permissions for Anonymous User under folder '$Mailbox''
                Add-MailboxFolderPermission @ParameterAnonymous -AccessRights "None" 
            }
        
        $permissions=(Get-MailboxFolderPermission $Mailbox).User |Where-Object {$_.UserType -eq 'Internal'} 
            Foreach ($permission in $permissions.DisplayName) 
            {
                #Removing all additional permissions for the Top of Information Store level
                Write-Host -ForegroundColor Green ' Removing Permissions for User '$Permission''
                Remove-MailboxFolderPermission -Identity "$Mailbox" -User $permission -Confirm:$false 
            }
        #Getting all folders under the given folder scope
        $folders=Get-MailboxFolderStatistics -Identity "$Mailbox" -FolderScope $FolderScope
        $folders=$folders[1..($folders.Length -1)]
        foreach ($folder in $folders)
        {
            $folder=($folder.FolderPath).replace("/","\")
            $PerParameters=
            @{ 
                'Identity'=("$mailbox"+":"+"$folder")
            }
            $permissions=(Get-MailboxFolderPermission @PerParameters).User |Where-Object {$_.UserType -eq 'Internal' -or $_.UserType -eq 'Unknown'} 
            
            Foreach ($permission in $permissions.DisplayName) 
            {
                $PerParameters.Add('Permission',($Permission))
                #Removing all additional permissions under the given folder tree
                Write-Host -ForegroundColor Green ' Removing Permissions for User '$Permission' under folder ' + $folder
                Remove-MailboxFolderPermission @PerParameters -Confirm:$false
                $PerParameters.Remove('Permission',($Permission))
            }
            
            if ((Get-MailboxFolderPermission @PerParameters -User "Default").User.Usertype -match 'Default')
            {
                # Setting default permissions for Default User under folder the given folder tree
                Write-Host -ForegroundColor Green ' Setting default permissions for Default User under folder '+ $folder
                Set-MailboxFolderPermission @PerParameters -User "Default" -AccessRights "None"
            }
            else 
            {
                #If the Default user permissions are missind the script will Add it to the User under the given folder tree
                Write-Host -ForegroundColor Green ' Adding default permissions for Default User under folder ' + $folder
                Add-MailboxFolderPermission @PerParameters -User "Default" -AccessRights "None" 
            }
            if ((Get-MailboxFolderPermission @PerParameters -User "Anonymous").User.Usertype -match 'Anonymous')
            {
                # Setting default permissions for Anonymous User under folder the given folder tree
                Write-Host -ForegroundColor Green ' Setting default permissions for Anonymous User under folder ' + $folder
                Set-MailboxFolderPermission @PerParameters -User "Anonymous" -AccessRights "None" 
            }
            else 
            {
                #If the Anonymous user permissions are missind the script will Add it to the User under the given folder tree
                Write-Host -ForegroundColor Green ' Adding default permissions for Anonymous User under folder ' + $folder
                Add-MailboxFolderPermission @PerParameters -User "Default" -AccessRights "None" 
            }

        }
     
    }
    End
    {
    Write-Host -ForegroundColor Green  "All default permissions has been fixed!"
    pause
    }
}

Export-ModuleMember -Function * -Variable *
