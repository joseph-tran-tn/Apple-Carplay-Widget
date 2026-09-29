import SwiftUI
import UIKit

/// Shared plate preferences for the host app and widget.
struct CarPersonalization: Equatable, Codable {
    var plateText: String
    /// Plate top-leading corner as fraction of the fitted photo (0...1).
    var plateX: Double
    var plateY: Double
    /// Multiplier for plate overlay size (0.5...2.0).
    var plateScale: Double
    /// When true, render the user-uploaded photo instead of the default Lux SA asset.
    var usesCustomPhoto: Bool
    /// When true, hide the custom plate overlay on preview and widget.
    var hidesPlate: Bool

    static let defaultPlateX: Double = 0.355
    static let defaultPlateY: Double = 0.615
    static let defaultPlateScale: Double = 1.0
    static let minPlateScale: Double = 0.5
    static let maxPlateScale: Double = 2.0

    static let `default` = CarPersonalization(
        plateText: "LUX SA2.0",
        plateX: defaultPlateX,
        plateY: defaultPlateY,
        plateScale: defaultPlateScale,
        usesCustomPhoto: false,
        hidesPlate: false
    )

    init(
        plateText: String,
        plateX: Double = Self.defaultPlateX,
        plateY: Double = Self.defaultPlateY,
        plateScale: Double = Self.defaultPlateScale,
        usesCustomPhoto: Bool = false,
        hidesPlate: Bool = false
    ) {
        self.plateText = plateText
        self.plateX = min(max(plateX, 0), 1)
        self.plateY = min(max(plateY, 0), 1)
        self.plateScale = Self.clampedScale(plateScale)
        self.usesCustomPhoto = usesCustomPhoto
        self.hidesPlate = hidesPlate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plateText = try container.decode(String.self, forKey: .plateText)
        plateX = try container.decodeIfPresent(Double.self, forKey: .plateX) ?? Self.defaultPlateX
        plateY = try container.decodeIfPresent(Double.self, forKey: .plateY) ?? Self.defaultPlateY
        plateScale = Self.clampedScale(
            try container.decodeIfPresent(Double.self, forKey: .plateScale) ?? Self.defaultPlateScale
        )
        usesCustomPhoto = try container.decodeIfPresent(Bool.self, forKey: .usesCustomPhoto) ?? false
        hidesPlate = try container.decodeIfPresent(Bool.self, forKey: .hidesPlate) ?? false
    }

    private enum CodingKeys: String, CodingKey {
        case plateText, plateX, plateY, plateScale, usesCustomPhoto, hidesPlate
    }

    var normalizedPlate: String {
        let trimmed = plateText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        return trimmed.isEmpty ? Self.default.plateText : String(trimmed.prefix(12))
    }

    mutating func clampPlatePosition() {
        plateX = min(max(plateX, 0), 1)
        plateY = min(max(plateY, 0), 1)
        plateScale = Self.clampedScale(plateScale)
    }

    static func clampedScale(_ value: Double) -> Double {
        min(max(value, minPlateScale), maxPlateScale)
    }
}

enum CarPersonalizationStore {
    static let suiteName = "group.com.vinfast.carplay.widgethost"
    private static let storageKey = "carPersonalization.v1"

    /// Simulator device `/tmp` is shared across app + widget extension sandboxes.
    private static var simulatorBridgeURL: URL {
        URL(fileURLWithPath: "/tmp/com.vinfast.carplay.widgethost.personalization.json")
    }

    static func load() -> CarPersonalization {
        loadIfPresent() ?? .default
    }

    static func loadIfPresent() -> CarPersonalization? {
        if let value = decodeFile(at: simulatorBridgeURL) {
            return value
        }
        if let value = decodeJSONFile() {
            return value
        }
        if let suite = UserDefaults(suiteName: suiteName),
           suite.object(forKey: storageKey) != nil,
           let value = decode(from: suite) {
            return value
        }
        if UserDefaults.standard.object(forKey: storageKey) != nil,
           let value = decode(from: .standard) {
            return value
        }
        return nil
    }

