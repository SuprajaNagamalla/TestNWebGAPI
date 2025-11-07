@echo off
REM Usage: run_ui_tests.bat [env] [groups] [suite] [browser] [publishTeamsNotification]
REM Example: run_ui_tests.bat QA smoke testng.xml chrome true

set ENV=%1
set GROUPS=%2
set SUITE=%3
set BROWSER=%4
set PUBLISH=%5

if "%ENV%"=="" set ENV=QA
if "%GROUPS%"=="" set GROUPS=smoke
if "%SUITE%"=="" set SUITE=src\test\resources\testSuites\testng.xml
if "%BROWSER%"=="" set BROWSER=chrome
if "%PUBLISH%"=="" set PUBLISH=true

mvn -pl rac_pad_ui test ^
  -Denv=%ENV% ^
  -Dgroups=%GROUPS% ^
  -DtestngXml=%SUITE% ^
  -Dbrowser=%BROWSER% ^
  -DpublishTeamsNotification=%PUBLISH%

exit /b %ERRORLEVEL%
