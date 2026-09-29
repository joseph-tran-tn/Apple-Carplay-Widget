# Widget edge-to-edge layout

## Result

Home Screen widget now **fills the rounded widget bounds** (no thick empty margin ring). Embossed Vietnamese clock remains **behind** the Lux SA cutout.

Verified on Simulator: `platform=iOS Simulator,id=A9B834A5-4187-4BE2-89FD-815F0F6D3734` (iPhone 18 Pro / iOS 27.0) — **BUILD SUCCEEDED**.

## What changed

| File | Change |
|------|--------|
| `Widget/LuxSAWidget.swift` | `.contentMarginsDisabled()`, `.containerBackgroundRemovable(false)`, `EdgeToEdgeWidget` with negative padding past `widgetContentMargins` (+ fixed bleed), scene also in `containerBackground` |
| `Widget/LuxSAWidgetView.swift` | `LuxSAWidgetScene` full-bleed `GeometryReader` + `scaledToFill` / slight `scaleEffect` so the car reaches edges; clock layered under cutout |
| `project.yml` | Asset catalogs live under `App/Assets.xcassets` and `Widget/Assets.xcassets` (XcodeGen was dropping `Shared/` `resources:`) |
| Cutout PNG | Regenerated dark-bg → alpha; copied into App + Widget catalogs |

## Media

- `/cursor/stores/self/media/widget-edge-to-edge.png` — full home screen after fix
- `/cursor/stores/self/media/widget-edge-to-edge-crop.png` — cropped widget close-up
- `/cursor/stores/self/media/widget-before-margins.png` — earlier padded state (wallpaper visible in margin ring)

## Note

iOS 17+ default content margins caused the “picture frame” look. Disabling margins alone was not enough on iOS 27 Simulator until the scene was also painted in `containerBackground` and expanded with negative padding.
