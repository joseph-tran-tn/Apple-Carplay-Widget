# Large widget top padding

On **systemLarge**, the embossed clock was clipped / stuck to the top chrome because edge-to-edge bleed used a large negative top inset while clock padding stayed at ~10pt.

## Fix

1. Pass `WidgetFamily` into `LuxSAWidgetScene`.
2. Large clock top padding: **50pt** (~30% less than the previous 72pt).
3. Disable top bleed for `.systemLarge` and add **+6pt** top inset.
4. Slightly smaller large time font (46pt) so glyphs clear the rounded corners.

## Verify

- Simulator: iPhone 18 Pro / iOS 27 (`A9B834A5-4187-4BE2-89FD-815F0F6D3734`)
- `xcodebuild` → **BUILD SUCCEEDED**
- Clock glyph band moved from ~y466 → ~y538 on a 1206×2622 shot after reload (bump `CFBundleVersion` + clear chrono cache)

## Media

- `media/widget-large-top-padding.png`
- `media/widget-large-top-padding-crop.png`