    @discardableResult
    static func save(_ value: CarPersonalization) -> Bool {
        var next = value
        next.plateText = next.normalizedPlate
        next.clampPlatePosition()
        guard let data = try? JSONEncoder().encode(next) else { return false }

        var wroteBridge = false
        do {
            try data.write(to: simulatorBridgeURL, options: .atomic)
            wroteBridge = true
        } catch {
            wroteBridge = false
        }

        if let suite = UserDefaults(suiteName: suiteName) {
            suite.set(data, forKey: storageKey)
            suite.set(true, forKey: storageKey + ".present")
            suite.set(Date().timeIntervalSince1970, forKey: storageKey + ".savedAt")
            suite.synchronize()
        }
        UserDefaults.standard.set(data, forKey: storageKey)
        UserDefaults.standard.set(true, forKey: storageKey + ".present")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: storageKey + ".savedAt")
        UserDefaults.standard.synchronize()

        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suiteName
        )?.appendingPathComponent("car-personalization.json") {
            try? data.write(to: groupURL, options: .atomic)
        }

        let home = URL(fileURLWithPath: NSHomeDirectory())
        try? data.write(
            to: home.appendingPathComponent("Library/car-personalization.json"),
            options: .atomic
        )
        try? data.write(
            to: home.appendingPathComponent("Documents/car-personalization.json"),
            options: .atomic
        )

        return wroteBridge
            || FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: suiteName
            ) != nil
            || UserDefaults.standard.data(forKey: storageKey) != nil
    }

    private static func decode(from defaults: UserDefaults) -> CarPersonalization? {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(CarPersonalization.self, from: data) else {
            return nil
        }
        return decoded
    }

    private static func decodeFile(at url: URL) -> CarPersonalization? {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(CarPersonalization.self, from: data) else {
            return nil
        }
        return decoded
    }

    private static func decodeJSONFile() -> CarPersonalization? {
        var candidates: [URL] = []
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suiteName
        )?.appendingPathComponent("car-personalization.json") {
            candidates.append(groupURL)
        }

        let home = URL(fileURLWithPath: NSHomeDirectory())
        candidates.append(home.appendingPathComponent("Library/car-personalization.json"))
        candidates.append(home.appendingPathComponent("Documents/car-personalization.json"))

        for url in candidates {
            if let value = decodeFile(at: url) {
                return value
            }
        }
        return nil
    }
}

/// Persists the optional custom hero photo for app + widget.
enum CarPhotoStore {
    private static let fileName = "custom-car-photo.jpg"

    private static var simulatorBridgeURL: URL {
        URL(fileURLWithPath: "/tmp/com.vinfast.carplay.widgethost.custom-photo.jpg")
    }

    static func loadImage() -> UIImage? {
        for url in candidateURLs() {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }

    @discardableResult
    static func save(imageData: Data) -> Bool {
        let jpeg: Data
        if let image = UIImage(data: imageData),
           let compressed = image.jpegData(compressionQuality: 0.88) {
            jpeg = compressed
        } else {
            jpeg = imageData
        }

        var ok = false
        for url in candidateURLs(includeWritableHome: true) {
            do {
                try jpeg.write(to: url, options: .atomic)
                ok = true
            } catch {
                continue
            }
        }
        return ok
    }

    static func clear() {
        for url in candidateURLs(includeWritableHome: true) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private static func candidateURLs(includeWritableHome: Bool = false) -> [URL] {
        var urls: [URL] = [simulatorBridgeURL]

        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: CarPersonalizationStore.suiteName
        )?.appendingPathComponent(fileName) {
            urls.append(groupURL)
        }

        let home = URL(fileURLWithPath: NSHomeDirectory())
        urls.append(home.appendingPathComponent("Library/\(fileName)"))
        urls.append(home.appendingPathComponent("Documents/\(fileName)"))

        if includeWritableHome {
            // Ensure parent dirs exist for Library/Documents writes.
            for url in urls.dropFirst() {
                try? FileManager.default.createDirectory(
                    at: url.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            }
        }
        return urls
    }
}
