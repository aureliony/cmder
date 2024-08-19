@echo off

setlocal EnableDelayedExpansion

for /f "tokens=1-4 delims=:., " %%a in ("%~1") do (
    set /a start_h=%%a, start_m=1%%b %% 100, start_s=1%%c %% 100, start_ms=1%%d %% 100
)
for /f "tokens=1-4 delims=:., " %%a in ("%~2") do (
    set /a end_h=%%a, end_m=1%%b %% 100, end_s=1%%c %% 100, end_ms=1%%d %% 100
)

:: Calculate differences
set /a ms=end_ms-start_ms, secs=end_s-start_s, mins=end_m-start_m, hours=end_h-start_h

:: Calculate total elapsed time in seconds
set /a totalsecs = hours*3600 + mins*60 + secs

:: Format milliseconds
if %ms% lss 10 set ms=0%ms%

:: Output result
echo %totalsecs%.%ms%s
