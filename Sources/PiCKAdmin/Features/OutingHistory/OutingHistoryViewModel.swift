import SwiftUI
import Observation

// MARK: - Response DTO
struct OutingHistoryResponse: Codable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let applicationCnt: Int
    let earlyReturnCnt: Int
}

// MARK: - Entity
struct OutingHistoryEntity: Identifiable, Equatable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let applicationCnt: Int
    let earlyReturnCnt: Int
}

// MARK: - ViewModel
@MainActor
@Observable
final class OutingHistoryViewModel {
    var studentItems: [OutingHistoryEntity] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    var filteredStudentItems: [OutingHistoryEntity] {
        guard !searchText.isEmpty else { return studentItems }

        let keyword = searchText.replacingOccurrences(of: " ", with: "").lowercased()

        return studentItems.filter { data in
            let searchableText =
                "\(data.grade)\(data.classNum)\(String(format: "%02d", data.num))\(data.userName)"
                .lowercased()

            return searchableText.contains(keyword)
        }
    }

    func fetchOutingHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIClient.shared.request(
                OutingHistoryAPI.getOutingHistory(),
                responseType: [OutingHistoryResponse].self
            )

            studentItems = response.map { dto in
                OutingHistoryEntity(
                    id: dto.id,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    applicationCnt: dto.applicationCnt,
                    earlyReturnCnt: dto.earlyReturnCnt
                )
            }
        } catch {
            studentItems = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
