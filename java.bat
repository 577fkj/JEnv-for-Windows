@echo off
for /f "delims=" %%i in ('jenv getjava') do set "var=%%i"

if exist "%var%/bin/java.exe" (
    "%var%/bin/java.exe" %*
) else (
    echo 出现错误:
    echo %var%
)