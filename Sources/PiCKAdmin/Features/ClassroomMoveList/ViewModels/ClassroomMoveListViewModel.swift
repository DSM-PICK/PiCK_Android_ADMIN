import Foundation
import Observation
import SwiftUI

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
            self.studentItems = []
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func fetchByClassroom() async {
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
