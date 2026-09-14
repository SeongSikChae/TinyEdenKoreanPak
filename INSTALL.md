# Tiny Eden 한국어 패치 적용법

## 준비

1. 게임을 완전히 종료합니다.
2. Steam에서 Tiny Eden 설치 폴더를 엽니다.
   - Steam 라이브러리 → Tiny Eden → 관리 → 로컬 파일 탐색
   - 기본 예시: `F:\SteamLibrary\steamapps\common\Tiny Eden`
3. 세이브 파일과 설정은 건드리지 않지만, 필요하면 미리 백업합니다.

## 설치

이 저장소의 `CGH` 폴더를 게임 설치 폴더의 `CGH` 폴더 위에 덮어씁니다.
최종 파일 위치는 다음과 같아야 합니다.

- `Tiny Eden\CGH\Binaries\Win64\dsound.dll`
- `Tiny Eden\CGH\Binaries\Win64\UniversalSigBypasser.asi`
- `Tiny Eden\CGH\Content\Localization\Game\Game.locmeta`
- `Tiny Eden\CGH\Content\Localization\Game\ko\Game.locres`
- `Tiny Eden\CGH\Content\Paks\CGH-Windows.pak`

`CGH-Windows.sig`는 삭제하거나 교체하지 말고 게임에 설치된 파일을 그대로 둡니다.

PowerShell로 복사하려면 경로를 환경에 맞게 바꿔 실행합니다.

```powershell
$Game = "F:\SteamLibrary\steamapps\common\Tiny Eden"
$Patch = "D:\Git\Mods\Tiny Eden\TinyEdenKoreanPak"
Copy-Item "$Patch\CGH\*" "$Game\CGH\" -Recurse -Force
```

게임을 실행한 뒤 설정의 Language에서 `한국어`를 선택합니다. Windows 표시 언어가
한국어라면 `System Default (Korean)`으로 적용될 수도 있습니다.

## 적용 확인

- 메인 메뉴와 대사가 한글로 표시되는지 확인합니다.
- 글자 자리가 비어 있다면 `CGH-Windows.pak` 및 Win64 폴더의 두 서명 우회 파일이
  모두 복사됐는지 확인합니다.
- 게임이 시작되지 않으면 먼저 아래 제거 절차로 복구한 뒤 지원 빌드를 확인합니다.

## 제거 및 복구

1. 다음 파일을 삭제합니다.
   - `CGH\Binaries\Win64\dsound.dll`
   - `CGH\Binaries\Win64\UniversalSigBypasser.asi`
   - `CGH\Content\Localization\Game\Game.locmeta`
   - `CGH\Content\Localization\Game\ko\Game.locres`
2. Steam → Tiny Eden → 속성 → 설치된 파일 → `게임 파일 무결성 검사`를 실행합니다.

무결성 검사는 수정된 `CGH-Windows.pak`과 삭제한 원본 파일을 복구합니다.

## 게임 업데이트 후

업데이트가 `CGH-Windows.pak`을 교체하면 한글 폰트가 사라집니다. 같은 패치를 다시
복사해도 실행되거나 적용되지 않을 수 있으므로, 우선 이 저장소에서 새 빌드 대응
패치가 제공되는지 확인합니다. 직접 재구축하려면
[에이전트 재구축 규칙](.cursor/rules/tiny-eden-rebuild.mdc)을 따릅니다.

## 보안 프로그램 안내

`dsound.dll`과 `UniversalSigBypasser.asi`는 수정 pak의 서명 검사를 우회하기 위해 게임
프로세스에 로드됩니다. 이 동작 때문에 보안 프로그램이 경고할 수 있습니다.
출처와 해시를 확인한 뒤 사용하고, 원하지 않으면 패치를 설치하지 마세요.
