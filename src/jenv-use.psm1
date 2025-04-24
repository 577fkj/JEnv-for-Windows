function Invoke-Use {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][boolean]$output,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv use <name>"'
        Write-Host '使用此命令, 您可以为当前 shell 会话设置 JAVA_HOME 和要使用的 Java 版本.'
        Write-Host '<name> 是您通过 "jenv add <name> <path>" 分配给路径的别名'
        Write-Host '注意, 这会覆盖 "jenv local"'
        return
    }

    # Remove the local JEnv
    if ($name -eq "remove") {
        $Env:JENVUSE = $null # Set for powershell users
        if ($output) {
            Set-Content -path "jenv.use.tmp" -value "remove" # Create temp file so no restart of the active shell is required
        }
        Write-Host "您的会话 JEnv 已被取消设置"
        return
    }


    # Check if specified JEnv is avaible
    $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
    if ($null -eq $jenv) {
        Write-Host ('没有名为 {0} 的 JEnv. 考虑使用 "jenv list"' -f $name)
        return
    }
    else {
        $Env:JAVA_HOME = $jenv.path # Set for powershell users
        $Env:JENVUSE = $jenv.path # Set for powershell users
        if ($output) {
            Set-Content -path "jenv.home.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
            Set-Content -path "jenv.use.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
        }
        Write-Host '已为当前 shell 会话更改 JEnv. 注意, 这会覆盖 "jenv local"'
    }
}