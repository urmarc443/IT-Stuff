$NetAdapters = (Get-NetAdapter).Name | sort
$NetHash = $NetAdapters | ForEach-Object {@{$_ = (Get-NetAdapter -Name $_).LinkLayerAddress}}
$DC = "172.16.1.10"

#Loop through IFs, Ping 172.16.1.10 (DC01) and if reply then break

foreach ($adapter in $NetAdapters)
{
            
    Disable-NetAdapter -Name $adapter -Confirm:$false

            
}
foreach ($adapter in $NetAdapters)
{
    Enable-NetAdapter $adapter -Confirm:$false
    sleep 3
    $Test_DC_PING = Test-NetConnection 172.16.1.10
    if ($Test_DC_PING.PingSucceeded -ne $null)
    {
        Write-Host "Good Connection"

        break
    }
    else
    {
        Write-Host "`nCouldn't connect to the DC...`n`nTrying the next adapter"
        Disable-NetAdapter $adapter -Confirm:$false
        sleep 3

    }
}