import SwiftUI

struct OutingHistoryView: View {
    var router: AppRouter
    @State var viewModel = OutingHistoryViewModel()

    var body: some View {
        ZStack {
            Color.Normal.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 커스텀 네비게이션 바
                navigationBar

                // 검색 바
                searchBar
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 24)

                // 컨텐츠
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.filteredStudentItems.isEmpty {
                    Spacer()
                    emptyView
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.filteredStudentItems) { data in
                                OutingHistoryCell(data: data)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .task { @MainActor in
            await viewModel.fetchOutingHistory()
        }
    }

    private var navigationBar: some View {
        ZStack {
            Text("이전 외출 기록")
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
        .background(Color.Normal.white)
    }

    private var searchBar: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.Normal.black)
                .padding(.leading, 16)

            TextField(
                "이름 또는 학번으로 검색",
                text: $viewModel.searchText
            )
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image("blackLogo", bundle: .module)
                .resizable()
                .frame(width: 88, height: 91)

            Text("일치하는 학생이 없어요")
                .pickText(type: .subTitle2, textColor: .Gray.gray500)
        }
    }
}

// MARK: - OutingHistoryCell
struct OutingHistoryCell: View {
    let data: OutingHistoryEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(data.grade)\(data.classNum)\(String(format: "%02d", data.num)) \(data.userName)")
                .pickText(type: .subTitle2, textColor: .Normal.black)

            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text("조기귀가")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.Primary.primary300)
                        .cornerRadius(8)

                    Text("\(data.earlyReturnCnt)회")
                        .pickText(type: .body2, textColor: .Normal.black)
                }

                HStack(spacing: 8) {
                    Text("외출")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.Primary.primary500)
                        .cornerRadius(8)

                    Text("\(data.applicationCnt)회")
                        .pickText(type: .body2, textColor: .Normal.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
}
