Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()


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


# Sorts the Hashtable to get the "biggest" processes
$data = $arr.GetEnumerator() | Sort-Object -Property value -Descending | Select-Object -First 5


# Form
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$form.Text = 'Delete Users Script'
$form.Size = New-Object System.Drawing.Size(280,200)
$form.StartPosition = 'CenterScreen'
$form.BackColor = 'white'
$form.FormBorderStyle = 'Fixed3D'


# Grid View
$gridView = New-Object System.Windows.Forms.DataGridView
$gridView.Size = New-Object System.Drawing.Size(280,200)
$gridView.ColumnCount = 2
$gridView.ColumnHeadersVisible = $true
$gridView.Columns[0].Name = 'Process'
$gridView.Columns[1].Name = 'RAM in MB'
$gridView.BackgroundColor = 'white'


# Add rows in grid view
foreach ($process in $data) {
    [void]$gridView.Rows.Add($process.Name, $process.Value)
}

$form.Controls.Add($gridView)


# Show the whole thing
$result = $form.ShowDialog()