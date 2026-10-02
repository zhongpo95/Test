@rem 이 도구가 시작한 로컬 Gemma 서버만 종료한다.
@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0manage.ps1" -Action Stop
if errorlevel 1 pause
