import SwiftUI

public struct OutListView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel = OutListViewModel()
    @State var isFloorPickerPresented = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Background.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar
                
                HStack {
                    Text("\(todayString) 외출자")
                        .pickText(type: .heading4, textColor: .Normal.black)
                        .padding(.leading, 24)

                    Spacer()
                    
                    Button(action: { isFloorPickerPresented = true }) {
                        HStack(spacing: 4) {
                            Text(floorDisplayText(viewModel.currentFloor))
                                .pickText(type: .body1, textColor: .Normal.black)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.Normal.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.Gray.gray200, lineWidth: 1)
                        )
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 24)

                Rectangle()
                    .fill(Color.Gray.gray200)
                    .frame(height: 0.5)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                HStack(spacing: 8) {
                    Button {
                        Task { await viewModel.changeType(.outing) }
                    } label: {
                        Text("외출")
                            .pickText(
                                type: .body1,
                                textColor: viewModel.currentType == .outing ? .Primary.primary500 : .Gray.gray600
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                viewModel.currentType == .outing
                                ? Color.Primary.primary50
                                : Color.clear
                            )
                            .cornerRadius(8)
                    }

                    Button {
                        Task { await viewModel.changeType(.earlyReturn) }
                    } label: {
                        Text("조기귀가")
                            .pickText(
                                type: .body1,
                                textColor: viewModel.currentType == .earlyReturn ? .Primary.primary500 : .Gray.gray600
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                viewModel.currentType == .earlyReturn
                                ? Color.Primary.primary50
                                : Color.clear
                            )
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.currentType == .outing && viewModel.outingItems.isEmpty {
                    emptyStateView(message: "아직 외출을 신청한 학생이 없어요")
                } else if viewModel.currentType == .earlyReturn && viewModel.earlyReturnItems.isEmpty {
                    emptyStateView(message: "아직 조기귀가를 신청한 학생이 없어요")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.currentType == .outing {
                                ForEach(viewModel.outingItems, id: \.id) { student in
                                    AcceptStudentCell(
                                        studentNumber: studentNumber(grade: student.grade, classNum: student.classNum, num: student.num),
                                        studentName: student.userName,
                                        startTime: student.start,
                                        endTime: student.end,
                                        activityType: "외출",
                                        reason: student.reason,
                                        isSelected: viewModel.selectedIds.contains(student.id),
                                        onTap: { viewModel.toggleSelection(id: student.id) }
                                    )
                                }
                            } else {
                                ForEach(viewModel.earlyReturnItems, id: \.id) { student in
                                    AcceptStudentCell(
                                        studentNumber: studentNumber(grade: student.grade, classNum: student.classNum, num: student.num),
                                        studentName: student.userName,
                                        startTime: student.start,
                                        endTime: "",
                                        activityType: "조기귀가",
                                        reason: student.reason,
                                        isSelected: false,
                                        onTap: { }
                                    )
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }

                if viewModel.currentType == .outing {
                    Button {
                        Task { await viewModel.returnStudents() }
                    } label: {
                        Text("복귀 시키기")
                            .pickText(type: .button1, textColor: .Normal.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(viewModel.selectedIds.isEmpty ? Color.Gray.gray400 : Color.Primary.primary500)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedIds.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden)
            .task {
                await viewModel.onAppear()
            }

            if isFloorPickerPresented {
                floorPickerOverlay
            }

            if viewModel.showAlert {
                alertOverlay
            }
        }
    }

    private var navigationBar: some View {
        ZStack {
            Text("외출자 목록")
                .pickText(type: .subTitle1, textColor: .Normal.black)

            HStack {
                Button {
                    dismiss()
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

    private func emptyStateView(message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image("blackLogo", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 91)

                Text(message)
                    .pickText(type: .body1, textColor: .Gray.gray500)
            }
            Spacer()
        }
    }

    private var floorPickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isFloorPickerPresented = false
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Text("층을 선택해주세요")
                        .pickText(type: .heading3, textColor: .Normal.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    ForEach([5, 2, 3, 4], id: \.self) { floor in
                        Button {
                            Task {
                                await viewModel.changeFloor(floor)
                                isFloorPickerPresented = false
                            }
                        } label: {
                            HStack {
                                Text(floorDisplayText(floor))
                                    .pickText(type: .body1, textColor: viewModel.currentFloor == floor ? .Primary.primary500 : .Normal.black)
                                Spacer()
                                if viewModel.currentFloor == floor {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.Primary.primary500)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }

                        if floor != 4 {
                            Rectangle()
                                .fill(Color.Gray.gray100)
                                .frame(height: 1)
                                .padding(.horizontal, 24)
                        }
                    }

                    Spacer().frame(height: 40)
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
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일"
        return formatter.string(from: Date())
    }

    private func floorDisplayText(_ floor: Int) -> String {
        switch floor {
        case 5: return "전체"
        default: return "\(floor)층"
        }
    }

    private func studentNumber(grade: Int, classNum: Int, num: Int) -> String {
        return "\(grade)\(classNum)\(num < 10 ? "0" : "")\(num)"
    }
}
