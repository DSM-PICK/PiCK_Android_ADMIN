import Foundation

public struct AcademicSchedule: Identifiable, Hashable {
    public let id: String
    public let eventName: String
    public let month: Int
    public let day: Int
    public let dayName: String
}

struct AcademicScheduleDTO: Decodable {
    let id: String
    let eventName: String
    let month: Int
    let day: Int
    let dayName: String
}
