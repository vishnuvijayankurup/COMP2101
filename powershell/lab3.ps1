# Get network adapter configuration objects and filter for enabled adapters

$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}



# Loop through each adapter and create a custom object with the desired properties

$output = foreach ($adapter in $adapters) {

    [PSCustomObject]@{

        "Adapter Description" = $adapter.Description

        "Index" = $adapter.Index

        "IP Address(es)" = $adapter.IPAddress -join ", "

        "Subnet Mask(s)" = $adapter.IPSubnet -join ", "

        "DNS Domain Name" = $adapter.DNSDomain

        "DNS Server(s)" = $adapter.DNSServerSearchOrder -join ", "

    }

}



# Format the output as a table for easy readability

$output | Format-Table -AutoSize

