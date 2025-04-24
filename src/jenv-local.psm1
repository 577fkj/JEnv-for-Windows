function Invoke-Local {
    param(
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv local <name>"'
        Write-Host '此命令允许您指定一个 Java 版本, 它将始终在此文件夹和所有子文件夹中使用'
        Write-Host '这会被 "jenv use" 覆盖'
        Write-Host '<name> 是您要指定的 JEnv 的别名'
        Write-Host "注意！在更改 JAVA_HOME 到本地环境之前, 您可能需要先调用 jenv.java 命令将直接可用"
        return
    }

    # Remove the local JEnv
    if ($name -eq "remove") {
        $config.locals = @($config.locals | Where-Object { $_.path -ne (Get-Location) })
        Write-Output "您的本地 JEnv 已被取消设置"
        return
    }

    # Check if specified JEnv is avaible
    $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
    if ($null -eq $jenv) {
        Write-Output "没有名为 $name 的 JEnv. 考虑使用 `"jenv list`""
        return
    }

    # Check if path is already used
    foreach ($jenv in $config.locals) {
        if ($jenv.path -eq (Get-Location)) {
            # if path is used replace with new version
            $jenv.name = $name
            Write-Output ("您已替换 {0} 的 Java 版本为 {1}" -f (Get-Location), $name)
            return
        }
    }

    # Add new JEnv
    $config.locals += [PSCustomObject]@{
        path = (Get-Location).path
        name = $name
    }

    Write-Output ("{0} 现在是 {1} 的本地 Java 版本" -f $name, (Get-Location))
}