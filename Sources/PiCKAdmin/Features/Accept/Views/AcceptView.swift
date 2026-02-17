import SwiftUI

public struct AcceptView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = AcceptViewModel()
    @State var selectedOption: ApplicationType = .outgoing
    @State var isTypePickerPresented: Bool = false

    public var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header: Filter & Action Buttons
                headerSection

                // Divider
                Rectangle()
                    .fill(Color.Gray.gray200)
                    .frame(height: 0.5)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                // Floor Filter (only for classroom move)
                if selectedOption == .classroomMove {
                    floorFilterSection
                }

                // Title
                HStack(spacing: 0) {
                    Text("\(selectedOption.title) 신청한 학생")
                        .pickText(type: .body2, textColor: .Gray.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, selectedOption == .classroomMove ? 16 : 10)
                .padding(.horizontal, 24)

                // Student List
                studentListSection

                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("pickLogo", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .padding(.leading, 8)
                }
            }
            .task {
                await viewModel.fetchInitialData()
            }

            // Type Picker Sheet
            if isTypePickerPresented {
                typePickerOverlay
            }

            // Approve Popup
            if viewModel.showApprovePopup {
                confirmPopup(
                    title: "선택한 신청을 수락하시겠습니까?",
                    explain: "수락하면 학생에게 알림이 전송됩니다.",
                    isApprove: true
                )
            }

            // Reject Popup
            if viewModel.showRejectPopup {
                confirmPopup(
                    title: "선택한 신청을 거절하시겠습니까?",
                    explain: "거절하면 학생에게 알림이 전송됩니다.",
                    isApprove: false
                )
            }

            // Alert
            if viewModel.showAlert {
                alertOverlay
            }
        }
        .background(Color.white)
        .toolbar(isTypePickerPresented ? .hidden : .visible, for: .tabBar)
    }

    private var headerSection: some View {
        HStack(spacing: 0) {
            HStack(spacing: 16) {
                // Filter Button
                Button(action: { isTypePickerPresented = true }) {
                    HStack(spacing: 4) {
                        Text(selectedOption.title)
                            .pickText(type: .body1, textColor: .Normal.black)
                            .lineLimit(1)
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

                // Date
                Text(Date().koreanMonthDayString())
                    .pickText(type: .body2, textColor: .Gray.gray700)
            }
            .padding(.leading, 24)

            Spacer()

            // Action Buttons
            HStack(spacing: 8) {
                Button(action: { viewModel.showRejectPopup = true }) {
                    Text("거절")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.Error.error)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(!viewModel.selectedItemIds.isEmpty ? 0 : 0.6))
                        )
                }
                .disabled(viewModel.selectedItemIds.isEmpty)

                Button(action: { viewModel.showApprovePopup = true }) {
                    Text("수락")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.Primary.primary900)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(!viewModel.selectedItemIds.isEmpty ? 0 : 0.6))
                        )
                }
                .disabled(viewModel.selectedItemIds.isEmpty)
            }
            .padding(.trailing, 24)
        }
        .padding(.top, 24)
    }

    private var floorFilterSection: some View {
        HStack(spacing: 0) {
            ForEach([1, 2, 3, 4, 5], id: \.self) { floor in
                Button {
                    Task {
                        await viewModel.fetchClassroomMovesByFloor(floor: floor)
                    }
                } label: {
                    Text("\(floor)층")
                        .pickText(
                            type: .body1,
                            textColor: viewModel.currentFloor == floor ? .Primary.primary500 : .Gray.gray600
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            viewModel.currentFloor == floor
                            ? Color.Primary.primary50
                            : Color.clear
                        )
                        .cornerRadius(8)
                }
                
                if floor != 5 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    @ViewBuilder
    private var studentListSection: some View {
        if viewModel.studentItems.isEmpty && !viewModel.isLoading {
            emptyStateView
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.studentItems, id: \.id) { item in
                        switch item {
                        case .application(let student):
                            AcceptStudentCell(
                                studentNumber: studentNumber(grade: student.grade, classNum: student.classNum, num: student.num),
                                studentName: student.userName,
                                startTime: student.start,
                                endTime: student.end,
                                activityType: "외출 수락",
                                reason: student.reason,
                                isSelected: viewModel.selectedItemIds.contains(student.id),
                                onTap: { viewModel.toggleSelection(id: student.id) }
                            )

                        case .classroomMove(let student):
                            AcceptClassroomMoveCell(
                                studentNumber: studentNumber(grade: student.grade, classNum: student.classNum, num: student.num),
                                studentName: student.userName,
                                startPeriod: student.start,
                                endPeriod: student.end,
                                currentClassroom: "\(student.grade)학년 \(student.classNum)반",
                                moveToClassroom: student.classroomName,
                                isSelected: viewModel.selectedItemIds.contains(student.id),
                                onTap: { viewModel.toggleSelection(id: student.id) }
                            )

                        case .earlyReturn(let student):
                            AcceptStudentCell(
                                studentNumber: studentNumber(grade: student.grade, classNum: student.classNum, num: student.num),
                                studentName: student.userName,
                                startTime: student.start,
                                endTime: "",
                                activityType: "조기 귀가",
                                reason: student.reason,
                                isSelected: viewModel.selectedItemIds.contains(student.id),
                                onTap: { viewModel.toggleSelection(id: student.id) }
                            )
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)
            }
        }
    }

    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image("blackLogo", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 91)

                Text(emptyStateMessage)
                    .pickText(type: .body1, textColor: .Gray.gray500)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateMessage: String {
        switch selectedOption {
        case .outgoing:
            return "아직 외출을 신청한 학생이 없어요"
        case .classroomMove:
            return "아직 교실 이동을 신청한 학생이 없어요"
        case .earlyReturn:
            return "아직 조기 귀가를 신청한 학생이 없어요"
        }
    }

    private var typePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isTypePickerPresented = false
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    HStack {
                        Text("수락 항목을 선택해주세요")
                            .pickText(type: .heading3, textColor: .Normal.black)
                        Spacer()
                        Text("✕")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.Gray.gray600)
                            .onTapGesture {
                                isTypePickerPresented = false
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    ForEach([ApplicationType.outgoing, .classroomMove, .earlyReturn], id: \.self) { type in
                        Button {
                            selectedOption = type
                            isTypePickerPresented = false
                            Task {
                                await viewModel.changeType(type)
                            }
                        } label: {
                            HStack {
                                Text(type.title)
                                    .pickText(type: .body1, textColor: selectedOption == type ? .Primary.primary500 : .Normal.black)
                                Spacer()
                                if selectedOption == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.Primary.primary500)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }

                        if type != .earlyReturn {
                            Rectangle()
                                .fill(Color.Gray.gray100)
                                .frame(height: 1)
                                .padding(.horizontal, 24)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.bottom, 100)
                .background(Color.Normal.white)
                .cornerRadius(20)
            }
        }
    }

    private func confirmPopup(title: String, explain: String, isApprove: Bool) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if isApprove {
                        viewModel.showApprovePopup = false
                    } else {
                        viewModel.showRejectPopup = false
                    }
                }

            VStack(spacing: 16) {
                Text(title)
                    .pickText(type: .heading3, textColor: .Normal.black)
                    .multilineTextAlignment(.center)

                Text(explain)
                    .pickText(type: .body2, textColor: .Gray.gray600)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button {
                        if isApprove {
                            viewModel.showApprovePopup = false
                        } else {
                            viewModel.showRejectPopup = false
                        }
                    } label: {
                        Text("취소")
                            .pickText(type: .button1, textColor: .Gray.gray600)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.Gray.gray100)
                            .cornerRadius(8)
                    }

                    Button {
                        Task {
                            if isApprove {
                                viewModel.showApprovePopup = false
                                await viewModel.approveSelected()
                            } else {
                                viewModel.showRejectPopup = false
                                await viewModel.rejectSelected()
                            }
                        }
                    } label: {
                        Text(isApprove ? "수락" : "거절")
                            .pickText(type: .button1, textColor: .Normal.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isApprove ? Color.Primary.primary500 : Color.Error.error)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Color.Normal.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
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

    private func studentNumber(grade: Int, classNum: Int, num: Int) -> String {
        return "\(grade)\(classNum)\(num < 10 ? "0" : "")\(num)"
    }
}
