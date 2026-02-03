import SwiftUI
#if canImport(PhotosUI)
import PhotosUI
#endif

struct BugReportView: View {
    var router: AppRouter
    @State var viewModel = BugReportViewModel()
    @FocusState var isDescriptionFocused: Bool

    #if canImport(PhotosUI)
    @State var selectedItems: [PhotosPickerItem] = []
    #endif

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    formContent
                }

                submitButton
            }
            .background(Color.Gray.gray50)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.Normal.black)
                            .font(.system(size: 20))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("버그 제보")
                        .pickText(type: .body1, textColor: .Normal.black)
                }
            }

            if viewModel.showAlert {
                alertOverlay
            }
        }
    }

    // MARK: - Form Content
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            bugLocationField
            bugDescriptionTextView
            bugImageSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    // MARK: - Bug Location Field
    private var bugLocationField: some View {
        PiCKTextField(
            text: $viewModel.bugLocation,
            placeholder: "예: 메인, 외출 신청",
            titleText: "어디서 버그가 발생했나요?"
        )
    }

    // MARK: - Bug Description TextView
    private var bugDescriptionTextView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("버그에 대해 설명해주세요")
                .pickText(type: .label1, textColor: .Normal.black)

            TextField("자세히 입력해주세요", text: $viewModel.bugDescription)
                .font(.system(size: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.Gray.gray50)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isDescriptionFocused ? Color.Primary.primary500 : .clear, lineWidth: 1)
                )
                .focused($isDescriptionFocused)
        }
    }

    // MARK: - Bug Image Section
    private var bugImageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("버그 사진을 첨부해주세요")
                .pickText(type: .label1, textColor: .Normal.black)

            #if canImport(PhotosUI)
            if viewModel.selectedImages.isEmpty {
                photosPickerButton(hasImages: false)
            } else {
                HStack(spacing: 12) {
                    photosPickerButton(hasImages: true)
                    selectedImagesScrollView
                }
            }
            #else
            imagePlaceholder
            #endif
        }
    }

    #if canImport(PhotosUI)
    private func photosPickerButton(hasImages: Bool) -> some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 3,
            matching: .images
        ) {
            if hasImages {
                imageButtonContent
            } else {
                emptyImageButtonContent
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            handleImageSelection(newItems: newItems)
        }
    }

    private func handleImageSelection(newItems: [PhotosPickerItem]) {
        Task {
            var images: [Data] = []
            for item in newItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    images.append(data)
                }
            }
            await MainActor.run {
                viewModel.selectedImages = images
            }
        }
    }

    private var selectedImagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, imageData in
                    imagePreview(imageData: imageData, index: index)
                }
            }
        }
    }

    private func imagePreview(imageData: Data, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let image = dataToImage(imageData) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.Gray.gray200)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button(action: {
                viewModel.removeImage(at: index)
                if index < selectedItems.count {
                    selectedItems.remove(at: index)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .padding(4)
        }
    }

    private func dataToImage(_ data: Data) -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
    #endif

    private var imageButtonContent: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 28, height: 28)
            .foregroundColor(.Gray.gray600)
            .frame(width: 100, height: 100)
            .background(Color.Gray.gray50)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.Gray.gray600, style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
    }

    private var emptyImageButtonContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.Gray.gray600)

            Text("사진을 첨부해주세요.")
                .pickText(type: .caption2, textColor: .Gray.gray500)

            Spacer()
        }
        .padding(.top, 22)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color.Gray.gray50)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.Gray.gray600, style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
    }

    private var imagePlaceholder: some View {
        emptyImageButtonContent
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        PiCKButton(
            buttonText: viewModel.isSubmitting ? "제보 중..." : "제보하기",
            isEnabled: viewModel.isSubmitButtonEnabled && !viewModel.isSubmitting,
            action: {
                Task {
                    await viewModel.submitBugReport()
                }
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    // MARK: - Alert Overlay
    private var alertOverlay: some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: viewModel.alertType == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(viewModel.alertType == .success ? .Primary.primary500 : .Error.error)

                Text(viewModel.alertMessage)
                    .pickText(type: .body1, textColor: .Normal.black)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.Normal.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .zIndex(999)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    viewModel.dismissAlert()
                    if viewModel.shouldDismiss {
                        router.pop()
                    }
                }
            }
        }
    }
}
