Describe "NSCP Wrapper Tests" {
    Context "Checks" {
        It "check_drivesize" {
            $result = .\nscpwrapper.ps1 -check check_drivesize -arguments 'drive=d:\' | ConvertFrom-Json
            $result.exitcode | Should -BeExactly 0
            $result.output | Should -Match 'OK'
            $result.perfdata | should -Match "d:\\ used'="
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
        It "check_cpu" {
            $result = .\nscpwrapper.ps1 -check check_cpu -Verbose | ConvertFrom-Json
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

#.\nscpwrapper.ps1 -check check_drivesize

#.\nscpwrapper.ps1 'check_memory' 'warning=used > 1%'