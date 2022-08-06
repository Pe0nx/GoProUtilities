# Sort-GoProFootage
function Sort-GoProFootage {

    # parameters
    [CmdletBinding()]
    param (
        $Path
    )

    # regex filter for filename
    $FilterFilename = '([a-zA-Z]{2})(\d{2})(\d{4})'
    
    # create table for file information
    $Table = @()

    # if path equals null set it to current path
    if ($NULL -eq $Path) {
        $Path = (Get-Location).Path
    } else {
        $Path = $Path
    }

    # set filetypes
    $Filetype = '*.mp4'

    # get files that match the regex filter
    $Files = Get-ChildItem -Path $Path\* -Include ($Filetype) | Where-Object {$_.Name -match $FilterFilename}

    # get file information
    if ($Files.Count -gt 0) {
        foreach ($File in $Files) {
            # get current file information
            $currentFilename = $File.Name
            $currentFiletype = $File.Extension

            # split filename into groups
            $MatchesFilename = $currentFilename | Select-String -Pattern $FilterFilename -AllMatches
            $Tag = $Chapter = $MatchesFilename.Matches[0].Groups[1].Value
            $Video = $MatchesFilename.Matches[0].Groups[3].Value
            $Chapter = $MatchesFilename.Matches[0].Groups[2].Value

            # set new filename
            $newFilename = $Tag+"-"+$Video+"-"+$Chapter+$currentFiletype

            # fill table
            $Row = "" | Select-Object currentFilename,Spacer,newFilename
            $Row.currentFilename = $currentFilename
            $Row.newFilename = $newFilename
            $Row.Spacer = '-->'
            $Table += $Row
        }

        # show table in console
        $Table | Format-Table -HideTableHeaders

        # ask for confirmation to rename files
        do {

            Write-Host "Should the files get renamed as stated above?"
            $Confirmation = Read-Host "[Y/N]"

            if ($Confirmation -eq 'n') {
                exit
            }
            
        } while (
            ($Confirmation -ne 'y')
        )

        # rename files
        $Counter = 0

        foreach ($File in $Table) {
            # check if file stil exists
            if (Test-Path -Path ($Path+'\'+$File.currentFilename)) {
                #rename file
                Rename-Item -Path ($Path+'\'+$File.currentFilename) -NewName ($Path+'\'+$File.newFilename)

                $Counter = $Counter + 1
            } else {
                Write-Host "`nFile" $File.currentFilename "doesn't exist anymore." -ForegroundColor Red
            }
        }
        
        Write-Host "`n"($Counter)"/"($Files.Count) "files renamed.`n" -ForegroundColor Blue
    } elseif ($Files.Count -eq 0) {
        Write-Host "`nNo files found.`n" -ForegroundColor Red
    }
}

Export-ModuleMember -Function ('Sort-GoProFootage')