@echo off
for /f "delims=" %%i in ('jenv getjava') do set "var=%%i"

if exist "%var%/bin/javac.exe" (
    "%var%/bin/javac.exe" %*
) else (
    echo 出现错误:
    echo %var%
)