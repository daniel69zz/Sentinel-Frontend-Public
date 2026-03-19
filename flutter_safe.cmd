@echo off
setlocal

set "FLUTTER_ROOT=C:\HACKAT~1\flutter"
set "PATH=%FLUTTER_ROOT%\bin;%PATH%"

call "%FLUTTER_ROOT%\bin\flutter.bat" %*
