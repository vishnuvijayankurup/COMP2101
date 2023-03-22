[CmdletBinding()]
param(
    [switch]$CPU,
    [switch]$OS,
    [switch]$RAM,
    [switch]$Video,
    [switch]$Disks,
    [switch]$Network
)

function Get-CpuReport {
    $processor = Get-WmiObject win32_processor
    Write-Output "Processor: $($processor.Name)"
}

function Get-OSReport {
    $os = Get-WmiObject win32_operatingsystem
    Write-Output "Operating System: $($os.Caption) $($os.Version)"
}

function Get-RAMReport {
    $ram = Get-WmiObject win32_computersystem
    $totalRam = [math]::Round($ram.TotalPhysicalMemory/1GB, 2)
    Write-Output "RAM: $totalRam GB"
}

function Get-VideoReport {
    $video = Get-WmiObject win32_videocontroller
    Write-Output "Video Controller: $($video.Name)"
}

function Get-DisksReport {
    $disks = Get-WmiObject win32_logicaldisk
    foreach ($disk in $disks) {
        $diskSize = [math]::Round($disk.Size/1GB, 2)
        $freeSpace = [math]::Round($disk.FreeSpace/1GB, 2)
        Write-Output "Drive $($disk.DeviceID): $freeSpace GB free of $diskSize GB"
    }
}

function Get-NetworkReport {
    $network = Get-WmiObject win32_networkadapterconfiguration | Where-Object {$_.IPAddress -ne $null}
    foreach ($adapter in $network) {
        Write-Output "Adapter: $($adapter.Description)"
        Write-Output "IP Address: $($adapter.IPAddress[0])"
        Write-Output "Subnet Mask: $($adapter.IPSubnet[0])"
        Write-Output "Default Gateway: $($adapter.DefaultIPGateway[0])"
        Write-Output ""
    }
}

if ($CPU) {
    Get-CpuReport
}

if ($OS) {
    Get-OSReport
}

if ($RAM) {
    Get-RAMReport
}

if ($Video) {
    Get-VideoReport
}

if ($Disks) {
    Get-DisksReport
}

if ($Network) {
    Get-NetworkReport
}

if (-not ($CPU -or $OS -or $RAM -or $Video -or $Disks -or $Network)) {
    Get-CpuReport
    Get-OSReport
    Get-RAMReport
    Get-VideoReport
    Get-DisksReport
    Get-NetworkReport
}
