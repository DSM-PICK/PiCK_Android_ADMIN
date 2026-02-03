import SwiftUI
import Observation

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

// MARK: - ViewModel
@MainActor
@Observable
final class CheckSelfStudyTeacherViewModel {
    var teachers: [SelfStudyTeacherEntity] = []
    var isLoading: Bool = false
    var selectedDate: Date = Date()
    var errorMessage: String?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    func fetchSelfStudyTeacher(for date: Date) async {
        isLoading = true
        errorMessage = nil
        selectedDate = date

        let dateString = dateFormatter.string(from: date)

        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getSelfStudyDirector(date: dateString),
                responseType: [SelfStudyTeacherResponse].self
            )

            teachers = response.map { dto in
                SelfStudyTeacherEntity(floor: dto.floor, teacherName: dto.teacherName)
            }
        } catch {
            teachers = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
