@echo off
setlocal EnableDelayedExpansion

where xperf.exe
if not !errorlevel! == 0 (
    echo error: xperf not found in path
    pause
    exit /b 1
)

echo starting in 5s
timeout -t 5
xperf -on base+interrupt+dpc
echo recording for 5s
timeout -t 5
xperf -d "!userprofile!\Desktop\kernel.etl"
echo recording stopped
xperf -quiet -i "!userprofile!\Desktop\kernel.etl" -o "!userprofile!\Desktop\report.txt" -a dpcisr
pause
exit /b 0