Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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


# Create window
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$form.Text = 'Delete Users Script'
$form.Size = New-Object System.Drawing.Size(370,180)
$form.StartPosition = 'CenterScreen'


# Create OKButton
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(20,100)
$OKButton.Size = New-Object System.Drawing.Size(50,25)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)


# Cancel OKButton
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100,100)
$cancelButton.Size = New-Object System.Drawing.Size(50,25)
$cancelButton.Text = "Cacel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)


# Labeltext
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,20)
$label.Size = New-Object System.Drawing.Size(100,20)
$label.Text = 'Select a script'
$form.Controls.Add($label)


# Listbox
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20,40)
$listBox.Size = New-Object System.Drawing.Size(300,20)
$listBox.Height = 50
$listBox.SelectionMode = 'MultiExtended'

# Listitems
[void]$listBox.Items.Add('Delete only local Users except admin')
[void]$listBox.Items.Add('Delete all domaine users except admin and your user')

$form.Controls.Add($listBox)
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    if ($listBox.SelectedIndex -eq 0) {
        remove_local_users
    }
    if ($listBox.SelectedIndex -eq 1) {
        remove_domain_users
    }
}