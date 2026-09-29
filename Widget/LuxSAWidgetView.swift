import SwiftUI
import WidgetKit

/// Full-bleed personalized Lux SA with embossed clock overlay.
struct LuxSAWidgetScene: View {
    let date: Date
    let personalization: CarPersonalization
    var family: WidgetFamily = .systemMedium

    /// Force-resolved personalization for rendering (host store → intent → default).
    private var resolvedPersonalization: CarPersonalization {
        CarPersonalizationStore.loadIfPresent() ?? personalization
    }

    private var clockTopPadding: CGFloat {
        switch family {
        case .systemSmall: return 8
        case .systemMedium: return 10
        case .systemLarge: return 50
        default: return 11
        }
    }

    private var timeFontSize: CGFloat {
        switch family {
        case .systemSmall: return 34
        case .systemMedium: return 44
        case .systemLarge: return 46
        default: return 40
        }
    }

    private var weekdayFontSize: CGFloat {
        switch family {
        case .systemSmall: return 13
        case .systemMedium: return 15
        case .systemLarge: return 16
        default: return 14
        }
    }

    private var dateFontSize: CGFloat {
        switch family {
        case .systemSmall: return 12
        case .systemMedium: return 13
        case .systemLarge: return 14
        default: return 13
        }
    }

    var body: some View {
        LuxSAHeroScene(
            date: date,
            personalization: resolvedPersonalization,
            clockTopPadding: clockTopPadding,
            timeFontSize: timeFontSize,
            weekdayFontSize: weekdayFontSize,
            dateFontSize: dateFontSize
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LuxSAWidgetView: View {
    var entry: LuxSAEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(inlineClockText)
        case .accessoryRectangular:
            accessoryLayout
        default:
            LuxSAWidgetScene(
                date: entry.date,
                personalization: entry.personalization,
                family: family
            )
        }
    }

    private var accessoryLayout: some View {
        HStack(spacing: 8) {
            PersonalizedCarImage(
                personalization: entry.personalization,
                alignment: .center,
                showsPlate: false
            )
            .frame(width: 40, height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            WidgetClockOverlay(
                date: entry.date,
                timeFontSize: 16,
                weekdayFontSize: 11,
                dateFontSize: 10
            )
            .scaleEffect(0.85, anchor: .leading)
        }
    }

    private var inlineClockText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "HH:mm EEE dd/MM"
        return formatter.string(from: entry.date)
    }
}

#if DEBUG
struct LuxSAWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LuxSAWidgetScene(
                date: Date(),
                personalization: .default,
                family: .systemMedium
            )
            .containerBackground(for: .widget) {
                LuxSAWidgetScene(
                    date: Date(),
                    personalization: .default,
                    family: .systemMedium
                )
            }
            .previewContext(WidgetPreviewContext(family: .systemMedium))

            LuxSAWidgetScene(
                date: Date(),
                personalization: CarPersonalization(plateText: "30A-5689"),
                family: .systemLarge
            )
            .containerBackground(for: .widget) {
                LuxSAWidgetScene(
                    date: Date(),
                    personalization: CarPersonalization(plateText: "30A-5689"),
                    family: .systemLarge
                )
            }
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
#endif
