Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Get all processes and group them by processname ex. 'firefox'
$processes = ps | Select-Object -Property ProcessName, Id, WS | Group-Object -Property ProcessName
# Initializes arrays with the size of processes array.length
$names = New-Object 'string[]' $processes.Length
$values = New-Object 'float[]' $processes.Length

$counter = 0
# create two arrays with names in $names and the combined values of the group in MB in $values
foreach ($processGroup in $processes) {
    $names[$counter] = $processGroup.Name
    # Iterate over the Group array in each row, so we can add all the memory in use together
    foreach ($process in $processGroup.Group) {
        # Select memory in mb of each process and sums them up
        $values[$counter] += $process.WS/1MB
    }
    $counter++
}

# Create hashtable
$arr = @{}
# Write Name as key and value as Value in hashtable
$counter = 0
foreach ($name in $names) {
    $arr.$name = $values[$counter]
    $counter++
}
# Sorts the Hashtable to get the "haviest" processes
$data = $arr.GetEnumerator() | Sort-Object -Property value -Descending | Select-Object -First 5

# Create window
$form = New-Object System.Windows.Forms.Form
$form.TopMost = true
$form.Text = 'Top 5 most memory consuming programms'
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = 'CenterScreen'

# Create GridView
$textBox = new-object System.Windows.Forms.TextBox

$textBox.Multiline = true
$textBox.Text = $data[0]

$form.Controls.Add($textBox)

$form.ShowDialog()