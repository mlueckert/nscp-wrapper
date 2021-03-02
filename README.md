# NSCP Wrapper

This project mainly consists of a Powershell script that is used in combination with the Nagios NCPA agent.

Until now we heavily used NSClient++ (nscp) to perform all our Windows based service checks. As this project is stale since several months we are looking into something new.

NCPA looks pretty good, but it offers not the same functionality as we had with nscp. Therefore the idea came up to just reuse nscp but trigger the checks from NCPA.

The goal of this wrapper is that most of the checks and all its special parameters can be reused with NCPA.

## Installation

1. Install NCPA and generate a Token

2. If you have NSClient++ (64Bit) installed, you only have to copy the nscpwrapper.ps1 file into the plugins directory of NCPA. If NSClient is not installed, download the ZIP file and unzip into ./plugins/nsclient

3. Test by navigate to ``https://ServerName:5693/api/plugins/nscpwrapper.ps1/check_nscp_version/?token=Token``

4. You should get a similar output:

```json
{
    "returncode": 0, 
    "stdout": "{\"output\":\"OK: 0.5.2.39 (2018-02-04)\",\"exitcode\":0,\"longoutput\":\"OK: 0.5.2.39 (2018-02-04)|\",\"perfdata\":\"\"}"
}
```

## Limitations

- It looks like check_cpu can only be used when nscp is running in daemon mode and not started adhoc as we do here.

## Parameters

-ShowCMD = will add a new attribute "cmd" to the output json with the full command.

``https://ServerName:5693/api/plugins/nscpwrapper.ps1/check_nscp_version/-ShowCMD/?token=Token``

```json
{
    "returncode": 0, 
    "stdout": "{\"output\":\"OK: 0.5.2.39 (2018-02-04)\",
    \"exitcode\":0,
    \"longoutput\":\"OK: 0.5.2.39 (2018-02-04)|\",
    \"cmd\":\"C:\\Program Files\\NSClient++\\nscp.exe client --module CheckNSCP --query check_nscp_version  --settings dummy\",
    \"perfdata\":\"\"}"
}
```

## Examples

### Run check_memory

``
https://[ServerName]:5693/api/plugins/nscpwrapper.ps1/check_memory/?token=[Token]
``

```json
{
    "returncode": 1, 
    "stdout": "{\"output\":\"WARNING: committed = 4.046GB, physical = 3.574GB\",\"exitcode\":1,\"longoutput\":\"WARNING: committed = 4.046GB, physical = 3.574GB|'committed'=4.04589GB;6.3996;7.19955;0;7.9995 'committed %'=51%;80;90;0;100 'physical'=3.57409GB;3.1996;3.59955;0;3.9995 'physical %'=89%;80;90;0;100\",\"perfdata\":\"'committed'=4.04589GB;6.3996;7.19955;0;7.9995 'committed %'=51%;80;90;0;100 'physical'=3.57409GB;3.1996;3.59955;0;3.9995 'physical %'=89%;80;90;0;100\"}"
}
```

### Run check_memory with thresholds

``
https://[ServerName]:5693/api/plugins/nscpwrapper.ps1/check_memory/"crit= used > 110%"/"warn= used > 110%"/show-all/?token=[Token]
``

Example Output:

```json
{
    "returncode": 0, 
    "stdout": "{\"output\":\"OK: committed = 4.058GB, physical = 3.591GB\",\"exitcode\":0,\"longoutput\":\"OK: committed = 4.058GB, physical = 3.591GB|'committed'=4.05768GB;8.79945;8.79945;0;7.9995 'committed %'=51%;110;110;0;100 'physical'=3.59069GB;4.39945;4.39945;0;3.9995 'physical %'=90%;110;110;0;100\",\"perfdata\":\"'committed'=4.05768GB;8.79945;8.79945;0;7.9995 'committed %'=51%;110;110;0;100 'physical'=3.59069GB;4.39945;4.39945;0;3.9995 'physical %'=90%;110;110;0;100\"}"
}
```
