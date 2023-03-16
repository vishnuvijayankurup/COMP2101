# Get network adapter configuration objects
$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration

# Filter enabled adapters only
$enabledAdapters = $adapters | Where-Object { $_.IPEnabled -eq $true }

# Format output
$report = $enabledAdapters | Select-Object Description, Index, IPAddress, SubnetMask, DNSDomain, DNSServerSearchOrder |
    Format-Table -AutoSize

# Output report
$report
