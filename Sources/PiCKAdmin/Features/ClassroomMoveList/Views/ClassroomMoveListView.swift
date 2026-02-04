import SwiftUI

public struct ClassroomMoveListView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel = ClassroomMoveListViewModel()
    @State var isTypePickerPresented = false
    @State var isClassroomPickerPresented = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Background.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar
                
                // Header
                HStack {
                    Text("\(todayString) 교실 이동자")
                        .pickText(type: .heading4, textColor: .Normal.black)
                        .padding(.leading, 24)

                    Spacer()
                    
                    // Filter Type Button (Floor / Classroom)
                    Button(action: { isTypePickerPresented = true }) {
                        HStack(spacing: 4) {
                            Text(viewModel.currentType.rawValue)
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

                // Divider
                Rectangle()
                    .fill(Color.Gray.gray200)
                    .frame(height: 0.5)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                // Secondary Filter (Floor Scroll or Classroom Picker)
                if viewModel.currentType == .floor {
                    floorFilterSection
                } else {
                    classroomFilterButtonSection
                }

                // List Area
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewModel.studentItems.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.studentItems, id: \.id) { item in
                                AcceptClassroomMoveCell(
                                    studentNumber: studentNumber(grade: item.grade, classNum: item.classNum, num: item.num),
                                    studentName: item.userName,
                                    startPeriod: item.start,
                                    endPeriod: item.end,
                                    currentClassroom: "\(item.grade)학년 \(item.classNum)반",
                                    moveToClassroom: item.classroomName,
                                    isSelected: false,
                                    onTap: {}
                                )
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden)
            .task {
                await viewModel.onAppear()
            }

            // Type Picker Overlay
            if isTypePickerPresented {
                typePickerOverlay
            }
            
            // Classroom Picker Overlay
            if isClassroomPickerPresented {
                classroomPickerOverlay
            }
        }
    }

    private var navigationBar: some View {
        ZStack {
            Text("교실 이동 현황")
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

    // MARK: - Subviews
    private var floorFilterSection: some View {
        HStack(spacing: 0) {
            ForEach([1, 2, 3, 4, 5], id: \.self) { floor in
                Button {
                    Task {
                        await viewModel.changeFloor(floor)
                    }
                } label: {
                    Text("\(floor)층")
                        .pickText(
                            type: .body1,
                            textColor: viewModel.selectedFloor == floor ? .Primary.primary500 : .Gray.gray600
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            viewModel.selectedFloor == floor
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
    
    private var classroomFilterButtonSection: some View {
        HStack {
            Spacer()
            Button {
                isClassroomPickerPresented = true
            } label: {
                HStack(spacing: 4) {
                    Text(classroomDisplayText)
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
            .padding(.top, 16)
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

                Text("아직 교실 이동을 한 학생이 없어요")
                    .pickText(type: .body1, textColor: .Gray.gray500)
            }
            Spacer()
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
                    Text("필터를 선택해주세요")
                        .pickText(type: .heading3, textColor: .Normal.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    ForEach([ClassroomMoveListType.floor, .classroom], id: \.self) { type in
                        Button {
                            Task {
                                await viewModel.changeType(type)
                                isTypePickerPresented = false
                            }
                        } label: {
                            HStack {
                                Text(type.rawValue)
                                    .pickText(type: .body1, textColor: viewModel.currentType == type ? .Primary.primary500 : .Normal.black)
                                Spacer()
                                if viewModel.currentType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.Primary.primary500)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }

                        if type == .floor {
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
    
    private var classroomPickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isClassroomPickerPresented = false
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Text("교실을 선택해주세요")
                        .pickText(type: .heading3, textColor: .Normal.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 20)

                    // Grade Selection
                    HStack(spacing: 8) {
                        ForEach([5, 1, 2, 3], id: \.self) { grade in
                            Button {
                                Task {
                                    await viewModel.changeClassroom(grade: grade, classNum: viewModel.selectedClassNum)
                                }
                            } label: {
                                Text(grade == 5 ? "전체" : "\(grade)학년")
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
                        ForEach([5, 1, 2, 3, 4], id: \.self) { classNum in
                            Button {
                                Task {
                                    await viewModel.changeClassroom(grade: viewModel.selectedGrade, classNum: classNum)
                                }
                            } label: {
                                Text(classNum == 5 ? "전체" : "\(classNum)반")
                                    .pickText(
                                        type: .body1,
                                        textColor: viewModel.selectedClassNum == classNum ? .Primary.primary500 : .Gray.gray600
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        viewModel.selectedClassNum == classNum
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
                        isClassroomPickerPresented = false
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

    // MARK: - Helpers
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일"
        return formatter.string(from: Date())
    }

    private var classroomDisplayText: String {
        let grade = viewModel.selectedGrade == 5 ? "전체" : "\(viewModel.selectedGrade)"
        let classNum = viewModel.selectedClassNum == 5 ? "전체" : "\(viewModel.selectedClassNum)"
        return "\(grade)-\(classNum)"
    }

    private func studentNumber(grade: Int, classNum: Int, num: Int) -> String {
        return "\(grade)\(classNum)\(num < 10 ? "0" : "")\(num)"
    }
}
