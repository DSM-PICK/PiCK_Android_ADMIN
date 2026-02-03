import Foundation
import Observation
import SwiftUI

// MARK: - OutList Type
public enum OutListType: String, Equatable, Hashable {
    case outing = "외출"
    case earlyReturn = "조기귀가"
}

// MARK: - Models
public struct OutListStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: String
    public let end: String
    public let reason: String
}

public struct OutListEarlyReturnStudent: Identifiable, Hashable {
    public let id: String
    public let userName: String
    public let grade: Int
    public let classNum: Int
    public let num: Int
    public let start: String
    public let reason: String
}

// MARK: - DTOs
struct OutListOutingDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: String
    let end: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case end
        case reason
    }
}

struct OutListEarlyReturnDTO: Decodable {
    let id: String
    let userName: String
    let grade: Int
    let classNum: Int
    let num: Int
    let start: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case grade
        case classNum = "class_num"
        case num
        case start
        case reason
    }
}

// MARK: - ViewModel
@Observable
public final class OutListViewModel {
    public var outingItems: [OutListStudent] = []
    public var earlyReturnItems: [OutListEarlyReturnStudent] = []
    public var selectedIds: Set<String> = []
    public var isLoading: Bool = false
    
    public var currentType: OutListType = .outing
    public var currentFloor: Int = 5 // 5 means "All"
    
    public var showAlert: Bool = false
    public var alertMessage: String = ""
    public var alertSuccessType: Bool = true
    
    public init() {}
    
    @MainActor
    public func onAppear() async {
        await fetchData()
    }
    
    @MainActor
    public func fetchData() async {
        isLoading = true
        defer { isLoading = false }
        
        if currentType == .outing {
            await fetchOutList()
        } else {
            await fetchEarlyReturnList()
        }
    }
    
    @MainActor
    private func fetchOutList() async {
        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getOutList(floor: currentFloor),
                responseType: [OutListOutingDTO].self
            )
            
            self.outingItems = response.map { dto in
                OutListStudent(
                    id: dto.id,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    end: dto.end,
                    reason: dto.reason
                )
            }
        } catch {
            print("Failed to fetch out list: \(error)")
            self.outingItems = []
        }
    }
    
    @MainActor
    private func fetchEarlyReturnList() async {
        do {
            let response = try await APIClient.shared.request(
                HomeAPI.getEarlyReturnList(floor: currentFloor),
                responseType: [OutListEarlyReturnDTO].self
            )
            
            self.earlyReturnItems = response.map { dto in
                OutListEarlyReturnStudent(
                    id: dto.id,
                    userName: dto.userName,
                    grade: dto.grade,
                    classNum: dto.classNum,
                    num: dto.num,
                    start: dto.start,
                    reason: dto.reason
                )
            }
        } catch {
            print("Failed to fetch early return list: \(error)")
            self.earlyReturnItems = []
        }
    }
    
    @MainActor
    public func changeType(_ type: OutListType) async {
        currentType = type
        selectedIds = []
        await fetchData()
    }
    
    @MainActor
    public func changeFloor(_ floor: Int) async {
        currentFloor = floor
        selectedIds = []
        await fetchData()
    }
    
    public func toggleSelection(id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
    
    @MainActor
    public func returnStudents() async {
        let idList = Array(selectedIds)
        guard !idList.isEmpty else { return }
        
        isLoading = true
        
        do {
            try await APIClient.shared.requestVoid(
                OutListAPI.returnStudents(idList: idList)
            )
            
            showSuccessAlert(message: "\(idList.count)명의 학생이 복귀 처리되었습니다")
            selectedIds = []
            await fetchOutList()
            
        } catch {
            showErrorAlert(message: "복귀 처리에 실패했습니다")
        }
        
        isLoading = false
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
}

public struct OutListAPI {
    public static func returnStudents(idList: [String]) -> APIEndpoint {
        let body = try? JSONEncoder().encode(idList)
        return APIEndpoint(
            path: "/application/return",
            method: .patch,
            body: body
        )
    }
}