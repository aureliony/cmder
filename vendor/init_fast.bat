@echo off

set CMDER_INIT_START=%time%

:: Init Script for cmd.exe shell
:: Created as part of cmder project

:: !!! THIS FILE IS OVERWRITTEN WHEN CMDER IS UPDATED
:: !!! Use "%CMDER_ROOT%\config\user_profile.cmd" to add your own startup commands

:: Use /v command line arg or set to > 0 for verbose output to aid in debugging.
if not defined verbose_output set verbose_output=0

:: Use /d command line arg or set to 1 for debug output to aid in debugging.
if not defined debug_output set debug_output=0

:: Use /t command line arg or set to 1 to display init time.
if not defined time_init set time_init=0

:: Use /f command line arg to speed up init at the expense of some functionality.
if not defined fast_init set fast_init=0

:: Use /max_depth 1-5 to set max recurse depth for calls to `enhance_path_recursive`
if not defined max_depth set max_depth=1

:: Add *nix tools to end of path. 0 turns off *nix tools, 2 adds *nix tools to the front of the path.
if not defined nix_tools set nix_tools=1

:: Remove trailing '\' from %CMDER_ROOT%
if "%CMDER_ROOT:~-1%" == "\" SET "CMDER_ROOT=%CMDER_ROOT:~0,-1%"

:: Include Cmder libraries
call "%cmder_root%\vendor\bin\cexec.cmd" /setpath
call "%cmder_root%\vendor\lib\lib_console"
call "%cmder_root%\vendor\lib\lib_base"
call "%cmder_root%\vendor\lib\lib_path"
call "%cmder_root%\vendor\lib\lib_git"
call "%cmder_root%\vendor\lib\lib_profile"

set "CMDER_USER_FLAGS= "

:var_loop
    if "%~1" == "" (
        goto :start
    ) else if /i "%1" == "/f" (
        set fast_init=1
    ) else if /i "%1" == "/t" (
        set time_init=1
    ) else if /i "%1" == "/v" (
        set verbose_output=1
    ) else if /i "%1" == "/d" (
        set debug_output=1
    ) else if /i "%1" == "/max_depth" (
        if "%~2" geq "1" if "%~2" leq "5" (
            set "max_depth=%~2"
            shift
        ) else (
            %print_error% "'/max_depth' requires a number between 1 and 5!"
            exit /b
        )
    ) else if /i "%1" == "/c" (
        if exist "%~2" (
            if not exist "%~2\bin" mkdir "%~2\bin"
            set "cmder_user_bin=%~2\bin"
            if not exist "%~2\config\profile.d" mkdir "%~2\config\profile.d"
            set "cmder_user_config=%~2\config"
            shift
        )
    ) else if /i "%1" == "/user_aliases" (
        if exist "%~2" (
            set "user_aliases=%~2"
            shift
        )
    ) else if /i "%1" == "/git_install_root" (
        if exist "%~2" (
            set "GIT_INSTALL_ROOT=%~2"
            shift
        ) else (
            %print_error% "The Git install root folder "%~2" that you specified does not exist!"
            exit /b
        )
    ) else if /i "%1" == "/nix_tools" (
        if "%2" equ "0" (
            REM Do not add *nix tools to path
            set nix_tools=0
            shift
        ) else if "%2" equ "1" (
            REM Add *nix tools to end of path
            set nix_tools=1
            shift
        ) else if "%2" equ "2" (
            REM Add *nix tools to front of path
            set nix_tools=2
            shift
        )
    ) else if /i "%1" == "/home" (
        if exist "%~2" (
            set "HOME=%~2"
            shift
        ) else (
            %print_error% The home folder "%2" that you specified does not exist!
            exit /b
        )
    ) else if /i "%1" == "/svn_ssh" (
        set SVN_SSH=%2
        shift
    ) else (
        set "CMDER_USER_FLAGS=%1 %CMDER_USER_FLAGS%"
    )
    shift
goto :var_loop

:start
:: Enable console related methods if verbose/debug is turned on
if %debug_output% gtr 0 (set print_debug=%lib_console% debug_output)
if %verbose_output% gtr 0 (
    set print_verbose=%lib_console% verbose_output
    set print_warning=%lib_console% show_warning
)

:: Sets CMDER_SHELL, CMDER_CLINK, CMDER_ALIASES variables
%lib_base% cmder_shell
%print_debug% init.bat "Env Var - CMDER_ROOT=%CMDER_ROOT%"
%print_debug% init.bat "Env Var - debug_output=%debug_output%"

