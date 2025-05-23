@echo off

rem # Check if powershell is in path
where /q pwsh
IF ERRORLEVEL 1 (
    where /q powershell
    IF ERRORLEVEL 1 (
        echo 在您的路径中找不到 pwsh.exe 或 powershell.exe.
        echo 请安装 PowerShell, 这是必需的
        exit /B
    ) ELSE (
        set ps=powershell
    )
) ELSE (
    set ps=pwsh
)

rem ps is the installed powershell
%ps% -executionpolicy remotesigned -File "%~dp0/src/jenv.ps1" %* --output

if exist jenv.home.tmp (
    FOR /F "tokens=* delims=" %%x in (jenv.home.tmp) DO (
        set JAVA_HOME=%%x
    )
    del -f jenv.home.tmp
)

if exist jenv.path.tmp (
    FOR /F "tokens=* delims=" %%x in (jenv.path.tmp) DO (
        set path=%%x
    )
    del -f jenv.path.tmp
)

if exist jenv.use.tmp (
    FOR /F "tokens=* delims=" %%x in (jenv.use.tmp) DO (
        if "%%x" == "remove" (
            set "JENVUSE="
        ) ELSE (
            set JENVUSE=%%x
        )
        
    )

    del -f jenv.use.tmp
)
