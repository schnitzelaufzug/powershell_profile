Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()


function delete_printers($printServer)
{
    # need to get rid of backslashes so we can compare it to beginning of printer name
    $printServer = $printServer.Trim("\")
    
    # Get all printers installed on that pc
    $pcPrinters = Get-WmiObject -Class Win32_Printer -ComputerName $env:COMPUTERNAME | Select-Object Name

    # Create new array to collect only network printers
    $listOfPrinters = New-Object 'string[]' $pcPrinters.Count

    # Only keep networkprinters in array
    $counter = 0
    foreach ($printer in $pcPrinters) {
        if ($printer.Name.split('\')[2] -eq $printServer) {
            $listOfPrinters[$counter] = $printer.Name
        }
        $counter++
    }

    # Filter all $null objects
    $listOfPrinters = $listOfPrinters.Where({ $null -ne $_ })

    # Iterate over each printer and remove it
    foreach ($printer in $listOfPrinters) {
        (New-Object -ComObject WScript.Network).RemovePrinterConnection($printer)
    }
}


# $printerNames = the printers that corrospond to the department which the user selected
function install_printers($printServer, $printerSet)
{
    # Install the corrosponding printers
    foreach ($printer in $printerSet.GetEnumerator().Name) {
        (New-Object -ComObject WScript.Network).AddWindowsPrinterConnection($printServer + $printer)
    }
}


# $printerNames = the printers that corrospond to the department which the user selected
function set_default($printServer, $printerSet)
{
    # Printer with value = 1 will be set as default
    foreach ($printer in $printerSet.GetEnumerator()) {
        if ($printer.Value -eq '1') {
            $defalutPritner = $printer.Name
        }
    }

    (New-Object -ComObject WScript.Network).SetDefaultPrinter($printServer + $defalutPritner)
    
    return $defalutPritner   
}


function execute_testprint($printServer, $defaultPrinter)
{
    $printers = Get-WmiObject -Class Win32_Printer -ComputerName $env:COMPUTERNAME

    foreach ($printer in $printers) {
        if ($printer.Name -eq $printServer + $defaultPrinter) {
            [void]$printer.PrintTestPage()
        }
    }
}


# Printserver name
$printServer = '\\eod-ads-01\'


# list of departments and corrosponding printer
$departments = @{
    Vivobarefoot = @{
        'EOD-VIV-01-F1' = 0;
        'EOD-VIV-01-F2' = 1
    };
    Voipango = @{
        'EOD-MAR-02-F1' = 0;
        'EOD-MAR-02-F2' = 0;
        'EOD-MAR-02-F3' = 0;
        'EOD-MAR-02-F4' = 1
    };
    Marketing = @{
        'EOD-MAR-02-F1' = 0;
        'EOD-MAR-02-F2' = 0;
        'EOD-MAR-02-F3' = 0;
        'EOD-MAR-02-F4' = 1
    };
}


# Create window
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$form.Text = 'Install Printer EOD'
$form.Size = New-Object System.Drawing.Size(400,400)
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
$label.Text = 'Abteilungsauswahl:'
$form.Controls.Add($label)


# Dropdown
$dropDown = new-object System.Windows.Forms.ComboBox
$dropDown.Location = new-object System.Drawing.Size(20,40)
$dropDown.Size = new-object System.Drawing.Size(300,50)
$form.Controls.Add($dropDown)


# Dropdown items
foreach ($department in $departments.GetEnumerator()) {
    [void]$dropDown.Items.Add($department.Name)
}
$dropDown.SelectedIndex = 0


[void]$form.ShowDialog()

delete_printers $printServer
install_printers $printServer $departments[$dropDown.SelectedItem]
$defaultPrinter = set_default $printServer $departments[$dropDown.SelectedItem]
execute_testprint $printServer $defaultPrinter