import Foundation
import SkipFuse
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let apiLogger = Logger(subsystem: "com.team.pick.admin", category: "APIClient")

public final class APIClient: @unchecked Sendable {
    public static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession

    private init() {
        self.baseURL = Secrets.apiBaseURL
        self.session = URLSession.shared
        apiLogger.info("APIClient initialized with baseURL: \(self.baseURL)")
    }

    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let rootURL = endpoint.customBaseURL ?? baseURL
        guard var urlComponents = URLComponents(string: rootURL + endpoint.path) else {
            apiLogger.info("Invalid URL: \(rootURL + endpoint.path)")
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            apiLogger.info("Failed to construct URL from components")
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

        apiLogger.info("REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")
        if let body = endpoint.body, let bodyString = String(data: body, encoding: .utf8) {
            apiLogger.info("BODY: \(bodyString)")
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                apiLogger.info("Invalid response type")
                throw APIError.invalidResponse
            }

            apiLogger.info("RESPONSE: \(httpResponse.statusCode) \(url.absoluteString)")
            if let responseString = String(data: data, encoding: .utf8) {
                apiLogger.info("DATA: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(T.self, from: data)
                    apiLogger.info("SUCCESS: \(endpoint.path)")
                    return result
                } catch {
                    apiLogger.info("Decoding error: \(error.localizedDescription)")
                    throw APIError.decodingError(error)
                }
            case 401:
                apiLogger.info("Unauthorized (401)")
                throw APIError.unauthorized
            default:
                apiLogger.info("Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            apiLogger.info("Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    public func requestVoid(_ endpoint: APIEndpoint) async throws {
        let rootURL = endpoint.customBaseURL ?? baseURL
        guard var urlComponents = URLComponents(string: rootURL + endpoint.path) else {
            apiLogger.info("Invalid URL: \(rootURL + endpoint.path)")
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            apiLogger.info("Failed to construct URL from components")
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

        apiLogger.info("REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                apiLogger.info("Invalid response type")
                throw APIError.invalidResponse
            }

            apiLogger.info("RESPONSE: \(httpResponse.statusCode) \(url.absoluteString)")
            if let responseString = String(data: data, encoding: .utf8) {
                apiLogger.info("DATA: \(responseString)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                apiLogger.info("SUCCESS: \(endpoint.path)")
                return
            case 401:
                apiLogger.info("Unauthorized (401)")
                throw APIError.unauthorized
            default:
                apiLogger.info("Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            apiLogger.info("Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    public func requestString(_ endpoint: APIEndpoint) async throws -> String {
        let rootURL = endpoint.customBaseURL ?? baseURL
        guard var urlComponents = URLComponents(string: rootURL + endpoint.path) else {
            apiLogger.info("Invalid URL: \(rootURL + endpoint.path)")
            throw APIError.invalidURL
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            apiLogger.info("Failed to construct URL from components")
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

        apiLogger.info("REQUEST: \(endpoint.method.rawValue) \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                apiLogger.info("Invalid response type")
                throw APIError.invalidResponse
            }

            apiLogger.info("RESPONSE: \(httpResponse.statusCode) \(url.absoluteString)")
            let responseString = String(data: data, encoding: .utf8) ?? ""
            apiLogger.info("DATA: \(responseString)")

            switch httpResponse.statusCode {
            case 200...299:
                apiLogger.info("SUCCESS: \(endpoint.path)")
                return responseString
            case 401:
                apiLogger.info("Unauthorized (401)")
                throw APIError.unauthorized
            default:
                apiLogger.info("Server error: \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            apiLogger.info("Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }
}
