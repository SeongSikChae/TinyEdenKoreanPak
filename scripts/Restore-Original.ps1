[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GamePath
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ExpectedPakSha256 = "FE66509DD0229E041A43EFFCACD28709184BB9B7F92EAD620F6CA9A44DFA5965"
$GamePath = [IO.Path]::GetFullPath($GamePath)
$backupPath = Join-Path $env:LOCALAPPDATA "TinyEdenKoreanPak\Backups\$ExpectedPakSha256"
$backupPak = Join-Path $backupPath "CGH-Windows.pak"
$backupSig = Join-Path $backupPath "CGH-Windows.sig"

if (-not (Test-Path -LiteralPath $backupPak -PathType Leaf) -or
    -not (Test-Path -LiteralPath $backupSig -PathType Leaf)) {
    throw @"
로컬 원본 백업을 찾지 못했습니다: $backupPath
Steam → Tiny Eden → 속성 → 설치된 파일 → 게임 파일 무결성 검사를 실행하세요.
"@
}

$installedPak = Join-Path $GamePath "CGH\Content\Paks\CGH-Windows.pak"
$installedSig = Join-Path $GamePath "CGH\Content\Paks\CGH-Windows.sig"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $installedPak) | Out-Null

Copy-Item -LiteralPath $backupPak -Destination $installedPak -Force
Copy-Item -LiteralPath $backupSig -Destination $installedSig -Force

@(
    (Join-Path $GamePath "CGH\Binaries\Win64\dsound.dll"),
    (Join-Path $GamePath "CGH\Binaries\Win64\UniversalSigBypasser.asi"),
    (Join-Path $GamePath "CGH\Content\Localization\Game\Game.locmeta"),
    (Join-Path $GamePath "CGH\Content\Localization\Game\ko\Game.locres")
) | ForEach-Object {
    Remove-Item -LiteralPath $_ -Force -ErrorAction SilentlyContinue
}

$koDirectory = Join-Path $GamePath "CGH\Content\Localization\Game\ko"
if ((Test-Path -LiteralPath $koDirectory) -and
    -not (Get-ChildItem -LiteralPath $koDirectory -Force)) {
    Remove-Item -LiteralPath $koDirectory -Force
}

$restoredHash = (Get-FileHash -LiteralPath $installedPak -Algorithm SHA256).Hash
if ($restoredHash -ne $ExpectedPakSha256) {
    throw "복구된 pak의 SHA-256이 원본과 일치하지 않습니다: $restoredHash"
}

Write-Host "원본 게임 파일 복구 완료"
