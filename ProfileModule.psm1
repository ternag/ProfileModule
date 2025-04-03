New-Alias -Name ll -Value Get-ChildItemLl
New-Alias -Name la -Value Get-ChildItemLa
New-Alias -Name sts -Value Start-TestShell

function Get-ChildItemLl { param ([String]$path = ".") Get-ChildItem -Path $path -Exclude .* }
function Get-ChildItemLa { param ([String]$path = ".") Get-ChildItem -Path $path -Force }
function Write-Info { param ([string]$message) Write-Host -ForegroundColor DarkYellow $message }
function Write-Error { param ([string]$message) Write-Host -ForegroundColor DarkRed $message }
function Write-Success { param ([string]$message) Write-Host -ForegroundColor Green $message }

function Show-Environment { 
  Write-Info "Get-ChildItem Env:"
  Get-ChildItem Env: 
}

function Convert-ToBase64 {
  [Cmdletbinding()]
  param(
    [parameter(ValueFromPipeline)] $Item
  )
  Process {
    return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Item))    
  }
}

function Convert-FromBase64 {
  [Cmdletbinding()]
  param(
    [parameter(ValueFromPipeline)] $Item
  )
  Process {
    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Item))
  }
}

function Start-TestShell ([string]$Module) {
  pwsh -NoExit -NoProfile -Command {
    param($Module)
    if ($Module) {
      Import-Module -Name $Module
      Write-Host -ForegroundColor DarkYellow "Imported module: " $Module
    }
    function prompt { 
      Write-Host -NoNewline -ForegroundColor Green "$($pwd.Path.Substring($pwd.Path.LastIndexOf("\"))) TEST";
      return ">"
    }
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
  } -args $Module
}

function Show-PortsInUse {
  Get-NetTCPConnection | ForEach-Object {
    $processId = $_.OwningProcess
    $process = Get-Process -Id $processId
    $_ | Select-Object LocalAddress, LocalPort, State, @{Name = "ProcessName"; Expression = { $process.ProcessName } }
    | Where-Object { ($_.State -eq "Established") -or ($_.State -eq "Listen") }
  } | Sort-Object LocalPort | Format-Table -AutoSize
}

function Reload-Module {
  param (
    [string] $ModuleName
  )
  Remove-Module -Name $ModuleName -Force
  Import-Module -Name $ModuleName
}


function Show-GitAliases {
  $aliases = git config -l | Select-String -Pattern "alias" 
  $objects = @(); # Create an empty array to store the objects
  ForEach ($alias in $aliases) {
    $arr = $alias.ToString().Replace("alias.", "").Split('='); 
    $obj = New-Object PSCustomObject -Property @{
      Alias = $arr[0]
      Command = ($arr[1..($arr.Length-1)] | Join-String)
    }
    $objects += $obj;
  }
  $objects  | Format-Table -Property 'Alias','Command'
}