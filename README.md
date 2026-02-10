# PiCK Admin

> 대덕소프트웨어마이스터고등학교 교사용 학생 관리 앱

학생의 외출/조기귀가 승인, 자습 감독, 교실 이동 관리 등을 처리하는 크로스플랫폼(iOS/Android) 관리자 앱입니다.

## Tech Stack

| 분류 | 기술 |
|------|------|
| Language | Swift 6.1 |
| Cross-Platform | [Skip](https://skip.tools) |
| UI | SwiftUI + SkipFuseUI |
| Architecture | MVVM (`@Observable` + async/await) |
| Networking | URLSession 기반 APIClient |
| Push | Firebase Cloud Messaging |
| Auth | JWT |

## Project Structure

```
Sources/PiCKAdmin/
├── Config/           # 환경 설정 및 시크릿 키
├── DesignSystem/     # 공통 UI 컴포넌트 (Button, TextField, Calendar 등)
├── Features/         # 기능별 모듈 (View + ViewModel)
├── Network/          # API 클라이언트, 엔드포인트, 모델
├── Router/           # NavigationStack 기반 라우팅
├── Storage/          # JWT 토큰 및 UserDefaults 관리
└── Resources/        # 리소스 파일
```

## Features

- **로그인/회원가입** - 시크릿키 + 이메일 인증 기반
- **외출/조기귀가 승인** - 학생 신청 승인/거절
- **외출자 목록 & 이력** - 현재 외출자 및 이력 조회
- **자습 감독** - 층별 감독 교사 확인 및 출석 체크
- **교실 이동 관리** - 학생 교실 이동 현황
- **급식 조회** - NEIS 연동
- **일정 관리** - 학교 일정 조회
- **버그 리포트** - 앱 내 버그 신고
