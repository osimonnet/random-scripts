@echo off
REM Usage: one4all.bat <JAR/WAR FILE>

SET "HELP_MSG=Usage: %~nx0 <WAR FILE | JAR FILE> [-v]"

REM Check for user input
if "%~1" == "" (
    echo %HELP_MSG%
    echo Error: Please provide the WAR/jar file name as an argument
    exit /b 1
)

REM Check if file provided exists
if not exist "%~1" (
    echo %HELP_MSG%
    echo Error: File "%~1" not found!
    exit /b 1
)

REM Init vars
SET "O_DIR=%CD%"
SET "CLASS_DIR=CLASSES"
SET "OUT_JAR=all.jar"

REM Create temp dir
mkdir "%TEMP%\%CLASS_DIR%"
7z x -y -o"%TEMP%\%CLASS_DIR%" "%~1"
cd /d "%TEMP%\%CLASS_DIR%"

REM Find all class resources
echo.
echo [+} Searching for resources...
:search_jars
for /f %%F in ('dir /b /s *.jar 2^>nul') do (
    7z x -y "%%F" -o"%%~dpF"
    echo   Processing "%%F"...
    del /f /q "%%F"
    goto search_jars
)
for /r %%D in (classes) do (
    echo   Processing "%%~fD"...
    robocopy "%%D" "%CD%" /s /e /mt:16 /np /njh /njs /ndl /nc /ns
    rmdir /s /q "%%D" 2>nul
)
del /s /q /f /a:-d "*.class" "*.xml" "*.properties"
for /f "delims=" %%I in ('dir /b /s /ad ^| sort /r') do (
    rd "%%I" 2>nul
)
echo.

REM Create jar
echo [+} Creating jar
echo.  %O_DIR%\%OUT_JAR%
jar -cf "%O_DIR%\%OUT_JAR%" *

REM Cleanup
cd /d "%O_DIR%"
rmdir /s /q "%TEMP%\%CLASS_DIR%"
