# Signing & iPhone device registration limit

## Symptom

Xcode shows something like:

> Your development team has reached the maximum number of registered iPhone devices.

Installing this app on a **physical iPhone** fails. This is an Apple ID / team **device quota** issue, not a bug in the VinFast widget code.

## Immediate workaround: iOS Simulator

Simulator builds **do not** register a new iPhone on your team.

1. Open `/Users/macbook/Projects/VinFastCarPlayWidget/VinFastCarPlayWidget.xcodeproj`.
2. In the Xcode toolbar, set the destination to an **iPhone Simulator** (e.g. iPhone 16) — **not** a connected physical phone.
3. Select scheme **VinFastCarPlayWidget** → **Run** (⌘R).
4. Add the **Lux SA Clock** widget from the Simulator Home Screen widget gallery.

Project signing is configured for this path:

- `CODE_SIGN_STYLE = Automatic`
- `CODE_SIGN_IDENTITY[sdk=iphonesimulator*] = -` (Sign to Run Locally)
- `CODE_SIGNING_REQUIRED[sdk=iphonesimulator*] = NO`
- Settings live in `Config/Signing.xcconfig` and `project.yml` (no hard-coded team ID).

Verify from Terminal:

```bash
cd ~/Projects/VinFastCarPlayWidget
xcodebuild -scheme VinFastCarPlayWidget \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' \
  -configuration Debug build
# Expect: ** BUILD SUCCEEDED **
```

Widget UI can also be checked in Xcode **Canvas** on `Widget/LuxSAWidgetView.swift` without installing to a phone.

## Free a device slot, then retry on device

1. Sign in at [developer.apple.com](https://developer.apple.com/account) with **your existing Apple ID** (do not create or invent credentials).
2. Go to **Account** → **Devices** (or Certificates, Identifiers & Profiles → Devices).
3. Remove iPhones you no longer use / no longer need for development.
4. In Xcode: target → **Signing & Capabilities** → **Automatically manage signing** → choose your **Personal Team**.
5. Connect the phone, select it as destination, Run again.

### Limits (approximate)

| Account type | Typical device registration limit |
|--------------|-----------------------------------|
| Free Apple ID / Personal Team | Often **3** devices |
| Paid Apple Developer Program | Higher (commonly up to 100), but you can still hit the cap |

Removing a device frees a slot after Apple’s portal updates (usually quick; restart Xcode if signing still errors).

## What not to do

- Do not switch Apple IDs or invent credentials to “bypass” the limit.
- Do not expect Simulator workarounds to enable true CarPlay-on-hardware testing without a device and Apple entitlements.

## Project path

`/Users/macbook/Projects/VinFastCarPlayWidget`
