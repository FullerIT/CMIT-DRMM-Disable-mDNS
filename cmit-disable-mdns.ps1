<# CMIT v2025-02-11-001 pellis@cmitsolutions.com

This script should be carefully tested and slowly deployed.
Disables mDNS, I recommend linking with the monitor script to keep the setting disabled. The target should be a device filter focusing Windows devices and excluding certain site groups like offboarding and/or a device group specifically for excluding devices from this policy. Excluded devices will respond to mDNS and send whatever cached credentials are in use.
This addresses mDNS poisoning attacks that can permit lateral movement in a network by receiving a hash that can be used in pass the hash. 
If you pcap you may see mDNS traffic, but it's often Application based, not OS based and can be safely ignored.
Sources:
https://www.thehacker.recipes/ad/movement/mitm-and-coerced-authentications/llmnr-nbtns-mdns-spoofing
Red Team Tool for lateral movement: https://github.com/lgandx/Responder

#>
# Define the registry path and value
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
$registryName = "EnableMulticast"
$desiredValue = 0

# Check if the registry path exists
if (-not (Test-Path -Path $registryPath)) {
    # Create the registry path if it does not exist
    New-Item -Path $registryPath -Force | Out-Null
    Write-Output "Registry path '$registryPath' created."
}

# Check if the registry value exists
if (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue) {
    # Get the current value
    $currentValue = (Get-ItemProperty -Path $registryPath -Name $registryName).$registryName
    
    # Check if the current value matches the desired value
    if ($currentValue -ne $desiredValue) {
        # Set the registry value to the desired value
        Set-ItemProperty -Path $registryPath -Name $registryName -Value $desiredValue
        Write-Output "Registry value '$registryName' updated to $desiredValue."
    } else {
        Write-Output "Registry value '$registryName' is already set to $desiredValue."
    }
} else {
    # If the registry value does not exist, create it and set it to the desired value
    New-ItemProperty -Path $registryPath -Name $registryName -PropertyType DWord -Value $desiredValue
    Write-Output "Registry value '$registryName' created and set to $desiredValue."
}