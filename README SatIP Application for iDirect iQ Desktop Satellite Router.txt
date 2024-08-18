Classification: UNCLASSIFIED
Overview
The SatIP application is a non-classified tool designed for managing and troubleshooting the iDirect iQ Desktop Satellite Router. This application provides functionalities for setting up a static IP address, accessing the router's configuration page, and toggling DHCP settings, among other features.

Application Features
Set IP Address: Configure the IP address of your network adapter.
Open Modem Configuration: Directly access the web interface of the iDirect iQ Desktop Satellite Router.
Obtain IP Automatically: Enable DHCP to have the router acquire an IP address automatically.
Settings Management: Adjust default IP and modem configuration URL.
Help: Access a guide for setup and troubleshooting.
Installation and Setup
Ensure Administrative Rights: The application requires elevated privileges to make network configuration changes. If not running as an administrator, it will prompt to restart with the necessary permissions.

File Locations:

SatIpCode.ps1: The primary PowerShell script that runs the application.
SatIpRun.bat: Batch file to execute the PowerShell script.
makeshortcut.bat: Batch file for creating a desktop shortcut to the application.
icon.png, kiwiimage.ico, foldericon.ico: Icon files used in the application interface.
settings.json: Configuration file storing default IP address and modem URL.
Shortcut Creation:Use the makeshortcut.bat file to create a shortcut on your desktop for quick access to the SatIpRun.bat file, which in turn executes the SatIpCode.ps1 script.
Usage

Launching the Application:

Run the SatIpRun.bat file. This batch file executes the PowerShell script SatIpCode.ps1, which opens the main application window.
Configuring IP Address:

Enter the desired IP address in the provided text box and click "Set IP" to configure your network adapter with the specified IP address, subnet mask, and default gateway.
Accessing Router Configuration:

Click "Open Modem Config" to open the router's web interface in your default web browser.
Enabling DHCP:

Click "Obtain IP Automatically" to switch your network adapter to DHCP mode.
Managing Settings:

Click "Settings" to adjust the default IP address and modem configuration URL. Save changes and restart the application for updates to take effect.
Help:

Click "Help" to display a guide with instructions for setup, configuration, and troubleshooting.
Troubleshooting
Shortcut Issues: If the desktop shortcut does not work or is not present, re-run the makeshortcut.bat file to recreate it.
Permission Issues: Ensure the application is run with administrative rights to make network changes.
Application Errors: If you encounter errors, verify that all files are correctly located in the application directory and that you have the necessary permissions.
Support
For additional assistance or technical support, refer to the iDirect iQ Desktop Satellite Router Installation, Support, and Maintenance Guide or contact your system administrator.

Note: This application and its documentation are intended for unclassified use only and should not be used for classified or sensitive operations.

End of Document