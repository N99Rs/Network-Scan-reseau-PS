# EX-Network-Wifi-Scan.ps1
# 🚀 Scan complet Wi-Fi + Réseau + Anomalies
# Fichier à enregistrer en UTF-8 avec BOM

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($true)

Write-Host "`n🌐 === EX CHECK - SCAN RÉSEAU & WI-FI ===`n" -ForegroundColor Cyan

# Liste des anomalies détectées
$anomalies = @()

# 1. Configuration IP
Write-Host "`n🔹 [1] Configuration réseau locale :" -ForegroundColor Yellow
$netConfig = Get-NetIPConfiguration
$netConfig | Format-Table -AutoSize

if (-not $netConfig.IPv4DefaultGateway) {
    $anomalies += "❌ Aucune passerelle par défaut (pas d’accès internet local possible)"
}

# 2. Interfaces
Write-Host "`n🔹 [2] Interfaces réseau :" -ForegroundColor Yellow
Get-NetAdapter | Format-Table Name, Status, MacAddress, LinkSpeed
Get-NetIPAddress | Format-Table InterfaceAlias, AddressFamily, IPAddress

# 3. Réseaux Wi-Fi détectés
Write-Host "`n🔹 [3] Réseaux Wi-Fi visibles :" -ForegroundColor Yellow
$wifiNetworks = netsh wlan show networks mode=bssid
if ($wifiNetworks -match "SSID") {
    Write-Output $wifiNetworks
} else {
    $anomalies += "❌ Aucun réseau Wi-Fi détecté"
}

# 4. Profils Wi-Fi enregistrés
Write-Host "`n🔹 [4] Profils Wi-Fi enregistrés :" -ForegroundColor Yellow
$wifiProfiles = netsh wlan show profiles
if ($wifiProfiles -match "All User Profile") {
    Write-Output $wifiProfiles
} else {
    $anomalies += "❌ Aucun profil Wi-Fi enregistré"
}

# 5. Table ARP
Write-Host "`n🔹 [5] Table ARP (résolution IP → MAC) :" -ForegroundColor Yellow
arp -a

# 6. Ping Internet
Write-Host "`n🔹 [6] Test de connectivité vers Google :" -ForegroundColor Yellow
$pingResult = Test-Connection -ComputerName www.google.com -Count 2 -Quiet
if ($pingResult) {
    Write-Host "✅ Internet accessible (ping OK)" -ForegroundColor Green
} else {
    Write-Host "❌ Ping vers Google échoué" -ForegroundColor Red
    $anomalies += "❌ Échec de connectivité Internet (ping Google)"
}

# 7. Ports ouverts
Write-Host "`n🔹 [7] Ports ouverts (LISTENING) :" -ForegroundColor Yellow
$ports = netstat -ano | Select-String "LISTENING"
if ($ports) {
    Write-Output $ports
} else {
    $anomalies += "❌ Aucun port en écoute détecté"
}

# 8. DNS configuré
Write-Host "`n🔹 [8] Serveurs DNS configurés :" -ForegroundColor Yellow
$dns = Get-DnsClientServerAddress | Where-Object {$_.ServerAddresses} | Select-Object -ExpandProperty ServerAddresses
if ($dns) {
    $dns | ForEach-Object { Write-Host "→ $_" }
} else {
    $anomalies += "❌ Aucun serveur DNS configuré"
}

# 🔍 Résumé
Write-Host "`n======================================" -ForegroundColor DarkGray
if ($anomalies.Count -eq 0) {
    Write-Host "`n✅ Aucune anomalie détectée. Réseau opérationnel !" -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Anomalies détectées :" -ForegroundColor Red
    foreach ($issue in $anomalies) {
        Write-Host $issue -ForegroundColor Red
    }
}
Write-Host "`nAppuie sur une touche pour quitter..." -ForegroundColor Cyan
[void][System.Console]::ReadKey($true)
