import Foundation

struct SelfStudyTeacherResponse: Codable {
    let floor: Int
    let teacherName: String
}

struct SelfStudyTeacherEntity: Identifiable, Equatable {
    var id: Int { floor }
    let floor: Int
    let teacherName: String
}
