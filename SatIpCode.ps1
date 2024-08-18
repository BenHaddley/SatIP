# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    # If not, restart the script with elevated privileges and hide the console window
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Add WPF assembly for GUI
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore  # Needed for image support

# Load settings from a JSON file
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$settingsPath = Join-Path $scriptPath "settings.json"

if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath | ConvertFrom-Json
    $defaultIPAddress = $settings.IPAddress
    $modemConfigURL = $settings.ModemURL
} else {
    $defaultIPAddress = "192.168.0.1"  # Default IP for iQ Desktop+ Satellite Router
    $modemConfigURL = "http://192.168.0.1"  # Default web interface URL
}

# Load the image using a relative path
$imagePath = Join-Path $scriptPath "icon.png"  # Relative path to the image file
$image = New-Object System.Windows.Controls.Image
$image.Source = [System.Windows.Media.Imaging.BitmapImage]::new([Uri]::new($imagePath))

# Function to save settings
function Save-Settings {
    param (
        [string]$IPAddress,
        [string]$ModemURL
    )
    $settings = @{
        IPAddress = $IPAddress
        ModemURL  = $ModemURL
    }
    $settings | ConvertTo-Json | Set-Content $settingsPath
}

# Updated function to restart the application
function Restart-Application {
    # Start a new process with hidden window
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    
    # Close the current instance of the window
    $window.Close()
    # Exit the current script
    exit
}

# Create a window
$window = New-Object system.Windows.Window
$window.Title = "SatIP"
$window.Width = 350
$window.Height = 400  # Adjusted to make room for the new Help button
$window.Background = (New-Object Media.BrushConverter).ConvertFromString("#2b2b2b")  # Darker gray background for entire window
$window.Foreground = (New-Object Media.BrushConverter).ConvertFromString("#ffffff")  # White text color
$window.WindowStartupLocation = "CenterScreen"

# Create a Grid layout
$grid = New-Object System.Windows.Controls.Grid
$window.Content = $grid

# Create a TextBox for IP Address input
$ipLabel = New-Object System.Windows.Controls.Label
$ipLabel.Content = "IP Address:"
$ipLabel.HorizontalAlignment = "Left"
$ipLabel.VerticalAlignment = "Top"
$ipLabel.Margin = "10,20,0,0"
$ipLabel.FontWeight = "Bold"
$ipLabel.Foreground = (New-Object Media.BrushConverter).ConvertFromString("#ffffff")  # White text color
$grid.Children.Add($ipLabel)

$ipTextBox = New-Object System.Windows.Controls.TextBox
$ipTextBox.Width = 200
$ipTextBox.HorizontalAlignment = "Left"
$ipTextBox.VerticalAlignment = "Top"
$ipTextBox.Margin = "120,20,0,0"
$ipTextBox.Text = $defaultIPAddress  # Default value
$ipTextBox.Background = (New-Object Media.BrushConverter).ConvertFromString("#3c3c3c")  # Darker gray for input background
$ipTextBox.Foreground = (New-Object Media.BrushConverter).ConvertFromString("#ffffff")  # White text color
$grid.Children.Add($ipTextBox)

# Button Style Template
$buttonWidth = 220
$buttonHeight = 40

# Define colors using System.Windows.Media.Brushes
$buttonBackground = [System.Windows.Media.Brushes]::DimGray  # Dark gray for buttons
$buttonForeground = [System.Windows.Media.Brushes]::White  # White text color

# Create a Button to set a static IP
$runButton = New-Object System.Windows.Controls.Button
$runButton.Content = "Set IP"
$runButton.Width = $buttonWidth
$runButton.Height = $buttonHeight
$runButton.HorizontalAlignment = "Center"
$runButton.VerticalAlignment = "Top"
$runButton.Margin = "0,70,0,0"
$runButton.Background = $buttonBackground
$runButton.Foreground = $buttonForeground
$runButton.FontWeight = "Bold"
$grid.Children.Add($runButton)

# Define the action when the Set IP button is clicked
$runButton.Add_Click({
    $newIPAddress = $ipTextBox.Text

    # Your script to set the static IP
    $ipAddress = $newIPAddress  # Set to use the new IP Address
    $subnetMask = "255.255.255.0"
    $gateway = $newIPAddress
    $dns = "8.8.8.8"

    # Get the network adapter
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

    # Set the IP address
    New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress $ipAddress -PrefixLength 24 -DefaultGateway $gateway

    # Set the DNS server
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $dns

    [System.Windows.MessageBox]::Show("IP address and DNS server have been set.", "Success", "OK", [System.Windows.MessageBoxButton]::OK)
})

