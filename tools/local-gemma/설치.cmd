@rem 로컬 Gemma 실행 파일과 모델을 설치한다.
@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0manage.ps1" -Action Install
pause
