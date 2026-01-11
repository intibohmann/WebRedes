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
        error = "No active Wi-Fi adapter found"
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
    $bssid       = $null
    $signal      = $null
    $channel     = $null

    foreach ($line in $raw) {

        if ($line -match "^SSID\s+\d+\s+:\s+(.*)$") {
            $currentSSID = $Matches[1].Trim()
        }

        if ($line -match "Network type\s+:\s+(.*)$") {
            $currentType = $Matches[1].Trim()
        }

        if ($line -match "Authentication\s+:\s+(.*)$") {
            $currentAuth = $Matches[1].Trim()
        }

        if ($line -match "Encryption\s+:\s+(.*)$") {
            $currentEnc = $Matches[1].Trim()
        }

        if ($line -match "BSSID\s+\d+\s+:\s+([0-9A-Fa-f:-]{17})") {
            $bssid = $Matches[1].Trim()
        }

        if ($line -match "Signal\s+:\s+(\d+)%") {
            $signal = [int]$Matches[1]
        }

        if ($line -match "Channel\s+:\s+(\d+)") {
            $channel = [int]$Matches[1]

            if ($bssid -and -not $networks.ContainsKey($bssid)) {
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
    if ($line -match "(\d+\.\d+\.\d+\.\d+)\s+([0-9a-fA-F\-]{17})\s+(dynamic|static)") {
        $neighbors += @{
            ip_address  = $Matches[1]
            mac_address = $Matches[2]
            entry_type  = $Matches[3]
        }
    }
}

$diagnostics = @{
    scan_attempts            = $scanAttempts
    total_networks_detected = $networkList.Count
    scan_status = if ($networkList.Count -eq 0) {
        "No networks detected – strong driver or hardware limitation"
    } elseif ($networkList.Count -eq 1) {
        "Only one network detected – driver limits passive scanning"
    } else {
        "Multiple networks successfully detected"
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