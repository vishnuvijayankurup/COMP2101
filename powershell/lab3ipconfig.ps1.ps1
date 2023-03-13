$networkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}

$report = @()

foreach ($adapter in $networkAdapters) {
    $adapterInfo = [PSCustomObject]@{
        "Adapter Description" = $adapter.Description
        "Index" = $adapter.Index
        "IP Address" = $adapter.IPAddress
        "Subnet Mask" = $adapter.IPSubnet
        "DNS Domain" = $adapter.DNSDomain
        "DNS Server" = $adapter.DNSServerSearchOrder
    }
    $report += $adapterInfo
}

$report | Format-Table -AutoSize
