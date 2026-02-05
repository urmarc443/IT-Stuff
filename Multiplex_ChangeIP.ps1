# Configuration
$networkPrefix = "192.168.1."  # The first three octets
$startNode = 11
$endNode = 15
$user = "root"                 # Or your admin user
$oldOctet = "10"               # The current 3rd octet value
$newOctet = "20"               # The value you want to change it to

# Setup ControlMaster directory
$sshFifos = Join-Path $env:USERPROFILE ".ssh\controlmasters"
if (-not (Test-Path $sshFifos)) { New-Item -ItemType Directory -Path $sshFifos | Out-Null }

foreach ($i in $startNode..$endNode) {
    $ip = "$networkPrefix$i"
    $ctl = "$sshFifos\$user@$ip"
    
    Write-Host "--- Processing Node: $ip ---" -ForegroundColor Cyan

    # 1. Establish Master Connection (Background)
    # Using Start-Process to handle the background persistence on Windows
    Start-Process ssh -ArgumentList "-NMS `"$ctl`" $user@$ip" -WindowStyle Hidden
    Start-Sleep -Seconds 2 # Brief pause for auth/handshake

    # 2. Define the remote commands
    # We use sed -i to edit files in-place. 
    # Logic: Look for the old octet surrounded by dots or in an IP pattern
    $remoteCmd = @"
        echo 'Updating /etc/hosts...'
        sed -i 's/\.$oldOctet\./\.$newOctet\./g' /etc/hosts

        echo 'Updating iptables...'
        sed -i 's/\.$oldOctet\./\.$newOctet\./g' /etc/sysconfig/iptables

        echo 'Updating ifcfg-eth1...'
        sed -i 's/IPADDR=192\.168\.$oldOctet\./IPADDR=192\.168\.$newOctet\./g' /etc/sysconfig/network-scripts/ifcfg-eth1
"@

    # 3. Execute via the multiplexed socket
    ssh -S $ctl $user@$ip $remoteCmd

    # 4. Close the Master connection for this node
    ssh -S $ctl -O exit $user@$ip
    Write-Host "Finished $ip`n" -ForegroundColor Green
}
