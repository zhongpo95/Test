# 로컬 Gemma의 공식 실행 파일 설치와 전용 서버 시작 및 종료를 관리한다.
param(
    [ValidateSet('Install', 'Start', 'Stop')][string]$Action = 'Start',
    [switch]$NoBrowser
)
$ErrorActionPreference = 'Stop'
$gemmaRoot = Join-Path $env:LOCALAPPDATA 'ArcanaGemma'
$gemmaVersion = 'v0.35.0'
$gemmaExe = Join-Path $gemmaRoot "ollama\$gemmaVersion\ollama.exe"
$gemmaModel = 'gemma4:12b-it-qat'
$gemmaStateFile = Join-Path $gemmaRoot 'processes.json'
$gemmaEndpoint = 'http://127.0.0.1:11435'
$gemmaPage = 'http://127.0.0.1:18765'
New-Item -ItemType Directory -Path $gemmaRoot -Force | Out-Null

function Get-OwnedProcess($record) {
    if ($null -eq $record) { return $null }
    $process = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
    if ($process -and $process.Path -eq $record.path -and $process.StartTime.ToUniversalTime().Ticks.ToString() -eq $record.startTicks) { return $process }
    return $null
}

function Save-Process($process, [string]$executable) {
    $process.Refresh()
    return @{ pid = $process.Id; path = $executable; startTicks = $process.StartTime.ToUniversalTime().Ticks.ToString() }
}

$gemmaState = if (Test-Path -LiteralPath $gemmaStateFile) { Get-Content -LiteralPath $gemmaStateFile -Raw | ConvertFrom-Json } else { $null }
if ($Action -eq 'Stop') {
    foreach ($record in @($gemmaState.ui, $gemmaState.ollama)) {
        $process = Get-OwnedProcess $record
        if ($process) {
            # Ollama의 추론 자식 프로세스까지 종료해 GPU 메모리 잔류를 막는다.
            & (Join-Path $env:WINDIR 'System32\taskkill.exe') /PID $process.Id /T /F | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "전용 프로세스 $($process.Id) 종료에 실패했습니다." }
        }
    }
    Write-Output 'Gemma 전용 서버를 종료했습니다.'
    exit 0
}

if ($Action -eq 'Install' -and !(Test-Path -LiteralPath $gemmaExe)) {
    $gemmaDownload = Join-Path $gemmaRoot 'downloads'
    New-Item -ItemType Directory -Path $gemmaDownload -Force | Out-Null
    $gemmaZip = Join-Path $gemmaDownload "ollama-$gemmaVersion-windows-amd64.zip"
    Write-Output 'Ollama 공식 실행 파일을 다운로드합니다. 약 1.46GB.'
    & curl.exe --fail --location --silent --show-error --retry 3 --continue-at - --output $gemmaZip "https://github.com/ollama/ollama/releases/download/$gemmaVersion/ollama-windows-amd64.zip"
    if ($LASTEXITCODE -ne 0) { throw 'Ollama 다운로드 실패. 설치를 다시 실행하면 이어받습니다.' }
    $gemmaExpected = 'd6f7d3dd4f5d013553a78c1e78b2521fcf41d43dd2863e4596cdc046fe6036db'
    if ((Get-FileHash -LiteralPath $gemmaZip -Algorithm SHA256).Hash -ne $gemmaExpected) { throw '공식 SHA-256 불일치. 다운로드 파일을 확인해 주세요.' }
    $gemmaBin = Split-Path -Parent $gemmaExe
    New-Item -ItemType Directory -Path $gemmaBin -Force | Out-Null
    Expand-Archive -LiteralPath $gemmaZip -DestinationPath $gemmaBin -Force
}
if (!(Test-Path -LiteralPath $gemmaExe)) { throw '먼저 설치.cmd를 실행해 주세요.' }

