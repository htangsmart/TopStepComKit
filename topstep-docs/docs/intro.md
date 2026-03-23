---
sidebar_position: 1
title: 概述
slug: /
---

# TopStepComKit SDK

TopStepComKit 是 TopStep 智能穿戴设备的 iOS SDK，为 App 与手表设备之间提供完整的通信和数据管理能力。

## SDK 架构

```
你的 App
    ↓
TopStepComKit          ← 对外统一入口（你只需要接这里）
    ↓
TopStepInterfaceKit    ← 接口定义层（Protocol、Model、枚举）
    ↓
TopStepFitKit          ← 中科设备实现
TopStepNewPlatformKit  ← 新平台设备实现
TopStepPersimwearKit   ← 柿子穿实现
TopStepSJWatchKit      ← 伸聚设备实现
TopStepCRPKit          ← CRP 设备实现
    ↓
TopStepBleMetaKit      ← 底层 BLE 通信框架
TopStepToolKit         ← 工具库（日志、数据库、加密）
```

## 功能模块

| 模块 | 说明 |
|------|------|
| 蓝牙连接 | 设备搜索、连接、绑定、断开、解绑 |
| 健康数据 | 心率、血氧、血压、压力、体温、心电、睡眠、运动、日常活动 |
| 数据同步 | 批量同步历史健康数据 |
| 设备管理 | 电量查询、查找设备、屏幕锁、固件升级 |
| 表盘管理 | 内置/自定义/云端表盘推送 |
| 通讯功能 | 消息通知、联系人、闹钟、提醒 |
| 系统设置 | 用户信息、单位、语言、时间、天气 |
| 扩展功能 | 音乐控制、相机快拍、眼镜、女性健康、AI 聊天 |

## 最低要求

- iOS 12.0+
- Xcode 13.0+
- CocoaPods

## 快速导航

- [快速开始](./quick-start) — 5 步接入 SDK
- [蓝牙连接 API](./api/ble-connect) — 核心连接接口
- [健康数据 API](./api/health/overview) — 健康监测接口
