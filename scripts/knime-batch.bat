@echo off
REM knime-batch.bat — Windows wrapper for KNIME headless/batch execution
REM
REM Usage:
REM   knime-batch run <workflow-dir-or-zip> [options]
REM   knime-batch load <workflow-dir-or-zip>
REM   knime-batch test <workflow-dir-or-zip>
REM   knime-batch help
REM
REM Environment:
REM   KNIME_HOME   — Path to KNIME installation directory (auto-detected if not set)
REM   KNIME_PREFS  — Path to preferences file (optional)

setlocal enabledelayedexpansion

REM --- Detect KNIME ---
if defined KNIME_HOME (
    set "KNIME_EXE=%KNIME_HOME%\knime.exe"
    if exist "!KNIME_EXE!" goto :found_knime
    echo ERROR: KNIME_HOME set to '%KNIME_HOME%' but knime.exe not found >&2
    exit /b 1
)

REM Check common Windows locations
for /d %%D in (
    "C:\Program Files\KNIME*"
    "C:\knime_*"
    "%USERPROFILE%\knime_*"
    "%LOCALAPPDATA%\KNIME*"
) do (
    if exist "%%~D\knime.exe" (
        set "KNIME_EXE=%%~D\knime.exe"
        goto :found_knime
    )
)

REM Check PATH
where knime.exe >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%I in ('where knime.exe') do set "KNIME_EXE=%%I"
    goto :found_knime
)

echo ERROR: Cannot find KNIME installation. Set KNIME_HOME or add knime.exe to PATH. >&2
exit /b 1

:found_knime
echo Using KNIME: %KNIME_EXE%

REM --- Parse command ---
set "CMD=%~1"
if "%CMD%"=="" set "CMD=help"
shift

if /i "%CMD%"=="run"  goto :cmd_run
if /i "%CMD%"=="load" goto :cmd_load
if /i "%CMD%"=="test" goto :cmd_test
if /i "%CMD%"=="help" goto :cmd_help
if /i "%CMD%"=="--help" goto :cmd_help
if /i "%CMD%"=="-h"   goto :cmd_help

echo Unknown command: %CMD% >&2
goto :cmd_help

REM --- Run command ---
:cmd_run
set "WORKFLOW=%~1"
shift
set "EXTRA_ARGS="
:run_args
if "%~1"=="" goto :run_exec
set "EXTRA_ARGS=%EXTRA_ARGS% %~1"
shift
goto :run_args
:run_exec
if exist "%WORKFLOW%\" (
    set "WF_ARG=-workflowDir=%WORKFLOW%"
) else (
    set "WF_ARG=-workflowFile=%WORKFLOW%"
)
set "PREFS_ARG="
if defined KNIME_PREFS set "PREFS_ARG=-preferences=%KNIME_PREFS%"
echo ^>^>^> "%KNIME_EXE%" -nosplash -consoleLog %WF_ARG% %PREFS_ARG% %EXTRA_ARGS%
"%KNIME_EXE%" -nosplash -consoleLog %WF_ARG% %PREFS_ARG% %EXTRA_ARGS%
exit /b %errorlevel%

REM --- Load command ---
:cmd_load
set "WORKFLOW=%~1"
shift
set "EXTRA_ARGS="
:load_args
if "%~1"=="" goto :load_exec
set "EXTRA_ARGS=%EXTRA_ARGS% %~1"
shift
goto :load_args
:load_exec
if exist "%WORKFLOW%\" (
    set "WF_ARG=-workflowDir=%WORKFLOW%"
) else (
    set "WF_ARG=-workflowFile=%WORKFLOW%"
)
set "PREFS_ARG="
if defined KNIME_PREFS set "PREFS_ARG=-preferences=%KNIME_PREFS%"
echo ^>^>^> "%KNIME_EXE%" -nosplash -consoleLog %WF_ARG% -noexecute -nosave %PREFS_ARG% %EXTRA_ARGS%
"%KNIME_EXE%" -nosplash -consoleLog %WF_ARG% -noexecute -nosave %PREFS_ARG% %EXTRA_ARGS%
exit /b %errorlevel%

REM --- Test command ---
:cmd_test
set "WORKFLOW=%~1"
shift
set "EXTRA_ARGS="
:test_args
if "%~1"=="" goto :test_exec
set "EXTRA_ARGS=%EXTRA_ARGS% %~1"
shift
goto :test_args
:test_exec
if exist "%WORKFLOW%\" (
    set "WF_ARG=-workflowDir=%WORKFLOW%"
) else (
    set "WF_ARG=-workflowFile=%WORKFLOW%"
)
set "PREFS_ARG="
if defined KNIME_PREFS set "PREFS_ARG=-preferences=%KNIME_PREFS%"
echo ^>^>^> "%KNIME_EXE%" -nosplash -consoleLog %WF_ARG% -nosave -reset %PREFS_ARG% %EXTRA_ARGS%
"%KNIME_EXE%" -nosplash -consoleLog %WF_ARG% -nosave -reset %PREFS_ARG% %EXTRA_ARGS%
exit /b %errorlevel%

REM --- Help ---
:cmd_help
echo.
echo knime-batch — KNIME headless/batch execution wrapper
echo.
echo COMMANDS
echo   run  ^<workflow^>  [opts]   Execute workflow (default: save in place)
echo   load ^<workflow^>  [opts]   Load-only validation (no execute, no save)
echo   test ^<workflow^>  [opts]   Execute without saving (dry run)
echo   help                      Show this help
echo.
echo OPTIONS (pass through to KNIME)
echo   -workflow.variable=NAME,VALUE,TYPE   Set workflow variable
echo   -credential=NAME;LOGIN;PW            Set credential
echo   -destFile=PATH.zip                   Save result as ZIP
echo   -destDir=PATH                        Save result to directory
echo   -masterkey=KEY                       Set encryption master key
echo   -failonloaderror                     Abort on load errors
echo   -updateLinks                         Update metanode links
echo   -reset                               Reset before execution
echo   -nosave                              Don't save after execution
echo.
echo ENVIRONMENT
echo   KNIME_HOME    Path to KNIME installation (auto-detected if unset)
echo   KNIME_PREFS   Path to Eclipse/KNIME preferences file
echo.
echo EXIT CODES
echo   0   Successful execution
echo   2   Parameters wrong or missing
echo   3   Error during workflow loading
echo   4   Error during execution
echo.
exit /b 0
