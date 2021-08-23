#! powershell
param(
    $HostName = "hdhomerun01.bit13.local"
)

function Invoke-FirmwareCheck {
    param(
        [Parameter(Mandatory=$true)]
        $HostName
    )
    begin {
        $CommandPath = Split-Path -Parent $PSCommandPath;
    }
    process {
        & (Join-Path -Path $CommandPath -ChildPath ./tools/hdhomerun-monitor.exe) -host $HostName -action "channels";
    }
}

Invoke-FirmwareCheck -HostName $HostName;