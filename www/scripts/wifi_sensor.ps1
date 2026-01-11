$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$hostname  = $env:COMPUTERNAME

$adapter = Get-NetAdapter |
    Where-Object {
        $_.Status -eq "Up" -and
        $_.InterfaceDescription -match "Wi-Fi|Wireless"
    } |
    Select-Object -First 1

$adapterInfo = if ($adapter) {
    @{
        name       = $adapter.Name
        mac        = $adapter.MacAddress
        link_speed = $adapter.LinkSpeed
        driver     = $adapter.InterfaceDescription
    }
} else {
    @{
        error = "Nenhum adaptador Wi-Fi ativo encontrado"
    }
}

$networks = @{}
$scanAttempts = 3

for ($attempt = 1; $attempt -le $scanAttempts; $attempt++) {

    $raw = netsh wlan show networks mode=bssid

    $currentSSID = $null
    $currentAuth = $null
    $currentEnc  = $null
    $currentType = $null

    foreach ($line in $raw) {

        if ($line -match "^SSID\s+\d+\s+:\s+(.*)$") {
            $currentSSID = $Matches[1].Trim()
        }

        if ($line -match "Tipo de rede\s+:\s+(.*)$") {
            $currentType = $Matches[1].Trim()
        }

        if ($line -match "Autenticação\s+:\s+(.*)$") {
            $currentAuth = $Matches[1].Trim()
        }

        if ($line -match "Criptografia\s+:\s+(.*)$") {
            $currentEnc = $Matches[1].Trim()
        }

        if ($line -match "BSSID\s+\d+\s+:\s+([0-9A-Fa-f:]{17})") {
            $bssid = $Matches[1].Trim()
        }

        if ($line -match "Sinal\s+:\s+(\d+)%") {
            $signal = [int]$Matches[1]
        }

        if ($line -match "Canal\s+:\s+(\d+)") {
            $channel = [int]$Matches[1]

            if (-not $networks.ContainsKey($bssid)) {
                $networks[$bssid] = @{
                    ssid           = $currentSSID
                    bssid          = $bssid
                    signal         = $signal
                    channel        = $channel
                    authentication = $currentAuth
                    encryption     = $currentEnc
                    network_type   = $currentType
                }
            }
        }
    }

    Start-Sleep -Seconds 4
}

$networkList = $networks.Values

$neighbors = @()

$arpTable = arp -a

foreach ($line in $arpTable) {
    if ($line -match "(\d+\.\d+\.\d+\.\d+)\s+([0-9a-f\-]{17})\s+(dynamic|static)") {
        $neighbors += @{
            ip_address  = $Matches[1]
            mac_address = $Matches[2]
            entry_type  = $Matches[3]
        }
    }
}

$diagnostics = @{
    scan_attempts          = $scanAttempts
    total_networks_detected = $networkList.Count
    scan_status = if ($networkList.Count -eq 0) {
        "Nenhuma rede detectada – forte limitação de driver ou hardware"
    } elseif ($networkList.Count -eq 1) {
        "Apenas uma rede detectada – driver limita varredura passiva"
    } else {
        "Múltiplas redes detectadas com sucesso"
    }
}

$result = @{
    timestamp   = $timestamp
    host        = $hostname
    adapter     = $adapterInfo
    diagnostics = $diagnostics
    networks    = $networkList
    neighbors   = $neighbors
}

$jsonPayload = $result | ConvertTo-Json -Depth 6 -Compress

$jsonPayload | Out-File "wifi_scan.json" -Encoding UTF8

Invoke-RestMethod `
    -Uri "http://localhost/WebRedes/www/upload.php" `
    -Method POST `
    -Body $jsonPayload `
    -ContentType "application/json; charset=utf-8"