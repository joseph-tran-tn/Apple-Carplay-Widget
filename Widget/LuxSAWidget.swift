import WidgetKit
import SwiftUI

struct LuxSAWidget: Widget {
    let kind: String = "LuxSAWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LuxSAConfigurationIntent.self,
            provider: LuxSATimelineProvider()
        ) { entry in
            FamilyAwareWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lux SA Clock")
        .description("VinFast Lux SA with Vietnamese clock, custom plate and personal photo.")
        .supportedFamilies(Self.carPlayOrientedFamilies)
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }

    private static var carPlayOrientedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [
            .systemSmall,
            .systemMedium,
            .systemLarge
        ]
        if #available(iOSApplicationExtension 16.0, *) {
            families.append(contentsOf: [.accessoryRectangular, .accessoryInline])
        }
        return families
    }
}

/// Reads the real widget family from the environment and renders the shared hero scene.
/// No negative edge bleed — cover crop must match the in-app preview frame.
private struct FamilyAwareWidgetEntryView: View {
    let entry: LuxSAEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        LuxSAWidgetScene(
            date: entry.date,
            personalization: entry.personalization,
            family: family
        )
        .containerBackground(for: .widget) {
            LuxSAWidgetScene(
                date: entry.date,
                personalization: entry.personalization,
                family: family
            )
        }
    }
}
