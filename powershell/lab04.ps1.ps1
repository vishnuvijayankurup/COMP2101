# Function to get system hardware description
function Get-SystemHardware {
    $computerSystem = Get-WmiObject Win32_ComputerSystem

    [PSCustomObject]@{
        Manufacturer    = $computerSystem.Manufacturer
        Model           = $computerSystem.Model
        SerialNumber    = $computerSystem.SerialNumber
        BIOSVersion     = (Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion
        Processor       = (Get-WmiObject Win32_Processor).Name
        Memory          = "{0:N2} GB" -f ($computerSystem.TotalPhysicalMemory / 1GB)
    }
}

# Function to get Operating System information
Function Get-OperatingSystem {
    $os = Get-WmiObject win32_operatingsystem
    If ($os.Caption) {
        Write-Host "Operating System: $($os.Caption) $($os.Version)" -ForegroundColor Cyan
    }
    Else {
        Write-Host "Operating System: Data Unavailable" -ForegroundColor Yellow
    }
}

# Define a function to get memory information
function Get-MemoryInformation {
    $memory = Get-WmiObject -Class "Win32_PhysicalMemory"
    $memory | ForEach-Object {
        $vendor = $_.Manufacturer
        $description = $_.Caption
        $size = "{0:n0}" -f ([math]::Round($_.Capacity / 1MB, 2))
        $bank = $_.BankLabel
        $slot = $_.DeviceLocator
        
        [PSCustomObject]@{
            Vendor = if($vendor) { $vendor } else { "N/A" }
            Description = if($description) { $description } else { "N/A" }
            Size = if($size) { $size + " MB" } else { "N/A" }
            Bank = if($bank) { $bank } else { "N/A" }
            Slot = if($slot) { $slot } else { "N/A" }
        }
    }
}

function Get-DiskInfo {
    # Get physical disk drive information
    $diskdrives = Get-CimInstance CIM_DiskDrive

    $diskReport = foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk
            foreach ($logicaldisk in $logicaldisks) {
                $diskSize = $disk.Size / 1GB -as [int]
                $diskFreeSpace = $logicaldisk.FreeSpace / 1GB -as [int]
                $diskPercentFree = [Math]::Round($logicaldisk.FreeSpace / $logicaldisk.Size * 100, 2)

                [PSCustomObject]@{
                    Manufacturer = $disk.Manufacturer
                    Model = $disk.Model
                    Size_GB = $diskSize
                    Partition = $partition.DeviceID
                    LogicalDisk = $logicaldisk.DeviceID
                    FreeSpace_GB = $diskFreeSpace
                    PercentFree = $diskPercentFree
                }
            }
        }
    }

    # Output physical disk drive information
    Write-Output "Physical Disk Drive Information"
    Write-Output "----------------------------------"
    $diskReport | Format-Table -AutoSize
}

# Get network adapter configuration objects
$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration

# Filter enabled adapters only
$enabledAdapters = $adapters | Where-Object { $_.IPEnabled -eq $true }

# Format output
$report = $enabledAdapters | Select-Object Description, Index, IPAddress, SubnetMask, DNSDomain, DNSServerSearchOrder |
    Format-Table -AutoSize



# Function to get video card information
function Get-VideoCardInfo {
    $adapter = Get-WmiObject -Class win32_videocontroller | Select-Object AdapterCompatibility, Description, VideoProcessor, VideoModeDescription
    if ($adapter) {
        return @{
            'Vendor' = $adapter.AdapterCompatibility
            'Description' = $adapter.Description
            'Resolution' = $adapter.VideoModeDescription.Split(',')[0]
        }
    } else {
        return @{
            'Vendor' = 'Data Unavailable'
            'Description' = 'Data Unavailable'
            'Resolution' = 'Data Unavailable'
        }
    }
}

# Main section to output the system information report
Write-Host "SYSTEM INFORMATION REPORT" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host

# System Hardware
Write-Host "System Hardware" -ForegroundColor Green
Write-Host "---------------" -ForegroundColor Green
Get-SystemHardware | Format-List | Out-String | ForEach-Object { $_.TrimEnd() }
Write-Host

# Call the functions to display the information
Get-OperatingSystem



# Call the Get-MemoryInformation function and format the output as a table
Get-MemoryInformation | Format-Table -AutoSize

Get-DiskInfo

# Get video card information
$videoCardInfo = Get-VideoCardInfo

# Output report
$report

# Output the information
Write-Host 'Video Card Information' -ForegroundColor Green
Write-Host '---------------------' -ForegroundColor Green
Write-Host 'Vendor: ' $videoCardInfo.Vendor
Write-Host 'Description: ' $videoCardInfo.Description
Write-Host 'Resolution: ' $videoCardInfo.Resolution
