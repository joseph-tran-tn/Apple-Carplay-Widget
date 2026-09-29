import SwiftUI
import UIKit

/// Shared hero scene used by the in-app preview and the Home Screen widget.
struct LuxSAHeroScene: View {
    let date: Date
    let personalization: CarPersonalization
    var previewPhoto: UIImage? = nil
    var clockTopPadding: CGFloat = 50
    var timeFontSize: CGFloat = 46
    var weekdayFontSize: CGFloat = 16
    var dateFontSize: CGFloat = 14
    /// When set, plate can be dragged (preview only).
    var onPlateMove: ((Double, Double) -> Void)? = nil
    var onPlateDragEnded: (() -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                PersonalizedCarImage(
                    personalization: personalization,
                    previewPhoto: previewPhoto,
                    alignment: .center,
                    onPlateMove: onPlateMove,
                    onPlateDragEnded: onPlateDragEnded
                )
                .frame(width: geo.size.width, height: geo.size.height)

                WidgetClockOverlay(
                    date: date,
                    timeFontSize: timeFontSize,
                    weekdayFontSize: weekdayFontSize,
                    dateFontSize: dateFontSize
                )
                .padding(.top, clockTopPadding)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

/// Flat white clock matching the in-app preview (shared with the widget).
struct WidgetClockOverlay: View {
    let date: Date
    var timeFontSize: CGFloat = 46
    var weekdayFontSize: CGFloat = 16
    var dateFontSize: CGFloat = 14

    private static let locale = Locale(identifier: "vi_VN")

    private var time: String { Self.format(date, "HH:mm") }
    private var weekday: String { Self.format(date, "EEEE") }
    private var day: String { Self.format(date, "dd/MM/yyyy") }

    var body: some View {
        VStack(spacing: 4) {
            Text(time)
                .font(.system(size: timeFontSize, weight: .bold, design: .rounded))
            Text(weekday)
                .font(.system(size: weekdayFontSize, weight: .semibold, design: .rounded))
            Text(day)
                .font(.system(size: dateFontSize, weight: .medium, design: .rounded))
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.55), radius: 2, y: 1)
    }

    private static func format(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
}
