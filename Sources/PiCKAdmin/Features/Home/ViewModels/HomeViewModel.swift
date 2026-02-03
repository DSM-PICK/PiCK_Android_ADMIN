import Foundation
import Observation
import SwiftUI

// MARK: - Home ViewModel
@Observable
public final class HomeViewModel {
    public var adminSelfStudyTeacher: String = ""
    public var selfStudyDirector: [SelfStudyDirector] = []
    public var outingAcceptList: [AcceptStudent] = []
    public var outingStudentList: [OutingStudent] = []
    public var classroomMoveList: [ClassroomMoveStudent] = []

    public var isHomeroomTeacher: Bool = false
    public var isSelfStudyTeacher: Bool = false
    public var classroom: String = "0학년 0반"
    public var floor: String = "0층"

    public var isLoading: Bool = false
    public var showAlert: Bool = false
    public var alertMessage: String = ""
    public var alertSuccessType: Bool = true

    public init() {}

    @MainActor
    public func fetchSelfStudyDirector(date: String) async {
        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getSelfStudyDirector(date: date),
                responseType: [SelfStudyDirectorDTO].self
            )
            self.selfStudyDirector = response.map {
                SelfStudyDirector(floor: $0.floor, teacherName: $0.teacherName)
            }
        } catch {
            print("Failed to fetch self study director: \(error)")
        }
    }

    @MainActor
    public func fetchAdminSelfStudyInfo() async {
        do {
            let response = try await APIClient.shared.requestString(
                HomeAPI.getAdminSelfStudyInfo()
            )
            self.adminSelfStudyTeacher = response
        } catch {
            print("Failed to fetch admin self study info: \(error)")
        }
    }

    @MainActor
    public func fetchSelfStudyAndClassroom() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getSelfStudyAndClassroom(),
                responseType: SelfStudyAndClassroomDTO.self
            )
            
            self.classroom = "\(response.grade)학년 \(response.classNum)반"
            self.floor = "\(response.selfStudyFloor)층"
            
            self.isHomeroomTeacher = (response.grade != 0 && response.classNum != 0)
            self.isSelfStudyTeacher = (response.selfStudyFloor != 0)
            
            if isHomeroomTeacher {
                await fetchAcceptLists(grade: response.grade, classNum: response.classNum)
            }
            
            if isSelfStudyTeacher {
                await fetchOutingLists(floor: response.selfStudyFloor)
            }
            
        } catch {
            print("Failed to fetch self study and classroom: \(error)")
        }
    }
    
    @MainActor
    private func fetchAcceptLists(grade: Int, classNum: Int) async {
        async let applications = APIClient.shared.request(
            HomeAPI.getApplicationsByGrade(grade: grade, classNum: classNum),
            responseType: [ApplicationDTO].self
        )
        async let earlyReturns = APIClient.shared.request(
            HomeAPI.getEarlyReturnByGrade(grade: grade, classNum: classNum),
            responseType: [EarlyReturnDTO].self
        )
        
        do {
            let (apps, returns) = try await (applications, earlyReturns)
            
            let appStudents = apps.map {
                AcceptStudent(id: $0.id, userName: $0.userName, grade: $0.grade, classNum: $0.classNum, num: $0.num, type: .outgoing)
            }
            let returnStudents = returns.map {
                AcceptStudent(id: $0.id, userName: $0.userName, grade: $0.grade, classNum: $0.classNum, num: $0.num, type: .earlyReturn)
            }
            
            self.outingAcceptList = (appStudents + returnStudents).sorted {
                if $0.grade != $1.grade { return $0.grade < $1.grade }
                if $0.classNum != $1.classNum { return $0.classNum < $1.classNum }
                return $0.num < $1.num
            }
        } catch {
            print("Failed to fetch accept lists: \(error)")
        }
    }
    
    @MainActor
    private func fetchOutingLists(floor: Int) async {
        async let outList = APIClient.shared.request(
            HomeAPI.getOutList(floor: floor),
            responseType: [ApplicationDTO].self
        )
        async let earlyReturnList = APIClient.shared.request(
            HomeAPI.getEarlyReturnList(floor: floor),
            responseType: [EarlyReturnDTO].self
        )
        async let classroomMoves = APIClient.shared.request(
            HomeAPI.getClassroomMoveByFloor(floor: floor),
            responseType: [ClassroomMoveDTO].self
        )
        
        do {
            let (outs, returns, moves) = try await (outList, earlyReturnList, classroomMoves)
            
            let outStudents = outs.map {
                OutingStudent(id: $0.id, userName: $0.userName, grade: $0.grade, classNum: $0.classNum, num: $0.num, type: .outgoing)
            }
            let returnStudents = returns.map {
                OutingStudent(id: $0.id, userName: $0.userName, grade: $0.grade, classNum: $0.classNum, num: $0.num, type: .earlyReturn)
            }
            
            self.outingStudentList = (outStudents + returnStudents).sorted {
                if $0.grade != $1.grade { return $0.grade < $1.grade }
                if $0.classNum != $1.classNum { return $0.classNum < $1.classNum }
                return $0.num < $1.num
            }
            
            self.classroomMoveList = moves.map {
                ClassroomMoveStudent(
                    id: $0.userId ?? UUID().uuidString,
                    userName: $0.userName,
                    grade: $0.grade,
                    classNum: $0.classNum,
                    num: $0.num,
                    start: $0.start,
                    end: $0.end,
                    classroomName: $0.classroomName
                )
            }
        } catch {
            print("Failed to fetch outing lists: \(error)")
        }
    }

    @MainActor
    public func acceptApplication(id: String) async {
        do {
            try await APIClient.shared.requestVoid(
                HomeAPI.updateApplicationStatus(idList: [id], status: "OK")
            )
            showSuccessAlert(message: "외출이 승인되었습니다")
            await refreshAcceptList()
        } catch {
            showErrorAlert(message: "외출 승인 실패")
        }
    }

    @MainActor
    public func rejectApplication(id: String) async {
        do {
            try await APIClient.shared.requestVoid(
                HomeAPI.updateApplicationStatus(idList: [id], status: "NO")
            )
            showSuccessAlert(message: "외출이 거절되었습니다")
            await refreshAcceptList()
        } catch {
            showErrorAlert(message: "외출 거절 실패")
        }
    }

    @MainActor
    public func acceptEarlyReturn(id: String) async {
        do {
            try await APIClient.shared.requestVoid(
                HomeAPI.updateEarlyReturnStatus(idList: [id], status: "OK")
            )
            showSuccessAlert(message: "조기귀가가 승인되었습니다")
            await refreshAcceptList()
        } catch {
            showErrorAlert(message: "조기귀가 승인 실패")
        }
    }

    @MainActor
    public func rejectEarlyReturn(id: String) async {
        do {
            try await APIClient.shared.requestVoid(
                HomeAPI.updateEarlyReturnStatus(idList: [id], status: "NO")
            )
            showSuccessAlert(message: "조기귀가가 거절되었습니다")
            await refreshAcceptList()
        } catch {
            showErrorAlert(message: "조기귀가 거절 실패")
        }
    }
    
    @MainActor
    private func refreshAcceptList() async {
        let components = classroom.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        if components.count >= 2, let grade = Int(components[0]), let classNum = Int(components[1]) {
            await fetchAcceptLists(grade: grade, classNum: classNum)
        }
    }

    @MainActor
    private func showSuccessAlert(message: String) {
        alertMessage = message
        alertSuccessType = true
        showAlert = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showAlert = false
        }
    }
    
    @MainActor
    private func showErrorAlert(message: String) {
        alertMessage = message
        alertSuccessType = false
        showAlert = true
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showAlert = false
        }
    }

    @MainActor
    public func dismissAlert() {
        showAlert = false
    }
}
