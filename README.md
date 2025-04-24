# JEnv for Windows 第2版来了。
### 对第1版的完全重写
## 只需3个单词即可更改当前Java版本

 - JEnv允许你更改当前的JDK版本。
 - 这对测试或拥有需要不同Java版本的项目非常有帮助
 - 例如，你可以构建一个需要java8的gradle项目，
   而无需更改环境变量，然后
   切换回java15继续工作
 - 它用cmd和powershell编写，因此可以更改环境变量并在任何Windows-10+上运行。

希望你喜欢它。如果你喜欢我的工作，请给我点个星。谢谢！

# 视频演示:
![jenv](https://user-images.githubusercontent.com/55546882/162501231-b2e030bf-1194-4a1d-8565-ccd503b63402.svg)

## 安装
1) **克隆这个仓库**
2) **将其添加到环境变量路径中**
3) **运行一次`jenv`，让脚本完成剩余工作**
4) **如果你使用cmd，需要调用批处理文件。如果使用PowerShell，应该调用/src/jenv.ps1**
5) **有些人报告将JEnv放入C:/Programs文件夹时遇到问题，因为需要管理员权限**
6) **希望我能帮到你。否则，请提出issue**

## 警告:
有时在进入一个指定了local jenv的新目录时，需要调用jenv。这将为当前shell设置JAVA_HOME，并确保像maven这样的工具能正常工作

## 使用方法（注意：local覆盖change。use覆盖local）
1) **添加新的Java环境（需要绝对路径）**  
*jenv add `<名称> <路径>`*  
示例：`jenv add jdk15 D:\Programme\Java\jdk-15.0.1`
 
2) **为当前会话更改Java版本**  
*jenv use `<名称>`*  
示例：`jenv use jdk15`  
用于脚本的环境变量：  
---PowerShell: `$ENV:JENVUSE="jdk17"`  
---CMD/BATCH: `set "JENVUSE=jdk17"`
 
3) **清除当前会话的Java版本**  
*jenv use remove*  
示例：`jenv use remove`  
用于脚本的环境变量：  
---PowerShell: `$ENV:JENVUSE=$null`  
---CMD/BATCH: `set "JENVUSE="`

4) **全局更改Java版本**  
*jenv change `<名称>`*  
示例：`jenv change jdk15`

5) **在此文件夹中始终使用这个Java版本**  
*jenv local `<名称>`*  
示例：`jenv local jdk15  `

6) **清除此文件夹的Java版本**  
*jenv local remove*  
示例：`jenv local remove` 
 
7) **列出所有Java环境**  
*jenv list*  
示例：`jenv list`

8) **从JEnv列表中删除现有JDK**  
*jenv remove `<名称>`*  
示例：`jenv remove jdk15`

9) **启用javac、javaw或其他位于java目录中的可执行文件**  
*jenv link `<可执行文件名>`*  
示例：`jenv link javac`

10) **卸载jenv并自动恢复你选择的Java版本**  
*jenv uninstall `<名称>`*  
示例：`jenv uninstall jdk17`

11) **自动搜索要添加的java版本**  
*jenv autoscan [--yes|-y] `?<路径>?`*  
示例：`jenv autoscan "C:\Program Files\Java"`  
示例：`jenv autoscan` // 将搜索整个系统
示例：`jenv autoscan -y "C:\Program Files\Java"` // 将接受默认值

## 工作原理
此脚本创建一个java.bat文件，调用正确版本的java.exe
当ps脚本更改环境变量时，它们会导出到tmp文件并由批处理文件应用
添加了PowerShell脚本的附加参数。"--output"别名"-o"将为批处理创建tmp文件。见下图

![SystemEnvironmentVariablesHirachyShell](https://user-images.githubusercontent.com/55546882/130204196-1a800310-4454-49bd-8d80-161b0e7cca3f.PNG)

![SystemEnvironmentVariablesHirachyPowerShell PNG](https://user-images.githubusercontent.com/55546882/130204185-b54368cc-34db-40d1-a707-4c5477ca236b.PNG)

## 贡献
如果你想贡献，随时欢迎。这对初学者来说是一个很好的仓库，因为代码量不大，你可以很容易地理解它的工作原理。  
对于运行测试，我建议你使用最新版本的PowerShell（pwsh.exe）：  
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2  
注意，你必须将其作为pwsh而不是powershell运行  
然后你需要安装Pester。这仅用于测试：`Install-Module -Name Pester -Force -SkipPublisherCheck`  
你也可以使用已安装的powershell。但是，它已经安装了一个旧的Pester模块，你不能使用它，我无法弄清楚如何更新它：https://github.com/pester/Pester/issues/1201  
导航到test文件夹并运行`test.ps1`文件。它将在测试期间备份你的环境变量和jenv配置，并在之后自动恢复它们。但你应该始终让测试完成，否则你的变量和配置将不会被恢复
