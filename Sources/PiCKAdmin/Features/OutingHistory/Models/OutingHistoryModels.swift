import Foundation

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
