# Filename: Get-WslHostIpAddresses.ps1


# Get the list of Ethernet and Wi-Fi adapters and their IPs
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
  (
    $_.InterfaceAlias -like "*Ethernet*" -or
    $_.InterfaceAlias -like "*Wi-Fi*"
  ) -and
  $_.InterfaceAlias -notlike "* (WSL)"
}

# Get the adapter details, including MAC addresses
$adapters = Get-NetAdapter | Where-Object {
  $_.Name -like "*Ethernet*" -or
  $_.Name -like "*Wi-Fi*"
}

# Create a list to hold structured data
$adapterInfoList = @()

# Loop through the IP addresses and find the matching adapter to get the MAC address
foreach ($ip in $ipAddresses) {
  $adapter = $adapters | Where-Object { $_.Name -eq $ip.InterfaceAlias }
  if ($adapter) {
    # Add the structured data to the list
    $adapterInfoList += [PSCustomObject]@{
      InterfaceAlias = $ip.InterfaceAlias
      IPAddress      = $ip.IPAddress
      MacAddress     = $adapter.MacAddress | ForEach-Object {
        $_.Replace("-", ":")
      }
    }
  }
}
# Convert the list to JSON format and output it
$adapterInfoList | ConvertTo-Json -Depth 2
