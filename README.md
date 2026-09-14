# Tiny Eden 한국어 패치 (비공식)

Tiny Eden의 UI와 게임 텍스트를 한국어로 표시하는 비공식 패치입니다.
기존 번역과 Azure Translator 기계번역을 바탕으로 일부 UI 문구를 교정했습니다.

- 대응 게임 버전: `0.10.6+1642`
- 번역 문자열: 3,679개
- 남아 있는 영문: 일부 설정 탭 등 별도 로컬라이제이션에 포함되지 않은 문자열

## 문서

- 설치·제거 방법: [INSTALL.md](INSTALL.md)
- 게임 업데이트 후 재구축 방법:
  [.cursor/rules/tiny-eden-rebuild.mdc](.cursor/rules/tiny-eden-rebuild.mdc)
- 배포 파일 무결성 값: [CHECKSUMS.sha256](CHECKSUMS.sha256)

## 배포 파일

- `CGH/Binaries/Win64/dsound.dll`
- `CGH/Binaries/Win64/UniversalSigBypasser.asi`
- `CGH/Content/Localization/Game/Game.locmeta`
- `CGH/Content/Localization/Game/ko/Game.locres`
- `CGH/Content/Paks/CGH-Windows.pak`

`CGH-Windows.pak`에는 게임에 원래 포함된 `NotoSansKR`를 UI 글꼴로 연결하기 위한
변경이 포함됩니다. 수정 pak을 로드하려면 함께 제공되는 ASI 로더와
UniversalSigBypasser가 필요합니다.

## 주의

- 게임 업데이트나 Steam 파일 무결성 검사 후에는 패치를 다시 적용해야 할 수 있습니다.
- 수정 pak과 서명 우회 도구는 해당 게임 빌드에 종속됩니다.
- 비공식 패치이며 사용에 따른 책임은 사용자에게 있습니다.
