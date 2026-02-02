import Foundation
import SkipFuse
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let apiLogger = Logger(subsystem: "com.team.pick.admin", category: "APIClient")

// MARK: - API Error
public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case unauthorized
    case serverError(Int)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다"
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다"
        case .unauthorized:
            return "인증이 만료되었습니다. 다시 로그인해주세요"
        case .serverError(let code):
            return "서버 오류가 발생했습니다 (\(code))"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다"
        }
    }
}

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoint
public struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?
    let queryItems: [URLQueryItem]?
    let customBaseURL: String?

    public init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil,
        customBaseURL: String? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.queryItems = queryItems
        self.customBaseURL = customBaseURL
    }
}

// MARK: - API Client
public final class APIClient: @unchecked Sendable {
    public static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession

    private init() {
        self.baseURL = Secrets.apiBaseURL
        self.session = URLSession.shared
        apiLogger.info("🌐 APIClient initialized with baseURL: \(self.baseURL)")
    }

    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let rootURL = endpoint.customBaseURL ?? baseURL
        guard var urlComponents = URLComponents(string: rootURL + endpoint.path) else {
            apiLogger.info("❌ Invalid URL: \(rootURL + endpoint.path)")
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            apiLogger.info("❌ Failed to construct URL from components")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization if available
        if let token = JwtStore.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Custom headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Log request
        apiLogger.info("📤 REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")
        if let body = endpoint.body, let bodyString = String(data: body, encoding: .utf8) {
            apiLogger.info("📤 BODY: \(bodyString)")
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                apiLogger.info("❌ Invalid response type")
                throw APIError.invalidResponse
            }

            // Log response
            apiLogger.info("📥 RESPONSE: \(httpResponse.statusCode) \(url.absoluteString)")
            if let responseString = String(data: data, encoding: .utf8) {
                apiLogger.info("📥 DATA: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(T.self, from: data)
                    apiLogger.info("✅ SUCCESS: \(endpoint.path)")
                    return result
                } catch {
                    apiLogger.info("❌ Decoding error: \(error.localizedDescription)")
                    throw APIError.decodingError(error)
                }
            case 401:
                apiLogger.info("❌ Unauthorized (401)")
                throw APIError.unauthorized
            default:
                apiLogger.info("❌ Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            apiLogger.info("❌ Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    public func requestVoid(_ endpoint: APIEndpoint) async throws {
        let rootURL = endpoint.customBaseURL ?? baseURL
        guard var urlComponents = URLComponents(string: rootURL + endpoint.path) else {
            apiLogger.info("❌ Invalid URL: \(rootURL + endpoint.path)")
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            apiLogger.info("❌ Failed to construct URL from components")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = JwtStore.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Log request
        apiLogger.info("📤 REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                apiLogger.info("❌ Invalid response type")
                throw APIError.invalidResponse
            }

            // Log response
            apiLogger.info("📥 RESPONSE: \(httpResponse.statusCode) \(url.absoluteString)")
            if let responseString = String(data: data, encoding: .utf8) {
                apiLogger.info("📥 DATA: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                apiLogger.info("✅ SUCCESS: \(endpoint.path)")
                return
            case 401:
                apiLogger.info("❌ Unauthorized (401)")
                throw APIError.unauthorized
            default:
                apiLogger.info("❌ Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            apiLogger.info("❌ Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    public func requestString(_ endpoint: APIEndpoint) async throws -> String {
        let rootURL = endpoint.customBaseURL ?? baseURL
        guard var urlComponents = URLComponents(string: rootURL + endpoint.path) else {
            apiLogger.info("❌ Invalid URL: \(rootURL + endpoint.path)")
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            apiLogger.info("❌ Failed to construct URL from components")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization if available
        if let token = JwtStore.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Custom headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Log request
        apiLogger.info("📤 REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                apiLogger.info("❌ Invalid response type")
                throw APIError.invalidResponse
            }

            // Log response
            apiLogger.info("📥 RESPONSE: \(httpResponse.statusCode) \(url.absoluteString)")
            let responseString = String(data: data, encoding: .utf8) ?? ""
            apiLogger.info("📥 DATA: \(responseString)")

            switch httpResponse.statusCode {
            case 200...299:
                apiLogger.info("✅ SUCCESS: \(endpoint.path)")
                return responseString
            case 401:
                apiLogger.info("❌ Unauthorized (401)")
                throw APIError.unauthorized
            default:
                apiLogger.info("❌ Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            apiLogger.info("❌ Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Auth API
public struct AuthAPI {
    public static func signin(adminId: String, password: String, deviceToken: String = "") -> APIEndpoint {
        let body = try? JSONEncoder().encode(SigninRequest(
            adminId: adminId,
            password: password,
            deviceToken: deviceToken
        ))
        return APIEndpoint(
            path: "/admin/login",
            method: .post,
            body: body
        )
    }

    public static func signup(
        secretKey: String,
        accountId: String,
        password: String,
        name: String
    ) -> APIEndpoint {
        let body = try? JSONEncoder().encode(SignupRequest(
            secretKey: secretKey,
            accountId: accountId,
            password: password,
            name: name
        ))
        return APIEndpoint(
            path: "/admin/signup",
            method: .post,
            body: body
        )
    }

    public static func sendVerificationCode(accountId: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(["accountId": accountId])
        return APIEndpoint(
            path: "/admin/email/send",
            method: .post,
            body: body
        )
    }

    public static func verifyCode(accountId: String, code: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(["accountId": accountId, "code": code])
        return APIEndpoint(
            path: "/admin/email/verify",
            method: .post,
            body: body
        )
    }

    public static func refreshToken() -> APIEndpoint {
        return APIEndpoint(
            path: "/admin/refresh",
            method: .post,
            headers: ["Refresh-Token": JwtStore.shared.refreshToken ?? ""]
        )
    }

    public static func deleteAccount() -> APIEndpoint {
        return APIEndpoint(
            path: "/admin/delete",
            method: .delete
        )
    }
}

// MARK: - Request/Response Models
public struct SigninRequest: Codable {
    public let adminId: String
    public let password: String
    public let deviceToken: String

    enum CodingKeys: String, CodingKey {
        case adminId = "admin_id"
        case password
        case deviceToken = "device_token"
    }
}

public struct SigninResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
}

public struct SignupRequest: Codable {
    public let secretKey: String
    public let accountId: String
    public let password: String
    public let name: String
}

// MARK: - Home API
public struct HomeAPI {
    // MARK: Home / Self Study
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

    // MARK: Accept (Homeroom Teacher)
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

    // MARK: Monitor (Self Study Teacher)
    public static func getClassroomMoveByFloor(floor: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/classroom/floor",
            queryItems: [
                URLQueryItem(name: "floor", value: String(floor)),
                URLQueryItem(name: "status", value: "OK")
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

// MARK: - Plan API
public struct PlanAPI {
    public static func fetchAcademicScheduleByDate(date: String) -> APIEndpoint {
        return APIEndpoint(
            path: "/schedule/date",
            queryItems: [URLQueryItem(name: "date", value: date)]
        )
    }

    public static func fetchMonthAcademicSchedule(year: String, month: String) -> APIEndpoint {
        return APIEndpoint(
            path: "/schedule/month",
            queryItems: [
                URLQueryItem(name: "year", value: year),
                URLQueryItem(name: "month", value: month)
            ]
        )
    }
}

// MARK: - School Meal API
public struct SchoolMealAPI {
    static let neisBaseURL = "https://open.neis.go.kr/hub"
    static let neisAPIKey = "d7841b2039214f68b21eafc749ba196a"
    static let neisAtptOfcdcScCode = "G10"
    static let neisSdSchulCode = "7430310"

    public static func fetchSchoolMeal(date: String) -> APIEndpoint {
        let neisDate = date.replacingOccurrences(of: "-", with: "")
        return APIEndpoint(
            path: "/mealServiceDietInfo",
            queryItems: [
                URLQueryItem(name: "KEY", value: neisAPIKey),
                URLQueryItem(name: "Type", value: "json"),
                URLQueryItem(name: "pIndex", value: "1"),
                URLQueryItem(name: "pSize", value: "100"),
                URLQueryItem(name: "ATPT_OFCDC_SC_CODE", value: neisAtptOfcdcScCode),
                URLQueryItem(name: "SD_SCHUL_CODE", value: neisSdSchulCode),
                URLQueryItem(name: "MLSV_YMD", value: neisDate)
            ],
            customBaseURL: neisBaseURL
        )
    }
}

// MARK: - Admin API
public struct AdminAPI {
    public static func getMyName() -> APIEndpoint {
        return APIEndpoint(path: "/admin/my-name")
    }
}

public struct UpdateStatusRequest: Codable {
    public let status: String
    public let idList: [String]
    
    enum CodingKeys: String, CodingKey {
        case status
        case idList = "id_list"
    }
}
