import SwiftUI
import UIKit

/// Hero photo (default Lux SA or user upload) with custom plate overlay.
struct PersonalizedCarImage: View {
    let personalization: CarPersonalization
    /// Optional in-memory preview while picking a new photo (before Save).
    var previewPhoto: UIImage? = nil
    var alignment: Alignment = .bottom
    var showsPlate: Bool = true
    /// When set, the plate can be dragged; reports normalized (0...1) top-leading on the photo.
    var onPlateMove: ((Double, Double) -> Void)? = nil
    var onPlateDragEnded: (() -> Void)? = nil

    @State private var dragStartNormalized: CGPoint?

    private var isDraggable: Bool { onPlateMove != nil && !personalization.hidesPlate }

    private var shouldShowPlate: Bool { showsPlate && !personalization.hidesPlate }

    private var resolvedPhoto: UIImage? {
        if let previewPhoto { return previewPhoto }
        if personalization.usesCustomPhoto, let custom = CarPhotoStore.loadImage() {
            return custom
        }
        // Always resolve a UIImage so cover aspect matches the real asset (not a 1:1 fallback).
        return UIImage(named: "LuxSA")
    }

    var body: some View {
        GeometryReader { geo in
            let photo = resolvedPhoto
            let imageAspect: CGFloat = {
                if let photo, photo.size.height > 0 {
                    return photo.size.width / photo.size.height
                }
                return geo.size.width / max(geo.size.height, 1)
            }()
            // Cover the frame (object-fit: cover): image may extend past edges, then clipped.
            let covered = Self.coveredImageSize(
                container: geo.size,
                imageAspect: imageAspect
            )
            let origin = Self.alignedOrigin(
                container: geo.size,
                fitted: covered,
                alignment: alignment
            )
            let scale = CGFloat(personalization.plateScale)
            let plateSize = CGSize(
                width: max(18, covered.width * 0.11 * scale),
                height: max(6, covered.height * 0.028 * scale)
            )
            let plateOrigin = CGPoint(
                x: origin.x + covered.width * personalization.plateX,
                y: origin.y + covered.height * personalization.plateY
            )

            ZStack(alignment: .topLeading) {
                Color.black

                if let photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: covered.width, height: covered.height)
                        .offset(x: origin.x, y: origin.y)
                }

                if shouldShowPlate {
                    LicensePlateBadge(
                        text: personalization.normalizedPlate,
                        highlighted: isDraggable,
                        fontSize: max(7, plateSize.height * 0.72) + 4
                    )
                    .frame(width: plateSize.width, height: plateSize.height)
                    .contentShape(Rectangle())
                    .offset(x: plateOrigin.x, y: plateOrigin.y)
                    .modifier(PlateDragModifier(
                        enabled: isDraggable,
                        fitted: covered,
                        plateSize: plateSize,
                        currentX: personalization.plateX,
                        currentY: personalization.plateY,
                        dragStartNormalized: $dragStartNormalized,
                        onPlateMove: onPlateMove,
                        onPlateDragEnded: onPlateDragEnded
                    ))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }

    /// Size that fully covers `container` while keeping `imageAspect` (CSS `object-fit: cover`).
    private static func coveredImageSize(container: CGSize, imageAspect: CGFloat) -> CGSize {
        let containerAspect = container.width / max(container.height, 1)
        if containerAspect > imageAspect {
            let width = container.width
            return CGSize(width: width, height: width / imageAspect)
        } else {
            let height = container.height
            return CGSize(width: height * imageAspect, height: height)
        }
    }

    private static func alignedOrigin(
        container: CGSize,
        fitted: CGSize,
        alignment: Alignment
    ) -> CGPoint {
        let x: CGFloat
        switch alignment {
        case .leading, .topLeading, .bottomLeading:
            x = 0
        case .trailing, .topTrailing, .bottomTrailing:
            x = container.width - fitted.width
        default:
            x = (container.width - fitted.width) / 2
        }

        let y: CGFloat
        switch alignment {
        case .top, .topLeading, .topTrailing:
            y = 0
        case .bottom, .bottomLeading, .bottomTrailing:
            y = container.height - fitted.height
        default:
            y = (container.height - fitted.height) / 2
        }
        return CGPoint(x: x, y: y)
    }
}

private struct PlateDragModifier: ViewModifier {
    let enabled: Bool
    let fitted: CGSize
    let plateSize: CGSize
    let currentX: Double
    let currentY: Double
    @Binding var dragStartNormalized: CGPoint?
    var onPlateMove: ((Double, Double) -> Void)?
    var onPlateDragEnded: (() -> Void)?

    func body(content: Content) -> some View {
        if enabled {
            content.highPriorityGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        guard let onPlateMove else { return }
                        if dragStartNormalized == nil {
                            dragStartNormalized = CGPoint(x: currentX, y: currentY)
                        }
                        guard let start = dragStartNormalized else { return }
                        let maxX = Double(max((fitted.width - plateSize.width) / fitted.width, 0))
                        let maxY = Double(max((fitted.height - plateSize.height) / fitted.height, 0))
                        let nextX = start.x + Double(value.translation.width / fitted.width)
                        let nextY = start.y + Double(value.translation.height / fitted.height)
                        onPlateMove(min(max(nextX, 0), maxX), min(max(nextY, 0), maxY))
                    }
                    .onEnded { _ in
                        dragStartNormalized = nil
                        onPlateDragEnded?()
                    }
            )
        } else {
            content
        }
    }
}

/// Compact plate overlay — sizes to text + tight padding.
struct LicensePlateBadge: View {
    let text: String
    var highlighted: Bool = false
    var fontSize: CGFloat = 13

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .heavy, design: .rounded))
            .foregroundStyle(Color(red: 0.08, green: 0.08, blue: 0.10))
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .padding(.horizontal, 2.5)
            .padding(.vertical, 1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color(red: 0.94, green: 0.94, blue: 0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(
                        highlighted ? Color.orange.opacity(0.95) : Color.black.opacity(0.55),
                        lineWidth: highlighted ? 1.5 : 1
                    )
            )
            .shadow(color: .black.opacity(0.45), radius: 1, y: 0.5)
    }
}