# Create a Button to open the modem configuration page
$openBrowserButton = New-Object System.Windows.Controls.Button
$openBrowserButton.Content = "Open Modem Config"
$openBrowserButton.Width = $buttonWidth
$openBrowserButton.Height = $buttonHeight
$openBrowserButton.HorizontalAlignment = "Center"
$openBrowserButton.VerticalAlignment = "Top"
$openBrowserButton.Margin = "0,120,0,0"
$openBrowserButton.Background = $buttonBackground
$openBrowserButton.Foreground = $buttonForeground
$openBrowserButton.FontWeight = "Bold"
$grid.Children.Add($openBrowserButton)

# Action for opening the modem configuration page using the modemConfigURL variable
$openBrowserButton.Add_Click({
    Start-Process "explorer.exe" $modemConfigURL
})

# Create a Button to set the adapter to obtain IP automatically
$dhcpButton = New-Object System.Windows.Controls.Button
$dhcpButton.Content = "Obtain IP Automatically"
$dhcpButton.Width = $buttonWidth
$dhcpButton.Height = $buttonHeight
$dhcpButton.HorizontalAlignment = "Center"
$dhcpButton.VerticalAlignment = "Top"
$dhcpButton.Margin = "0,170,0,0"
$dhcpButton.Background = $buttonBackground
$dhcpButton.Foreground = $buttonForeground
$dhcpButton.FontWeight = "Bold"
$grid.Children.Add($dhcpButton)

# Add the image to the bottom right, adjusting the margin to move it further down
$image.HorizontalAlignment = "Right"
$image.VerticalAlignment = "Bottom"
$image.Margin = "0,0,10,50"  # Adjust the bottom margin to move it down further
$image.Width = 60  # Adjust the size as needed
$image.Height = 60
$grid.Children.Add($image)

# Create a Button for settings
$settingsButton = New-Object System.Windows.Controls.Button
$settingsButton.Content = "Settings"
$settingsButton.Width = $buttonWidth
$settingsButton.Height = $buttonHeight
$settingsButton.HorizontalAlignment = "Center"
$settingsButton.VerticalAlignment = "Top"
$settingsButton.Margin = "0,220,0,0"
$settingsButton.Background = $buttonBackground
$settingsButton.Foreground = $buttonForeground
$settingsButton.FontWeight = "Bold"
$grid.Children.Add($settingsButton)

# Create a Help Button for guidance
$helpButton = New-Object System.Windows.Controls.Button
$helpButton.Content = "Help"
$helpButton.Width = $buttonWidth
$helpButton.Height = $buttonHeight
$helpButton.HorizontalAlignment = "Center"
$helpButton.VerticalAlignment = "Top"
$helpButton.Margin = "0,270,0,0"
$helpButton.Background = $buttonBackground
$helpButton.Foreground = $buttonForeground
$helpButton.FontWeight = "Bold"
$grid.Children.Add($helpButton)

# Define the action when the Help button is clicked
$helpButton.Add_Click({
    $helpText = @"
This guide provides key steps to follow while using the SatIP program with the iQ Desktop+ Satellite Router:

1. **Pre-Installation**:
   - Choose a location with easy access, adequate power, and proper ventilation.
   - Avoid placing the router near heat sources or in dusty environments.

2. **Installation**:
   - Connect the iQ Desktop+ Satellite Router to the power supply using the appropriate method (AC or DC).
   - Use the 'Set IP' button to configure the router's IP address and ensure it is on the same subnet as your PC.

3. **Configuration**:
   - After setting the IP, use the 'Open Modem Config' button to access the modem's web interface for further configuration.
   - Use the 'Obtain IP Automatically' button if you need the router to acquire an IP address automatically from a DHCP server.

4. **Troubleshooting**:
   - Monitor the LED indicators on the router for status information (e.g., power, RX/TX status).
   - Refer to the troubleshooting section in the manual for specific LED behaviors indicating errors.

For detailed instructions, refer to the iQ Desktop+ Satellite Router Installation, Support, and Maintenance Guide.
"@
    [System.Windows.MessageBox]::Show($helpText, "Help", [System.Windows.MessageBoxButton]::OK)
})

