@echo off

rem Find root dir

rem if not defined CMDER_ROOT (
rem     for /f "delims=" %%i in ("%~dp0\..\..") do (
rem         set "cmder_root=%%~fi"
rem     )
rem )

rem if defined cmder_user_bin (
rem     set CMDER_VSCODE_INIT_ARGS=%cmder_user_bin%\vscode_init_args.cmd
rem ) else (
rem     set CMDER_VSCODE_INIT_ARGS=%CMDER_ROOT%\bin\vscode_init_args.cmd
rem )

rem if not exist "%CMDER_VSCODE_INIT_ARGS%" (
rem     echo Creating initial "%CMDER_VSCODE_INIT_ARGS%"...
rem     copy "%CMDER_ROOT%\vendor\bin\vscode_init_args.cmd.default" "%CMDER_VSCODE_INIT_ARGS%"
rem ) else (
rem     call "%CMDER_VSCODE_INIT_ARGS%"
rem )

IF [%1] == [] (
    REM -- manually opened console (Ctrl + Shift + `) --
    CALL "%~dp0..\init_fast.bat"
) ELSE (
    REM -- task --
    CALL cmd %*
    exit
)
