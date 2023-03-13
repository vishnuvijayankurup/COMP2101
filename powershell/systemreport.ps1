[CmdletBinding()]
param(
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

function Get-CPUInfo {
    Get-WmiObject Win32_Processor | Select-Object Name, Manufacturer, MaxClockSpeed | Format-Table -AutoSize
}

function Get-OSInfo {
    Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture | Format-Table -AutoSize
}

function Get-RAMInfo {
    Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum | % {[Math]::Round(($_.Sum / 1MB), 2)} | % {"$($_) GB"}
}

function Get-VideoInfo {
    Get-WmiObject Win32_VideoController | Select-Object Name, AdapterCompatibility, VideoProcessor | Format-Table -AutoSize
}

function Get-DiskInfo {
    Get-WmiObject Win32_LogicalDisk | Select-Object DeviceID, MediaType, VolumeName, @{Name="Size";Expression={$_.Size / 1GB}}, @{Name="FreeSpace";Expression={$_.FreeSpace / 1GB}} | Format-Table -AutoSize
}

function Get-NetworkInfo {
    Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq "True"} | Select-Object Description, IPAddress, MACAddress | Format-Table -AutoSize
}

if ($System) {
    Get-CPUInfo
    Get-OSInfo
    Get-RAMInfo
    Get-VideoInfo
}

if ($Disks) {
    Get-DiskInfo
}

if ($Network) {
    Get-NetworkInfo
}

if (-not $System -and -not $Disks -and -not $Network) {
    Get-CPUInfo
    Get-OSInfo
    Get-RAMInfo
    Get-VideoInfo
    Get-DiskInfo
    Get-NetworkInfo
}
