import SwiftUI

// MARK: - Self Study Card
struct SelfStudyCard: View {
    let adminMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Date().koreanDateString())
                .pickText(type: .body2)
                .padding(.top, 14)
                .padding(.leading, 20)

            Spacer()

            Text(adminMessage.isEmpty ? "자습감독 정보를 불러오는 중입니다" : adminMessage)
                .pickText(type: .body1)
                .padding(.bottom, 14)
                .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}

// MARK: - Accordion View
struct AccordionView<Content: View>: View {
    @State var isExpanded: Bool = false
    let badge: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 8) {
                    Image("bottomArrow", bundle: .module)
                        .foregroundColor(.Normal.black)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    
                    Text(badge)
                        .pickText(type: .label1, textColor: .Primary.primary500)
                    
                    Text(title)
                        .pickText(type: .label1, textColor: .Normal.black)
                    
                    Spacer()
                }
                .padding(16)
                .background(Color.Normal.white)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(spacing: 0) {
                    content()
                }
                .padding(.bottom)
            }
        }
        .background(Color.Normal.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Accept Cell
struct AcceptCell: View {
    let studentNumber: String
    let name: String
    let type: OutgoingType
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            HStack(spacing: 8) {
                Text("\(studentNumber) \(name)")
                    .pickText(type: .heading3, textColor: .Normal.black)
                
                Text(type.title)
                    .pickText(type: .body2, textColor: .Primary.primary400)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .strokeBorder(Color.Primary.primary400, lineWidth: 1)
                    )
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onReject) {
                    Text("거절")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.Error.error)
                        .cornerRadius(8)
                }

                Button(action: onAccept) {
                    Text("승인")
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.Primary.primary500)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Gray.gray50)
        .cornerRadius(12)
    }
}

// MARK: - Outing Cell
struct OutingCell: View {
    let studentNumber: String
    let name: String
    let type: OutgoingType

    var body: some View {
        HStack(spacing: 2) {
            Text("\(studentNumber) \(name)")
                .pickText(type: .heading3, textColor: .Normal.black)

            Spacer()

            HStack(spacing: 8) {
                Button(action: {}) {
                    Text(type.title)
                        .pickText(type: .body2, textColor: .Normal.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(type == .outgoing ? Color.Primary.primary500 : Color.Primary.primary300)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.Gray.gray50)
        .cornerRadius(12)
    }
}

// MARK: - All Self Study Card
struct AllSelfStudyCard: View {
    let selfStudyDirector: [SelfStudyDirector]

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                if selfStudyDirector.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        Text("오늘은\n자습감독 선생님이 없습니다.")
                            .pickText(type: .body2, textColor: .Normal.black)
                        Spacer()
                    }
                    .padding(.leading, 20)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("오늘의 자습 감독 선생님 입니다")
                            .pickText(type: .body2)
                            .padding(.top, 27.5)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(selfStudyDirector, id: \.floor) {
                                director in
                                HStack(spacing: 16) {
                                    Text("\(director.floor)층")
                                        .pickText(type: .body2, textColor: .Primary.primary500)

                                    Text("\(director.teacherName) 선생님")
                                        .pickText(type: .button1, textColor: .Normal.black)
                                }
                            }
                        }
                        .padding(.top, 16)

                        Spacer()
                    }
                    .padding(.leading, 20)
                }

                Spacer()
            }

            HStack {
                Spacer()
                Image("calendar", bundle: .module)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 172)
        .background(Color.Gray.gray50)
        .cornerRadius(8)
    }
}
