import SwiftUI

struct InfoSettingView: View {
    let secretKey: String
    let accountId: String
    let code: String
    let password: String
    @State private var viewModel = InfoSettingViewModel()
    @Environment(\.appRouter) var router: AppRouter

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                headerSection

                teacherCheckSection
                    .padding(.top, 48)
                    .padding(.leading, 24)

                if viewModel.isTeacher {
                    gradeClassSelectSection
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                }

                PiCKTextField(
                    text: $viewModel.name,
                    placeholder: "이름을 입력해주세요",
                    titleText: "이름"
                )
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Spacer()

                PiCKButton(
                    buttonText: "완료",
                    isEnabled: viewModel.isFormValid,
                    isLoading: viewModel.isLoading,
                    action: {
                        Task {
                            await viewModel.signup(
                                secretKey: secretKey,
                                accountId: accountId,
                                code: code,
                                password: password
                            )
                        }
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
            .hideKeyboardOnTap()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: viewModel.isSignupSuccessful) { _, isSuccessful in
                if isSuccessful {
                    router.replace(with: .home)
                }
            }
            .navigationBarBackButtonHidden(true)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        router.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.Normal.black)
                    }
                }
            }
            #endif
            .overlay(alignment: .top) {
                if viewModel.errorMessage != nil {
                    errorToast
                }
            }

            if viewModel.showGradeClassPicker {
                gradeClassPickerOverlay
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("PiCK")
                    .foregroundColor(.Primary.primary500)
                Text("에 회원가입하기")
            }
            .pickText(type: .heading2)

            Text("선생님 정보를 입력해주세요.")
                .pickText(type: .body1, textColor: .Gray.gray600)
        }
        .padding(.top, 80)
        .padding(.leading, 24)
    }

    private var teacherCheckSection: some View {
        HStack(spacing: 8) {
            Text("담임 선생님이신가요?")
                .pickText(type: .subTitle1, textColor: .Normal.black)
            Button(action: {
                viewModel.isTeacher.toggle()
            }) {
                Image(viewModel.isTeacher ? "checkBoxOn" : "checkBoxOff", bundle: .module)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }

    private var gradeClassSelectSection: some View {
        HStack(spacing: 8) {
            gradeClassButton(
                title: "학년",
                value: viewModel.selectedGrade == 0 ? "선택" : "\(viewModel.selectedGrade)학년"
            )
            gradeClassButton(
                title: "반",
                value: viewModel.selectedClass == 0 ? "선택" : "\(viewModel.selectedClass)반"
            )
        }
    }

    private func gradeClassButton(title: String, value: String) -> some View {
        Button(action: {
            viewModel.showGradeClassPicker = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .pickText(type: .label1, textColor: .Normal.black)
                
                HStack {
                    Text(value)
                        .pickText(type: .body1, textColor: value == "선택" ? .Gray.gray500 : .Normal.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.Gray.gray500)
                }
                .padding(.horizontal, 16)
                .frame(height: 51)
                .background(Color.Gray.gray50)
                .cornerRadius(4)
            }
        }
    }

    private var gradeClassPickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showGradeClassPicker = false
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Text("학년/반 선택")
                        .pickText(type: .heading3, textColor: .Normal.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    // Grade Selection
                    HStack(spacing: 8) {
                        ForEach([1, 2, 3], id: \.self) { grade in
                            Button {
                                viewModel.selectedGrade = grade
                            } label: {
                                Text("\(grade)학년")
                                    .pickText(
                                        type: .body1,
                                        textColor: viewModel.selectedGrade == grade ? .Primary.primary500 : .Gray.gray600
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        viewModel.selectedGrade == grade
                                            ? Color.Primary.primary50
                                            : Color.Gray.gray100
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Class Selection
                    HStack(spacing: 8) {
                        ForEach([1, 2, 3, 4], id: \.self) { classNum in
                            Button {
                                viewModel.selectedClass = classNum
                            } label: {
                                Text("\(classNum)반")
                                    .pickText(
                                        type: .body1,
                                        textColor: viewModel.selectedClass == classNum ? .Primary.primary500 : .Gray.gray600
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        viewModel.selectedClass == classNum
                                            ? Color.Primary.primary50
                                            : Color.Gray.gray100
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    // Confirm Button
                    Button {
                        viewModel.showGradeClassPicker = false
                    } label: {
                        Text("확인")
                            .pickText(type: .button1, textColor: .Normal.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.Primary.primary500)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .background(Color.Normal.white)
                .cornerRadius(20) // Simplified corner radius for brevity
            }
        }
    }

    private var errorToast: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.Error.error)
            Text(viewModel.errorMessage ?? "")
                .pickText(type: .body2, textColor: .Normal.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Gray.gray800)
        .cornerRadius(8)
        .padding(.top, 60)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation {
                    viewModel.errorMessage = nil
                }
            }
        }
    }
}
