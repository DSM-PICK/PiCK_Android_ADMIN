import Foundation

// MARK: - Response DTO
struct SelfStudyTeacherResponse: Codable {
    let floor: Int
    let teacherName: String
}

// MARK: - Entity
struct SelfStudyTeacherEntity: Identifiable, Equatable {
    var id: Int { floor }
    let floor: Int
    let teacherName: String
}
