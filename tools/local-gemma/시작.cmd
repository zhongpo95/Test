@rem 로컬 Gemma 번역과 사건 제작 화면을 시작한다.
@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0manage.ps1" -Action Start
if errorlevel 1 pause
