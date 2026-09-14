[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GamePath,

    [string]$AesKey = $env:TINY_EDEN_AES_KEY,

    [string]$RepakPath,

    [string]$WorkPath = (Join-Path $env:LOCALAPPDATA "TinyEdenKoreanPak\Work"),

    [switch]$KeepWork
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ExpectedGameVersion = "0.10.6+1642"
$ExpectedPakSha256 = "FE66509DD0229E041A43EFFCACD28709184BB9B7F92EAD620F6CA9A44DFA5965"
$ExpectedPakSize = 121098155
$RepakVersion = "0.2.3"
$RepakUrl = "https://github.com/trumank/repak/releases/download/v$RepakVersion/repak_cli-x86_64-pc-windows-msvc.zip"

$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$GamePath = [IO.Path]::GetFullPath($GamePath)
$PakPath = Join-Path $GamePath "CGH\Content\Paks\CGH-Windows.pak"
$SigPath = Join-Path $GamePath "CGH\Content\Paks\CGH-Windows.sig"
$GameExe = Join-Path $GamePath "CGH\Binaries\Win64\CGH-Win64-Shipping.exe"

function Assert-File {
    param([string]$Path, [string]$Description)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Description 파일을 찾을 수 없습니다: $Path"
    }
}

function ConvertTo-LongPath {
    param([string]$Path)
    $fullPath = [IO.Path]::GetFullPath($Path)
    if ($fullPath.StartsWith("\\")) {
        return "\\?\UNC\" + $fullPath.Substring(2)
    }
    return "\\?\" + $fullPath
}

