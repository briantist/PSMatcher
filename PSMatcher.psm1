﻿$PSVersion = $PSVersionTable.PSVersion.Major

switch ($PSVersion) {
    5 {$target = "classic"}
    6 {$target = "dotnetcore"}
}

$null = [System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\$target\NMatcher.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\$target\Newtonsoft.Json.dll")
$null = [System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\$target\Sprache.dll")

function New-BoolCompatibleResult {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [NMatcher.Matching.Result]
        $Result
    )

    Begin {
        $displayProperties = @('Successful', 'ErrorMessage') -as [String[]]
        $propertySet = New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList 'DefaultPropertySet', $displayProperties
        $ddpStandardMembers = @($propertySet) -as [System.Management.Automation.PSMemberInfo[]]
    }

    Process {
        $Result.Successful |
            Add-Member -NotePropertyName Result -NotePropertyValue $result -TypeName NMatcher.Matching.Result -Force -PassThru |
            Add-Member -MemberType ScriptProperty -Name Successful -Value { $this.Result.Successful } -Force -PassThru |
            Add-Member -MemberType ScriptProperty -Name ErrorMessage -Value { $this.Result.ErrorMessage } -Force -PassThru |
            Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $ddpStandardMembers -Force -PassThru
    }
}

function Test-Json {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Alias('Actual')]
        [ValidateNotNullOrEmpty()]
        $Value ,

        [Parameter(
            Mandatory
        )]
        [Alias('Test')]
        [ValidateNotNullOrEmpty()]
        $Referecnce
    )

    Begin {
        $matcher = New-Object -TypeName NMatcher.Matcher
    }

    Process {
        $matcher.MatchJson($Value, $Referecnce) | New-BoolCompatibleResult
    }
}

Export-ModuleMember -Function Test-Json