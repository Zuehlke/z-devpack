@echo off
cd %~dp0
call mount-drive.cmd
call set-env.bat
cd /D W:\
start "DevPack" 