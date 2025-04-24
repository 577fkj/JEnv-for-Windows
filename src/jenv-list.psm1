function Invoke-List {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help
    )

    if ($help) {
        Write-Host '"jenv list"'
        Write-Host "此命令将显示每个添加的 Java 版本及其名称"
        Write-Host '您必须使用 "jenv add" 添加 Java 版本'
        Write-Host '然后您可以使用各种命令如 "jenv use" 或 "jenv change" 设置它们'
        Write-Host "此命令还将告诉您指定的每个本地 JEnv"
        Write-Host '您可以通过 "jenv local" 告诉 JEnv 它应该始终在桌面上使用 jdk8'
        return
    }

    Write-Host "所有可用的 Java 版本"
    Write-Host ($config.jenvs | Format-Table | Out-String)
    Write-Host "所有本地指定版本"
    Write-Host ($config.locals | Format-Table | Out-String)
}