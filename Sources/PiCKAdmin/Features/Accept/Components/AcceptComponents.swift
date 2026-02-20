import SwiftUI

struct AcceptStudentCell: View {
    let studentNumber: String
    let studentName: String
    let startTime: String
    let endTime: String
    let activityType: String
    let reason: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text("\(studentNumber) \(studentName)")
                        .pickText(type: .button1, textColor: .Normal.black)
                        .lineLimit(1)

                    if !endTime.isEmpty {
                        Text("\(startTime) - \(endTime)")
                            .pickText(type: .body2, textColor: .Gray.gray700)
                            .lineLimit(1)
                    } else {
                        Text(startTime)
                            .pickText(type: .body2, textColor: .Gray.gray700)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(activityType)
                        .pickText(type: .caption1, textColor: .Primary.primary500)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            Capsule()
                                .stroke(Color.Primary.primary500, lineWidth: 1)
                        )
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                Text(reason)
                    .pickText(type: .body2, textColor: .Gray.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Gray.gray50)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.Primary.primary500 : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AcceptClassroomMoveCell: View {
    let studentNumber: String
    let studentName: String
    let startPeriod: Int
    let endPeriod: Int
    let currentClassroom: String
    let moveToClassroom: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text("\(studentNumber) \(studentName)")
                        .pickText(type: .button1, textColor: .Normal.black)

                    Text("\(startPeriod)교시 - \(endPeriod)교시")
                        .pickText(type: .body2, textColor: .Gray.gray900)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                HStack(spacing: 8) {
                    Text(currentClassroom)
                        .pickText(type: .body1, textColor: .Normal.black)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                        .foregroundColor(.Normal.black)

                    Text(moveToClassroom)
                        .pickText(type: .body1, textColor: .Normal.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.Primary.primary300)
                        .cornerRadius(14)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.Gray.gray50)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.Primary.primary500 : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
