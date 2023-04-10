%usedir%="%HOMEDRIVE%%HOMEPATH%\AltanOS"

%uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Bypass

powershell Start-process powershell -Verb RunAS %usedir%/update.ps1

%uacadmuser% %powshcmd% Set-ExecutionPolicy -ExecutionPolicy Restricted
