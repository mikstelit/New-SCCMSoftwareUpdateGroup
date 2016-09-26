<#
.Synopsis
   Creates a new Software Update Group using the supplied updates.
.DESCRIPTION
   Creates a new Software Update Group using the supplied updates.
.EXAMPLE
   New-SCCMSoftwareUpdateGroup -SUGName 'Test SUG' -SUGDescription 'A test SUG'
.EXAMPLE
   New-SCCMSoftwareUpdateGroup -SUGName 'Test SUG'`
                           -SUGDescription 'A test SUG' `
                           -UpdatesFile '.\NewUpdates.txt' `
                           -SiteCode 'S1' `
                           -Categories @('Windows Server 2012','Windows Server 2012 R2')
#>
Function New-SCCMSoftwareUpdateGroup
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$SUGName,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$SUGDescription,

        [Parameter(Mandatory=$false,
                   Position=2)]
        [string]$UpdatesFile='.\Updates.txt',

        [Parameter(Mandatory=$false,
                   Position=3)]
        [string]$SiteCode = 'S1',

        [Parameter(Mandatory=$false,
                   Position=4)]
        [string[]]$Categories = @('Windows Server 2012', `
                    'Windows Server 2012 R2', `
                    'Windows Server 2008', `
                    'Windows Server 2008 R2')
    )

    Try
    {
        Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
        $Updates = @()

        $BulletinIDs = Get-Content $UpdatesFile
        CD "$($SiteCode):"
    }
    Catch
    {
        Write-Output $Error[0].Exception.Message
        Exit
    }

    Foreach ($BulletinID in $BulletinIDs)
    {
        Foreach ($Category in $Categories)
        {
            $Update = (Get-CMSoftwareUpdate -BulletinId $BulletinID -CategoryName $Category -Fast).CI_ID

            If($Update)
            {
                $Updates += $Update
            }
        }
    }

    New-CMSoftwareUpdateGroup -Name $SUGName -Description $SUGDescription -SoftwareUpdateId $Updates
}