#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\spaceship.omp.json" | Invoke-Expression

# Misc

function Tail() #optional param to take lines of tail
{
    param(
        [Parameter(Manditory=$true)][string]$fileIn,
        [Parameter(Manditory=$false)][int32]$linesOut
    )
    if ($fileIn, $linesOut) {
        Get-Content $fileIn -Wait -Tail $linesOut
    }

    else {
        Get-Content $fileIn -Wait -Tail 50
    }
}

function vim()
{
    param(
        [Parameter][string]$fileIn
    )
    if ($fileIn) {
        bash -c vi $fileIn
    }

    else {
        bash -c vi
    }
}

function ll()
{
    param(
        [Parameter][string]$dirIn
    )
    if ($dirIn) {
        get-childItem  -force $dirIn
    }

    else {
        get-childItem  -force 
    }
}

function cut {
  param(
    [Parameter(ValueFromPipeline=$True)] 
    [string]$inputobject,
    [string]$delimiter='\s+',
    [string[]]$field
  )

  process {
    if ($field -eq $null) { $inputobject -split $delimiter } else {
      ($inputobject -split $delimiter)[$field] }
  }
}
