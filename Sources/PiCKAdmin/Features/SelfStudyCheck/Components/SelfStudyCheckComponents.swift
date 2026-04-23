import SwiftUI

struct StudentAttendanceCell: View {
    let student: StudentAttendanceItem
    let onStatusTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(student.studentNumber)
                    .pickText(type: .body1, textColor: .Gray.gray600)
                    .frame(width: 50, alignment: .leading)

                Text(student.userName)
                    .pickText(type: .button1, textColor: .Normal.black)
            }

            Spacer()

            Button(action: onStatusTap) {
                Text(student.status)
                    .pickText(type: .body2, textColor: statusColor(student.status))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(statusBackgroundColor(student.status))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(statusBorderColor(student.status), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.Normal.white)
        .cornerRadius(8)
        .padding(.vertical, 4)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "출석":
            return .Normal.white
        case "이동":
            return .Normal.white
        case "귀가", "외출":
            return .Error.error
        case "현체", "취업":
            return .Gray.gray900
        default:
            return .Normal.black
        }
    }

    private func statusBackgroundColor(_ status: String) -> Color {
        switch status {
        case "출석":
            return .Primary.primary500
        case "이동":
            return .Gray.gray700
        case "귀가", "외출":
            return .Error.errorLight
        case "현체", "취업":
            return .Gray.gray200
        default:
            return .Gray.gray100
        }
    }

    private func statusBorderColor(_ status: String) -> Color {
        switch status {
        case "출석":
            return .Primary.primary500
        case "이동":
            return .Gray.gray700
        case "귀가", "외출":
            return .Error.error
        case "현체", "취업":
            return .Gray.gray600
        default:
            return .Gray.gray400
        }
    }
}
