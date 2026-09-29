# VinFast Lux SA CarPlay Widget

iOS host app + WidgetKit extension that shows a **VinFast Lux SA** hero photo with an **embossed 3D Vietnamese clock** (time, weekday, date) overlaid on top.

Deployment target: **iOS 17+**. Stack: SwiftUI + WidgetKit. No third-party libraries.

## Open in Xcode

```bash
open ~/Projects/VinFastCarPlayWidget/VinFastCarPlayWidget.xcodeproj
```

Or double-click `VinFastCarPlayWidget.xcodeproj` in Finder.

If you edit `project.yml`, regenerate the project:

```bash
cd ~/Projects/VinFastCarPlayWidget
xcodegen generate
```

## Run on Simulator (recommended default)

**Prefer the iOS Simulator** — it does **not** register a physical iPhone against your Apple ID, so it works even when you see:

> Your development team has reached the maximum number of registered iPhone devices.

1. In Xcode’s destination menu (toolbar next to the scheme), choose **iPhone 18 Pro** (Simulator, iOS 27.0) — **not** a physical device (e.g. “Joseph”).
2. Scheme: **VinFastCarPlayWidget** → press **Run** (⌘R).
3. Signing uses **Automatic** + Simulator ad-hoc identity (`Sign to Run Locally` / `-`). No new device slot is consumed.
4. On the Simulator Home Screen: long-press → **Edit Home Screen** → **+** → **Lux SA Clock** → add Small / Medium / Large.

Verified CLI destination (this Mac has two “iPhone 18 Pro” sims — prefer **id** to avoid ambiguity):

```bash
cd ~/Projects/VinFastCarPlayWidget
xcodebuild -scheme VinFastCarPlayWidget \
  -destination 'platform=iOS Simulator,id=A9B834A5-4187-4BE2-89FD-815F0F6D3734' \
  -configuration Debug build
# Equivalent name form when unique: platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0
```

See also: [Signing & device limit](docs/signing-device-limit.md) (mirrored in the Agent Store).

## Preview in Xcode Canvas

1. Open `Widget/LuxSAWidgetView.swift`.
2. Enable **Canvas** (Editor → Canvas) and resume the preview.
3. You should see the embossed clock (`HH:mm`, `Thứ …`, `dd/MM/yyyy`, locale `vi_VN`) behind the Lux SA silhouette.

## Run on a physical iPhone (after freeing a device slot)

Free Apple IDs are often capped at **3** registered devices; paid teams have higher limits but can still hit the cap.

1. Open [developer.apple.com](https://developer.apple.com) → **Account** → **Devices**.
2. Remove unused iPhones you no longer need.
3. In Xcode → target → **Signing & Capabilities** → enable **Automatically manage signing** → pick your **Personal Team** (do not change Apple ID unless you intend to).
4. Plug in the phone, trust the computer, select it as destination, then Run.

Until a slot is free, stay on **Simulator**.

## Layout

- Full-bleed personalized hero (default Lux SA or personal photo + custom plate) → top scrim → `EmbossedClockView` overlay.
- Host app: **Cá nhân hóa** — plate text, drag position, and personal photo upload with live preview (see `docs/car-personalization.md`).
- Families: Small / Medium / Large (plus Lock Screen accessories).
- **Large** uses extra top padding (~50pt, ~30% less than the prior 72pt inset) and no top bleed so the clock clears chrome without sitting too low.
- Emboss is pure SwiftUI layered text (highlight + shadow + fill).
- `LuxSATimelineProvider` emits one entry per minute and reloads about every hour.

## CarPlay note

Supported widget families include Small / Medium / Large (and Lock Screen accessories). **A real CarPlay dashboard experience requires Apple’s CarPlay entitlement** and additional CarPlay app configuration. Without that entitlement you can still develop and preview on Home Screen, Lock Screen, and Xcode Previews.

## Project structure

```
VinFastCarPlayWidget/
  App/                      # Minimal host app
  Widget/                   # WidgetKit extension
  Config/Signing.xcconfig   # Simulator-friendly Automatic Signing
  Shared/Assets.xcassets/
  docs/signing-device-limit.md
  project.yml
  README.md
```

## Bundle IDs

| Target | Bundle ID |
|--------|-----------|
| Host app | `com.vinfast.carplay.widgethost` |
| Widget extension | `com.vinfast.carplay.widgethost.LuxSAWidget` |

Signing: **Automatic**. Simulator uses local ad-hoc signing. Physical device needs a free slot on your existing Apple ID / team.