:: Set the Cmder directory paths
set CMDER_CONFIG_DIR=%CMDER_ROOT%\config

:: Check if we're using Cmder individual user profile
if defined CMDER_USER_CONFIG (
    %print_debug% init.bat "CMDER IS ALSO USING INDIVIDUAL USER CONFIG FROM '%CMDER_USER_CONFIG%'!"

    if not exist "%CMDER_USER_CONFIG%\..\opt" md "%CMDER_USER_CONFIG%\..\opt"
    set CMDER_CONFIG_DIR=%CMDER_USER_CONFIG%
)

:: Pick the right version of Clink
set clink_architecture=x64
set architecture_bits=64

goto :INJECT_CLINK

:INJECT_CLINK
    %print_verbose% "Injecting Clink!"

    :: Check if Clink is not present
    if not exist "%CMDER_ROOT%\vendor\clink\clink_%clink_architecture%.exe" (
        %print_error% "Clink executable is not present in 'vendor\clink\clink_%clink_architecture%.exe'"
        goto :SKIP_CLINK
    )

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

    :: Check if a fatal error occurred when trying to inject Clink
    if errorlevel 2 (
        REM %print_error% "Clink injection has failed with error code: %errorlevel%"
        goto :SKIP_CLINK
    )

    goto :CLINK_FINISH

:SKIP_CLINK
    %print_warning% "Skipping Clink Injection!"

    for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
    chcp 65001>nul

    :: Revert back to plain cmd.exe prompt without clink
    prompt $E[1;32;49m$P$S$_$E[1;30;49mλ$S$E[0m

    chcp %cp%>nul

:CLINK_FINISH

:: Prepare for git-for-windows

:: Detect which git.exe version to use
:: * if the user points to a specific git, use that
:: * test if git is in path and if yes, use that
:: * last, use our vendored git
:: also check that we have a recent enough version of git by examining the version string
if defined GIT_INSTALL_ROOT if exist "%GIT_INSTALL_ROOT%\cmd\git.exe" (
    rem do nothing
) else if "%fast_init%" == "1" (
    %print_debug% init.bat "Fast init is enabled, vendored Git does not exist"
    for /F "delims=" %%F in ('where git.exe 2^>nul') do (
	set "EXT_GIT_EXE=%%~fF"
        %print_debug% init.bat "Found User installed Git at '%%~fF'. Skipping Git Auto-Detect!"
    )
)

rem :PATH_ENHANCE :: 0.04s
rem %lib_path% enhance_path "%CMDER_ROOT%\vendor\bin"

:: Drop *.bat and *.cmd files into "%CMDER_ROOT%\config\profile.d"
:: to run them at startup.
:: "usebackq" is very slow
rem %lib_profile% run_profile_d "%CMDER_ROOT%\config\profile.d"
rem if defined CMDER_USER_CONFIG (
rem     %lib_profile% run_profile_d "%CMDER_USER_CONFIG%\profile.d"
rem )

:USER_ALIASES
:: Allows user to override default aliases store using profile.d
:: scripts run above by setting the 'aliases' env variable.
::
:: Note: If overriding default aliases store file the aliases
:: must also be self executing, see '.\user_aliases.cmd.default',
:: and be in profile.d folder.
if not defined user_aliases (
    set "user_aliases=%CMDER_CONFIG_DIR%\user_aliases.cmd"
)

:: Add aliases to the environment
type "%user_aliases%" | findstr /b /l /i "history=cat " >nul
if "%ERRORLEVEL%" == "0" (
    echo Migrating alias 'history' to new Clink 1.x.x...
    call "%CMDER_ROOT%\vendor\bin\alias.cmd" /d history
    echo Restart the session to activate changes!
)

call "%user_aliases%"

:: Set home path
if not defined HOME set "HOME=%USERPROFILE%"
%print_debug% init.bat "Env Var - HOME=%HOME%"

set "initialConfig=%CMDER_ROOT%\config\user_profile.cmd"
if exist "%initialConfig%" (
    REM Create this file and place your own command in there
    %print_debug% init.bat "Calling - %initialConfig%"
    call "%initialConfig%"
) else (
    echo Creating user startup file: "%initialConfig%"
    copy "%CMDER_ROOT%\vendor\user_profile.cmd.default" "%initialConfig%"
)

set initialConfig=

set CMDER_INIT_END=%time%

if %time_init% gtr 0 (
    "%cmder_root%\vendor\bin\timer.cmd" "%CMDER_INIT_START%" "%CMDER_INIT_END%"
)
exit /b
