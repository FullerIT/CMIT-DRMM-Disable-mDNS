<# CMIT v2024-11-20-01 pellis

This script should be carefully tested and slowly deployed.
Disables mDNS, I recommend linking with the monitor script to keep the setting disabled. The target should be a device filter focusing Windows devices and excluding certain site groups like offboarding and/or a device group specifically for excluding devices from this policy. Excluded devices will respond to mDNS and send whatever cached credentials are in use.
This addresses mDNS poisoning attacks that can permit lateral movement in a network by receiving a hash that can be used in pass the hash. 
If you pcap you may see mDNS traffic, but it's often Application based, not OS based and can be safely ignored.
Sources:
https://www.thehacker.recipes/ad/movement/mitm-and-coerced-authentications/llmnr-nbtns-mdns-spoofing
Red Team Tool for lateral movement: https://github.com/lgandx/Responder

#>

# Define the registry path and value
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$registryName = "EnableMDNS"
$expectedValue  = 0

# Check if the registry path and value exist and have the expected value
if ((Test-Path -Path $registryPath) -and 
    (Get-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue) -and 
    ((Get-ItemProperty -Path $registryPath -Name $registryName).$registryName -eq $expectedValue)) {
    # Value is present and correct
    Write-Host "<-Start Result->"
    Write-Host "STATUS=Registry value '$registryName' is set and correct"
    Write-Host "<-End Result->"
    exit 0
} else {
    # Value is either not present or not correct
    Write-Host "<-Start Result->"
    Write-Host "STATUS=Registry value '$registryName' is missing or not set to $expectedValue."
    Write-Host "<-End Result->"
    exit 1
}