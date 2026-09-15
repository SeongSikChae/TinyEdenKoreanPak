# Tiny Eden 한국어 패치 (비공식)

Tiny Eden의 UI와 게임 텍스트를 한국어로 표시하는 비공식 패치입니다.
기존 번역과 Azure Translator 기계번역을 바탕으로 일부 UI 문구를 교정했습니다.

- 대응 게임 버전: `0.10.6+1642`
- 번역 문자열: 3,679개
- 최근 번역 검수: 2026-09-14, 영문 원문·공식 일본어 대조 후 659개 문구 교정
- 남아 있는 영문: 일부 설정 탭 등 별도 로컬라이제이션에 포함되지 않은 문자열

## 문서

- 설치·제거 방법: [INSTALL.md](INSTALL.md)
- 게임 업데이트 후 재구축 방법:
  [.cursor/rules/tiny-eden-rebuild.mdc](.cursor/rules/tiny-eden-rebuild.mdc)
- 배포 파일 무결성 값: [CHECKSUMS.sha256](CHECKSUMS.sha256)
- 라이선스 및 제3자 저작물: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## 배포 파일

- `CGH/Binaries/Win64/dsound.dll`
- `CGH/Binaries/Win64/UniversalSigBypasser.asi`
- `CGH/Content/Localization/Game/Game.locmeta`
- `CGH/Content/Localization/Game/ko/Game.locres`
- `scripts/Install-KoreanPatch.ps1`
- `scripts/Restore-Original.ps1`

저장소에는 원본 또는 수정된 `CGH-Windows.pak`을 포함하지 않습니다. 설치 스크립트가
사용자의 정품 게임 pak을 로컬 작업 폴더에 풀고, 게임에 원래 포함된 `NotoSansKR`를
UI 글꼴로 연결한 pak을 생성해 설치합니다. 생성된 pak은 Git에서 제외됩니다.

자세한 실행 방법은 [INSTALL.md](INSTALL.md)를 참고하세요.

## 번역 품질

배포 중인 한국어 locres는 3,679개 항목을 대상으로 빈 번역, 변수·마크업 토큰,
줄바꿈, 깨진 문자와 locres 왕복 변환을 검사했습니다. 현재 파일의 SHA-256은
`0606A87B5BC7CDCB826EC9D7E6CE9738026DBA925377F805CCD7559D85859C46`입니다.
전체 배포 파일의 값은 [CHECKSUMS.sha256](CHECKSUMS.sha256)에서 확인할 수 있습니다.

## 주의

- 게임 업데이트나 Steam 파일 무결성 검사 후에는 패치를 다시 적용해야 할 수 있습니다.
- 수정 pak과 서명 우회 도구는 해당 게임 빌드에 종속됩니다.
- 루트 MIT 라이선스는 게임 자산과 제3자 바이너리에 적용되지 않습니다.
- `UniversalSigBypasser.asi`는 CC BY-NC 4.0이므로 상업적으로 이용할 수 없습니다.
- 비공식 패치이며 사용에 따른 책임은 사용자에게 있습니다.
