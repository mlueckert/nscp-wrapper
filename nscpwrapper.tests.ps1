Describe "NSCP Wrapper Tests" {
    Context "Checks" {
        It "check_drivesize" {
            $result = .\nscpwrapper.ps1 -check check_drivesize -arguments 'drive=d:\' | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 0
            $result.output | Should -Match 'OK'
            $result.perfdata | should -Match "d:\\ used'="
        }
        It "check_pagefile" {
            $result = .\nscpwrapper.ps1 -check check_pagefile | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 0
            $result.output | Should -Match 'OK'
            $result.perfdata | should -Match "pagefile.sys'="
        }
        It "check_uptime" {
            $result = .\nscpwrapper.ps1 -check check_uptime | ConvertFrom-Json
            $result.exitcode | Should -BeIn 0,1,2
            $result.output | Should -Match 'uptime:.*boot:'
            $result.perfdata | should -Match "uptime'="
        }
        It "check_nscp_version" {
            $result = .\nscpwrapper.ps1 -check check_nscp_version | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 0
            $result.output | Should -Match 'OK'
            $result.perfdata | Should -BeNullOrEmpty
        }
        It "check_nscp" {
            $result = .\nscpwrapper.ps1 -check check_nscp | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 0
            $result.output | Should -Match ' crash\(es\)'
            $result.perfdata | Should -BeNullOrEmpty
        }
        #CPU check does only work when nsclient is running as a daemon.
        It "check_cpu" -Skip {
            $result = .\nscpwrapper.ps1 -check check_cpu -Arguments 'filter=none' -Verbose | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 0
            $result.output | Should -Match 'OK: CPU load is ok.'
            $result.perfdata | Should -BeNullOrEmpty
        }
        It "non existing checkname given" {
            $result = .\nscpwrapper.ps1 -check check_blubla | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 3
            $result.output | Should -BeExactly "UNKNOWN - Wrapper error: No NSCP module found for check_blubla"
            $result.perfdata | Should -BeNullOrEmpty
        }

    }
}