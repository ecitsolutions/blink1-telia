$path = "$home" + '\AppData\Roaming\Blink1-Telia'
$new_delay = $args[0]
$new_config = $args[0] -match '^[0-9]+$'

$config = Get-Content -Raw -Path "$path\config.json" | ConvertFrom-Json

if ($config.busy_delay -eq $null){
    @{blink_delay=$config.blink_delay; busy_delay=60; username=$config.username; usersave=$config.usersave} | ConvertTo-Json | Out-File "$path\config.json"
    $config.busy_delay = 60
}

if ($new_config -eq $true) {
    $config = Get-Content -Raw -Path "$path\config.json" | ConvertFrom-Json
    @{blink_delay=$new_delay; busy_delay=$config.busy_delay; username=$config.username; usersave=$config.usersave} | ConvertTo-Json | Out-File "$path\config.json"
    Write-Host "Blink-Delay endret til $new_delay ms"
    break
}

if ($config.blink_delay -eq $null){
    @{blink_delay=600; busy_delay=$config.busy_delay; username=$config.username; usersave=$config.usersave} | ConvertTo-Json | Out-File "$path\config.json"
    $config.blink_delay = 600
}

if ($config.usersave -eq $null){
    @{blink_delay=$config.blink_delay; busy_delay=$config.busy_delay; username=$config.username; usersave=$false} | ConvertTo-Json | Out-File "$path\config.json"
    $config.usersave = $false
}

#Stopp Telia status loopen
function Stop-Telia {
    if (Get-Job -Name "Telia" -ErrorAction SilentlyContinue) {
        Stop-Job -Name Telia
        Remove-Job -Name Telia
    }
}

Stop-Telia

#Validate
While ($validate -eq $null) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form 
    $form.Text = "Logg inn på Telia"
    $form.Size = New-Object System.Drawing.Size(300,325)
    $form.StartPosition = "CenterScreen"
    $form.Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
    $form.Topmost = $true
    $Form.FormBorderStyle = "FixedSingle"

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(115,245)
    $OKButton.Size = New-Object System.Drawing.Size(75,30)
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(195,245)
    $CancelButton.Size = New-Object System.Drawing.Size(75,30)
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(10,10)
    $label1.Size = New-Object System.Drawing.Size(280,20)
    $label1.Text = "Fyll inn ditt Telia-brukernavn:"
    $form.Controls.Add($label1)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10,90)
    $label2.Size = New-Object System.Drawing.Size(280,20)
    $label2.Text = "Fyll inn ditt Telia-passord:"
    $form.Controls.Add($label2)
    
    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(10,140)
    $label3.Size = New-Object System.Drawing.Size(280,20)
    $label3.Text = "Sekunder mellom samtale-slutt og endring av farge:"
    $form.Controls.Add($label3)
    
    $label4 = New-Object System.Windows.Forms.Label
    $label4.Location = New-Object System.Drawing.Point(10,190)
    $label4.Size = New-Object System.Drawing.Size(280,20)
    $label4.Text = "Millisekunder mellom fargebytte:"
    $form.Controls.Add($label4)

    $username = New-Object System.Windows.Forms.TextBox 
    $username.Location = New-Object System.Drawing.Point(10,30) 
    $username.Size = New-Object System.Drawing.Size(260,20)
    if (!($config.username -eq $null)){
        $username.Text = $config.username
    }
    $form.Controls.Add($username)

    $remember = New-Object System.Windows.Forms.Checkbox
    $remember.Location = New-Object System.Drawing.Size(10,60) 
    $remember.Size = New-Object System.Drawing.Size(120,20)
    $remember.Text = "Husk brukernavn"
    if ($config.usersave -eq $true){
        $remember.Checked = $true
    }
    else {
        $remember.Checked = $false
    }
    $form.Controls.Add($remember)

    $password = New-Object System.Windows.Forms.TextBox
    $password.PasswordChar = '*'
    $password.Location = New-Object System.Drawing.Point(10,110) 
    $password.Size = New-Object System.Drawing.Size(260,20) 
    $form.Controls.Add($password)
    
    $busydelay = New-Object System.Windows.Forms.NumericUpDown
    $busydelay.Location = New-Object System.Drawing.Point(10,160) 
    $busydelay.Size = New-Object System.Drawing.Size(260,20)
    $busydelay.Maximum = 600
    $busydelay.Value = $config.busy_delay
    $busydelay.Increment = 5
    $form.Controls.Add($busydelay)
    
    $blinkdelay = New-Object System.Windows.Forms.NumericUpDown
    $blinkdelay.Location = New-Object System.Drawing.Point(10,210) 
    $blinkdelay.Size = New-Object System.Drawing.Size(260,20)
    $blinkdelay.Maximum = 5000
    $blinkdelay.Value = $config.blink_delay
    $blinkdelay.Increment = 10
    $form.Controls.Add($blinkdelay)
    
    & $path\blink1-tool.exe -m $config.blink_delay --cyan | Out-Null
    $result = $form.ShowDialog()

    if ($remember.Checked -eq $true){
        if ($username.Text -eq ""){
            $config.username = $null
        }
        else {
            $config.username = $username.Text
        }
        $config.usersave = $true
    }
    else {
        $config.username = $null
        $config.usersave = $false
    }
    
    @{blink_delay=$blinkdelay.Value; busy_delay=$busydelay.Value; username=$config.username; usersave=$config.usersave} | ConvertTo-Json | Out-File "$path\config.json"
    $config.blink_delay = $blinkdelay.Value
    $config.busy_delay = $busydelay.Value

    if ($result -eq "OK"){

        $postParams = @{loginName=$username.Text; loginPassword=$password.Text}
        Invoke-RestMethod -uri 'https://sb.telia.no/bn/login' -Method Post -Body $postParams -SessionVariable session | Out-Null

        $req = $null
        $req = Invoke-RestMethod -Uri 'https://sb.telia.no/api/call/active' -Method POST -WebSession $session

        if ($req.error -eq $false){
            $validate = "1"
        }
        else {
            [System.Windows.MessageBox]::Show('Feil brukernavn eller passord','Blink1-Telia','Ok','Info') | Out-Null
        }
    }
    else {
        $validate = "2"
    }
    
}
if ($validate -eq "2") {
    & $path\blink1-tool.exe -m $config.blink_delay --off | Out-Null
    break
}

