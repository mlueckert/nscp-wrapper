#Naemon Plugin output description https://www.naemon.org/documentation/usersguide/pluginapi.html
# .\nsclient\nscp.exe --help
#$ErrorActionPreference = 'Stop'

function Get-StatusCode(){
    param(
        $Value,
        $Key,
        [Switch]$All
    )
    $StatusCodes = @{
        OK = 0
        WARNING = 1
        CRITICAL = 2
        UNKNOWN = 3
    }
    if($All -or $par){
        $StatusCodes
    }
    elseif ($Value) {
        $StatusCodes.GetEnumerator() | Where-Object {$_.Value -eq $Value}
    }
    else {
        $StatusCodes.GetEnumerator() | Where-Object {$_.Key -eq $Key}
    }
}

try {
    #$nscp_output = .\nsclient\nscp.exe client --module CheckSystem --query check_memory 'warning=used > 100%' --settings dummy
    $nscp_output = .\nsclient\nscp.exe client --module CheckDisk --query check_drivesize 'crit=free<10%' 'drive=c' --settings dummy
    if($nscp_output -match "Failed to validate filter"){
        throw $nscp_output
    }

    $plugin_exitcode = $LASTEXITCODE
    
    $regex_output = [Regex]::new('\G(?<output>.*)\|')
    $regex_output_result = $regex_output.Matches($nscp_output)
    $plugin_output = $regex_output_result.Groups | Where-Object {$_.Name -eq 'output' -and -not [string]::IsNullOrEmpty($_.Value)} | Select-Object -Property Value
    
    
    $regex_perfdata = [Regex]::new('\|(?<perfdata>.*)')
    $regex_perfdata_result = $regex_perfdata.Matches($nscp_output)
    $plugin_perfdata = $regex_perfdata_result.Groups | Where-Object {$_.Name -eq 'perfdata' -and -not [string]::IsNullOrEmpty($_.Value)} | Select-Object -Property Value

    $regex_longoutput = [Regex]::new('(?<longoutput>.*)\|*.*\n?')
    $regex_longoutput_result = $regex_longoutput.Matches($nscp_output)
    $plugin_longoutput = $regex_longoutput_result.Groups | Where-Object {$_.Name -eq 'longoutput' -and -not [string]::IsNullOrEmpty($_.Value)} | Select-Object -Property Value


    $Output = @{
        exitcode = $plugin_exitcode
        output = $plugin_output.Value.Trim()
        longoutput = $plugin_longoutput.Value.Trim()
        perfdata = $plugin_perfdata.Value.Trim()
    }
    $Output | ConvertTo-Json

}
catch {
    $ReturnMessage = @{
        exitcode = 3
        output = "UNKNOWN - Wrapper error: {0}" -f $_.Exception.Message
    }
    $ReturnMessage | ConvertTo-Json
}
