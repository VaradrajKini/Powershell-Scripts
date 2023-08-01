# Path of the script
$Script_path = Split-Path -Parent $MyInvocation.MyCommand.Path

# Target folder which contains the files that you want to replace
$Target_Folder_Path = "C:\inetpub\wwwroot"

# File filters to search for
$FileFilters  = @("web.config","appsettings.json","config.json")

# Temp Folder path where the files will be moved and strings replaced
$Temp_folder = "$Script_path\Temp"

$FindReplaceEntries = Import-Csv "$Script_path\String_Find_n_Replace.csv"

$LogFileName = "log_$((Get-Date).ToString("MMddyyyy_HHmm")).txt"

foreach ($FindReplace in $FindReplaceEntries) {

    <# $FindReplaceEntries is the current item #>
    $OldString = $FindReplace.Find
    $ReplaceString = $FindReplace.Replace

    foreach ($FileFilter in $FileFilters) {
        $TargetFiles = Get-Childitem -include $FileFilter -Recurse
        $FilesModified = @()

        foreach ($TargetFile in $TargetFiles){
            if((Get-Content $TargetFile) | Select-String $OldString){
                Copy-Item $TargetFile.Fullname -Destination $Temp_folder
                Push-Location $Temp_folder
                Get-Content $FileFilter | Foreach-Object {$_ -replace $OldString, $ReplaceString} | Set-Content $TargetFile.Fullname
                Remove-Item $FileFilter -Force
                Pop-Location
                $FilesModified += $TargetFile.Fullname
            }

            $FilesModified | Out-File "$Script_path\Log\$LogFileName" -Append
        }
    }
}