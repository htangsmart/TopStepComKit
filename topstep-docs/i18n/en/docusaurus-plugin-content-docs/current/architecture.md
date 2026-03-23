---
sidebar_position: 3
title: Architecture
---

# SDK Architecture

This page describes the layered architecture of the TopStepComKit SDK and the responsibilities of each component.

## Layered Architecture

```
┌─────────────────────────────────────┐
│              Your App               │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│          TopStepComKit               │  ← Unified API entry point
│   Single entry, hides implementation│
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│        TopStepInterfaceKit           │  ← Interface definition layer
│  Protocol + Model + Enum             │
└──────┬──────┬──────┬──────┬─────────┘
       │      │      │      │
  ┌────▼─┐ ┌──▼──┐ ┌─▼──┐ ┌▼────┐
  │ Fit  │ │ NPK │ │ SJ │ │ CRP │  ← Platform implementations
  └──────┘ └──┬──┘ └────┘ └─────┘
              │
       ┌──────▼──────┐
       │ BleMetaKit  │  ← Low-level BLE communication
       └──────┬──────┘
              │
       ┌──────▼──────┐
       │  ToolKit    │  ← Utilities
       └─────────────┘
```

## Component Descriptions

| Component | Description |
|-----------|-------------|
| `TopStepComKit` | The only public-facing entry point. Import only this in your app. |
| `TopStepInterfaceKit` | Defines all interface Protocols, data models, and enumerations. |
| `TopStepFitKit` | Implementation for Realtek (FIT) series devices. |
| `TopStepNewPlatformKit` | Implementation for BES (New Platform) devices. |
| `TopStepPersimwearKit` | Implementation for Persimwear devices. |
| `TopStepSJWatchKit` | Implementation for SJ (Shenju) devices. |
| `TopStepCRPKit` | Implementation for CRP (Moyang) devices. |
| `TopStepBleMetaKit` | Low-level BLE command encapsulation and communication protocol. |
| `TopStepToolKit` | Logging, database, encryption and other utilities. |

## Design Principles

**Single Entry Point** — Your app only interacts with `TopStepComKit`. You never import or reference platform-specific kits directly.

**Interface-driven** — All feature modules are defined as Objective-C protocols in `TopStepInterfaceKit`. Instances are accessed through `[TopStepComKit sharedInstance].xxx` (e.g. `.heartRate`, `.bleConnector`), making the implementation replaceable.

**Multi-platform** — The same API works across all supported device platforms. The SDK selects the correct underlying implementation based on `TSSDKType` you specify during initialization.
