function Invoke-Link {
    param (
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$executable
    )

    if ($help) {
        Write-Host '"jenv link" <executable>'
        Write-Host "使用此命令, 您可以为 JAVA_HOME 内的可执行文件创建快捷方式"
        Write-Host '<executable> 是二进制文件的名称, 例如 "javac" 或 "javaw"'
        Write-Host '例如, 使用 "jenv link javac" 启用 javac'
        Write-Host '使用 "jenv list" 列出所有已注册的 Java 版本'
        return
    }

    $payload = @'
        @echo off
        for /f "delims=" %%i in ('jenv getjava') do set "var=%%i"

        if exist "%var%/bin/{0}.exe" (
            "%var%/bin/{0}.exe" %*
        ) else (
            echo There was an error:
            echo %var%
        )
'@ -f $executable

    Set-Content ((get-item $PSScriptRoot).parent.fullname + "/$executable.bat") $payload

}