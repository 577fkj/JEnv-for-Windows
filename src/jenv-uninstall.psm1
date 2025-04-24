function Invoke-Uninstall {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name
    )

    if ($help) {
        Write-Host '"jenv uninstall" <name>'
        Write-Host '此命令删除 jenv 并将指定的 jenv 恢复为 java'
        Write-Host '<name> 是您通过 "jenv add <name> <path>" 分配给路径的别名'
        return
    }

    # Check if specified JEnv is avaible
    $jenv = $config.jenvs | Where-Object { $_.name -eq $name }
    if ($null -eq $jenv) {
        Write-Host ('没有名为 {0} 的 JEnv.考虑使用 "jenv list"' -f $name)
        return
    }

    # Abort Uninstall
    if ((Open-Prompt "卸载 JEnv" "您确定要从此计算机完全删除 JEnv 吗?" "是", "否" "这将从您的计算机中删除 JEnv", "最后一次机会中止操作" 1) -eq 1) {
        Write-Host "已中止卸载"
        return
    }

    #region Restore the specified java version

    # Restore PATH
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
    $systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)

    # Filter out the jenv path
    $root = (get-item $PSScriptRoot).parent.fullname
    $userPath = ($userPath | Where-Object { $_ -ne $root } ) -join ";"
    $systemPath = ($systemPath | Where-Object { $_ -ne $root } ) -join ";"

    #Update user path
    $userPath = $userPath + ";" + $jenv.path + "\bin"

    # Set the new PATH
    $path = $userPath + ";" + $systemPath
    $Env:PATH = $path # Set for powershell users
    if ($output) {
        Set-Content -path "jenv.path.tmp" -value $path # Create temp file so no restart of the active shell is required
    }

    # Restore JAVA_HOME
    $Env:JAVA_HOME = $jenv.path # Set for powershell users
    if ($output) {
        Set-Content -path "jenv.home.tmp" -value $jenv.path # Create temp file so no restart of the active shell is required
    }

    # Set globally
    Write-Host "JEnv is changing your environment variables. This process could take longer"
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javahome, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User) # Set globally

    # Either delete %appdata%/jenv or keep config
    $uninstall = Open-Prompt "卸载 JEnv" "您想保留配置文件吗" "是", "否" "如果您稍后重新安装 JEnv, 它将使用所有已配置的 java_homes 和本地设置", "如果您重新安装 JEnv, 它必须从头开始设置.如果您不打算重新安装 JEnv, 请选择此项" 0
    if ($uninstall -eq 1) {
        Remove-Item $env:appdata/jenv -recurse -force
    }
    #endregion

    # Delete jenv folder
    Remove-Item (get-item $PSScriptRoot).Parent.FullName -Recurse -Force

    # Exit the script so jenv.ps1 wont continue to run
    Write-Host "已成功卸载 JEnv"
    Exit 0
}