# Tiny Eden 한국어 패치 적용법

## 준비

1. 게임을 완전히 종료합니다.
2. Steam에서 Tiny Eden 설치 폴더를 엽니다.
   - Steam 라이브러리 → Tiny Eden → 관리 → 로컬 파일 탐색
   - 기본 예시: `F:\SteamLibrary\steamapps\common\Tiny Eden`
3. Steam 파일 무결성 검사를 실행해 지원 버전 `0.10.6+1642`의 깨끗한 원본 pak을
   준비합니다.
4. 최신 게임 실행 파일에서 확인한 AES 키를 준비합니다. AES 키는 저장소에 포함되지
   않습니다.

## 설치

PowerShell에서 저장소 폴더로 이동한 뒤 설치 스크립트를 실행합니다.

```powershell
$env:TINY_EDEN_AES_KEY = "본인이 확인한 AES 키"
.\scripts\Install-KoreanPatch.ps1 `
  -GamePath "F:\SteamLibrary\steamapps\common\Tiny Eden"
```

스크립트는 다음 작업을 자동으로 수행합니다.

1. 원본 pak의 크기와 SHA-256을 검사합니다.
2. `%LOCALAPPDATA%\TinyEdenKoreanPak\Backups\`에 원본 pak과 sig를 백업합니다.
3. repak 0.2.3이 없으면 공식 GitHub 릴리스에서 내려받습니다.
4. 정품 pak을 로컬 작업 폴더에 풀어 게임 내 `NotoSansKR`로 UI 폰트를 치환합니다.
5. 수정 pak을 로컬에서 생성하고 게임 폴더에 설치합니다.
6. 한국어 locres와 서명 우회 파일을 알맞은 위치에 복사합니다.

repak이 이미 있다면 자동 다운로드 대신 직접 지정할 수 있습니다.

```powershell
.\scripts\Install-KoreanPatch.ps1 `
  -GamePath "F:\SteamLibrary\steamapps\common\Tiny Eden" `
  -AesKey "본인이 확인한 AES 키" `
  -RepakPath "C:\Tools\repak.exe"
```

`CGH-Windows.sig`는 삭제하거나 교체하지 않고 게임의 원본 파일을 유지합니다.
게임을 실행한 뒤 설정의 Language에서 `한국어`를 선택합니다. Windows 표시 언어가
한국어라면 `System Default (Korean)`으로 적용될 수도 있습니다.

## 적용 확인

- 메인 메뉴와 대사가 한글로 표시되는지 확인합니다.
- 글자 자리가 비어 있다면 `CGH-Windows.pak` 및 Win64 폴더의 두 서명 우회 파일이
  모두 복사됐는지 확인합니다.
- 게임이 시작되지 않으면 먼저 아래 제거 절차로 복구한 뒤 지원 빌드를 확인합니다.

## 제거 및 복구

설치 스크립트가 만든 로컬 백업으로 복구합니다.

```powershell
.\scripts\Restore-Original.ps1 `
  -GamePath "F:\SteamLibrary\steamapps\common\Tiny Eden"
```

백업이 없거나 복구에 실패하면 Steam → Tiny Eden → 속성 → 설치된 파일 →
`게임 파일 무결성 검사`를 실행합니다.

## 게임 업데이트 후

업데이트가 `CGH-Windows.pak`을 교체하면 한글 폰트가 사라집니다. 같은 패치를 다시
실행해도 설치 스크립트가 지원 버전 불일치를 감지하고 중단합니다. 우선 이 저장소에서
새 빌드 대응 패치가 제공되는지 확인합니다. 직접 재구축하려면
[에이전트 재구축 규칙](.cursor/rules/tiny-eden-rebuild.mdc)을 따릅니다.

## 보안 프로그램 안내

`dsound.dll`과 `UniversalSigBypasser.asi`는 수정 pak의 서명 검사를 우회하기 위해 게임
프로세스에 로드됩니다. 이 동작 때문에 보안 프로그램이 경고할 수 있습니다.
출처와 해시를 확인한 뒤 사용하고, 원하지 않으면 패치를 설치하지 마세요.

`UniversalSigBypasser.asi`는 CC BY-NC 4.0 라이선스이며 상업적으로 이용할 수 없습니다.
게임 자산과 외부 도구의 권리·출처는 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)를
확인하세요.
