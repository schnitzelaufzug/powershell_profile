Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# called by user selection
function remove_local_users {
	$arr = Get-LocalUser | where {$_.Name -ne 'Administrator' -and $_.Name -ne 'DefaultAccount' -and $_.Name -ne 'Gast'} 
	for ($i = 0; $i -lt ($arr.length-1); $i++) {
		$null = $arr[$i] | Remove-LocalUser | Out-Null
	}
}

function remove_domain_users {
    $loggedInUser = Get-WMIObject -class Win32_ComputerSystem | select username | foreach {$_.username.split('\')[1]}
	# Get all users in User folder that are not Administrator or logged in user.
    $users = Get-WmiObject -Class Win32_UserProfile | where{ $_.LocalPath.split('\')[1] -eq 'Users' -and $_.LocalPath.split('\')[-1] -ne $loggedInUser -and $_.LocalPath.split('\')[-1] -ne 'Administrator' }
    if ($users) {
        foreach ($user in $users) {
            $null = $user.Delete()
        }
    }
}


# Form
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$form.Text = 'Delete Users Script'
$form.Size = New-Object System.Drawing.Size(350,160)
$form.StartPosition = 'CenterScreen'
$form.BackColor = 'white'
$form.FormBorderStyle = 'Fixed3D'


# OK button
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(20,80)
$OKButton.Size = New-Object System.Drawing.Size(50,25)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)


# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(270,80)
$cancelButton.Size = New-Object System.Drawing.Size(50,25)
$cancelButton.Text = "Cacel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)


# Labeltext for dropdown
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,20)
$label.Size = New-Object System.Drawing.Size(100,20)
$label.Text = 'Select an option'
$form.Controls.Add($label)


# Dropdown
$dropDown = new-object System.Windows.Forms.ComboBox
$dropDown.Location = new-object System.Drawing.Size(20,40)
$dropDown.Size = new-object System.Drawing.Size(300,50)


# Dropdown items
[void]$dropDown.Items.Add('Delete only local Users except admin')
[void]$dropDown.Items.Add('Delete all domaine users except admin and your user')
$dropDown.SelectedIndex = 0
$form.Controls.Add($dropDown)


# Show the whole thing
$result = $form.ShowDialog()

# Take result and call script
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    if ($dropDown.SelectedIndex -eq 0) {
        remove_local_users
    }
    if ($dropDown.SelectedIndex -eq 1) {
        remove_domain_users
    }
}