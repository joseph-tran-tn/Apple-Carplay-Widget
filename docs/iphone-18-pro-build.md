# iPhone 18 Pro / iOS 27 build status

**Date:** 2026-09-29  
**Project:** `/Users/macbook/Projects/VinFastCarPlayWidget`

## Result

**BUILD SUCCEEDED** on **iPhone 18 Pro Simulator / iOS 27.0**

| Item | Value |
|------|--------|
| Destination (verified) | `platform=iOS Simulator,id=A9B834A5-4187-4BE2-89FD-815F0F6D3734` |
| Name / OS | iPhone 18 Pro, OS 27.0 |
| Signing | Sign to Run Locally (Simulator ad-hoc; no device registration) |
| Install / launch | App installed + launched: `com.vinfast.carplay.widgethost` (pid observed) |

Name-only destination `platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0` can fail here because **two** iPhone 18 Pro devices exist under iOS 27.0 (`A9B834A5-…` and `2FA46E4B-…`). Use the **id** form.

## Physical device

Physical phone **Joseph (27.0)** is visible, but was **not** used — team device registration quota is still blocked. Stay on Simulator until a slot is freed (see `docs/signing-device-limit.md`).

## Runtime

iOS 27.0 Simulator runtime is already installed (`com.apple.CoreSimulator.SimRuntime.iOS-27-0`). No download needed on this Mac.
