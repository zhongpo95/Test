# 가장 최근 v177 플레이어의 진단과 리플레이를 원본 변경 없이 별도 압축파일에 보존한다.
param(
    [string]$LogDirectory = 'C:\Program Files (x86)\war3\logs',
    [string]$WarcraftDocuments = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Warcraft III'),
    [string]$OutputDirectory = (Join-Path $env:USERPROFILE 'Downloads\HeraIncident')
)
$ErrorActionPreference = 'Stop'
$latest = Get-ChildItem -LiteralPath $LogDirectory -File |
    Where-Object { $_.Name -match '^hera_rpg_desync_v177_MP_p\d+_part\d+\.txt$' } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $latest) { throw 'v177 실행 기록이 없습니다. 이전 판 로그를 대신 수집하지 않습니다.' }
if ($latest.Name -notmatch '_p(\d+)_part') { throw '플레이어 번호를 확인할 수 없습니다.' }
$slot = $Matches[1]
$bundle = Join-Path $OutputDirectory ('v177_p' + $slot + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
New-Item -ItemType Directory -Path $bundle | Out-Null
$logTarget = New-Item -ItemType Directory -Path (Join-Path $bundle 'logs')
$copied = Get-ChildItem -LiteralPath $LogDirectory -File | Where-Object {
    $_.Name -match ('^hera_rpg_.+_v(?:160|177_MP)_p' + $slot + '(?:_part\d+)?\.txt$')
}
foreach ($file in $copied) { Copy-Item -LiteralPath $file.FullName -Destination $logTarget.FullName }
$cutoff = $latest.LastWriteTime.AddMinutes(-2)
$replay = Join-Path $WarcraftDocuments 'Replay\LastReplay.w3g'
if ((Test-Path -LiteralPath $replay) -and (Get-Item -LiteralPath $replay).LastWriteTime -ge $cutoff) {
    Copy-Item -LiteralPath $replay -Destination $bundle
}
$errorRoot = Join-Path $WarcraftDocuments 'Errors'
if (Test-Path -LiteralPath $errorRoot) {
    $crash = Get-ChildItem -LiteralPath $errorRoot -Directory |
        Where-Object { $_.LastWriteTime -ge $cutoff } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($crash) { Copy-Item -LiteralPath $crash.FullName -Destination (Join-Path $bundle 'crash') -Recurse }
}
Get-ChildItem -LiteralPath $bundle -Recurse -File | ForEach-Object {
    [pscustomobject]@{File=$_.FullName.Substring($bundle.Length + 1); Bytes=$_.Length;
        Modified=$_.LastWriteTime.ToString('o'); SHA256=(Get-FileHash -LiteralPath $_.FullName).Hash}
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $bundle 'manifest.json') -Encoding utf8
Compress-Archive -LiteralPath $bundle -DestinationPath ($bundle + '.zip')
Write-Output ($bundle + '.zip')
