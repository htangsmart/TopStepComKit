---
sidebar_position: 3
title: 架构说明
---

# SDK 架构说明

> 本页面详细介绍 TopStepComKit SDK 的分层架构和各组件的职责。

## 分层架构图

```
┌─────────────────────────────────────┐
│              你的 App                │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│          TopStepComKit               │  ← 对外统一入口
│   统一的 API 入口，屏蔽底层差异        │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│        TopStepInterfaceKit           │  ← 接口定义层
│  Protocol + Model + Enum 定义        │
└──────┬──────┬──────┬──────┬─────────┘
       │      │      │      │
  ┌────▼─┐ ┌──▼──┐ ┌─▼──┐ ┌▼────┐
  │ Fit  │ │ NPK │ │ SJ │ │ CRP │  ← 各平台实现
  └──────┘ └──┬──┘ └────┘ └─────┘
              │
       ┌──────▼──────┐
       │ BleMetaKit  │  ← 底层 BLE 通信
       └──────┬──────┘
              │
       ┌──────▼──────┐
       │  ToolKit    │  ← 工具库
       └─────────────┘
```

## 各组件说明

| 组件 | 说明 |
|------|------|
| `**TopStepComKit**` | 对外暴露的统一入口，你只需要 import 这一个 |
| `**TopStepInterfaceKit**` | 定义所有接口 Protocol、数据模型和枚举 |
| `**TopStepFitKit**` | 中科（Fit）系列设备的实现 |
| `**TopStepNewPlatformKit**` | 新平台设备的实现 |
| `**TopStepPersimwearKit**` | 柿子穿（Persimwear）设备的实现 |
| `**TopStepSJWatchKit**` | 伸聚（SJ）设备的实现 |
| `**TopStepCRPKit**` | CRP 设备的实现 |
| `**TopStepBleMetaKit**` | 底层 BLE 命令封装和通信协议 |
| `**TopStepToolKit**` | 日志、数据库、加密等工具函数 |
