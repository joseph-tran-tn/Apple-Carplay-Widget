import AppIntents
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
struct LuxSAConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Lux SA Clock"
    static var description = IntentDescription("Cá nhân hóa biển số Lux SA.")

    @Parameter(title: "Biển số", default: "LUX SA2.0")
    var plateText: String

    func personalization() -> CarPersonalization {
        var value = CarPersonalizationStore.load()
        value.plateText = plateText
        return value
    }
}
