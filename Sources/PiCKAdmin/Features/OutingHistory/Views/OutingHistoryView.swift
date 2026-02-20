import SwiftUI

struct OutingHistoryView: View {
    @Environment(\.appRouter) var router: AppRouter
    @State var viewModel = OutingHistoryViewModel()

    var body: some View {
        ZStack {
            Color.Normal.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                searchBar
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 24)

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
