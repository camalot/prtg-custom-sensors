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
    # $res = parent::execute($this->url('GenieLogin.asp'));
    # $pattern = '/<input\\s+type="hidden"\\s+name="webToken"\\s+value=(\\d{1,})\\s+\\/>/i';

    $result = Invoke-WebRequest "http://$HostName/GenieLogin.asp" -SessionVariable session;
    $form = $result.Forms[0];
    $webToken = $result.AllElements | Where-Object {
      $_.name -eq "webToken" 
    } | Select-Object name, value;

    # 'body' => 'loginUsername='.$username.'&loginPassword='.$password.'&webToken='.$webtoken,
    # 'cookies' => $this->jar,
    # 'headers' => ['content-type' => 'application/x-www-form-urlencoded']

    # LOGIN
    $form.Fields["loginUsername"] = $UserName;
    $form.Fields["loginPassword"] = $Password;
    $result = Invoke-WebRequest "http://$HostName/goform/GenieLogin" -WebSession $session -Body $form -Method "POST" -UseBasicParsing;
  }
  process {
    try {
      $result = Invoke-WebRequest "http://$HostName/DocsisStatus.asp" -WebSession $session -UseBasicParsing;
      $pattern = '<td\s+class="style1">Connectivity State<\/td>\s*<td>(.*?)<\/td>';
      $CONN_STATUS = "DOWN";
      if ( $result.Content -match $pattern ) {
        $CONN_STATUS = $Matches[1];
      }

      $pattern = '(?mi)<tr>(?:<td>.*?<\/td>){7}<td>(\d+)<\/td><td>(\d+)<\/td><td>(\d+)<\/td><\/tr>';
      $allMatches = $result.Content | Select-String $pattern -AllMatches | ForEach-Object {
        $_.Matches
      }
      $uncorrectable = 0 -as [int];
      $unerrored = 0 -as [int];
      $correctable = 0 -as [int];
      for ($mi = 0; $mi -lt $allMatches.Length - 2; $mi++) {
        $m = $allMatches[$mi];
        $unerrored += $m.Groups[1].Value -as [int];
        $correctable += $m.Groups[2].Value -as [int];
        $uncorrectable += $m.Groups[3].Value -as [int];
      }

      # $UNERRORED_COUNT = short_number -number $unerrored;
      # $CORRECTABLE_COUNT = short_number -number $correctable;
      # $UNCORRECTABLE_COUNT = short_number -number $uncorrectable;

      $prtg = @{
        prtg = @{
          result = @(
            # @{
            #   channel = "Connectivity";
            #   value = $CONN_STATUS;
            # },
            @{
              channel = "Unerrored Codewords";
              value   = $unerrored
            },
            @{
              channel = "Correctable Codewords";
              value   = $correctable
            },
            @{
              channel = "Uncorrectable Codewords";
              value   = $uncorrectable
            }
          )
        };
        # status = $CONN_STATUS;
        # success = $UNERRORED_COUNT;
        # warning = $CORRECTABLE_COUNT;
        # error = $UNCORRECTABLE_COUNT;
      };
      ConvertTo-Json -InputObject $prtg -Depth 3;
    } catch {
      ConvertTo-Json -InputObject @{
        prtg = @{
          error = 1;
          text = $_.Message;
        }
      } -Depth 3;
    }
  }
}

function short_number {
  param(
    $number
  )
  process {
    if ($number -lt 100) {
      return "{0:n0}" -f $number;
    } elseif ($number -lt 1000000) {
      return ("{0:n2}" -f ($number / 1000)) + "K";
    } elseif ($number -lt 1000000000) {
      return ("{0:n2}" -f ($number / 1000000)) + "M";
    } else {
      return ("{0:n2}" -f ($number / 1000000000)) + "B";
    }
  }
}

Invoke-Login -UserName $UserName -Password $Password;