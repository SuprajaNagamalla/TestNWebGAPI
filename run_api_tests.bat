@echo off
REM Simple API test runner (no args), waits 2 minutes before exiting

setlocal

REM Check if MASTER_KEY is set (required for encrypted configuration)
if "%MASTER_KEY%"=="" (
    echo Warning: MASTER_KEY environment variable is not set.
    echo This may cause failures if encrypted configuration is required.
    echo.
)

REM ---- Fixed config ----
set "GROUPS=regression"
REM Test suite lives under the rac_pad_api module
set "SUITE=src\test\resources\testSuites\csm.xml"
set "PUBLISH=false"

REM Convert Windows path to forward slashes for Maven/TestNG
set "SUITE_UNIX=%SUITE:\=/%"

echo Running Maven with:
echo   groups=%GROUPS%
echo   suite=%SUITE%
echo   publishTeamsNotification=%PUBLISH%
echo.

REM Build the args in one variable to avoid line continuations
set "MVN_ARGS=-pl rac_pad_api -am -Dgroups=%GROUPS% -DsuiteXmlFile=%SUITE_UNIX% -DtestngXml=%SUITE_UNIX% -DpublishTeamsNotification=%PUBLISH%"

REM Show the complete command that will be executed
echo.
echo Full Maven Command:
echo mvn %MVN_ARGS% clean install test
echo.

REM Execute the command
call mvn %MVN_ARGS% clean install test
set "EXITCODE=%ERRORLEVEL%"

echo.
echo Maven exited with code %EXITCODE%
echo.
echo ===== Review the above output. Closing in 2 minutes... =====
timeout /t 120 >nul

endlocal & exit /b %EXITCODE%
