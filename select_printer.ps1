Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


# Create window
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$form.Text = 'Top 5 most memory consuming programms'
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = 'CenterScreen'


# Create textbox
$textBox = new-object System.Windows.Forms.TextBox

$textBox.Multiline = $true
$textBox.Text = $data[0]

$form.Controls.Add($textBox)

$form.ShowDialog()
