#Naemon Plugin output description https://www.naemon.org/documentation/usersguide/pluginapi.html
# .\nsclient\nscp.exe --help
#$ErrorActionPreference = 'Stop'
[CmdletBinding()]
param(
    [String]$Check,
    [String[]]$Arguments
)
function Get-StatusCode() {
    param(
        $Value,
        $Key,
        [Switch]$All
    )
    $StatusCodes = @{
        OK       = 0
        WARNING  = 1
        CRITICAL = 2
        UNKNOWN  = 3
    }
    if ($All -or $par) {
        $StatusCodes
    }
    elseif ($Value) {
        $StatusCodes.GetEnumerator() | Where-Object { $_.Value -eq $Value }
    }
    else {
        $StatusCodes.GetEnumerator() | Where-Object { $_.Key -eq $Key }
    }
}

function Get-NSCPModule() {
    param(
        [String]$CheckNameRegex
    )
    $Modules = @{
        CheckDisk   = 'check_drivesize'
        CheckSystem = 'check_memory','check_cpu'
        CheckWMI    = 'check_wmi'
        CheckNSCP   = 'check_nscp', 'check_nscp_version'
    }
    $return = $Modules.GetEnumerator() | Where-Object { $_.Value -match $CheckNameRegex } | Select-Object -First 1 -ExpandProperty Name

    if ([string]::IsNullOrEmpty($return)) {
        throw ("No NSCP module found for {0}" -f $CheckNameRegex)
    }
    else {
        $return
    }
}

function Get-PluginText() {
    param(
        $Regex,
        $InputString,
        $CaptureGroup
    )
    $regex_output = [Regex]::new($Regex)
    $regex_output_result = $regex_output.Matches($InputString)
    $plugin_output = $regex_output_result.Groups | Where-Object { $_.Name -eq $CaptureGroup -and -not [string]::IsNullOrEmpty($_.Value) } | Select-Object -Property Value
    if ($plugin_output) {
        $plugin_output = $plugin_output.Value.Trim()
    }
    else {
        $plugin_output = ''
    }
    $plugin_output
}

try {
    #$nscp_output = .\nsclient\nscp.exe client --module CheckSystem --query check_memory 'warning=used > 100%' --settings dummy
    Write-Verbose ".\nsclient\nscp.exe client --module $(Get-NSCPModule $check) --query $Check $Arguments --settings dummy"
    $nscp_output = .\nsclient\nscp.exe client --module $(Get-NSCPModule $check) --query $Check $Arguments --settings dummy
    if ($nscp_output -match "Failed to validate filter") {
        throw $nscp_output
    }

    $plugin_exitcode = $LASTEXITCODE
    $plugin_output = Get-PluginText -Regex '\G(?<output>.*)\|' -InputString $nscp_output -CaptureGroup 'output'
    $plugin_perfdata = Get-PluginText -Regex '\|(?<perfdata>.*)' -InputString $nscp_output -CaptureGroup 'perfdata'
    $plugin_longoutput = Get-PluginText -Regex '(?<longoutput>.*)\|*.*\n?' -InputString $nscp_output -CaptureGroup 'longoutput'

    $Output = @{
        exitcode   = $plugin_exitcode
        output     = $plugin_output
        longoutput = $plugin_longoutput
        perfdata   = $plugin_perfdata
    }
    $Output | ConvertTo-Json

}
catch {
    $ReturnMessage = @{
        exitcode = 3
        output   = "UNKNOWN - Wrapper error: {0}" -f $_.Exception.Message
    }
    $ReturnMessage | ConvertTo-Json
}
