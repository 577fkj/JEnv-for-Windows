function Invoke-Add {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][string]$name,
        [Parameter(Mandatory = $true)][string]$path
    )

    if ($help) {
        Write-Host '"jenv add" <name> <path>'
        Write-Host "通过此命令, 您可以告诉 JEnv 您已安装的 Java 版本"
        Write-Host '<name> 是您必须为 Java 版本提供的别名, 以便更容易引用.它不能是 remove'
        Write-Host '<path> 是 bin 文件夹的父路径.例如: "C:\Program Files\Java\jdk-17"'
        Write-Host '您必须先注册 JEnv, 然后才能使用 "jenv change"、"jenv use" 或 "jenv local"'
        Write-Host '使用 "jenv list" 列出所有已注册的 Java 版本'
        Write-Host '此命令不用于指定本地 JEnv. 使用 "jenv local" 进行此操作'
        return
    }

    # Name cannot be remove due to the local remove
    if ($name -eq "remove") {
        Write-Output '您的 JEnv 名称不能是 "remove". 查看 "jenv remove"'
        return
    }

    # Check if name is already used
    foreach ($jenv in $config.jenvs) {
        if ($jenv.name -eq $name) {
            Write-Output "已经存在名为 $name 的 JEnv. 考虑使用 ""jenv list"""
            return
        }
    }
    # Check if the path is a valid java home
    if (!(Test-Path -Path $path/bin/java.exe -PathType Leaf)) {
        Write-Output ($path + "/bin/java.exe 未找到. 您的路径不是有效的 JAVA_HOME")
        return
    }

    # Add new JEnv
    $config.jenvs += [PSCustomObject]@{
        name = $name
        path = $path
    }
    Write-Output ("成功添加新的 JEnv: " + $name)
}