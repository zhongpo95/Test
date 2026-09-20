# 빌드한 영상 플러그인과 테스트 맵만 지정된 JN 및 맵 폴더에 설치하고 해시를 대조한다.
param(
    [Parameter(Mandatory=$true)][string]$WarcraftDirectory,
    [Parameter(Mandatory=$true)][string]$PackageDirectory,
    [Parameter(Mandatory=$true)][string]$TestMap,
    [Parameter(Mandatory=$true)][string]$MapsDirectory,
    [Parameter(Mandatory=$true)][string]$ReportPath
)
$ErrorActionPreference = 'Stop'
if (!(Test-Path -LiteralPath (Join-Path $WarcraftDirectory 'JNLoader.exe'))) { throw 'JNLoader.exe was not found' }
$pluginDirectory = Join-Path $WarcraftDirectory 'JNService\Plugins'
if (!(Test-Path -LiteralPath $pluginDirectory -PathType Container)) { throw 'JN plugin directory was not found' }
$entries = @(
    @{ Source = (Join-Path $PackageDirectory 'Arcana.Video.dll'); Target = (Join-Path $pluginDirectory 'Arcana.Video.dll') },
    @{ Source = (Join-Path $PackageDirectory 'ArcanaVideo\ffmpeg.exe'); Target = (Join-Path $pluginDirectory 'ArcanaVideo\ffmpeg.exe') },
    @{ Source = (Join-Path $PackageDirectory 'ArcanaVideo\LICENSE'); Target = (Join-Path $pluginDirectory 'ArcanaVideo\LICENSE') },
    @{ Source = (Join-Path $PackageDirectory 'ArcanaVideo\README.txt'); Target = (Join-Path $pluginDirectory 'ArcanaVideo\README.txt') },
    @{ Source = $TestMap; Target = (Join-Path $MapsDirectory '0.15_OPENGL_VIDEO_TEST.w3x') }
)
foreach ($entry in $entries) {
    if (!(Test-Path -LiteralPath $entry.Source -PathType Leaf)) { throw "Package file missing. $($entry.Source)" }
}
$report = @()
foreach ($entry in $entries) {
    $sourceHash = (Get-FileHash -LiteralPath $entry.Source -Algorithm SHA256).Hash
    $backup = $null
    if (Test-Path -LiteralPath $entry.Target) {
        $oldHash = (Get-FileHash -LiteralPath $entry.Target -Algorithm SHA256).Hash
        if ($oldHash -ne $sourceHash) {
            $backup = $entry.Target + '.' + [DateTime]::Now.ToString('yyyyMMdd-HHmmss-fff') + '.bak'
            Copy-Item -LiteralPath $entry.Target -Destination $backup
        }
    }
    New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($entry.Target)) | Out-Null
    Copy-Item -LiteralPath $entry.Source -Destination $entry.Target -Force
    $targetHash = (Get-FileHash -LiteralPath $entry.Target -Algorithm SHA256).Hash
    if ($sourceHash -ne $targetHash) { throw "Installed file differs. $($entry.Target)" }
    $report += [pscustomobject]@{ Path = $entry.Target; SHA256 = $targetHash; Backup = $backup }
}
$report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding utf8
$report
