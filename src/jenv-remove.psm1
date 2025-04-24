function Invoke-Remove {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv remove" <name>'
        Write-Host '使用此命令, 您可以删除通过 "jenv add" 注册的任何 Java 版本'
        Write-Host '<name> 是您通过 "jenv add <name> <path>" 分配给路径的别名'
        return
    }

    # Remove the JEnv
    $config.jenvs = @($config.jenvs | Where-Object { $_.name -ne $name })
    # Remove any jenv local with that name
    $config.locals = @($config.locals | Where-Object { $_.name -ne $name })
    Write-Output '您的 JEnv 已成功移除'
}