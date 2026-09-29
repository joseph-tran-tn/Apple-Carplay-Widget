import WidgetKit
import Foundation

struct LuxSAEntry: TimelineEntry {
    let date: Date
    let personalization: CarPersonalization
}

struct LuxSATimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> LuxSAEntry {
        LuxSAEntry(date: Date(), personalization: .default)
    }

    func snapshot(
        for configuration: LuxSAConfigurationIntent,
        in context: Context
    ) async -> LuxSAEntry {
        LuxSAEntry(date: Date(), personalization: resolved(configuration))
    }

    func timeline(
        for configuration: LuxSAConfigurationIntent,
        in context: Context
    ) async -> Timeline<LuxSAEntry> {
        let calendar = Calendar.current
        let now = Date()
        let personalization = resolved(configuration)
        var entries: [LuxSAEntry] = []

        let startOfMinute = calendar.dateInterval(of: .minute, for: now)?.start ?? now
        for offset in 0..<60 {
            if let date = calendar.date(byAdding: .minute, value: offset, to: startOfMinute) {
                entries.append(LuxSAEntry(date: date, personalization: personalization))
            }
        }

        let nextUpdate = calendar.date(byAdding: .minute, value: 60, to: startOfMinute)
            ?? now.addingTimeInterval(3600)
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }

    /// Prefer values saved in the host app (Save button). Fall back to Edit Widget.
    private func resolved(_ configuration: LuxSAConfigurationIntent) -> CarPersonalization {
        if let stored = CarPersonalizationStore.loadIfPresent() {
            return stored
        }
        return configuration.personalization()
    }
}
