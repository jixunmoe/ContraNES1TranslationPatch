@echo off
pushd %~dp0
if not exist out mkdir out
pushd src
for /R . %%i in (*) do (
	echo.
	echo Build %%~ni...
	python "%~dp0\p65-py3\p65.py" "%%~i" "%~dp0\out\%%~ni.bin"
)
popd