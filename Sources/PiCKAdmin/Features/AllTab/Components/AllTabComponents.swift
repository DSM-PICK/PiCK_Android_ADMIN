import SwiftUI

struct TeacherInfoView: View {
    let teacherName: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image("profile", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.leading, 24)
                .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("대덕소프트웨어마이스터고등학교")
                    .pickText(type: .label1, textColor: .Normal.black)
                
                Text("\(teacherName) 선생님")
                    .pickText(type: .label1, textColor: .Normal.black)
            }
            .padding(.leading, 24)
            .padding(.top, 12)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 84)
        .background(Color.white)
    }
}

struct AllTabMenuList: View {
    let onOutListTap: () -> Void
    let onClassroomMoveListTap: () -> Void
    let onLogoutTap: () -> Void
    let onCheckTeacherTap: () -> Void
    let onBugReportTap: () -> Void
    let onChangePasswordTap: () -> Void
    let onSelfStudyCheckTap: () -> Void
    let onOutingHistoryTap: () -> Void
    let onResignTap: () -> Void

    var body: some View {
        MenuListView(
            sections: [
                MenuSectionModel(title: "출결 확인", items: [
                    MenuItemModel(
                        iconName: "location",
                        title: "외출자 목록",
                        action: onOutListTap
                    ),
                    MenuItemModel(
                        iconName: "beforeOuting",
                        title: "자습시간 출결",
                        action: onSelfStudyCheckTap
                    ),
                    MenuItemModel(
                        iconName: "moveClass",
                        title: "교실 이동 현황",
                        action: onClassroomMoveListTap
                    ),
                    MenuItemModel(
                        iconName: "book",
                        title: "이전 외출기록",
                        action: onOutingHistoryTap
                    )
                ]),
                MenuSectionModel(title: "도움말", items: [
                    MenuItemModel(
                        iconName: "smile",
                        title: "자습 감독 선생님 확인",
                        action: onCheckTeacherTap
                    ),
                    MenuItemModel(
                        iconName: "bug",
                        title: "버그 제보",
                        action: onBugReportTap
                    )
                ]),
                MenuSectionModel(title: "계정", items: [
                    MenuItemModel(
                        iconName: "changePassword",
                        title: "비밀번호 변경",
                        action: onChangePasswordTap
                    ),
                    MenuItemModel(
                        iconName: "logout",
                        title: "로그아웃",
                        iconColor: .Error.error,
                        action: onLogoutTap
                    ),
                    MenuItemModel(
                        iconName: "withDraw",
                        title: "회원탈퇴",
                        iconColor: .Error.error,
                        action: onResignTap
                    )
                ])
            ]
        )
    }
}

struct MenuListView: View {
    let sections: [MenuSectionModel]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(sections) { section in
                MenuSectionView(section: section)
            }
        }
        .padding(.leading, 24)
    }
}

struct MenuSectionView: View {
    let section: MenuSectionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(section.title)
                .pickText(type: .label1)
                .foregroundColor(.Gray.gray400)
                .padding(.top, 32)
                .padding(.bottom, 16)

            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    MenuItemCell(item: item)
                }
            }
        }
    }
}

struct MenuItemCell: View {
    let item: MenuItemModel
    
    var body: some View {
        Button(action: {
            item.action?()
        }) {
            HStack(spacing: 20) {
                Image(item.iconName, bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(item.iconColor)
                
                Text(item.title)
                    .pickText(type: .label1, textColor: .Normal.black)
                
                Spacer()
            }
            .padding(.vertical, 20)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
