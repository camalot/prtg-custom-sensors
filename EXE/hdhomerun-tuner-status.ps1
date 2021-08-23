<#
http://hdhomerun01.bit13.local/tuners.html
<table>
<tr><td>Tuner 0 Channel</td><td>none</td></tr>
<tr><td>Tuner 1 Channel</td><td>none</td></tr>
</table>

#>

param (
    [Parameter()]
    $HostName = "hdhomerun01.bit13.local"
)


function Invoke-TunerStatus {
    param(
        [Parameter(Mandatory=$true)]
        $HostName
    )
    begin {
        $CommandPath = Split-Path -Parent $PSCommandPath;
    }
    process {
        & (Join-Path -Path $CommandPath -ChildPath ./tools/hdhomerun-monitor.exe) -host $HostName -action "tuners";
    }
}

Invoke-TunerStatus -HostName $HostName;

<#

function Get-AvailableTuners {
    param (
        [Parameter(Mandatory=$true)]
        $HostName
    )
    begin {
        $PATTERN = "(?si)<tr>\s*<td>([^<]+)</td>\s*<td>([^<]+)</td></tr>";
        $checkUrl = "http://$HostName/tuners.html";
    }

    process {
        $inUse = 0;
        $result = Invoke-WebRequest -Uri "$checkUrl" -Method GET -UseBasicParsing | Select-String $PATTERN -AllMatches;
        for($m = 0; $m -lt $result.Matches.Count; $m++) {
            if( $result.Matches[$m].Groups[2].Value -ne "none" ) {
                $inUse += 1;
                "$($result.Matches[$m].Groups[1]) is in use" | Write-Host;
            } else {
                "$($result.Matches[$m].Groups[1]) is available" | Write-Host;
            }
        }
        $available = ($result.Matches.Count - $inUse);
        "$available tunners available" | Write-Host;
        return $inUse;
    }
}

Get-AvailableTuners -HostName $HostName;#>