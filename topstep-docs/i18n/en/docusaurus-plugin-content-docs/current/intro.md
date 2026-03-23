---
sidebar_position: 1
title: SDK Overview
slug: /
---

# TopStepComKit SDK

TopStepComKit is the iOS SDK for TopStep smart wearable devices. It provides a complete set of APIs for communication and data management between your app and the device.

## Architecture

```
Your App
    ↓
TopStepComKit          ← Unified API entry point (only this layer needed)
    ↓
TopStepInterfaceKit    ← Interface definitions (Protocol, Model, Enum)
    ↓
TopStepFitKit          ← Realtek device implementation
TopStepNewPlatformKit  ← BES device implementation
TopStepPersimwearKit   ← Persimwear device implementation
TopStepSJWatchKit      ← SJ device implementation
TopStepCRPKit          ← CRP device implementation
    ↓
TopStepBleMetaKit      ← Low-level BLE communication framework
TopStepToolKit         ← Utilities (logging, database, encryption)
```

## Feature Modules

| Module | Description |
|--------|-------------|
| BLE Connect | Device scan, connect, bind, disconnect, unbind |
| Health Data | Heart rate, blood oxygen, blood pressure, stress, temperature, ECG, sleep, sport, daily activity |
| Data Sync | Batch sync of historical health data |
| Device Management | Battery, find device, screen lock, OTA firmware upgrade |
| Dial Management | Built-in / custom / cloud watchface push |
| Communication | Notifications, contacts, alarms, reminders |
| System Settings | User info, units, language, time, weather |
| Extras | Music control, camera shutter, glasses, female health, AI chat |

## Requirements

- iOS 12.0+
- Xcode 13.0+
- CocoaPods

## Quick Navigation

- [Quick Start](./quick-start) — 5-step SDK integration
- [BLE Connect API](./api/ble-connect) — Core connection interface
- [Health Data API](./api/health/overview) — Health monitoring interfaces
