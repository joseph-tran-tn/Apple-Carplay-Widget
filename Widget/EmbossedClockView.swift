import SwiftUI

/// Layered emboss: highlight + shadow + fill (no third-party libraries).
struct EmbossedClockView: View {
    let date: Date
    var compact: Bool = false
    var timeFontSize: CGFloat? = nil

    private static let locale = Locale(identifier: "vi_VN")

    private var resolvedTimeSize: CGFloat {
        timeFontSize ?? (compact ? 34 : 52)
    }

    private var timeText: String {
        Self.format(date, "HH:mm")
    }

    private var weekdayText: String {
        // e.g. "Thứ Ba"
        Self.format(date, "EEEE")
    }

    private var dateText: String {
        Self.format(date, "dd/MM/yyyy")
    }

    var body: some View {
        VStack(spacing: compact ? 2 : 6) {
            EmbossedText(
                text: timeText,
                font: .system(
                    size: resolvedTimeSize,
                    weight: .bold,
                    design: .rounded
                )
            )
            EmbossedText(
                text: weekdayText,
                font: .system(
                    size: compact ? 13 : 18,
                    weight: .semibold,
                    design: .rounded
                )
            )
            EmbossedText(
                text: dateText,
                font: .system(
                    size: compact ? 12 : 16,
                    weight: .medium,
                    design: .rounded
                )
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(timeText), \(weekdayText), \(dateText)")
    }

    private static func format(_ date: Date, _ template: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.setLocalizedDateFormatFromTemplate(template)
        // Prefer fixed patterns for stable HH:mm and dd/MM/yyyy.
        switch template {
        case "HH:mm":
            formatter.dateFormat = "HH:mm"
        case "dd/MM/yyyy":
            formatter.dateFormat = "dd/MM/yyyy"
        case "EEEE":
            formatter.dateFormat = "EEEE"
        default:
            break
        }
        return formatter.string(from: date)
    }
}

private struct EmbossedText: View {
    let text: String
    let font: Font

    private let fill = Color(red: 0.92, green: 0.93, blue: 0.96)
    private let highlight = Color.white.opacity(0.85)
    private let shadow = Color.black.opacity(0.65)

    var body: some View {
        ZStack {
            // Deep shadow (bottom-right)
            Text(text)
                .font(font)
                .foregroundStyle(shadow)
                .offset(x: 1.4, y: 1.6)
                .blur(radius: 0.4)

            // Soft ambient shadow
            Text(text)
                .font(font)
                .foregroundStyle(Color.black.opacity(0.35))
                .offset(x: 0.6, y: 2.2)
                .blur(radius: 1.2)

            // Highlight (top-left)
            Text(text)
                .font(font)
                .foregroundStyle(highlight)
                .offset(x: -1.1, y: -1.2)

            // Base fill
            Text(text)
                .font(font)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            fill,
                            Color(red: 0.72, green: 0.74, blue: 0.80)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}

#Preview("Embossed Clock") {
    ZStack {
        Color.black
        EmbossedClockView(date: Date())
    }
}
