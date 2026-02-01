# 1. Setup variables
$user = "your_username"
$remote = "remote_host_ip"
$newOctet = "99"  # Set your desired 3rd octet here

$password = Read-Host "Enter sudo password" -AsSecureString
$passPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($passPtr)

# 2. Define the remote commands
# The regex looks for: 10. (any digits) . (the target digits) .
$remoteCmds = @"
echo '$plainPass' | sudo -S bash -c '
    # Update network adapter
    sed -i "s/\(10\.[0-9]\+\.\)[0-9]\+\./\1$newOctet\./g" /etc/sysconfig/network-scripts/ifcfg-eth1
    
    # Update iptables
    sed -i "s/\(10\.[0-9]\+\.\)[0-9]\+\./\1$newOctet\./g" /etc/iptables
    
    # Update hosts
    sed -i "s/\(10\.[0-9]\+\.\)[0-9]\+\./\1$newOctet\./g" /etc/hosts

    # Optional: Reload iptables to apply changes
    # systemctl restart iptables 
'
"@

# 3. Execute
ssh -t $user@$remote $remoteCmds
