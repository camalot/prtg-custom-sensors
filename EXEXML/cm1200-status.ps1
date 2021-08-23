param(
  $HostName = "192.168.100.1",
  [Parameter(Mandatory = $true)]
  $UserName,
  [Parameter(Mandatory = $true)]
  $Password
)


function Invoke-Login {
  param (
    [Parameter(Mandatory = $true)]
    $UserName,
    [Parameter(Mandatory = $true)]
    $Password
  );
  begin {
    try {
      $secPass = ConvertTo-SecureString $Password -AsPlainText -Force;
      $cred = New-Object System.Management.Automation.PSCredential($UserName, $secPass);
      $result = Invoke-WebRequest "http://$HostName/DocsisStatus.htm" -Credential $cred -UseBasicParsing;
    } catch {
      ConvertTo-Json -InputObject @{
        prtg = @{
          error = $_.Exception.Status;
          text  = $_.Exception.Message;
        }
      } -Depth 3;
      return;
    }
  }
  process {
    try {
      

      $pattern = '(?ism)function\s(InitTagValue|InitDsTableTagValue)\(\)\s*\{.*?tagValueList\s*=\s*''([^'']*)';
      $CONN_STATUS = "DOWN";
      $dsuncorrectable = 0 -as [int];
      $dscorrectable = 0 -as [int];

      $result.Content | Select-String $pattern -AllMatches | ForEach-Object { $_.Matches; } | 
      ForEach-Object {
        $g = $_.Groups;
        $tagList = $g[2].Value.Split("|");
        
        switch ($g[1].Value) {
          "InitDsTableTagValue" {
            $nill, $tags = $tagList;
            chunk_array -inputArray $tags -chunkSize 9 | ForEach-Object {
              $chunk = $_;
              if ($chunk.Length -eq 9) {
                $dscorrectable += $chunk[7] -as [int];
                $dsuncorrectable += $chunk[8] -as [int];
              }
            };
            break;
          };
          "InitTagValue" {
            $CONN_STATUS = $tagList[2];
            break;
          };
          default {
            break;
          }
        } 
      };

      $prtg = @{
        prtg  = @{
          result = @(
            @{
              channel = "Downstream Uncorrectable Codewords";
              value   = $dsuncorrectable
              mode    = "Abolsute"
              unit    = "Count"
              limitmaxwarning = 10000
              limitmaxerror   = 10000000
            },
            @{
              channel = "Downstream Correctable Codewords";
              value   = $dscorrectable
              mode    = "Abolsute"
              unit    = "Count"
            }
          )
        };
        error = 0;
        text  = "Connectivity: $CONN_STATUS / UnCorrectable: $(short_number -number $dsuncorrectable) / Correctable: $(short_number -number $dscorrectable)";
      };
      ConvertTo-Json -InputObject $prtg -Depth 3;
    }
    catch {
      ConvertTo-Json -InputObject @{
        prtg = @{
          error = $_.Exception.Status;
          text  = $_.Exception.Message;
        }
      } -Depth 3;
    }
  }
}

function chunk_array {
  param (
    $inputArray,
    $chunkSize
  )
  # Creating a new array
 
  # Defining the chunk size
  $outArray = @();
  $parts = [math]::Ceiling($inputArray.Length / $chunkSize);
 
  # Splitting the array to chunks of the same size

  for ($i = 0; $i -le $parts; $i++) {
    $start = $i * $chunkSize;
    $end = (($i + 1) * $chunkSize) - 1;
    Write-Output $start;
    Write-Output $end;
    $outArray += , @($inputArray[$start..$end]);
  }
 
  return $outArray;
}

function short_number {
  param(
    $number
  )
  process {
    if ($number -lt 100) {
      return "{0:n0}" -f $number;
    }
    elseif ($number -lt 1000000) {
      return ("{0:n2}" -f ($number / 1000)) + "K";
    }
    elseif ($number -lt 1000000000) {
      return ("{0:n2}" -f ($number / 1000000)) + "M";
    }
    else {
      return ("{0:n2}" -f ($number / 1000000000)) + "B";
    }
  }
}

Invoke-Login -UserName $UserName -Password $Password;