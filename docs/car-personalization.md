# Car personalization

The host app lets Joseph customize the Lux SA widget:

1. **License plate** — text (max 12 chars), drag position, **scale slider** (50%–200%), optional **Ẩn biển số**  
2. **Personal photo** — PhotosPicker upload; optional reset to default Lux SA asset  
3. **Lưu** (toolbar, top-right) — commits plate + photo + visibility/scale to Home Screen widget 

Paint color options were removed.

## App icon

iOS 27 **Liquid Glass** style: translucent ruby-red glass car glyph on charcoal with specular highlights and floating red glass pill (`App/Assets.xcassets/AppIcon.appiconset/AppIcon.png`, 1024×1024, full-bleed — system applies squircle mask).

## Checklist

- [x] Remove paint/color options
- [x] Personal photo picker + reset to Lux SA default
- [x] Preview ~1:1.05 aspect; cover crop
- [x] Native iOS button styles
- [x] Hide plate + plate scale slider
- [x] Shared `LuxSAHeroScene` (preview = widget)
- [x] App icon (red / black car) — iOS 27 Liquid Glass style
- [x] App display name: **Car Widget**

## Sync

| Path | Behavior |
|------|----------|
| Preview | Live plate/photo on a **~1:1.05** canvas (slightly taller, matches Home Screen Large); clock padding ~Large |
| Save | Writes JSON + JPEG to Simulator `/tmp` bridge (+ App Group when available), reloads timelines |
| Edit Widget | Plate text fallback via `LuxSAConfigurationIntent` |

## Key files

- `App/ContentView.swift` — UI; system `.glass` / `.glassProminent` buttons (iOS 26+), bordered fallbacks below  
- `Shared/CarPersonalization.swift` — prefs + `CarPhotoStore`  
- `Shared/PersonalizedCarImage.swift` — hero (cover/fill) + plate overlay  
