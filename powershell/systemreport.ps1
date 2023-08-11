function systemInfo {
    $systemHardware = Get-CimInstance Win32_ComputerSystem

    $output = "System Hardware Information`n" +
              "Manufacturer: {0}`n" -f $systemHardware.Manufacturer +
              "Model: {0}`n" -f $systemHardware.Model +
              "Total Physical Memory: {0} GB`n" -f [math]::Round($systemHardware.TotalPhysicalMemory / 1GB, 2) +
              "System Type: {0}" -f $systemHardware.SystemType
    
    Write-Host $output
}


function OSInfo {
    $operatingSystem = Get-CimInstance Win32_OperatingSystem

    $output = "Operating System Information`n" +
              "Name: {0}`n" -f $operatingSystem.Caption +
              "Version: {0}`n" -f $operatingSystem.Version +
              "Build Number: {0}`n" -f $operatingSystem.BuildNumber +
              "Service Pack: {0}`n" -f $operatingSystem.CSDVersion +
              "Architecture: {0}" -f $operatingSystem.OSArchitecture
    
    Write-Host $output
}

function theRAMInfo {
    $ramInfo = Get-CimInstance Win32_PhysicalMemory
    $totalRAM = ($ramInfo | Measure-Object Capacity -Sum).Sum / 1GB

    $ramTable = $ramInfo | ForEach-Object {
        [PSCustomObject]@{
            Vendor = $_.Manufacturer
            Description = $_.PartNumber
            SizeGB = [math]::Round($_.Capacity / 1GB, 2)
            Bank = $_.BankLabel
            Slot = $_.DeviceLocator
        }
    }

    $output = $ramTable | Format-Table -AutoSize | Out-String
    $totalRAMSummary = "Total Installed RAM: $totalRAM GB"

    Write-Host $output
    Write-Host
    Write-Host $totalRAMSummary
}


function networkInfo {
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

    $output = $adapters | ForEach-Object {
        $adapter = $_
        $ipAddresses = $adapter.IPAddress -join ', '
        $subnetMasks = $adapter.IPSubnet -join ', '
        $dnsServers = $adapter.DNSServerSearchOrder -join ', '

        "Network Adapter Information`n" +
        "Adapter Description: $($adapter.Description)`n" +
        "Index: $($adapter.Index)`n" +
        "IP Addresses: $ipAddresses`n" +
        "Subnet Masks: $subnetMasks`n" +
        "DNS Domain: $($adapter.DNSDomain)`n" +
        "DNS Servers: $dnsServers`n" +
        ("=" * 40)
    }

    Write-Host $output
}


function diskInfo {
    $diskDrives = Get-CimInstance Win32_DiskDrive

    $diskInformation = $diskDrives | ForEach-Object {
        $disk = $_
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition

        $partitions | ForEach-Object {
            $partition = $_
            $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk

            $logicalDisks | ForEach-Object {
                $logicalDisk = $_
                [PSCustomObject]@{
                    Manufacturer = $disk.Manufacturer
                    Model = $disk.Model
                    SizeGB = [math]::Round($disk.Size / 1GB, 2)
                    Drive = $logicalDisk.DeviceID
                    FreeSpaceGB = [math]::Round($logicalDisk.FreeSpace / 1GB, 2)
                }
            }
        }
    }

    $diskInformation | Format-Table -AutoSize
}


systemInfo
OSInfo
theRAMInfo
networkInfo
diskInfo
