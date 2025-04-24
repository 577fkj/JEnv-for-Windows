<#
.Description
Source: https://github.com/FelixSelter/JEnv-for-Windows/
This is the root script of an application called JEnv for Windows
JEnv allows you to change your current JDK Version.
This is helpful for testing or if you have projects requiring different versions of java
For example you can build a gradle project which requires java8 without changing your enviroment variables and then switch back to work with java15
It"s written in cmd and powershell so it can change the enviroment variables and can run on any Windows-10+.
#>

# Setup params
param (
    <#
    "jenv list"                     List all registered Java-Envs.
    "jenv add <name> <path>"        Adds a new Java-Version to JEnv which can be refferenced by the given name
    "jenv remove <name>"            Removes the specified Java-Version from JEnv
    "jenv change <name>"            Applys the given Java-Version globaly for all restarted shells and this one
    "jenv use <name>"               Applys the given Java-Version locally for the current shell
    "jenv local <name>"             Will use the given Java-Version whenever in this folder. Will set the Java-version for all subfolders as well
    "jenv autoscan <path> [-y]"     Will scan the given path for java installations and ask to add them to JEnv. Path is optional and "--yes|-y" accepts defaults.
    #>
    [Parameter(Position = 0)][validateset("list", "add", "change", "use", "remove", "local", "getjava", "link", "uninstall", "autoscan")] [string]$action,

    # Displays this helpful message
    [Alias("h")]
    [Switch]$help,

    # Creates a jenv.path.tmp and jenv.home.tmp file when anything changes so for example the batch file can change its vars so no reboot is required
    [Alias("o")]
    [Switch]$output,

    # Accept defaults
    [Alias("y")]
    [Switch]$yes,

    [parameter(mandatory = $false, position = 1, ValueFromRemainingArguments = $true)]$arguments
)

#region Load all required modules
Import-Module $PSScriptRoot\util.psm1  # Provides the Open-Prompt function
Import-Module $PSScriptRoot\jenv-list.psm1 -Force
Import-Module $PSScriptRoot\jenv-add.psm1 -Force
Import-Module $PSScriptRoot\jenv-remove.psm1 -Force
Import-Module $PSScriptRoot\jenv-change.psm1 -Force
Import-Module $PSScriptRoot\jenv-use.psm1 -Force
Import-Module $PSScriptRoot\jenv-local.psm1 -Force
Import-Module $PSScriptRoot\jenv-getjava.psm1 -Force
Import-Module $PSScriptRoot\jenv-link.psm1 -Force
Import-Module $PSScriptRoot\jenv-uninstall.psm1 -Force
Import-Module $PSScriptRoot\jenv-autoscan.psm1 -Force
#endregion

#region Installation
# TODO: Check for autoupdates
$JENV_VERSION = "v2.2.1"

#region Remove any java versions from path
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
$systemPath = [System.Environment]::GetEnvironmentVariable("PATH", "MACHINE").split(";", [System.StringSplitOptions]::RemoveEmptyEntries)


# Windows will check the PATH environment variable for java executables.
# But actually there are two different PATHs.
# The first one is set by the administrator of the machine and cannot be edited by the user. It is used for global shared software
# The second one can be set by the user. It is used for individual software
# Jenv needs to ensure that its dummy java.bat script is the first one to be found by windows
# When searching for an executable, windows checks the systems PATH first and the users afterwards
$javaPaths = (Get-Command java -All).source
$root = (get-item $PSScriptRoot).parent.fullname
$dummyScript = ("{0}\java.bat" -f $root)
if ($javaPaths.IndexOf($dummyScript) -eq -1) {
    $wrongJavaPaths = $javaPaths
}
else {
    $wrongJavaPaths = ($javaPaths | Select-Object -SkipLast ($javaPaths.Length - $javaPaths.IndexOf($dummyScript)))
}

# Remove all javas from system path
foreach ($java in $wrongJavaPaths) {
    if ($systemPath.Contains((get-item $java).Directory.FullName)) {
        # Filter out any existing JEnv
        $systemPath = ($systemPath | Where-Object { !($_ -eq $root) })
        # Prepend JEnv
        $systemPath = , $root + $systemPath

        Write-Host ("JEnv 在您的计算机 PATH 环境变量中发现了 java 可执行文件.`nJEnv 需要在 PATH 中放置一个 java 虚拟可执行文件才能正常工作.`n因此您需要手动从 PATH 中移除任何其他 java 可执行文件.`n或者您也可以将 '{0}' 放置在机器 PATH 的顶部" -f $root)
        switch (Open-Prompt "JEnv 安装" "您想将 JEnv 附加到机器路径的开头吗?(此操作需要管理员权限！)" "是", "否" ("将 JEnv ({0}) 附加到机器 PATH 环境变量的开头" -f $root), "中止并退出脚本" 1) {
            0 {
                Write-Host "好的.这可能需要几秒钟时间"
                # Write to PATH
                try {
                    [System.Environment]::SetEnvironmentVariable("PATH", $systemPath -join ";", [System.EnvironmentVariableTarget]::Machine) # Set globally
                }
                catch [System.Management.Automation.MethodInvocationException] {
                    Write-Host "JEnv 想要更改您的系统环境变量. 因此, 您需要以管理员权限重新启动它.这应该只需要一次.如果您不想这样做, 则必须在每次打开终端时调用 JEnv 来更改会话变量"
                }
            }
            1 {
                Write-Host "已中止. PATH 将仅为此 shell 会话修改.您应该考虑手动更改 PATH"
            }
        }
        # Its fine to break here. If we already put something in the machines path we do not need to change the users path as windows checks the machines path first
        break
    }

    # This block only executes if no java was found in the systems path. Because the paths array contains the machine elements followed by the user elements.
    if ($userPath.Contains((get-item $java).Directory.FullName)) {
        # Filter out any existing JEnv
        $userPath = ($userPath | Where-Object { !($_ -eq $root) })
        # Prepend JEnv
        $userPath = , $root + $userPath

        Write-Host ("JEnv 在您的用户 PATH 环境变量中发现了 java 可执行文件.`nJEnv 需要在 PATH 中放置一个 java 虚拟可执行文件才能正常工作.`n因此您需要手动从 PATH 中移除任何其他 java 可执行文件.`n或者您也可以将 '{0}' 放置在用户 PATH 的顶部" -f $root)
        switch (Open-Prompt "JEnv 安装" "您想将 JEnv 附加到用户路径的开头吗?" "是", "否" ("将 JEnv ({0}) 附加到用户 PATH 环境变量的开头" -f $root), "中止并退出脚本" 1) {
            0 {
                Write-Host "好的.这可能需要几秒钟时间"
                # Write to PATH
                [System.Environment]::SetEnvironmentVariable("PATH", $userPath -join ";", [System.EnvironmentVariableTarget]::User) # Set globally
            }
            1 {
                Write-Host "已中止. PATH 将仅为此 shell 会话修改.您应该考虑手动更改 PATH"
            }
        }
        break
    }

}

