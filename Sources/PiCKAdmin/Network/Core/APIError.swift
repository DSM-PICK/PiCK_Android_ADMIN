import Foundation

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
