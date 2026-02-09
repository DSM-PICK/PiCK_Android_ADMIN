import SwiftUI

struct InfoSettingView: View {
    let secretKey: String
    let accountId: String
    let code: String
    let password: String
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = InfoSettingViewModel()
    @State var nameText: String = ""
    @State var isTeacher: Bool = false
    @State var selectedGrade: Int = 0
    @State var selectedClass: Int = 0
    @State var showGradeClassPicker: Bool = false

    var isFormValid: Bool {
        if nameText.isEmpty { return false }
        if isTeacher {
            return selectedGrade != 0 && selectedClass != 0
        }
        return true
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Text("회원가입")
                        .pickText(type: .subTitle1, textColor: .Normal.black)

                    HStack {
                        Button {
                            router.pop()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.Normal.black)
                        }
                        .padding(.leading, 16)
                        Spacer()
                    }
                }
                .frame(height: 56)

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
                .padding(.top, 58)
                .padding(.leading, 24)

                HStack(spacing: 8) {
                    Text("담임 선생님이신가요?")
                        .pickText(type: .subTitle1, textColor: .Normal.black)
                    Button(action: {
                        isTeacher.toggle()
                    }) {
                        Image(isTeacher ? "checkBoxOn" : "checkBoxOff", bundle: .module)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.top, 48)
                .padding(.leading, 24)

                if isTeacher {
                    HStack(spacing: 8) {
                        gradeClassButton(title: "학년", value: selectedGrade == 0 ? "선택" : "\(selectedGrade)학년")
                        gradeClassButton(title: "반", value: selectedClass == 0 ? "선택" : "\(selectedClass)반")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                }

                PiCKTextField(
                    text: $nameText,
                    placeholder: "이름을 입력해주세요",
                    titleText: "이름"
                )
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Spacer()

                PiCKButton(
                    buttonText: "완료",
                    isEnabled: isFormValid,
                    isLoading: viewModel.isLoading,
                    action: {
                        viewModel.name = nameText
                        viewModel.isTeacher = isTeacher
                        viewModel.selectedGrade = selectedGrade
                        viewModel.selectedClass = selectedClass
                        Task {
                            await viewModel.signup(
                                secretKey: secretKey,
                                accountId: accountId,
                                code: code,
                                password: password
                            )
                            if viewModel.isSignupSuccessful {
                                router.replace(with: .home)
                            }
                        }
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
            .hideKeyboardOnTap()
            .frame(maxWidth: .infinity, alignment: .leading)

            if showGradeClassPicker {
                gradeClassPickerOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .overlay(alignment: .top) {
            if viewModel.errorMessage != nil {
                errorToast
            }
        }
    }

    private func gradeClassButton(title: String, value: String) -> some View {
        Button(action: {
            showGradeClassPicker = true
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
                    showGradeClassPicker = false
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

                    HStack(spacing: 8) {
                        ForEach([1, 2, 3], id: \.self) { grade in
                            Button {
                                selectedGrade = grade
                            } label: {
                                Text("\(grade)학년")
                                    .pickText(
                                        type: .body1,
                                        textColor: selectedGrade == grade ? .Primary.primary500 : .Gray.gray600
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedGrade == grade
                                            ? Color.Primary.primary50
                                            : Color.Gray.gray100
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    HStack(spacing: 8) {
                        ForEach([1, 2, 3, 4], id: \.self) { classNum in
                            Button {
                                selectedClass = classNum
                            } label: {
                                Text("\(classNum)반")
                                    .pickText(
                                        type: .body1,
                                        textColor: selectedClass == classNum ? .Primary.primary500 : .Gray.gray600
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedClass == classNum
                                            ? Color.Primary.primary50
                                            : Color.Gray.gray100
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    Button {
                        showGradeClassPicker = false
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
                .cornerRadius(20)
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