$gemmaOllama = Get-OwnedProcess $gemmaState.ollama
if (!$gemmaOllama) {
    $listener = New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback, 11435)
    try { $listener.Start() } catch { throw '11435 포트를 다른 프로그램이 사용 중입니다.' } finally { $listener.Stop() }
    # 환경 변수는 이 스크립트와 자식 프로세스에만 적용한다.
    $env:OLLAMA_HOST = '127.0.0.1:11435'
    $env:OLLAMA_MODELS = Join-Path $gemmaRoot 'models'
    $env:OLLAMA_NO_CLOUD = '1'
    $env:OLLAMA_NUM_PARALLEL = '1'
    $env:OLLAMA_MAX_LOADED_MODELS = '1'
    $env:OLLAMA_CONTEXT_LENGTH = '8192'
    $gemmaOllama = Start-Process -FilePath $gemmaExe -ArgumentList 'serve' -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $gemmaRoot 'ollama.out.log') -RedirectStandardError (Join-Path $gemmaRoot 'ollama.err.log')
    @{ollama = (Save-Process $gemmaOllama $gemmaExe); ui = $gemmaState.ui} | ConvertTo-Json | Set-Content -LiteralPath $gemmaStateFile -Encoding UTF8
    $gemmaState = Get-Content -LiteralPath $gemmaStateFile -Raw | ConvertFrom-Json
}
$gemmaReady = $false
for ($attempt = 0; $attempt -lt 30; $attempt++) {
    try { $null = Invoke-RestMethod "$gemmaEndpoint/api/version" -TimeoutSec 2; $gemmaReady = $true; break } catch { Start-Sleep -Milliseconds 500 }
}
if (!$gemmaReady) { throw "모델 서버 시작 실패. $gemmaRoot\ollama.err.log를 확인해 주세요." }

if ($Action -eq 'Install') {
    $env:OLLAMA_HOST = '127.0.0.1:11435'
    Write-Output 'Gemma 4 12B QAT 모델을 다운로드합니다. 약 7.2GB.'
    & $gemmaExe pull $gemmaModel
    if ($LASTEXITCODE -ne 0) { throw '모델 다운로드 실패. 설치를 다시 실행해 주세요.' }
    Write-Output '설치 완료. 시작.cmd로 번역과 사건 제작 화면을 엽니다.'
    exit 0
}

$gemmaModels = Invoke-RestMethod "$gemmaEndpoint/api/tags" -TimeoutSec 5
if ($gemmaModels.models.name -notcontains $gemmaModel) { throw 'Gemma 모델이 없습니다. 설치.cmd를 실행해 주세요.' }
$gemmaUi = Get-OwnedProcess $gemmaState.ui
if (!$gemmaUi) {
    $listener = New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback, 18765)
    try { $listener.Start() } catch { throw '18765 포트를 다른 프로그램이 사용 중입니다.' } finally { $listener.Stop() }
    $nodeCommand = Get-Command node.exe -ErrorAction SilentlyContinue
    $gemmaNode = if ($nodeCommand) { $nodeCommand.Source } else { Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe' }
    if (!(Test-Path -LiteralPath $gemmaNode)) { throw 'Node.js 22 이상을 설치해 주세요.' }
    $gemmaNodeVersion = & $gemmaNode --version
    if ($gemmaNodeVersion -notmatch '^v(\d+)\.' -or [int]$Matches[1] -lt 22) { throw 'Node.js 22 이상이 필요합니다.' }
    $gemmaScript = Join-Path $PSScriptRoot 'server.cjs'
    $gemmaUi = Start-Process -FilePath $gemmaNode -ArgumentList ('"' + $gemmaScript + '"') -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $gemmaRoot 'ui.out.log') -RedirectStandardError (Join-Path $gemmaRoot 'ui.err.log')
    @{ollama = (Save-Process $gemmaOllama $gemmaExe); ui = (Save-Process $gemmaUi $gemmaNode)} | ConvertTo-Json | Set-Content -LiteralPath $gemmaStateFile -Encoding UTF8
}
$gemmaUiReady = $false
for ($attempt = 0; $attempt -lt 20; $attempt++) {
    $gemmaUi.Refresh()
    if ($gemmaUi.HasExited) { throw "화면 서버가 종료됐습니다. $gemmaRoot\ui.err.log를 확인해 주세요." }
    try { $reply = Invoke-WebRequest $gemmaPage -UseBasicParsing -TimeoutSec 2; if ($reply.Content -notmatch 'Arcana ·') { throw '화면 확인 실패.' }; $gemmaUiReady = $true; break } catch { Start-Sleep -Milliseconds 250 }
}
if (!$gemmaUiReady) { throw "화면 서버 시작 실패. $gemmaRoot\ui.err.log를 확인해 주세요." }
if (!$NoBrowser) { Start-Process $gemmaPage -WindowStyle Hidden }
Write-Output "실행 완료. $gemmaPage"
