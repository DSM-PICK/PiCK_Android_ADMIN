import SwiftUI

// MARK: - Student Attendance Cell
struct StudentAttendanceCell: View {
    let student: StudentAttendanceItem
    let onStatusTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Student Number & Name
            HStack(spacing: 8) {
                Text(student.studentNumber)
                    .pickText(type: .body1, textColor: .Gray.gray600)
                    .frame(width: 50, alignment: .leading)

                Text(student.userName)
                    .pickText(type: .button1, textColor: .Normal.black)
            }

            Spacer()

            // Status Button
            Button(action: onStatusTap) {
                Text(student.status)
                    .pickText(type: .body2, textColor: statusColor(student.status))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(statusBackgroundColor(student.status))
                    .cornerRadius(8)
            }
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
            return .Primary.primary500
        case "이동":
            return .Gray.gray700
        case "귀가", "외출":
            return .Primary.primary400
        case "현체", "취업":
            return .Gray.gray600
        default:
            return .Normal.black
        }
    }

    private func statusBackgroundColor(_ status: String) -> Color {
        switch status {
        case "출석":
            return .Primary.primary50
        case "이동":
            return .Gray.gray100
        case "귀가", "외출":
            return .Primary.primary50.opacity(0.5)
        case "현체", "취업":
            return .Gray.gray100
        default:
            return .Gray.gray100
        }
    }
}
