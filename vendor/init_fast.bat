@echo off

set CMDER_INIT_START=%time%

:: Init Script for cmd.exe shell
:: Created as part of cmder project

set time_init=0

:: Remove trailing '\' from %CMDER_ROOT%
if "%CMDER_ROOT:~-1%" == "\" SET "CMDER_ROOT=%CMDER_ROOT:~0,-1%"

:var_loop
    if "%~1" == "" (
        goto :start
    ) else if /i "%1" == "/t" (
        set time_init=1
    )
    shift
goto var_loop

:start

:: Set the Cmder directory paths
set CMDER_CONFIG_DIR=%CMDER_ROOT%\config

:: Pick the right version of Clink
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set clink_architecture=x86
) else if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set clink_architecture=x64
)

goto :INJECT_CLINK

:INJECT_CLINK
    :: Run Clink
    if not exist "%CMDER_CONFIG_DIR%\settings" if not exist "%CMDER_CONFIG_DIR%\clink_settings" (
        echo Generating Clink initial settings in "%CMDER_CONFIG_DIR%\clink_settings"
        copy "%CMDER_ROOT%\vendor\clink_settings.default" "%CMDER_CONFIG_DIR%\clink_settings"
        echo Additional *.lua files in "%CMDER_CONFIG_DIR%" are loaded on startup.
    )

    if not exist "%CMDER_CONFIG_DIR%\cmder_prompt_config.lua" (
        echo Creating Cmder prompt config file: "%CMDER_CONFIG_DIR%\cmder_prompt_config.lua"
        copy "%CMDER_ROOT%\vendor\cmder_prompt_config.lua.default" "%CMDER_CONFIG_DIR%\cmder_prompt_config.lua"
    )

    :: Cleanup legacy Clink Settings file
    if exist "%CMDER_CONFIG_DIR%\settings" if exist "%CMDER_CONFIG_DIR%\clink_settings" (
        del "%CMDER_CONFIG_DIR%\settings"
    )

    :: Cleanup legacy Clink history file
    if exist "%CMDER_CONFIG_DIR%\.history" if exist "%CMDER_CONFIG_DIR%\clink_history" (
        del "%CMDER_CONFIG_DIR%\.history"
    )

    "%CMDER_ROOT%\vendor\clink\clink_%clink_architecture%.exe" inject --quiet --profile "%CMDER_CONFIG_DIR%" --scripts "%CMDER_ROOT%\vendor"

    goto :CLINK_FINISH

:SKIP_CLINK
    for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
    chcp 65001>nul

    :: Revert back to plain cmd.exe prompt without clink
    prompt $E[1;32;49m$P$S$_$E[1;30;49mλ$S$E[0m

    chcp %cp%>nul

:CLINK_FINISH

set CMDER_INIT_END=%time%

if %time_init% gtr 0 (
    "%cmder_root%\vendor\bin\timer.cmd" "%CMDER_INIT_START%" "%CMDER_INIT_END%"
)
exit /b
