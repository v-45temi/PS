Execution of this script is on your own risk. Please read the code before you run it. It will need a change of the execution policy for PowerShell.

This script will help you to reset the mail enabled public folder object in all Exchange Server Versions. 
This will not remove the public folder itself, it is recreating the mail objects in Active Directory.
All of the smtp address assigned to the Public Folders will be set to the new objects again.
You have the ability to back up the List of all mail enabled public folders, to disable all of them and to enable all of them again and assign the smtp addresses.
The File should be saved in default PowerShell modules folder under a folder with the same name as the script.

Instructions:

Start PowerShell.exe and set the execution policy to "unrestricted". More info, about execution policy you can find here: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1

Navigate to the holder folder of the script and run it. You will be asked, what do you want to do first, the options are the following:

-Backup-MailPublicFolders (This option will created a temp folder under C:\, if it is not present and MailPFs.csv file with a backup of all mail enabled public folders in the organization. It will back up all proxy smtp addresses of all mail PFs.)

-Disable-AllMailPublicFolders (This option will disable all mail public folders. This will remove the corrupted mail PF ad objects in Active Directory. DON'T USE IT WITHOUT BACKUPING THEM WITH THE FIRST OPTION!!!)

-Enable-OldMailPublicFolders (This option will create all mail public folders, which are presented in the Backup and assign all smtp addresses, which day had.)

All of the options could be used separately.

