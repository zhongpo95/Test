# 공식 StormLib과 Python 코드를 묶어 Windows용 BLP 정리 실행 파일을 만든다.
param(
    [string]$PythonExe = 'python',
    [string]$OutputDir = (Join-Path $PSScriptRoot 'dist'),
    [string]$WorkDir = (Join-Path $PSScriptRoot 'build'),
    [string]$StormLibPath = ''
)
$ErrorActionPreference = 'Stop'
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
$WorkDir = [System.IO.Path]::GetFullPath($WorkDir)
New-Item -ItemType Directory -Force -Path $OutputDir, $WorkDir | Out-Null
if (-not $StormLibPath) {
    $archivePath = Join-Path $WorkDir 'stormlib_dll.zip'
    if (-not (Test-Path -LiteralPath $archivePath)) {
        Invoke-WebRequest 'https://github.com/ladislav-zezula/StormLib/releases/download/v9.40/stormlib_dll.zip' -OutFile $archivePath
    }
    $expected = 'B2C9635E7B63EDEE1BD7C82E7DC180D739F3ACCB2B8994804C7774E464CE89AE'
    if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $expected) {
        throw 'StormLib 배포 파일 체크섬이 다릅니다.'
    }
    $nativeDir = Join-Path $WorkDir 'stormlib'
    Expand-Archive -LiteralPath $archivePath -DestinationPath $nativeDir -Force
    $StormLibPath = Join-Path $nativeDir 'x64\StormLib.dll'
}
$StormLibPath = (Resolve-Path -LiteralPath $StormLibPath).Path
& $PythonExe -c 'import struct,sys; assert struct.calcsize("P") == 8 and sys.version_info >= (3,11), "64-bit Python 3.11+ required"'
if ($LASTEXITCODE -ne 0) { throw '64비트 Python 3.11 이상이 필요합니다.' }
$env:STORMLIB_PATH = $StormLibPath
$env:BLP_GUI_TESTS = '1'
& $PythonExe -B -m unittest discover -s $PSScriptRoot -v
if ($LASTEXITCODE -ne 0) { throw 'BLP 정리 검사가 실패했습니다.' }
& $PythonExe -m PyInstaller --noconfirm --clean --onefile --windowed --name ArcanaBLPCleaner `
    --distpath $OutputDir --workpath (Join-Path $WorkDir 'pyinstaller') --specpath $WorkDir `
    --add-binary "$StormLibPath;." --add-data "$(Join-Path $PSScriptRoot 'StormLib-LICENSE.txt');." `
    (Join-Path $PSScriptRoot 'app.py')
if ($LASTEXITCODE -ne 0) { throw '실행 파일 패키징이 실패했습니다.' }
$env:BLP_PACKAGED_EXE = Join-Path $OutputDir 'ArcanaBLPCleaner.exe'
& $PythonExe -B -m unittest discover -s $PSScriptRoot -p test_packaged.py -v
if ($LASTEXITCODE -ne 0) { throw '패키징된 실행 파일 검사가 실패했습니다.' }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'README.md') -Destination $OutputDir
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'StormLib-LICENSE.txt') -Destination $OutputDir
Get-FileHash -LiteralPath (Join-Path $OutputDir 'ArcanaBLPCleaner.exe') -Algorithm SHA256
