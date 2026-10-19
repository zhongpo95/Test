# ASI 제작기의 x86 실행 로더와 단일 Windows EXE를 새 폴더에 빌드한다.
param(
    [Parameter(Mandatory=$true)][string]$PythonExe,
    [Parameter(Mandatory=$true)][string]$TccExe,
    [Parameter(Mandatory=$true)][string]$StormLibDll,
    [Parameter(Mandatory=$true)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
$taskBuildRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $taskBuildRoot) { throw '기존 빌드를 보존합니다. 새 출력 폴더를 지정해 주세요.' }
New-Item -ItemType Directory -Path $taskBuildRoot | Out-Null
$taskLoader = Join-Path $taskBuildRoot 'loader.dll'
$taskExports = Join-Path $taskBuildRoot 'loader.def'
"LIBRARY card-loader.dll`n`nEXPORTS`nArcanaCardPackStatus`n" | Set-Content -LiteralPath $taskExports -Encoding ascii
& $TccExe -shared (Join-Path $PSScriptRoot 'loader.c') $taskExports -lkernel32 -o $taskLoader
if ($LASTEXITCODE -ne 0) { throw 'x86 로더 컴파일 실패' }
& $PythonExe -m PyInstaller --noconfirm --onefile --windowed --name ArcanaASIPackager `
    --distpath (Join-Path $taskBuildRoot 'dist') --workpath (Join-Path $taskBuildRoot 'build') `
    --specpath $taskBuildRoot --add-binary ($taskLoader + ';.') `
    --add-binary ((Resolve-Path -LiteralPath $StormLibDll).Path + ';.') `
    (Join-Path $PSScriptRoot 'packager.py')
if ($LASTEXITCODE -ne 0) { throw 'Windows EXE 빌드 실패' }
Get-Item -LiteralPath (Join-Path $taskBuildRoot 'dist\ArcanaASIPackager.exe')
