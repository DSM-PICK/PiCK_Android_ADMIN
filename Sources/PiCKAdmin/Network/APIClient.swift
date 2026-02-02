import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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

    public init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.queryItems = queryItems
    }
}

// MARK: - API Client
public final class APIClient: @unchecked Sendable {
    public static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession

    private init() {
        // TODO: Replace with actual API base URL
        self.baseURL = "https://api.pick.dsm.hs.kr"
        self.session = URLSession.shared
    }

    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
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

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    public func requestVoid(_ endpoint: APIEndpoint) async throws {
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
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

        do {
            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Auth API
public struct AuthAPI {
    public static func signin(email: String, password: String) -> APIEndpoint {
        let body = try? JSONEncoder().encode(SigninRequest(accountId: email, password: password))
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
}

// MARK: - Request/Response Models
public struct SigninRequest: Codable {
    public let accountId: String
    public let password: String
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
