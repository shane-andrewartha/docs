#
# This script performs an arbitary function
#
# How to run
#  powershell.exe -ExecutionPolicy Bypass -File {your-file-name}.ps1 -mode:0 -action:"Hello, World!"
#
# 2023-07-12 1001 Added script's arguments and functions
# 2023-07-12 1000 Initial version
#

## Allow users to run your script with -Verbose (for more output)
[cmdletbinding()]

## Script argument(s)
param(	[int]      $mode = 1,   # By default do nothing
         [string] $action = "No action was provided by user" )

## Include(s)
# . "{relative-path-to-your-file".pm

## Function(s)
function Write-FormattedOutput {
[cmdletbinding()]
param( [string] $Message = "No message", 
       [bool] $ToJson = $True )

   # 2023-07-12T11:20:56
   $sortableTimestamp = "{0:yyyy-MM-ddTHH:mm:ss}" -F $(Get-Date)
   

   # { "Time":  "2023-07-12 1001", "Message":  "Hello, World!" }
   $eventObject = New-Object PSObject
   $eventObject | Add-Member -MemberType NoteProperty -Name "Message" -Value "$message" -Force
   $eventObject | Add-Member -MemberType NoteProperty -Name "Time" -Value "$sortableTimestamp" -Force

   if ($ToJson) {
      $jsonObject = $eventObject | ConvertTo-Json
      # Remove CR/LF 
      $jsonObject = $jsonObject -replace "`n","" -replace "`r",""
      Write-Output "$jsonObject"
   }
   else {   
      Write-Output "$eventObject"
   }
}
function Execute-Command
{
[cmdletbinding()]
param( [string] $Exe = "hostname", [string] $Args = "" )

  # Setup the Process startup info
  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName = "$Exe"
  if ($Args) {
      $pinfo.Arguments = " $Args"
  } else {
      $pinfo.Arguments = ""
  }
  $pinfo.UseShellExecute = $false
  $pinfo.CreateNoWindow = $true
  $pinfo.RedirectStandardOutput = $true
  $pinfo.RedirectStandardError = $true

  # For debug
  Write-Verbose -Message "           $Exe $Args"

  # Create a process object using the startup info
  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $pinfo

  # Start the process
  try {
    $rv = $process.Start() #| Out-Null
  } catch {
    Throw "$process.StandardError.ReadToEnd()"
  }

  # get output from stdout and stderr
  if ("$rv") {
     $prefix = ""  # "`n"
     $stdout = "$prefix" + $process.StandardOutput.ReadToEnd() + $process.StandardError.ReadToEnd()
     return "$($stdout.Trim())"
  } else {
     # return null
  }
} 

## Main method
try {

	# User of this script can use %ERRORLEVEL% return codes to detect an unclean exit
	[int] $tellCaller = 0

	# Looking up this script's name
   $scriptName = ($MyInvocation.MyCommand.Definition).split('\\')[-1]
   
	# Getting timestamp for output
	# Eg. 2017-10-10T21:57:22.000Z
	$sortableTimestamp = "{0:yyyy-MM-ddTHH:mm:ss}" -F $(Get-Date)
	Write-Verbose "$sortableTimestamp $scriptName has begun"

	# Show local PowerShell version
	$verNum = [string] $PSVersionTable.PSVersion
	$execPol = Get-ExecutionPolicy
	Write-Verbose -Message "PowerShell V$VerNum, ExecutionPolicy $execPol"

	# Check if -Verbose and or -Debug have been specified by the caller
	if (-Not ($VerbosePreference -like 'SilentlyContinue')) {
		Write-Verbose -Message "Verbose switch was specified ($VerbosePreference)"
	}
	if (-Not ($DebugPreference -like 'SilentlyContinue')) {
		Write-Verbose -Message "Debug switch was specified. Debug logging is on ($DebugPreference)"
	} else {
		Write-Verbose -Message "Debug output is off. DebugPreference is $DebugPreference"
	}   

   #### Your code below #################################
   
   # Looking up this script's name
   [string] $scriptFullName = "$($MyInvocation.MyCommand.Definition)"
   [string] $stanzaName = "$($scriptName.split('\\')[-1])"

   # Echoing to stdout
   [string] $msg = "Test message from inputs.conf [powershell://$($stanzaName)] script = . \`"$($scriptFullName)\`""
   Write-FormattedOutput -Message:"$msg"

   # Trying to exe a cmd, output to stdout or stderr
   Execute-Command -Exe:"hostname" -Args:""

   #### Your code above #################################
   
   # Test-ExceptionHandler # throws WriteErrorException, tests whether your caller sees your script exited with 0 or aborted: echo %ERRORLEVEL%

	$sortableTimestamp = "{0:yyyy-MM-ddTHH:mm:ss}" -F $(Get-Date)
	Write-Verbose "$sortableTimestamp $scriptName has ended"

   Write-Verbose "Exit 0"
   # Exit cleanly, end of script
   Exit 0
}
catch {
   Write-Verbose "Exit 1"
   # Exit uncleanly, tell the caller we aborted, output to stderr
	if (-Not $?) { 
      Write-Error "Exception caught: $_.Exception.Message"
      Exit 1
   }
}