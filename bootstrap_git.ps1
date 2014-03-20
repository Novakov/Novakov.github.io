$downloads = Invoke-RestMethod https://code.google.com/feeds/p/msysgit/downloads/basic 

$download = $downloads | ? {$_.title.Trim() -match '^Git-\d\.\d.\d-preview\d+\.exe+'} | select -First 1

$downloadUrl = ($download.link | ? rel -EQ 'direct').href

$target = "$($env:TEMP)\git-install.exe"

echo "Downloading Git install from $downloadUrl"

Invoke-WebRequest $downloadUrl -OutFile $target

& $target /SP- /verysilent /CLOSEAPPLICATIONS
