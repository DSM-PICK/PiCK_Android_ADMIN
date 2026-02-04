import Foundation
import SwiftUI
import SkipFuse

private let bugReportLogger = Logger(subsystem: "com.team.pick.admin", category: "BugReport")

@MainActor
@Observable
final class BugReportViewModel {
    var bugLocation: String = ""
    var bugDescription: String = ""
    var selectedImages: [Data] = []
    var isSubmitting: Bool = false
    var showAlert: Bool = false
    var alertType: AlertType = .success
    var alertMessage: String = ""
    var shouldDismiss: Bool = false

    var isSubmitButtonEnabled: Bool {
        !bugLocation.isEmpty && !bugDescription.isEmpty
    }

    enum AlertType {
        case success
        case error
    }

    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }

    func addImage(_ imageData: Data) {
        if selectedImages.count < 3 {
            selectedImages.append(imageData)
        }
    }

    func submitBugReport() async {
        guard !bugLocation.isEmpty && !bugDescription.isEmpty else { return }

        isSubmitting = true

        do {
            var fileNames: [String] = []

            // Upload images first if any
            if !selectedImages.isEmpty {
                fileNames = try await uploadImages()
            }

            // Submit bug report
            try await submitReport(fileNames: fileNames)

            isSubmitting = false
            alertType = .success
            alertMessage = "버그 제보가 완료되었습니다"
            showAlert = true
            shouldDismiss = true

            // Reset form
            bugLocation = ""
            bugDescription = ""
            selectedImages = []

        } catch {
            bugReportLogger.error("Bug report submission failed: \(error.localizedDescription)")
            isSubmitting = false
            alertType = .error
            alertMessage = "버그 제보를 실패했어요"
            showAlert = true
        }
    }

    private func uploadImages() async throws -> [String] {
        let boundary = UUID().uuidString
        var bodyData = Data()

        for (index, imageData) in selectedImages.enumerated() {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            bodyData.append(imageData)
            bodyData.append("\r\n".data(using: .utf8)!)
        }
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let endpoint = BugReportAPI.uploadImages(boundary: boundary, body: bodyData)
        let response = try await APIClient.shared.request(endpoint, responseType: [String].self)
        return response
    }

    private func submitReport(fileNames: [String]) async throws {
        let endpoint = BugReportAPI.submitBugReport(
            title: bugLocation,
            content: bugDescription,
            fileNames: fileNames
        )
        try await APIClient.shared.requestVoid(endpoint)
    }

    func dismissAlert() {
        showAlert = false
    }
}
