import SwiftUI

public struct SelfStudyCheckView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = SelfStudyCheckViewModel()

    public var body: some View {
        ZStack {
            Color.Background.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                headerSection

                studentListSection

                saveButton
            }

            if viewModel.showGradeClassPicker {
                gradeClassPickerOverlay
            }

            if viewModel.showStatusPicker {
                statusPickerOverlay
            }

            if viewModel.showAlert {
                alertOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .task {
            await viewModel.fetchStudents()
        }
    }

    private var navigationBar: some View {
        ZStack {
            Text("자습시간 출결")
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
        .background(Color.Background.background)
    }

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    viewModel.showGradeClassPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text("\(viewModel.selectedGrade)학년 \(viewModel.selectedClass)반")
                            .pickText(type: .body1, textColor: .Normal.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.Normal.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.Gray.gray200, lineWidth: 1)
                    )
                }

                Spacer()

                Text(Date().koreanDateString())
                    .pickText(type: .body2, textColor: .Gray.gray600)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            HStack(spacing: 0) {
                ForEach(Period.allCases, id: \.self) { period in
                    Button {
                        Task {
                            await viewModel.selectPeriod(period)
                        }
                    } label: {
                        Text(period.title)
                            .pickText(
                                type: .body1,
                                textColor: viewModel.selectedPeriod == period ? .Primary.primary500 : .Gray.gray500
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                viewModel.selectedPeriod == period
                                    ? Color.Primary.primary50
                                    : Color.clear
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Rectangle()
                .fill(Color.Gray.gray200)
                .frame(height: 1)
                .padding(.top, 16)
        }
    }

    private var studentListSection: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .padding(.top, 100)
                }
            } else if viewModel.studentItems.isEmpty {
                VStack(spacing: 12) {
                    Image("pickLogo", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 91)
                        .opacity(0.5)

                    Text("등록된 학생이 없습니다")
                        .pickText(type: .body1, textColor: .Gray.gray500)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.studentItems, id: \.id) { student in
                        StudentAttendanceCell(
                            student: student,
                            onStatusTap: {
                                viewModel.selectedStudentId = student.id
                                viewModel.showStatusPicker = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveAttendance()
            }
        } label: {
            Text("저장")
                .pickText(type: .button1, textColor: .Normal.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.isChanged && !viewModel.isSaving
                        ? Color.Primary.primary500
                        : Color.Gray.gray400
                )
                .cornerRadius(12)
        }
        .disabled(!viewModel.isChanged || viewModel.isSaving)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.Normal.white)
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

                    HStack(spacing: 8) {
                        ForEach([1, 2, 3], id: \.self) { grade in
                            Button {
                                Task {
                                    await viewModel.selectGradeAndClass(grade: grade, classNum: viewModel.selectedClass)
                                }
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

                    HStack(spacing: 8) {
                        ForEach([1, 2, 3, 4], id: \.self) { classNum in
                            Button {
                                Task {
                                    await viewModel.selectGradeAndClass(grade: viewModel.selectedGrade, classNum: classNum)
                                }
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
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
    }

    private var statusPickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showStatusPicker = false
                    viewModel.selectedStudentId = nil
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Text("출결 상태 선택")
                        .pickText(type: .heading3, textColor: .Normal.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(AttendanceStatus.allCases, id: \.self) { status in
                            Button {
                                if let studentId = viewModel.selectedStudentId {
                                    viewModel.updateStudentStatus(id: studentId, status: status.korean)
                                }
                                viewModel.showStatusPicker = false
                                viewModel.selectedStudentId = nil
                            } label: {
                                Text(status.korean)
                                    .pickText(type: .body1, textColor: .Normal.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.Gray.gray100)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(Color.Normal.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
        }
    }

    private var alertOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: viewModel.alertSuccessType ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(viewModel.alertSuccessType ? .Primary.primary500 : .Error.error)
                Text(viewModel.alertMessage)
                    .pickText(type: .body1, textColor: .Normal.black)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.Gray.gray50)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .padding(.bottom, 100)
        }
        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut, value: viewModel.showAlert)
    }
}
