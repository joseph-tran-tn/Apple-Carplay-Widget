# Hero photo widget (no cutout)

Joseph switched to a full studio photo — **no background removal**, clock **overlaid on top** of the car (not behind).

Latest asset shows the **entire Lux SA** (three-quarter full body). Layout uses `scaledToFit` on black fill so the car is not cropped.

## Layout

1. `Image("LuxSA")` full-bleed (`scaledToFill`)
2. Light top scrim for readability
3. `EmbossedClockView` aligned top (HH:mm / Thứ … / dd/MM/yyyy)

Edge-to-edge margins (`contentMarginsDisabled` + bleed) kept for small/medium.
For **systemLarge**, top bleed is disabled and the clock gets **72pt** top padding so time glyphs clear the rounded chrome.

## Build

iPhone 18 Pro / iOS 27 Simulator — **BUILD SUCCEEDED**

## Media

- `media/vinfast-lux-sa-hero.jpg` — source photo
- `media/widget-hero-car.png` / `media/widget-hero-car-crop.png` — Simulator
