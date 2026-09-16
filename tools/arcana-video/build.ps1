# 설치된 JN 런타임을 참조하여 x86 영상 플러그인과 독립 시험 프로그램을 빌드한다.
param(
    [Parameter(Mandatory=$true)][string]$WarcraftDirectory,
    [Parameter(Mandatory=$true)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
$runtime = Join-Path $WarcraftDirectory 'JNService\Cirnix.JassNative.Runtime.dll'
$jass = Join-Path $WarcraftDirectory 'JNService\Plugins\Cirnix.JassNative.dll'
$easyHook = Join-Path $WarcraftDirectory 'EasyHook.dll'
foreach ($file in @($compiler,$runtime,$jass,$easyHook)) {
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required build file missing. $file" }
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$sharedSources = @((Join-Path $PSScriptRoot 'VideoPlayer.cs'),(Join-Path $PSScriptRoot 'OpenGlOverlay.cs'))
& $compiler /nologo /target:library /platform:x86 /optimize+ /warn:4 /warnaserror+ "/out:$OutputDirectory\Arcana.Video.dll" "/reference:$runtime" "/reference:$jass" "/reference:$easyHook" @sharedSources (Join-Path $PSScriptRoot 'Plugin.cs')
if ($LASTEXITCODE -ne 0) { throw 'Plugin compilation failed' }
& $compiler /nologo /target:exe /platform:x86 /optimize+ /warn:4 /warnaserror+ /define:VIDEO_SELF_TEST "/out:$OutputDirectory\VideoSelfTest.exe" "/reference:$easyHook" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll @sharedSources (Join-Path $PSScriptRoot 'VideoSelfTest.cs')
if ($LASTEXITCODE -ne 0) { throw 'Self-test compilation failed' }
foreach ($name in @('EasyHook.dll','EasyHook32.dll')) {
    Copy-Item -LiteralPath (Join-Path $WarcraftDirectory $name) -Destination (Join-Path $OutputDirectory $name) -Force
}
Get-FileHash -LiteralPath "$OutputDirectory\Arcana.Video.dll" -Algorithm SHA256