$path = ($systemPath + $userPath) -join ";"

$Env:PATH = $path # Set for powershell users
if ($output) {
    Set-Content -path "jenv.path.tmp" -value $path # Create temp file so no restart of the active shell is required
}
#endregion

#region Load the config
# Create folder if neccessary. Pipe to null to avoid created message
if (!(test-path $Env:APPDATA\JEnv\)) {
    New-Item -ItemType Directory -Force -Path $Env:APPDATA\JEnv\ | Out-Null
}
# Creates the config file if neccessary
if (!(test-path $Env:APPDATA\JEnv\jenv.config.json)) {
    New-Item -type "file" -path $Env:APPDATA\JEnv\ -name jenv.config.json | Out-Null
}
# Load the config
$config = Get-Content -Path ($Env:APPDATA + "\JEnv\jenv.config.json") -Raw |  ConvertFrom-Json
# Initialize with empty object if config file is empty so Add-Member works
if ($null -eq $config) {
    $config = New-Object -TypeName psobject
}
# Add jenvs property if it does not exist
if (!($config | Get-Member jenvs)) {
    Add-Member -InputObject $config -MemberType NoteProperty -Name jenvs -Value @()
}
# Add locals property if it does not exist
if (!($config | Get-Member locals)) {
    Add-Member -InputObject $config -MemberType NoteProperty -Name locals -Value @()
}
# Add locals property if it does not exist
if (!($config | Get-Member global)) {
    Add-Member -InputObject $config -MemberType NoteProperty -Name global -Value ""
}
#endregion

#endregion

#region Apply java_home for jenv local
$localname = ($config.locals | Where-Object { $_.path -eq (Get-Location) }).name
$javahome = ($config.jenvs | Where-Object { $_.name -eq $localname }).path
if ($null -eq $localname) {
    $javahome = $config.global
}
$Env:JAVA_HOME = $javahome # Set for powershell users
if ($output) {
    Set-Content -path "jenv.home.tmp" -value $javahome # Create temp file so no restart of the active shell is required
}
#endregion

if ($help -and $action -eq "") {
    Write-Host '"jenv list"                            列出所有已注册的 Java 环境.'
    Write-Host '"jenv add <name> <path>"               添加新的 Java 版本到 JEnv, 可通过给定名称引用'
    Write-Host '"jenv remove <name>"                   从 JEnv 中移除指定的 Java 版本'
    Write-Host '"jenv change <name>"                   全局应用指定的 Java 版本, 对所有重启的 shell 和当前 shell 生效'
    Write-Host '"jenv use <name>"                      在当前 shell 本地应用指定的 Java 版本'
    Write-Host '"jenv local <name>"                    在当前文件夹及所有子文件夹中使用指定的 Java 版本'
    Write-Host '"jenv link <executable>"               为 JAVA_HOME 内的可执行文件创建快捷方式, 例如 "javac"'
    Write-Host '"jenv uninstall <name>"                删除 JEnv 并将指定的 Java 版本恢复到系统中.您可以保留配置文件'
    Write-Host '"jenv autoscan [--yes|-y] ?<path>?"    扫描指定路径查找 Java 安装并询问是否添加到 JEnv.路径是可选的, "--yes|-y" 表示接受默认值.'
    Write-Host '通过 "jenv <list/add/remove/change/use/local> --help" 获取各命令的帮助'
}
else {

    # Call the specified command
    # Action has to be one of the following because of the validateset
    switch ( $action ) {
        list { Invoke-List $config $help }
        add { Invoke-Add $config $help @arguments }
        remove { Invoke-Remove $config $help @arguments }
        use { Invoke-Use $config $help $output @arguments }
        change { Invoke-Change $config $help $output @arguments }
        local { Invoke-Local $config $help @arguments }
        getjava { Get-Java $config }
        link { Invoke-Link $help @arguments }
        uninstall { Invoke-Uninstall $config $help @arguments }
        autoscan { Invoke-AutoScan $config $help $yes @arguments }
    }

    #region Save the config
    ConvertTo-Json $config | Out-File $Env:APPDATA\JEnv\jenv.config.json
    #endregion
}