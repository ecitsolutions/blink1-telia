$path = "$home" + '\AppData\Roaming\Blink1-Telia'
$loc = Get-Location
$delay = $args[0]
$new_delay = $args[0] -match '^[0-9]+$'

if (!($new_delay -eq $true)) {$delay = 600}

Add-Type -AssemblyName PresentationFramework

if (Test-Path "$path"){$install = $false}
else {$install = $true}

if ($install -eq $true){
    if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet)) {
        [System.Windows.MessageBox]::Show("Internett tilkoblingen ser ikke ut til å fungere, avslutter.",'Blink1-Telia','Ok','Error') | Out-Null
        break
    }
    New-Item "$path" -type directory | Out-Null
    Set-Location "$path"
    if (!(Get-Location) -eq "$path") {Write-Output "Kan ikke gå i $path"; pause; break}
    Invoke-WebRequest "https://raw.githubusercontent.com/officecenter/blink1-telia/master/main.ps1" -OutFile "$path\main.ps1"
    @{blink_delay=$delay; busy_delay=60; username=$null; usersave=$false} | ConvertTo-Json | Out-File "$path\config.json"
    Invoke-WebRequest "http://thingm.com/blink1/downloads/blink1-tool-win.zip" -OutFile "$path\blink1.zip"
    Expand-Archive blink1.zip
    Move-Item "$path\blink1\blink1-tool.exe" "$path\blink1-tool.exe"
    Remove-Item -Recurse blink1
    Remove-Item blink1.zip
    if (Test-Path "$home\Desktop\Blink1-Telia.lnk" -PathType Leaf) {Remove-Item "$home\Desktop\Blink1-Telia.lnk"}
    if (Test-Path "$home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Blink1-Telia.lnk" -PathType Leaf) {Remove-Item "$home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Blink1-Telia.lnk"}

    if($error.Count -ge 1) {
        [System.Windows.MessageBox]::Show("En feil oppsto, avslutter.",'Blink1-Telia','Ok','Error') | Out-Null
        break
    }

    $w = New-Object -ComObject WScript.Shell
    $link_desktop = $w.CreateShortcut("$home\Desktop\Blink1-Telia.lnk")
    $link_desktop.TargetPath = 'powershell' 
    $link_desktop.arguments = '-WindowStyle hidden -file ' + "`"$path\main.ps1`""
    $link_desktop.save() > $null

    $link_menu = $w.CreateShortcut("$home\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Blink1-Telia.lnk")
    $link_menu.TargetPath = 'powershell' 
    $link_menu.arguments = '-WindowStyle hidden -file ' + "`"$path\main.ps1`""
    $link_menu.save() > $null

    [System.Windows.MessageBox]::Show("Takk for at du installerte Blink1-Telia.
    En snarvei til programmet skal være lagt til på Skrivebordet og Start-Menyen.
    Vær vennlig og rapporter bugs på https://github.com/officecenter/blink1-telia",'Blink1-Telia','Ok','Info') | Out-Null
}
else {
    [System.Windows.MessageBox]::Show("Blink1-Telia er allerede installert i mappen
    $path",'Blink1-Telia','Ok','Info') | Out-Null
}

Set-Location $loc