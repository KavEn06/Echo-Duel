@echo off
rem Start the course ModelSim 18.1, rather than Questa 2023 from PATH.
cd /d "%~dp0"
set "SIMULATOR=C:\intelFPGA\Quartus_Prime_Standard_18.1\modelsim_ase\win32aloem\vsim.exe"
if not exist "%SIMULATOR%" (
  echo Course ModelSim 18.1 was not found. Open ModelSim and run: do testbench.do
  pause
  exit /b 1
)
start "" "%SIMULATOR%" -do results.do
