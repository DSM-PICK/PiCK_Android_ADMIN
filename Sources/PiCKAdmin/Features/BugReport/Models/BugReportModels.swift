import Foundation

// MARK: - Bug Report Request
struct BugReportRequest: Codable {
    let title: String
    let model: String
    let content: String
    let fileName: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case model
        case content
        case fileName = "file_name"
    }
}

// MARK: - Image Upload Response
struct ImageUploadResponse: Codable {
    let fileNames: [String]

    enum CodingKeys: String, CodingKey {
        case fileNames = "file_name"
    }
}
