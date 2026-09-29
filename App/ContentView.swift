import SwiftUI
import PhotosUI
import WidgetKit
import UIKit

struct ContentView: View {
    /// Width / height for Home Screen Large–like preview (~1 : 1.05).
    private static let widgetPreviewAspectRatio: CGFloat = 1.0 / 1.05

    @State private var personalization = CarPersonalizationStore.load()
    @State private var savedSnapshot = CarPersonalizationStore.load()
    @State private var showSaveBanner = false
    @State private var saveMessage = ""
    @State private var isDraggingPlate = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isPhotoPickerPresented = false
    @State private var pendingPhotoData: Data?
    @State private var previewPhoto: UIImage?
    @State private var wantsDefaultPhoto = false
    @FocusState private var plateFocused: Bool

    private var hasUnsavedChanges: Bool {
        personalization.normalizedPlate != savedSnapshot.normalizedPlate
            || abs(personalization.plateX - savedSnapshot.plateX) > 0.0005
            || abs(personalization.plateY - savedSnapshot.plateY) > 0.0005
            || abs(personalization.plateScale - savedSnapshot.plateScale) > 0.0005
            || personalization.hidesPlate != savedSnapshot.hidesPlate
            || pendingPhotoData != nil
            || wantsDefaultPhoto
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background
                    .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 22) {
                            previewCard
                            plateSection
                            photoSection
                                .id("photoSection")
                            hint
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .padding(.bottom, 24)
                    }
                    .scrollDisabled(isDraggingPlate)
                    .onAppear {
                        if ProcessInfo.processInfo.environment["SCROLL_TO_PHOTO"] == "1" {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                withAnimation {
                                    proxy.scrollTo("photoSection", anchor: .top)
                                }
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack(spacing: 12) {
                        Text("Cá nhân hóa widget")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(hasUnsavedChanges ? "Lưu" : "Đã lưu", action: saveAndApply)
                            .fontWeight(.semibold)
                            .modifier(SystemPrimaryButtonChrome())
                            .controlSize(.regular)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                }

                if showSaveBanner {
                    VStack {
                        Text(saveMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.top, 12)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .allowsHitTesting(false)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            let loaded = CarPersonalizationStore.load()
            personalization = loaded
            savedSnapshot = loaded
            previewPhoto = loaded.usesCustomPhoto ? CarPhotoStore.loadImage() : nil
            pendingPhotoData = nil
            wantsDefaultPhoto = false
        }
        .onChange(of: photoPickerItem) { _, item in
            Task {
                guard let item else { return }
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    pendingPhotoData = data
                    previewPhoto = image
                    wantsDefaultPhoto = false
                    personalization.usesCustomPhoto = true
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.04, blue: 0.08),
                Color(red: 0.14, green: 0.03, blue: 0.06),
                Color(red: 0.04, green: 0.04, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Xem trước widget")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if hasUnsavedChanges {
                    Text("Chưa lưu")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.orange.opacity(0.95))
                }
            }

            ZStack {
                LuxSAHeroScene(
                    date: Date(),
                    personalization: personalization,
                    previewPhoto: previewPhoto,
                    clockTopPadding: 50,
                    timeFontSize: 46,
                    weekdayFontSize: 16,
                    dateFontSize: 14,
                    onPlateMove: personalization.hidesPlate ? nil : { x, y in
                        isDraggingPlate = true
                        personalization.plateX = x
                        personalization.plateY = y
                    },
                    onPlateDragEnded: personalization.hidesPlate ? nil : {
                        isDraggingPlate = false
                    }
                )
            }
            // Home Screen Large is slightly taller than square (~width:height = 1:1.05).
            .aspectRatio(Self.widgetPreviewAspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .onAppear(perform: exportLargeWidgetSnapshot)

            if !personalization.hidesPlate {
                HStack {
                    Text("Kéo biển số (viền cam) để đặt đúng vị trí trên xe.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    Button("Đặt lại") {
                        personalization.plateX = CarPersonalization.defaultPlateX
                        personalization.plateY = CarPersonalization.defaultPlateY
                    }
                    .modifier(SystemSecondaryButtonChrome())
                    .controlSize(.small)
                }
            }
        }
    }

    private var plateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Biển số")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            Toggle("Ẩn biển số", isOn: $personalization.hidesPlate)
                .tint(.accentColor)

            if !personalization.hidesPlate {
                TextField("VD: 30A-12345", text: $personalization.plateText)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($plateFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(.white)
                    .onChange(of: personalization.plateText) { _, value in
                        let filtered = String(value.uppercased().prefix(12))
                        if filtered != value {
                            personalization.plateText = filtered
                        }
                    }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Cỡ biển số")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                        Spacer()
                        Text("\(Int((personalization.plateScale * 100).rounded()))%")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Slider(
                        value: $personalization.plateScale,
                        in: CarPersonalization.minPlateScale...CarPersonalization.maxPlateScale,
                        step: 0.05
                    )
                    .tint(.accentColor)
                }

                Text("Tối đa 12 ký tự. Widget sẽ phủ biển gốc trên ảnh.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            } else {
                Text("Biển số tùy chỉnh sẽ không hiện trên widget.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ảnh cá nhân")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            GeometryReader { geo in
                let thumbSide = geo.size.width * 0.3
                HStack(alignment: .center, spacing: 14) {
                    Color.black
                        .overlay {
                            Group {
                                if let previewPhoto {
                                    Image(uiImage: previewPhoto)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image("LuxSA")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(width: thumbSide, height: thumbSide)
                            .clipped()
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: thumbSide, height: thumbSide)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            isPhotoPickerPresented = true
                        } label: {
                            Label("Chọn ảnh…", systemImage: "photo.on.rectangle.angled")
                        }
                        .modifier(SystemSecondaryButtonChrome())
                        .controlSize(.regular)
                        .photosPicker(
                            isPresented: $isPhotoPickerPresented,
                            selection: $photoPickerItem,
                            matching: .images
                        )

                        if personalization.usesCustomPhoto || previewPhoto != nil {
                            Button("Dùng ảnh Lux SA mặc định") {
                                pendingPhotoData = nil
                                previewPhoto = nil
                                photoPickerItem = nil
                                wantsDefaultPhoto = true
                                personalization.usesCustomPhoto = false
                            }
                            .buttonStyle(.borderless)
                            .controlSize(.small)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: geo.size.width, height: thumbSide, alignment: .center)
            }
            .aspectRatio(1 / 0.3, contentMode: .fit) // height = 30% of width for 1:1 thumb

            Text("Ảnh sẽ hiển thị full trên widget sau khi nhấn Lưu.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hint: some View {
        VStack(spacing: 6) {
            if hasUnsavedChanges {
                Text("Có thay đổi chưa lưu — nhấn Lưu góc trên phải.")
                    .font(.caption)
                    .foregroundStyle(.orange.opacity(0.9))
            }
            Text("Chọn ảnh cá nhân, ẩn/hiện biển số, rồi nhấn Lưu.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.55))
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .padding(.bottom, 24)
    }

    private func exportLargeWidgetSnapshot() {
        // iPhone Large-ish points; 3x for a crisp compare asset.
        let width: CGFloat = 338
        let height = width / Self.widgetPreviewAspectRatio
        let scene = LuxSAHeroScene(
            date: Date(),
            personalization: personalization,
            previewPhoto: previewPhoto,
            clockTopPadding: 50,
            timeFontSize: 46,
            weekdayFontSize: 16,
            dateFontSize: 14
        )
        .frame(width: width, height: height)

        let renderer = ImageRenderer(content: scene)
        renderer.scale = 3
        guard let image = renderer.uiImage, let data = image.pngData() else { return }
        let url = URL(fileURLWithPath: "/tmp/com.vinfast.widget-large-snapshot.png")
        try? data.write(to: url, options: .atomic)
    }

    private func saveAndApply() {
        plateFocused = false
        isDraggingPlate = false
        personalization.plateText = personalization.normalizedPlate
        personalization.clampPlatePosition()

        if wantsDefaultPhoto {
            CarPhotoStore.clear()
            personalization.usesCustomPhoto = false
            previewPhoto = nil
        } else if let pendingPhotoData {
            _ = CarPhotoStore.save(imageData: pendingPhotoData)
            personalization.usesCustomPhoto = true
            previewPhoto = UIImage(data: pendingPhotoData) ?? previewPhoto
        }

        pendingPhotoData = nil
        wantsDefaultPhoto = false
        photoPickerItem = nil

        _ = CarPersonalizationStore.save(personalization)
        savedSnapshot = personalization

        WidgetCenter.shared.reloadTimelines(ofKind: "LuxSAWidget")
        WidgetCenter.shared.reloadAllTimelines()

        saveMessage = "Đã lưu — widget đang cập nhật"
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            showSaveBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.25)) {
                showSaveBanner = false
            }
        }
    }
}




/// Uses the system Liquid Glass button styles on iOS 26+; bordered styles otherwise.
private struct SystemPrimaryButtonChrome: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
    }
}

private struct SystemSecondaryButtonChrome: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
    }
}

#Preview {
    ContentView()
}
