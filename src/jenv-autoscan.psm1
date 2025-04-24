function Invoke-AutoScan {
    param (
        [Parameter(Mandatory = $true)][object]$config,
        [Parameter(Mandatory = $true)][boolean]$help,
        [Parameter(Mandatory = $true)][boolean]$acceptDefaults,
        [string]$path
    )

    if ($help) {
        Write-Host '"jenv autoscan <path>"'
        Write-Host '这将在给定路径中搜索任何 java.exe 文件, 并提示用户将其添加到 JEnv'
        Write-Host '<path> 是要搜索的路径, 如 "C:\Program Files\Java"'
        Write-Host '如果未提供 <path>, JEnv 将搜索整个系统'
        return
    }

    $paths = @($path)
    if ( $path -eq "") {
        # Get Drives including Temp folders
        $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Root
        # Only keep the physical drive letter
        $drives = $drives | ForEach-Object { $_.Substring(0, 3) }
        # Only keep unique
        $paths = $drives | Select-Object -Unique
    }
    # Check if the provided path exists
    elseif (!(Test-Path -Path $path -PathType Container)) {
        Write-Host "The provided path does not exist"
        return
    }

    # Iterate over paths and find java.exe
    Write-Host "JEnv 正在搜索您计算机上的 java.exe.这可能需要一些时间..."
    $javaExecutables = @()
    foreach ($path in $paths) {
        $path = $path + "\\"
        $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction "SilentlyContinue" | Where-Object { $_.FullName.EndsWith("\bin\java.exe") }
        if ($null -ne $files) {
            $files | ForEach-Object {
                $javaExecutables += $_.FullName
            }
        }
    }

    # Filter out jenv tests java.exe
    $root = (get-item $PSScriptRoot).parent.fullname
    $javaExecutables = $javaExecutables | Where-Object { $_.Contains($root) -eq $false }

    # Ask user if java.exe should be added to the list
    foreach ($java in $javaExecutables) {
        $version = Get-JavaMajorVersion $java
        if ($null -eq $version) {
            # skip the invalid java path
            continue
        }
        if ($acceptDefaults) {
            Invoke-Add $config $false $version ($java -replace "\\bin\\java\.exe$", "")
        } else {
            switch (Open-Prompt "JEnv 自动扫描" ("在 {0} 找到 java.exe.默认名称为: '{1}'.您想将其添加到列表中吗?" -f $java, $version) "是", "否", "重命名" ("这将使用别名 '{1}' 将 {0} 添加到 JEnv" -f $java, $version), ("跳过 {0}" -f $java), "更改默认名称" 1) {
                0 {
                    Invoke-Add $config $false $version ($java -replace "\\bin\\java\.exe$", "")
                }
                2 {
                    Invoke-Add $config $false (Read-Host ("为 {0} 输入新名称" -f $java)) ($java -replace "\\bin\\java\.exe$", "")
                }
            }
        }
    }

}