import Foundation
import Observation
import SwiftUI

// MARK: - ClassroomMoveList Type
public enum ClassroomMoveListType: String, Equatable, Hashable {
    case floor = "층으로"
    case classroom = "교실로"
}

// MARK: - Models
public struct ClassroomMoveListStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: Int
    public let end: Int
    public let classroomName: String
}

// MARK: - DTOs
struct ClassroomMoveListDTO: Decodable {
    let userName: String
    let classroomName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: Int
    let end: Int
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case classroomName = "classroom_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case end
        case userId = "user_id"
    }
}

// MARK: - ViewModel
@Observable
public final class ClassroomMoveListViewModel {
    public var studentItems: [ClassroomMoveListStudent] = []
    public var isLoading: Bool = false
    
    public var currentType: ClassroomMoveListType = .floor
    public var selectedFloor: Int = 2
    public var selectedGrade: Int = 5 // 5 means "All"
    public var selectedClassNum: Int = 5 // 5 means "All"
    
    public var errorMessage: String? = nil
    
    public init() {}
    
    @MainActor
    public func onAppear() async {
        await fetchData()
    }
    
    @MainActor
    public func fetchData() async {
        isLoading = true
        defer { isLoading = false }
        
        if currentType == .floor {
            await fetchByFloor()
        } else {
            await fetchByClassroom()
        }
    }
    
    @MainActor
    private func fetchByFloor() async {
        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getClassroomMoveByFloor(floor: selectedFloor),
                responseType: [ClassroomMoveListDTO].self
            )
            
            self.studentItems = response.map { dto in
                ClassroomMoveListStudent(
                    id: dto.userId ?? UUID().uuidString,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    end: dto.end,
                    classroomName: dto.classroomName
                )
            }
        } catch {
            print("Failed to fetch classroom move by floor: \(error)")
            self.studentItems = []
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func fetchByClassroom() async {
        // If selectedGrade is 5 (All), fallback to a default floor or show all?
        // iOS implementation says: if state.selectedGrade == 5 { return loadClassroomMoveListByFloor(floor: 5) }
        
        if selectedGrade == 5 {
            do {
                let response = try await APIClient.shared.request(
                    HomeAPI.getClassroomMoveByFloor(floor: 5),
                    responseType: [ClassroomMoveListDTO].self
                )
                self.studentItems = response.map { dto in
                    ClassroomMoveListStudent(
                        id: dto.userId ?? UUID().uuidString,
                        userName: dto.userName,
                        grade: dto.grade,
                        classNum: dto.classNum,
                        num: dto.num,
                        start: dto.start,
                        end: dto.end,
                        classroomName: dto.classroomName
                    )
                }
            } catch {
                self.studentItems = []
                self.errorMessage = error.localizedDescription
            }
            return
        }

        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getClassroomMoveByClassroom(grade: selectedGrade, classNum: selectedClassNum),
                responseType: [ClassroomMoveListDTO].self
            )
            
            self.studentItems = response.map { dto in
                ClassroomMoveListStudent(
                    id: dto.userId ?? UUID().uuidString,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    end: dto.end,
                    classroomName: dto.classroomName
                )
            }
        } catch {
            print("Failed to fetch classroom move by classroom: \(error)")
            self.studentItems = []
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func changeType(_ type: ClassroomMoveListType) async {
        currentType = type
        await fetchData()
    }
    
    @MainActor
    public func changeFloor(_ floor: Int) async {
        selectedFloor = floor
        await fetchByFloor()
    }
    
    @MainActor
    public func changeClassroom(grade: Int, classNum: Int) async {
        selectedGrade = grade
        selectedClassNum = classNum
        await fetchByClassroom()
    }
}
