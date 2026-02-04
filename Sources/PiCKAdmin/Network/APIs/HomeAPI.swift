import Foundation

public struct HomeAPI {
    // MARK: - Self Study
    public static func getSelfStudyDirector(date: String) -> APIEndpoint {
        return APIEndpoint(
            path: "/self-study/today",
            queryItems: [URLQueryItem(name: "date", value: date)]
        )
    }

    public static func getAdminSelfStudyInfo() -> APIEndpoint {
        return APIEndpoint(
            path: "/self-study/admin"
        )
    }

    public static func getSelfStudyAndClassroom() -> APIEndpoint {
        return APIEndpoint(
            path: "/admin/main"
        )
    }

    // MARK: - Application (Homeroom Teacher)
    public static func getApplicationsByGrade(grade: Int, classNum: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/application/grade",
            queryItems: [
                URLQueryItem(name: "grade", value: String(grade)),
                URLQueryItem(name: "class_num", value: String(classNum))
            ]
        )
    }

    public static func getEarlyReturnByGrade(grade: Int, classNum: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/early-return/grade",
            queryItems: [
                URLQueryItem(name: "grade", value: String(grade)),
                URLQueryItem(name: "class_num", value: String(classNum))
            ]
        )
    }

    public static func updateApplicationStatus(idList: [String], status: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(UpdateStatusRequest(status: status, idList: idList))
        return APIEndpoint(
            path: "/application/status",
            method: .patch,
            body: body
        )
    }

    public static func updateEarlyReturnStatus(idList: [String], status: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(UpdateStatusRequest(status: status, idList: idList))
        return APIEndpoint(
            path: "/early-return/status",
            method: .patch,
            body: body
        )
    }

    // MARK: - Classroom Move (Self Study Teacher)
    public static func getClassroomMoveByFloor(floor: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/class-room/floor",
            queryItems: [
                URLQueryItem(name: "floor", value: String(floor)),
                URLQueryItem(name: "status", value: "OK")
            ]
        )
    }

    public static func getClassroomMoveByClassroom(grade: Int, classNum: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/class-room/grade",
            queryItems: [
                URLQueryItem(name: "grade", value: String(grade)),
                URLQueryItem(name: "class_num", value: String(classNum))
            ]
        )
    }

    public static func getOutList(floor: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/application/floor",
            queryItems: [
                URLQueryItem(name: "floor", value: String(floor)),
                URLQueryItem(name: "status", value: "OK")
            ]
        )
    }

    public static func getEarlyReturnList(floor: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/early-return/floor",
            queryItems: [
                URLQueryItem(name: "floor", value: String(floor)),
                URLQueryItem(name: "status", value: "OK")
            ]
        )
    }
}
