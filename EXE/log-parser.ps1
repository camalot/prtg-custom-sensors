param (
  $Path,
  $Name
)

$files = Get-ChildItem $Path* | Sort-Object LastWriteTime -descending
$fileName = $files[0].FullName


$logFile = Join-Path -Path D:\ServerFolders\Logs -ChildPath "$Name.log"
Get-Content $fileName | select -Last 100 > $logFile