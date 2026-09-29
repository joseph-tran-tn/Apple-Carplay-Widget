# Full-body Lux SA photo

Joseph provided a new studio shot so the widget shows the **entire car** (bumper → taillight), not a cropped close-up.

## Changes

1. Replaced `Widget/Assets.xcassets/LuxSA.imageset/vinfast-lux-sa.jpg` (and App mirror) with the new 1024×1024 hero.
2. Switched image layout from `scaledToFill` → **`scaledToFit`** on a black studio fill so Medium/Large do not crop the nose or rear.

Clock stays overlaid on top with Large top padding from the previous fix.

## Verify

- Simulator iPhone 18 Pro / iOS 27 — **BUILD SUCCEEDED**
- Large widget shows full three-quarter Lux SA + embossed clock

## Media

- `media/vinfast-lux-sa-full-body.jpg` — source
- `media/widget-full-car.png` / `media/widget-full-car-crop.png` — Simulator
