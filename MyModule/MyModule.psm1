﻿
Function Get-BBMyEvents
{
<#
.SYNOPSIS
Gets events.

.DESCRIPTION
Get's some events from a user created file

.PARAMETER Log
The log to get events from.

.PARAMETER Latest
The number of events.

.PARAMETER EventID
The EventID.

.INPUTS

.OUTPUTS

.Example

.Example

.NOTES
v1.0.0
Author:     Brad Beckwith
Date:       2016
Location:   PowerShell training class at InterfaceTT
#>
    #	[cmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    [cmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [String[]]$ComputerName = ".",
        [String]$Log = "Security",
        [Int]$Latest = 2,
        [Int]$EventID = 4624
    )
    
<#    
    BEGIN
    {
        
    }
 #>

    PROCESS
    {
        
        If ($PSCmdlet.ShouldProcess($ComputerName))
        {
            Write-Verbose "Getting $Latest Events"
            Write-Debug "The event ID is $EventID"
            
            $Null | Out-File -FilePath C:\temp\Errorlog.txt
            
            ForEach ($C in $ComputerName)
            {
                Try
                {
                    Get-EventLog -LogName $Log `
                                 -Newest $Latest `
                                 -InstanceId $EventID `
                                 -ComputerName $C `
                                 -ErrorAction Stop
                } # END: TRY
                Catch
                {
                    Write-Warning "$C is offline."
                    
                    if (Test-Path "C:\temp")
                    {
                        $C | Out-File -FilePath C:\temp\Errorlog.txt -Append
                    }
                    
                } # END: Catch
                Finally
                {
                    Write-Host "`nDone with $C" -ForegroundColor Green
                }
                
            } # END: ForEach ($C in $ComputerName)    
        }
        
    }
<#    
    END
    {
        EndBlock
    }
#>
    
} # END: Function Get-MyEvents 

#region Test
    <#
    Get-BBMyEvents -ComputerName AZSKGFSESD01, AZSKGFSMSD01
    Write-Host " ======================== " -ForegroundColor Red
    Get-Content -Path c:\temp\ErrorLog.txt

    Get-BBMyEvents -Latest 10
    #>
#EndRegion

function Get-WindowsProductKey([string]$ComputerName)
{
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER ComputerName

.EXAMPLE

.EXAMPLE

.INPUTS

.OUTPUTS

.NOTES

#>
    
    $Reg = [WMIClass] ("\\" + $ComputerName + "\root\default:StdRegProv")
    $values = [byte[]]($reg.getbinaryvalue(2147483650,"SOFTWARE\Microsoft\Windows NT\CurrentVersion","DigitalProductId").uvalue)
    $lookup = [char[]]("B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9")
    $keyStartIndex = [int]52;
    $keyEndIndex = [int]($keyStartIndex + 15);
    $decodeLength = [int]29
    $decodeStringLength = [int]15
    $decodedChars = new-object char[] $decodeLength 
    $hexPid = new-object System.Collections.ArrayList
    for ($i = $keyStartIndex; $i -le $keyEndIndex; $i++){ [void]$hexPid.Add($values[$i]) }
    for ( $i = $decodeLength - 1; $i -ge 0; $i--)
        {                
         if (($i + 1) % 6 -eq 0){$decodedChars[$i] = '-'}
         else
           {
            $digitMapIndex = [int]0
            for ($j = $decodeStringLength - 1; $j -ge 0; $j--)
            {
                $byteValue = [int](($digitMapIndex * [int]256) -bor [byte]$hexPid[$j]);
                $hexPid[$j] = [byte] ([math]::Floor($byteValue / 24));
                $digitMapIndex = $byteValue % 24;
                $decodedChars[$i] = $lookup[$digitMapIndex];
             }
            }
         }
    $STR = ''     
    $decodedChars | % { $str+=$_}
    Write-Output "`nWindows Product Key: $STR`n"
} # END: Function Get-WindowsProductKey


Export-ModuleMember Get-BBMyEvents, Get-WindowsProductKey