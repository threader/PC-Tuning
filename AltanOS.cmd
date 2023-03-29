set "usedir=%HOMEDRIVE%%HOMEPATH%\Desktop\AltanOS.inst"
mkdir %usedir%

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set nsarchbit=x64
)ELSE (set nsarchbit=Win32)

set "uacadmuser=%usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe -Priority:AboveNormal -M:S -U:S -P:E --wait"

if exist %usedir%\bin\Nsudo\%nsarchbit%\NSudoLG.exe goto skipnsudo
 %bitsadminget% https://github.com/M2Team/NSudo/releases/download/9.0-Preview1/NSudo_9.0_Preview1_9.0.2676.0.zip %usedir%\Nsudo.zip 
 %powshcmd% "Expand-Archive -Force '%usedir%\Nsudo.zip' '%usedir%\bin\Nsudo'"
:skipnsudo

%uacadmuser% %cd%\bootstrap-AltanOS.cmd