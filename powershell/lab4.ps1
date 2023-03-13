# Function to get system hardware information
Function Get-SystemHardware {
    $computerSystem = Get-WmiObject win32_computersystem
    $manufacturer = $computerSystem.Manufacturer
    $model = $computerSystem.Model
    $totalPhysicalMemory = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
    
    # Output results
    [PSCustomObject]@{
        "Manufacturer" = $manufacturer
        "Model" = $model
        "Total Physical Memory (GB)" = $totalPhysicalMemory
    }
}

# Function to get operating system information
Function Get-OperatingSystem {
    $operatingSystem = Get-WmiObject win32_operatingsystem
    $name = $operatingSystem.Caption
    $version = $operatingSystem.Version
    
    # Output results
    [PSCustomObject]@{
        "Name" = $name
        "Version" = $version
    }
}

function Get-ProcessorInfo {
    $processors = Get-WmiObject Win32_Processor
    foreach ($processor in $processors) {
        Write-Host "Processor Information"
        Write-Host "---------------------"
        Write-Host "Description: $($processor.Name)"
        Write-Host "Speed: $([math]::Round($processor.MaxClockSpeed / 1e9, 2)) GHz"
        Write-Host "Number of Cores: $($processor.NumberOfCores) cores"
        if ($processor.L3CacheSize -gt 0) {
            Write-Host "L1 Cache Size: $(($processor.L1CacheSize / 1KB).ToString("F2")) KB"
            Write-Host "L2 Cache Size: $(($processor.L2CacheSize / 1KB).ToString("F2")) KB"
            Write-Host "L3 Cache Size: $(($processor.L3CacheSize / 1MB).ToString("F2")) MB"
        }
        elseif ($processor.L2CacheSize -gt 0) {
            Write-Host "L1 Cache Size: $(($processor.L1CacheSize / 1KB).ToString("F2")) KB"
            Write-Host "L2 Cache Size: $(($processor.L2CacheSize / 1MB).ToString("F2")) MB"
        }
        elseif ($processor.L1CacheSize -gt 0) {
            Write-Host "L1 Cache Size: $(($processor.L1CacheSize / 1KB).ToString("F2")) KB"
        }
        else {
            Write-Host "Cache Size: N/A"
        }
        Write-Host ""
    }
}

# Function to format memory size in human-friendly format
function Format-MemorySize ($size) {
    if ($size -lt 1KB) {
        return "$size Bytes"
    }
    elseif ($size -lt 1MB) {
        return "{0:N2} KB" -f ($size / 1KB)
    }
    elseif ($size -lt 1GB) {
        return "{0:N2} MB" -f ($size / 1MB)
    }
    elseif ($size -lt 1TB) {
        return "{0:N2} GB" -f ($size / 1GB)
    }
    else {
        return "{0:N2} TB" -f ($size / 1TB)
    }
}

# Function to retrieve RAM details
function Get-RAMDetails {
    $memory = Get-WmiObject Win32_PhysicalMemory | Select-Object Manufacturer, PartNumber, Description, Capacity, MemoryType, BankLabel, DeviceLocator
    $memory | ForEach-Object {
        $size = Format-MemorySize $_.Capacity
        $_ | Add-Member -MemberType NoteProperty -Name SizeFormatted -Value $size
    }
    return $memory
}

# Function to retrieve system information
function Get-SystemInfo {
    $system = Get-WmiObject Win32_ComputerSystem
    $os = Get-WmiObject Win32_OperatingSystem
    $cpu = Get-WmiObject Win32_Processor
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, MediaType, Size, FreeSpace
    $info = [PSCustomObject] @{
        "System Name" = $system.Name
        "Manufacturer" = $system.Manufacturer
        "Model" = $system.Model
        "Operating System" = $os.Caption
        "OS Version" = $os.Version
        "CPU" = $cpu.Name
        "CPU Cores" = $cpu.NumberOfCores
        "CPU Threads" = $cpu.NumberOfLogicalProcessors
        "Disk Drives" = $disk.Count
        "Total Disk Space" = Format-MemorySize ($disk | Measure-Object Size -Sum).Sum
    }
    return $info
}

# Function to retrieve system information
function Get-SystemInfo {
    [PSCustomObject]@{
        "Operating System" = (Get-CimInstance Win32_OperatingSystem).Caption
        "Processor" = (Get-CimInstance Win32_Processor).Name
        "RAM" = "{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        "IP Address" = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -notlike "169.*"}).IPAddress
        "Default Gateway" = (Get-NetRoute | Where-Object {$_.DestinationPrefix -eq "0.0.0.0/0.0.0.0"}).NextHop
    }
}

# Function to retrieve disk drive information
function Get-DiskDriveInfo {
    $diskdrives = Get-CimInstance CIM_diskdrive
    $output = foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_diskpartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
                [PSCustomObject]@{
                    "Vendor" = $disk.Manufacturer
                    "Model" = $disk.Model
                    "Drive Letter" = $logicaldisk.DeviceID
                    "Size(GB)" = "{0:N2}" -f ($logicaldisk.Size / 1GB)
                    "Free Space(GB)" = "{0:N2}" -f ($logicaldisk.FreeSpace / 1GB)
                    "Free Space %" = "{0:P2}" -f ($logicaldisk.FreeSpace / $logicaldisk.Size)
                }
            }
        }
    }
    $output
}

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




# Output system hardware information
Write-Host "System Hardware Information"
Write-Host "==========================="
Get-SystemHardware | Format-List

# Output operating system information
Write-Host "Operating System Information"
Write-Host "============================"
Get-OperatingSystem | Format-List

Get-ProcessorInfo


# Display RAM details as a table
Write-Host "RAM Details"
Write-Host "-----------"
Get-RAMDetails | Format-Table -AutoSize Manufacturer, PartNumber, Description, SizeFormatted, BankLabel, DeviceLocator

# Display system information as a table
Write-Host "`nSystem Information"
Write-Host "------------------"
Get-SystemInfo | Format-Table -AutoSize


# Output disk drive information
Write-Host "`nDisk Drive Information"
Write-Host "------------------------"
Get-DiskDriveInfo | Format-Table -AutoSize

$report | Format-Table -AutoSize

# Function to get video controller information
Function Get-VideoControllerInfo {
    $videoController = Get-CimInstance -Class "Win32_VideoController" | Select-Object Name,AdapterRAM,DriverVersion,VideoProcessor,VideoModeDescription,CurrentHorizontalResolution,CurrentVerticalResolution
    If ($videoController) {
        return $videoController
    } Else {
        return "Data Unavailable"
    }
}

# Function to format screen resolution
Function Format-ScreenResolution {
    Param([int]$HorizontalResolution,[int]$VerticalResolution)
    If (($HorizontalResolution) -and ($VerticalResolution)) {
        return "$HorizontalResolution x $VerticalResolution"
    } Else {
        return "Data Unavailable"
    }
}

# System Information Report

# Video Card Information
Write-Host "Video Card Information`n" -ForegroundColor Green
$videoControllerInfo = Get-VideoControllerInfo
If ($videoControllerInfo -ne "Data Unavailable") {
    Write-Host "Vendor:`t`t" -NoNewline; Write-Host $videoControllerInfo.VideoProcessor
    Write-Host "Description:`t" -NoNewline; Write-Host $videoControllerInfo.Name
    Write-Host "Screen Resolution:`t" -NoNewline; Write-Host (Format-ScreenResolution -HorizontalResolution $videoControllerInfo.CurrentHorizontalResolution -VerticalResolution $videoControllerInfo.CurrentVerticalResolution)
} Else {
    Write-Host $videoControllerInfo
}

