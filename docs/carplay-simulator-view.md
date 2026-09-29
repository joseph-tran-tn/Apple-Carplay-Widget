# CarPlay Simulator view (status)

## What we could open

On this Mac (Xcode 27), classic **Simulator.app** is gone. The phone UI runs inside **Device Hub** (`com.apple.dt.Devices`):

- Path: `/Applications/Xcode.app/Contents/Applications/DeviceHub.app`
- CarPlay tooling is a DeviceKit plugin:  
  `…/DeviceKit.framework/…/PlugIns/CarPlaySimulator.devicekitplugin`  
  (dylib — not a standalone `.app`; launch via Device Hub / Xcode developer tools)

iPhone 18 Pro / iOS 27 Simulator was **booted**, VinFast host + widget installed and running.

## CarPlay display

`simctl io … enumerate` showed a **CarPlay** screen (`Screen Type: CarPlay`, 720×480, name `Wireless`).

Attempts:

1. Set `SimulatorExternalDisplay = 2114` in `com.apple.iphonesimulator` prefs  
2. `simctl io … screenConfig --display=3 power on`  
3. Screenshot `--display=3` / `Wireless`

**Result:** CarPlay framebuffer captured as **720×480 solid black**. Device Hub phone window briefly showed **“Connecting display…”** then settled on the phone chrome. No usable CarPlay dashboard UI window appeared for a clean screenshot.

Accessibility automation against Device Hub menus failed (no AX menu bar on the process).

## Lux SA on CarPlay?

**Honest answer: No.** The Lux SA surface is a **WidgetKit home-screen widget**, not a CarPlay app scene. Real CarPlay UI needs Apple’s **CarPlay entitlement** + CarPlay app APIs. Even system CarPlay Simulator UI did not fully connect here, so there is no proof of third-party content on CarPlay.

## Closest alternative (captured)

Phone Simulator home screen with the Lux SA widget (edge-to-edge after the layout fix):

- See `media/widget-edge-to-edge.png`

## How Joseph can open CarPlay Simulator manually

1. Boot an iPhone Simulator in **Device Hub** / Xcode  
2. Xcode → **Open Developer Tool** → look for **CarPlay Simulator** (Device Hub plugin), **or** in the Simulator/Device Hub UI use the equivalent of **I/O → External Displays → CarPlay** if listed  
3. Wait until the CarPlay main display is connected (not stuck on “Connecting display…”)  
4. Screenshot that CarPlay window

If CarPlay Simulator still won’t connect, reinstall the iOS 27 Simulator runtime (Xcode → Settings → Platforms) and retry with a fresh simulator device.