function Remove-DirectoryRobust {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    try {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
    }
    catch {
        $longPath = ConvertTo-LongPath $Path
        & cmd.exe /d /c rd /s /q "`"$longPath`""
        if (Test-Path -LiteralPath $Path) {
            throw "작업 폴더를 정리하지 못했습니다: $Path"
        }
    }
}

function Get-Repak {
    if ($script:RepakPath) {
        Assert-File $script:RepakPath "repak"
        return [IO.Path]::GetFullPath($script:RepakPath)
    }

    $toolsPath = Join-Path $env:LOCALAPPDATA "TinyEdenKoreanPak\Tools\repak-$RepakVersion"
    $exePath = Join-Path $toolsPath "repak.exe"
    if (Test-Path -LiteralPath $exePath) {
        return $exePath
    }

    New-Item -ItemType Directory -Force -Path $toolsPath | Out-Null
    $zipPath = Join-Path $toolsPath "repak.zip"
    Write-Host "repak $RepakVersion 다운로드 중..."
    Invoke-WebRequest -Uri $RepakUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $toolsPath -Force
    Remove-Item -LiteralPath $zipPath -Force

    $downloaded = Get-ChildItem -LiteralPath $toolsPath -Recurse -Filter "repak.exe" |
        Select-Object -First 1
    if (-not $downloaded) {
        throw "다운로드한 압축 파일에서 repak.exe를 찾지 못했습니다."
    }
    if ($downloaded.FullName -ne $exePath) {
        Copy-Item -LiteralPath $downloaded.FullName -Destination $exePath -Force
    }
    return $exePath
}

Assert-File $GameExe "게임 실행"
Assert-File $PakPath "원본 pak"
Assert-File $SigPath "원본 sig"

if ([string]::IsNullOrWhiteSpace($AesKey)) {
    throw "AES 키가 필요합니다. -AesKey 매개변수 또는 TINY_EDEN_AES_KEY 환경변수를 설정하세요."
}

$pak = Get-Item -LiteralPath $PakPath
$pakHash = (Get-FileHash -LiteralPath $PakPath -Algorithm SHA256).Hash
if ($pak.Length -ne $ExpectedPakSize -or $pakHash -ne $ExpectedPakSha256) {
    throw @"
지원하는 깨끗한 원본 pak이 아닙니다.
지원 버전: $ExpectedGameVersion
예상 SHA-256: $ExpectedPakSha256
현재 SHA-256: $pakHash

이미 패치했거나 게임이 업데이트된 경우 Steam 파일 무결성 검사를 먼저 실행하세요.
게임이 업데이트됐다면 이 저장소의 재구축 규칙에 새 버전 정보를 반영해야 합니다.
"@
}

$repak = Get-Repak
$repakVersionOutput = (& $repak --version 2>&1 | Out-String).Trim()
if ($repakVersionOutput -notmatch [regex]::Escape($RepakVersion)) {
    Write-Warning "검증된 repak 버전($RepakVersion)과 다릅니다: $repakVersionOutput"
}

$buildPath = Join-Path $WorkPath $pakHash
$unpackPath = Join-Path $buildPath "unpacked"
$outputPak = Join-Path $buildPath "CGH-Windows.pak"
$backupPath = Join-Path $env:LOCALAPPDATA "TinyEdenKoreanPak\Backups\$pakHash"

Remove-DirectoryRobust $buildPath
New-Item -ItemType Directory -Force -Path $unpackPath, $backupPath | Out-Null

if (-not (Test-Path -LiteralPath (Join-Path $backupPath "CGH-Windows.pak"))) {
    Copy-Item -LiteralPath $PakPath -Destination (Join-Path $backupPath "CGH-Windows.pak")
    Copy-Item -LiteralPath $SigPath -Destination (Join-Path $backupPath "CGH-Windows.sig")
}

Write-Host "원본 pak 압축 해제 중..."
& $repak --aes-key $AesKey unpack -o $unpackPath $PakPath
if ($LASTEXITCODE -ne 0) {
    throw "repak 압축 해제에 실패했습니다. AES 키와 게임 버전을 확인하세요."
}

$koreanFont = Get-ChildItem -LiteralPath $unpackPath -Recurse -Filter "NotoSansKR-Regular.ufont" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*Foundation\Fonts\NotoSans*" } |
    Select-Object -First 1
$notoTargets = @(Get-ChildItem -LiteralPath $unpackPath -Recurse -Filter "NotoSansSC-*.ufont" `
    -ErrorAction SilentlyContinue)
$montserratTargets = @(Get-ChildItem -LiteralPath $unpackPath -Recurse `
    -Filter "MontserratAlternates-*.ufont" -ErrorAction SilentlyContinue)

if (-not $koreanFont) {
    throw "게임 pak에서 NotoSansKR-Regular.ufont를 찾지 못했습니다."
}
if ($notoTargets.Count -ne 9 -or $montserratTargets.Count -ne 18) {
    throw "예상한 폰트 파일 수와 다릅니다. NotoSansSC=$($notoTargets.Count), Montserrat=$($montserratTargets.Count)"
}

foreach ($target in ($notoTargets + $montserratTargets)) {
    [IO.File]::Copy(
        (ConvertTo-LongPath $koreanFont.FullName),
        (ConvertTo-LongPath $target.FullName),
        $true
    )
}

$pathHashSeed = [Convert]::ToUInt32("B3C6F6DB", 16)
Write-Host "한글 폰트 pak 생성 중..."
& $repak --aes-key $AesKey pack `
    --version V11 `
    --compression Oodle `
    --path-hash-seed $pathHashSeed `
    --mount-point "../../../" `
    $unpackPath `
    $outputPak
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPak)) {
    throw "한글 폰트 pak 생성에 실패했습니다."
}

$pakInfo = (& $repak --aes-key $AesKey info $outputPak 2>&1 | Out-String)
foreach ($expected in @(
    "mount point: ../../../",
    "version: V11",
    "compression: Oodle",
    "path hash seed: Some(B3C6F6DB)",
    "4722 file entries"
)) {
    if ($pakInfo -notmatch [regex]::Escape($expected)) {
        throw "생성된 pak 검증에 실패했습니다. 누락 정보: $expected"
    }
}

$patchFiles = @{
    (Join-Path $RepositoryRoot "CGH\Binaries\Win64\dsound.dll") =
        (Join-Path $GamePath "CGH\Binaries\Win64\dsound.dll")
    (Join-Path $RepositoryRoot "CGH\Binaries\Win64\UniversalSigBypasser.asi") =
        (Join-Path $GamePath "CGH\Binaries\Win64\UniversalSigBypasser.asi")
    (Join-Path $RepositoryRoot "CGH\Content\Localization\Game\Game.locmeta") =
        (Join-Path $GamePath "CGH\Content\Localization\Game\Game.locmeta")
    (Join-Path $RepositoryRoot "CGH\Content\Localization\Game\ko\Game.locres") =
        (Join-Path $GamePath "CGH\Content\Localization\Game\ko\Game.locres")
}

foreach ($source in $patchFiles.Keys) {
    Assert-File $source "패치"
    $destination = $patchFiles[$source]
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Force
}
Copy-Item -LiteralPath $outputPak -Destination $PakPath -Force

$installedHash = (Get-FileHash -LiteralPath $PakPath -Algorithm SHA256).Hash
Write-Host ""
Write-Host "Tiny Eden $ExpectedGameVersion 한국어 패치 설치 완료"
Write-Host "생성 pak SHA-256: $installedHash"
Write-Host "원본 백업: $backupPath"
Write-Host "게임 설정의 Language에서 한국어를 선택하세요."

if (-not $KeepWork) {
    Remove-DirectoryRobust $buildPath
}
