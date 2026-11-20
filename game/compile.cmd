@echo off
rem Full hardware build. Real Intel RAM/PLL/audio IP is used by the QSF.
cd /d "%~dp0"
set "QUARTUS=C:\intelFPGA\Quartus_Prime_Lite_23.1\quartus\bin64\quartus_sh.exe"
if not exist "%QUARTUS%" set "QUARTUS=C:\intelFPGA\Quartus_Prime_Standard_18.1\quartus\bin64\quartus_sh.exe"
if not exist "%QUARTUS%" (
  echo Quartus was not found at the installed course paths.
  exit /b 1
)
echo Compiling Echo Duel. Results are saved in compile.log and output_files.
"%QUARTUS%" --flow compile echo_duel_m1 > compile.log 2>&1
set "RESULT=%ERRORLEVEL%"
type compile.log
echo Quartus exit code: %RESULT%
exit /b %RESULT%
