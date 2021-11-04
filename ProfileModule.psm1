Set-Alias -Name ll -Value Get-ChildItemLl
Set-Alias -Name la -Value Get-ChildItemLa
Set-Alias -Name sts -Value Start-TestShell

function Get-ChildItemLl { param ([String]$path = ".") Get-ChildItem -Path $path -Exclude .* }
function Get-ChildItemLa { param ([String]$path = ".") Get-ChildItem -Path $path -Force}
function Write-Info { param ([string]$message) Write-Host -ForegroundColor DarkYellow $message}
function Write-Error { param ([string]$message) Write-Host -ForegroundColor DarkRed $message}

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

function Add-Path {
    <#
      .SYNOPSIS
        Adds a Directory to the Current Path
      .DESCRIPTION
        Add a directory to the current path.  This is useful for 
        temporary changes to the path or, when run from your 
        profile, for adjusting the path within your powershell 
        prompt.
      .EXAMPLE
        Add-Path -Directory "C:\Program Files\Notepad++"
      .PARAMETER Directory
        The name of the directory to add to the current path.
    #>
  
    [CmdletBinding()]
    param (
      [Parameter(
        Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='What directory would you like to add?')]
      [Alias('dir')]
      [string[]]$Directory
    )
  
    PROCESS {
      $Path = $env:PATH.Split(';')
  
      foreach ($dir in $Directory) {
        if ($Path -contains $dir) {
          Write-Verbose "$dir is already present in PATH"
        } else {
          if (-not (Test-Path $dir)) {
            Write-Verbose "$dir does not exist in the filesystem"
          } else {
            $Path = $dir + $Path
          }
        }
      }
  
      $env:PATH = [String]::Join(';', $Path)
    }
  }

  function Start-TestShell ([string]$Module)
  {
    pwsh -NoExit -NoProfile -Command {
      param($Module)
      Import-Module ProfileModule  -DisableNameChecking
      if($Module)
      {
        Import-Module -Name $Module
        Write-Host "Imported module: " $Module
      }
      function prompt { 
        Write-Host -NoNewline -ForegroundColor Green "$($pwd.Path.Substring($pwd.Path.LastIndexOf("\"))) TEST";
        return ">"
      }
    } -args $Module
  }