# Define the action when the Settings button is clicked
$settingsButton.Add_Click({
    # Create a new window for settings
    $settingsWindow = New-Object system.Windows.Window
    $settingsWindow.Title = "Settings"
    $settingsWindow.Width = 300
    $settingsWindow.Height = 200
    $settingsWindow.Background = (New-Object Media.BrushConverter).ConvertFromString("#2b2b2b")
    $settingsWindow.Foreground = (New-Object Media.BrushConverter).ConvertFromString("#ffffff")
    $settingsWindow.WindowStartupLocation = "CenterScreen"

    # Create a Grid layout for settings
    $settingsGrid = New-Object System.Windows.Controls.Grid
    $settingsWindow.Content = $settingsGrid

    # IP Address label and TextBox
    $ipSettingsLabel = New-Object System.Windows.Controls.Label
    $ipSettingsLabel.Content = "New IP Address:"
    $ipSettingsLabel.HorizontalAlignment = "Left"
    $ipSettingsLabel.VerticalAlignment = "Top"
    $ipSettingsLabel.Margin = "10,10,0,0"
    $ipSettingsLabel.FontWeight = "Bold"
    $settingsGrid.Children.Add($ipSettingsLabel)

    $ipSettingsTextBox = New-Object System.Windows.Controls.TextBox
    $ipSettingsTextBox.Width = 200
    $ipSettingsTextBox.HorizontalAlignment = "Left"
    $ipSettingsTextBox.VerticalAlignment = "Top"
    $ipSettingsTextBox.Margin = "120,10,0,0"
    $ipSettingsTextBox.Text = $defaultIPAddress  # Current value
    $ipSettingsTextBox.Background = (New-Object Media.BrushConverter).ConvertFromString("#3c3c3c")
    $ipSettingsTextBox.Foreground = (New-Object Media.BrushConverter).ConvertFromString("#ffffff")
    $settingsGrid.Children.Add($ipSettingsTextBox)

    # Modem Config URL label and TextBox
    $urlSettingsLabel = New-Object System.Windows.Controls.Label
    $urlSettingsLabel.Content = "New Modem URL:"
    $urlSettingsLabel.HorizontalAlignment = "Left"
    $urlSettingsLabel.VerticalAlignment = "Top"
    $urlSettingsLabel.Margin = "10,50,0,0"
    $urlSettingsLabel.FontWeight = "Bold"
    $settingsGrid.Children.Add($urlSettingsLabel)

    $urlSettingsTextBox = New-Object System.Windows.Controls.TextBox
    $urlSettingsTextBox.Width = 200
    $urlSettingsTextBox.HorizontalAlignment = "Left"
    $urlSettingsTextBox.VerticalAlignment = "Top"
    $urlSettingsTextBox.Margin = "120,50,0,0"
    $urlSettingsTextBox.Text = $modemConfigURL  # Current value
    $urlSettingsTextBox.Background = (New-Object Media.BrushConverter).ConvertFromString("#3c3c3c")
    $urlSettingsTextBox.Foreground = (New-Object Media.BrushConverter).ConvertFromString("#ffffff")
    $settingsGrid.Children.Add($urlSettingsTextBox)

    # Save Button
    $saveButton = New-Object System.Windows.Controls.Button
    $saveButton.Content = "Save"
    $saveButton.Width = 80
    $saveButton.Height = 30
    $saveButton.HorizontalAlignment = "Center"
    $saveButton.VerticalAlignment = "Bottom"
    $saveButton.Margin = "0,0,0,10"
    $saveButton.Background = $buttonBackground
    $saveButton.Foreground = $buttonForeground
    $saveButton.FontWeight = "Bold"
    $settingsGrid.Children.Add($saveButton)

    # Define the action when the Save button is clicked
    $saveButton.Add_Click({
        $newIPAddress = $ipSettingsTextBox.Text
        $newModemURL = $urlSettingsTextBox.Text

        # Update the variables and save them to the settings file
        $defaultIPAddress = $newIPAddress
        $modemConfigURL = $newModemURL
        Save-Settings -IPAddress $newIPAddress -ModemURL $newModemURL

        # Close the settings window
        $settingsWindow.Close()

        # Restart the application
        Restart-Application
    })

    # Show the settings window
    $settingsWindow.ShowDialog()
})

# Show the main window
$window.ShowDialog()
