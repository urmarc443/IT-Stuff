$AdapterNames = (Get-NetAdapter).Name | sort

$DC = "172.16.1.10"

$GoodNet = Test-Connection $DC -Count 1 -Quiet
$conn = $false
$TIMEOUT_COUNT = 0
#Loop through IFs, Ping 172.16.1.10 (DC01) and if reply then break
#Job can be created to achieve promise so that the other adapters can be set once the deployment moves from connecting to the domain
#$job = Start-Job -ScriptBlock { Test-Connection -TargetName (Get-Content -Path "Servers.txt") }
#$Results = Receive-Job $job -Wait

while ($conn -eq $false)
{
    if ($TIMEOUT_COUNT -eq 3)
    {
        $conn = $true
        Write-Host "TIMEOUT: 3 FAILED ATTEMPTS"
        break
    }
    foreach ($adapter in $AdapterNames)
    {
            
        Disable-NetAdapter -Name $adapter -Confirm:$false

            
    }
    foreach ($adapter in $IFNames)
    {
        Enable-NetAdapter $adapter -Confirm:$false
        sleep 3
        $Test_DC_PING = Test-NetConnection -WarningAction SilentlyContinue
        if ($Test_DC_PING.PingSucceeded -eq $true)
        {
            Write-Host "Good Connection"
            $conn = $true
            break
        }
        else
        {
            Write-Host "`nCouldn't connect to the DC...`n`nTrying the next adapter"
            Disable-NetAdapter $adapter -Confirm:$false
            sleep 3
            $TIMEOUT_COUNT += 1
        }
    }
}