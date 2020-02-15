@echo off

set name=main

REM delete existing ROM, if it exists
if exist %name%.gb del %name%.gb

echo Compilation step 1/4: Assembling...

rgbasm -o%name%.o %name%.asm

if errorlevel 1 goto cleanup

echo Compilation step 2/4: Linking...
rgblink -o %name%.gb -m %name%.map -n %name%.sym %name%.o

if errorlevel 1 goto cleanup

echo Compilation step 3/4: Fixing...
rgbfix -v -p 0x00 %name%.gb

start bgb %name%.gb

:cleanup
echo Compilation step 4/4: Cleaning up...
del *.o
del *.map
rem del *.sym
rem You probably want to leave the .sym files for debugging purposes