$telia = {
    $path = $args[0]
    $config = $args[1]
    $postParams = $args[2]
    Invoke-RestMethod -uri 'https://sb.telia.no/bn/login' -Method Post -Body $postParams -SessionVariable session | Out-Null

    # Loop
    While ($true) {
        $req = $null
        $req = Invoke-RestMethod -Uri 'https://sb.telia.no/api/call/active' -Method POST -WebSession $session

        if ($req.error -eq $false){
            if($req.activecall.agent){
                & $path\blink1-tool.exe -m $config.blink_delay --red
                $busy = 1
            }
            else {
                if ($busy -eq 1){
                    Start-Sleep $config.busy_delay
                    $busy = 0
                }
                else {
                    & $path\blink1-tool.exe -m $config.blink_delay --green
                }
            }
            Start-Sleep 3
        }
        else {
            & $path\blink1-tool.exe -m $config.blink_delay --yellow
            Start-Sleep 5
        }
    }
}

#Form
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.Size = New-Object Drawing.Size @(210,230)
$form.StartPosition = "CenterScreen"
$form.Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$form.Topmost = $true

#Knapp 1
$btn1 = New-Object System.Windows.Forms.Button
$btn1.add_click({
    if (!(Get-Job -Name "Telia" -ErrorAction SilentlyContinue)) {
        Start-Job -Name Telia -ScriptBlock $telia -ArgumentList $path, $config, $postParams | Out-Null
    }
})
$btn1.Text = "Telia status"
$btn1.Size = New-Object System.Drawing.Size(170,30)
$btn1.Location = New-Object System.Drawing.Size(10,10)
$btn1.backcolor = "LightGray"

#Knapp 2
$btn2 = New-Object System.Windows.Forms.Button
$btn2.add_click({
    Stop-Telia
    & $path\blink1-tool.exe -m $config.blink_delay --green
})
$btn2.Text = "Ledig"
$btn2.Size = New-Object System.Drawing.Size(170,30)
$btn2.Location = New-Object System.Drawing.Size(10,45)
$btn2.backcolor = "Lime"

#Knapp 3
$btn3 = New-Object System.Windows.Forms.Button
$btn3.add_click({
    Stop-Telia
    & $path\blink1-tool.exe -m $config.blink_delay --red
})
$btn3.Text = "Opptatt"
$btn3.Size = New-Object System.Drawing.Size(170,30)
$btn3.Location = New-Object System.Drawing.Size(10,80)
$btn3.backcolor = "DeepPink"

#Knapp 4
$btn4 = New-Object System.Windows.Forms.Button
$btn4.add_click({
    Stop-Telia
    & $path\blink1-tool.exe -m $config.blink_delay --blue
})
$btn4.Text = "Kake"
$btn4.Size = New-Object System.Drawing.Size(170,30)
$btn4.Location = New-Object System.Drawing.Size(10,115)
$btn4.backcolor = "DeepSkyBlue"

#Knapp 5
$btn5 = New-Object System.Windows.Forms.Button
$btn5.add_click({
    Stop-Telia
    & $path\blink1-tool.exe -m $config.blink_delay --off
    $form.Close()
})
$btn5.Text = "Avslutt"
$btn5.Size = New-Object System.Drawing.Size(170,30)
$btn5.Location = New-Object System.Drawing.Size(10,150)
$btn5.backcolor = "Silver"

& $path\blink1-tool.exe -m $config.blink_delay --magenta | Out-Null

#Form
$form.Controls.Add($btn1)
$form.Controls.Add($btn2)
$form.Controls.Add($btn3)
$form.Controls.Add($btn4)
$form.Controls.Add($btn5)
$form.ShowDialog()