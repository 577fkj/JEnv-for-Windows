function Invoke-Change {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][boolean]$output,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv change <name>"'
        Write-Host '使用此命令, 您可以全局设置 JAVA_HOME 和要使用的 Java 版本.这将被 "jenv local" 和 "jenv use" 覆盖'
        Write-Host '<name> 是您通过 "jenv add <name> <path>" 分配给路径的别名'
        return
    }

    # Check if specified JEnv is avaible
    $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
    if ($null -eq $jenv) {
        Write-Host ('没有名为 {0} 的 JEnv. 考虑使用 "jenv list"' -f $name)
        return
    }
    else {
        Write-Host "全局设置 JAVA_HOME.这可能需要一些时间"
        $config.global = $jenv.path
        $Env:JAVA_HOME = $jenv.path # Set for powershell users
        if ($output) {
            Set-Content -path "jenv.home.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
        }
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jenv.path, [System.EnvironmentVariableTarget]::User) # Set globally}
        Write-Host "JEnv 已全局更改"
    }
}