![eatssu_main](https://github.com/user-attachments/assets/ae21de9d-8333-46fb-b0ad-d8578f572fda)

# EAT-SSU: 숭실대 학식 리뷰 앱 
**EAT-SSU는 숭실대학교 학생들의 즐겁고 편리한 학식 이용을 꿈꾸는 프로젝트입니다.**
- `학생식당`, `도담식당`, `푸드코트`, `스낵코너`, `기숙사 식당`의 모든 메뉴를 비교할 수 있어요.
- 학식에 대한 리뷰를 통해 숭실대 학우들과 정보를 공유할 수 있어요.
- 식당의 운영시간과 위치를 확인할 수 있어요!
- [More & Contact](https://hi-jin-1514.notion.site/EAT-SSU-b04aaec9b7814a628c6ef6b3e08c74a3)

## 다운로드 
2023.11.27~ 서비스 중
- [App Store](https://apps.apple.com/kr/app/eat-ssu-%EC%88%AD%EC%8B%A4%EB%8C%80-%ED%95%99%EC%8B%9D-%EB%A6%AC%EB%B7%B0-%EC%95%B1/id6472618331)
- [Play Store](https://play.google.com/store/apps/details?id=com.eatssu.android)

## Tuist 개발환경

> 개발자 별 로컬에서 어떤 방법을 사용해서 `tuist`의 버전을 괸리하느냐에 따라서 호환성 통일을 위해서 확인해야 합니다.

⭐️ EATSSU iOS에서는 `tuist 4.24.0`을 사용하고 있습니다.

### Mise 사용 시

- [mise](https://github.com/jdx/mise)에서 설치합니다.
- 이 때 `Homebrew`로도 `mise`를 설치할 수 있는데, 정상동작하지 않기 때문에 꼭 위의 링크로 진행해야 합니다.
- 아래의 명령어를 진행해서 사용하면 됩니다.
- mise를 사용하면 프로젝트 별로 tuist 버전을 다르게 사용할 수 있어서, 이 방법을 채택하는 것을 권장합니다.
```zsh
tuist install
tuist generate
```

### Homebrew 사용 시

- [Tuist Quick Install Guide](https://docs.tuist.dev/en/guides/quick-start/install-tuist)를 참고해서 설치하면 됩니다.
- 아래의 명령어를 순차적으로 입력해 사용하면 됩니다.

```zsh
brew tap tuist/tuist
brew install --formula tuist@4.24.0
```

## Issue Title

``` zsh
[Commit Type] 이슈 제목
```

## Commit Type

> issue탭의 label과 동일

`Setting` 프로젝트 세팅, 라이브러리 설치

`Feat` 새로운 기능 구현 (new feature)

`Add` 파일 추가

`Fix` 버그 수정 (bug fix)

`Docs` 문서 작성, 수정 (documentation)

`Refactor` 코드 리팩토링 (refactoring)

`Test` 테스트 코드, 리팩토링 테스트 코드 추가

`Chore` 빌드 업무 수정, 패키지 매니저 수정, 파일 이동 및 이름 변경 등 (production code 변경이 없는 경우)

## Commit Message Conventions

``` zsh
[#이슈번호] 커밋메시지
### Description
- [#1] Project Setting
- [#2] Add AlermBar
```

## Branch Title Conventions

```zsh
Commit Type / issue number
```

## Code Convention**

### 1. 네이밍

- 함수, 메서드 : **lowerCamelCase** 사용하고, 동사로 시작한다.
- 변수, 상수 : **lowerCamelCase** 사용한다.
- 약어
  - 약어로 시작하는 경우: 소문자로 표기
  - 그 외의 경우에는 약어를 항상 대문자로 표기합니다
- 클래스, 구조체, enum, extension 등 : **UpperCamelCase** 사용한다.
  - enum의 각 case에는 **lowerCamelCase**를 사용

### 2. 띄어쓰기, 들여쓰기, 공백

- MARK 주석 위와 아래에는 공백 필수
- 콜론(`:`)을 쓸 때에는 콜론의 오른쪽에만 공백 두기 (단, 삼항 연산자의 경우 콜론 앞뒤로 띄우기)
- `if let`, `guard let` 구문이 긴 경우에는 줄바꿈하고 한 칸 들여쓰기
- 콤마(`,`) 뒤에 공백 추가
- 연산자 앞뒤로 공백을 추가합니다.
- 화살표(`->`) 양쪽에 가독성을 위해 빈 공백을 추가합니다.
- `@objc`, `블럭 단위` 사이에는 줄바꿈을 추가합니다.

### 3. 주석

- `///` 를 사용해서 문서화에 사용되는 주석 남기기
- `// MARK:` 를 사용해서 연관된 코드를 구분짓기
- 가능한 코드 안에서 문서화를 진행해서 생산성을 올릴 수 있도록 정리하기

## Folder Structure
```
iOS
 ┣ EATSSU_MVC
 ┃  ┣ EATSSU_MVC
 ┃  ┃  ┗ Sources
 ┃  ┃     ┣ Data
 ┃  ┃     ┃  ┣ Firebase
 ┃  ┃     ┃  ┣ LocalDB
 ┃  ┃     ┃  ┗ Network
 ┃  ┃     ┣ Notification
 ┃  ┃     ┣ Presentation
 ┃  ┃     ┃  ┣ Auth
 ┃  ┃     ┃  ┃  ┣ Enum
 ┃  ┃     ┃  ┃  ┣ View
 ┃  ┃     ┃  ┃  ┗ ViewController
 ┃  ┃     ┃  ┣ Home
 ┃  ┃     ┃  ┃  ┣ Enum
 ┃  ┃     ┃  ┃  ┣ Model
 ┃  ┃     ┃  ┃  ┣ Protocol
 ┃  ┃     ┃  ┃  ┣ View
 ┃  ┃     ┃  ┃  ┗ ViewController
 ┃  ┃     ┃  ┣ MyPage
 ┃  ┃     ┃  ┃  ┣ Enum
 ┃  ┃     ┃  ┃  ┣ Model
 ┃  ┃     ┃  ┃  ┣ View
 ┃  ┃     ┃  ┃  ┗ ViewController
 ┃  ┃     ┃  ┗ Review
 ┃  ┃     ┃     ┣ View
 ┃  ┃     ┃     ┗ ViewController
 ┃  ┃     ┗ Utility
 ┃  ┗ UnitTests
 ┣ EATSSU_MVVM
 ┃  ┗ EATSSU_MVVM
 ┃     ┗ Sources
 ┣ EATSSUComponents
 ┃  ┗ EATSSUComponents
 ┃     ┗ Sources
 ┃        ┗ Extension
 ┣ fastlane
 ┣ Tuist
 ┗ 기타 파일들
```
