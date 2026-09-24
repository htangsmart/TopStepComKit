# TopStepComKit

TopStepComKit 是 TopStep 智能穿戴设备的 iOS SDK，为 App 与手表设备之间提供完整的通信和数据管理能力。统一接口层覆盖蓝牙连接、健康数据、设备控制全场景，屏蔽底层多平台差异，开发者只需对接一套 API。

**[📖 完整文档](https://topstep-sdk-doc.htangsmart.com/)**

---

## 功能模块

| 模块 | 功能 |
|------|------|
| 蓝牙连接 | 设备搜索、配对、绑定、解绑，5 阶段状态机管理 |
| 健康数据 | 心率、血氧、血压、压力、体温、心电、睡眠、运动监测 |
| 数据同步 | 按时间范围批量获取历史健康数据 |
| 设备管理 | 电量状态、设备定位、屏幕锁定、固件 OTA 升级 |
| 表盘管理 | 推送内置、自定义及云端表盘 |
| 通讯功能 | 消息提醒、联系人、闹钟管理 |
| 系统设置 | 用户信息、单位、语言、时间、天气配置 |
| 扩展功能 | 音乐控制、相机快拍、女性健康、AI 聊天 |

---

## 环境要求

- iOS 15.0+（自 1.0.0-beta11 起；beta10 及之前为 iOS 12.0+）
- Xcode 13.0+
- CocoaPods 1.10.0+

---

## 安装

在 Podfile 中添加：

```ruby
source 'https://github.com/CocoaPods/Specs.git'

# 四个底层 Pod 从官方 Git 获取
pod 'FitCloudKit', :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
pod 'FitCloudDFUKit', :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
pod 'FitCloudWFKit', :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'
pod 'FitCloudNWFKit', :git => 'https://github.com/htangsmart/FitCloudPro-SDK-iOS.git'

# 基础模块（必需）
pod 'TopStepComKit-Git/Foundation'

# 通信模块（必需）
pod 'TopStepComKit-Git/ComKit'

# 纯 Fit（与 FitAIImp 二选一）
pod 'TopStepComKit-Git/FitCoreImp'

# Fit + AI（与 FitCoreImp 二选一，会自动安装 AIImp，要求 iOS 13+）
# pod 'TopStepComKit-Git/FitAIImp'

# 其他设备实现模块（按需选择）
# pod 'TopStepComKit-Git/NpkImp'
# pod 'TopStepComKit-Git/FwImp'  # 仅支持 arm64 真机
```

`FitCoreImp` 和 `FitAIImp` 都包含 `TopStepFitKit.framework`，不能同时安装。
直接使用 `pod 'TopStepComKit-Git'` 时，默认选择 `FitAIImp`、`NpkImp`
和 `FwImp`，其中 `AIImp` 由 `FitAIImp` 自动引入。

`FitCoreImp` 和 `FitAIImp` 均通过四个官方 Pod 获取底层框架和资源，不再引用 `FitBase`。
Podfile 仅指定官方 Git 地址，podspec 仅声明依赖名称，不额外固定提交或版本。
宿主 App 与 TopStepComKit 通过同名 Pod 共用依赖，实际安装版本及提交由 `Podfile.lock` 记录。

| Pod | 配套依赖 |
| --- | --- |
| FitCloudKit | 核心框架及资源 |
| FitCloudDFUKit | RTKLEFoundation、RTKOTASDK、RTKLocalPlaybackSDK、iOSDFULibrary |
| FitCloudWFKit | ABParTool |
| FitCloudNWFKit | zipzap |

已有这些 Pod 的项目沿用同一 Git 地址的声明即可，不要重复添加，也不要将 SDK Git 仓库添加为 Specs 源。
初始化、回调和蓝牙连接逻辑不变。

`iOSDFULibrary` 和 `zipzap` 由官方 Pod 管理。如果旧项目的 `iOSDFULibrary` 版本约束
与官方 Pod 冲突，需移除多余约束，并执行 `pod update iOSDFULibrary`
更新锁文件及 CocoaPods 生成的工程、资源脚本。

然后执行：

```bash
pod install
```

### Info.plist 权限配置

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要蓝牙权限以连接智能穿戴设备</string>
```

---

## 快速开始

### 1. 初始化 SDK

在 `AppDelegate.m` 中完成初始化：

```objc
#import <TopStepComKit/TopStepComKit.h>

TSKitConfigOptions *configs = [TSKitConfigOptions configOptionWithSDKType:TSSDKTypeFIT
                                                                  license:@"your_license_key"];
configs.isDebugMode = YES; // 发布时改为 NO

__weak typeof(self) weakSelf = self;
[[TopStepComKit sharedInstance] initSDKWithConfigOptions:configs
                                             completion:^(BOOL isSuccess, NSError *error) {
    if (isSuccess) {
        [[[TopStepComKit sharedInstance] log] quickConfigureWithSaveEnabled:YES completion:nil];
        [weakSelf autoConnect];
    }
}];
```

### 2. 扫描设备

```objc
[[[TopStepComKit sharedInstance] bleConnector]
    startSearchPeripheral:^(TSPeripheral *peripheral) {
        if (peripheral.systemInfo.mac.length > 0) {
            // 更新设备列表
        }
    }
    errorHandler:^(TSBleConnectionError errorCode) {
        // 处理扫描错误
    }];
```

### 3. 连接设备

```objc
TSConnectOptions *options = [[TSConnectOptions alloc] init];
options.userID   = @"user_id";
options.authCode = @"qr_auth_code"; // 扫描设备二维码获取

[[[TopStepComKit sharedInstance] bleConnector]
    connectWithPeripheral:peripheral
                  options:options
               completion:^(BOOL isSuccess, TSPeripheral *device, NSError *error) {
        if (isSuccess) {
            // 连接成功
        }
    }];
```

### 4. 读取健康数据

```objc
id<TSHeartRateInterface> hrInterface = [[TopStepComKit sharedInstance] heartRate];

if ([hrInterface isFuncSupported]) {
    [hrInterface getLatestHeartRateWithCompletion:^(TSHeartRateModel *model, NSError *error) {
        if (model) {
            NSLog(@"Heart rate: %ld bpm", (long)model.value);
        }
    }];
}
```

---

## 架构说明

```
┌─────────────────────────────────────┐
│           TopStepComKit             │  ← 统一入口，仅需一次 import
├─────────────────────────────────────┤
│        TopStepInterfaceKit          │  ← 协议、数据模型、枚举定义
├──────────┬──────────────────────────┤
│ FitKit   │   FwKit   |    TPBKit    │  ← 各平台具体实现
├─────────────────────────────────────┤
│              BleMetaKit             │  ← BLE 指令封装与通信协议
├─────────────────────────────────────┤
│               ToolKit               │  ← 日志、数据库、加密工具
└─────────────────────────────────────┘
```

---

## 模块说明

| 模块 | 组件 | 说明 |
|------|------|------|
| Foundation | TopStepInterfaceKit.xcframework<br>TopStepToolKit.xcframework | 接口定义与基础工具，所有模块必需 |
| ComKit | TopStepComKit.xcframework | 设备通信核心，依赖 Foundation |
| FitCoreImp | Core 版 TopStepFitKit.xcframework | 纯 Fit 实现 |
| FitAIImp | AI 版 TopStepFitKit.xcframework | 完整 Fit AI 实现，依赖 AIImp |
| AIImp | TopStepAIKit.xcframework<br>AIBuds SDK | AI 运行时、Provider 与资源 |
| NpkImp | TopStepNewPlatformKit.xcframework | 当前只发布 Core 实现 |
| FwImp | TopStepPersimwearKit.xcframework | 当前只发布 Core 实现，仅支持 arm64 真机 |

> **注意**：FwImp 不支持模拟器（x86_64/arm64-simulator）。lint 和发布时需跳过模拟器校验：
> ```sh
> pod lib lint TopStepComKit-Git.podspec --skip-import-validation --allow-warnings
> pod trunk push TopStepComKit-Git.podspec --skip-import-validation --allow-warnings
> ```

---

## 文档

| 资源 | 链接 |
|------|------|
| 完整文档 | https://topstep-sdk-doc.htangsmart.com/ |
| 快速开始 | https://topstep-sdk-doc.htangsmart.com/docs/quick-start |
| API 参考 | https://topstep-sdk-doc.htangsmart.com/docs/api/ble-connect |
| 架构说明 | https://topstep-sdk-doc.htangsmart.com/docs/architecture |
| 更新日志 | https://topstep-sdk-doc.htangsmart.com/docs/changelog |

---

## 版本历史

### 1.0.0-beta11 (2026-09-24)

#### ⚠️ 破坏性变更 —— 最低支持版本升至 iOS 15.0，请谨慎更新

- **自本版本起，SDK 与 Example 工程的最低部署版本由 iOS 12.0 / 13.0 统一提升至 iOS 15.0**（Xcode 27 / iOS 27 SDK 仅支持 15.0 及以上的部署版本）。
- 若你的 App 仍需支持 iOS 15.0 以下系统，请**暂勿升级**，继续使用 `1.0.0-beta10`；升级前请确认 App 的 `IPHONEOS_DEPLOYMENT_TARGET` 与 Podfile 的 `platform :ios` 均不低于 `15.0`。
- Example Podfile 的 `post_install` 会把所有低于 15.0 的 Pod 部署版本统一抬高到 15.0，并移除 AFNetworking 对私有头 `<netinet6/in6.h>` 的引用以适配 iOS 27 SDK。

#### ✨ 新增功能

**接口层（TopStepInterfaceKit）**
- 新增华盛达客户定制接口 `TSHuashengdaInterface`（`TopStepComKit.huashengda`）：ICE 标签、家长模式 / 家长控制、课堂模式、任务与奖励、习惯、使用统计、游戏记录与排名趋势，配套 `TSHsdDefines`、`TSHsdParentalModeModel`、`TSHsdParentalControlModel`、`TSHsdClassroomModeModel`、`TSHsdTaskModel`、`TSHsdHabitModel`、`TSHsdUsageModel`、`TSHsdGameModel`
- 闹钟新增类型能力：`TSAlarmClockInterface` 增加 `isSupportAlarmType` / `fetchSupportedAlarmTypes:`，`TSAlarmClockModel` 增加 `alarmType`
- 表盘新增槽位查询：`TSPeripheralDialInterface` 增加 `isSupportDialSlots` / `fetchDialSlots:`，新增 `TSDialSlotModel`
- `TSMediaFileInterface` 补充说明：下载成功后设备侧文件是否移除由平台决定（FitCloud 会自动删除），调用方不应再对刚下载的文件调用 `deleteMediaFile:completion:`

**AIImp（TopStepAIKit）**
- 新增 AI 问答（Question Answer）能力：`TSAIQuestionAnswerAgent`，`TSAIQuestionAnswerInterface` / `TSAIQuestionAnswerConfig` 调整，支持文字、手机、耳机、手表四种输入方式
- 新增同声传译（Interpretation）：`TSAIInterpretationInterface`、`TSAIInterpretationRequest`、`TSAIInterpretationSnapshot`、`TSAIInterpretationDefines`、`TSAIKitInterpretationAdapter`
- 新增面对面对话翻译（Conversation Translation）：`TSAIConversationTranslationInterface`、`TSAIConversationTranslationConfig`、`TSAIConversationTranslationTurn`、`TSAIConversationTranslationEvent`、`TSAIConversationTranslationSnapshot`、`TSAIKitConversationTranslationAdapter`
- AI 录音增强：支持暂停 / 继续（`pauseAudioRecording` / `resumeAudioRecording`）、设备侧请求开始 / 暂停 / 继续回调（`TSAIAudioRecordDeviceRequest`）、App 端采集 PCM 推送（手机 / 蓝牙耳机拾音）、转写文本下发至设备（`TSAIAudioRecordTranscriptDelivery`），新增设备侧退出原因枚举
- 新增 `TSAIDeviceBridge` / `TSAIDeviceBridgeEventSink` / `TSAIDeviceAISessionBridge`、`TSAIUseCaseParameters`、`TSAIContext` 扩展
- 更新 AIBuds 全套 xcframework（AIBudsAI、AIBudsAudio、AIBudsMagicHelper、AIBudsStarBurst、AIBudsVoiceAssistant、AIBudsCrashReporter 等）
- `TopStepComKit.xcframework` 修正 Info.plist 中 arm64 / simulator 切片声明顺序

**FitCoreImp / FitAIImp**
- 新增 `TSFitHuashengda`、`TSHsdModels+Fit`：华盛达定制能力 FitCloud 实现
- 类型闹钟与 FitCloud「日程」互转（`TSFitScheduleAlarmIdBase`、`fitIsScheduleAlarm:` 等）
- AI 事件源新增设备请求暂停 / 继续录音事件；新增 `isSyncInProgress` 供 App 发起 AI 会话前规避数据同步冲突（40003）
- 新增 `TSFitMediaFileCallbackGuard`

**NpkImp**
- 新增 `TSNpkHuashengda`、`TSNpkHsdAbility`、`TSHsdModels+Npk`、`TSMetaHuashengda`、`PbHsdParam`：华盛达定制能力 NPK 实现（设备能力位 27–34）
- 新增 `TSNpkEpo`（EPO 星历）、`TSNpkOfflineMaps`（离线地图）
- 新增 `TSMetaSlotSpace` 表盘槽位、闹钟 `type` 字段
- 表盘构建流水线私有头补充（`TSNpkDialBuild*`、`TSNpkRes*`、`TSNpkScreen*` 等）

**FwImp**
- 新增 `TSFwHuashengda`：`TSHuashengdaInterface` 的 Persimwear 实现（各能力均返回不支持）

**Example Demo**
- 新增「华盛达定制」功能页 `TSHuashengdaVC`（ICE、家长模式、课堂模式、任务、习惯、使用统计、游戏共 7 个子模块）
- 新增「AI 问答」页 `TSAIQuestionAnswerVC`：文字 / 手机 / 耳机 / 手表四种拾音，支持设备主动发起问答时自动跳转（`TSAIQADeviceSessionCoordinator`）
- 同声传译页重构为上下分栏布局（`TSAIInterpreterSplitView`、`TSAIInterpreterTranscriptPanelView`、`TSAIInterpreterLineCell`、`TSAIInterpreterSetupSheetVC`），移除 `TSAIInterpreterUtteranceCell`
- AI 录音页支持选择拾音方式（设备 / 手机 / 蓝牙耳机），新增 `TSAIAudioRecordAppCapture` App 侧采集，支持暂停 / 继续与设备侧请求
- 闹钟编辑器支持闹钟类型选择（`TSAlarmTypePickerVC`）
- 新增中 / 英 / 印地语文案（华盛达、同声传译、闹钟类型），Info.plist 补充麦克风、定位权限说明与 `audio` 后台模式
- 连接成功后打印 `TSPeripheral` 调试信息

#### 🔧 改进与修复

- Example：运动推送页修复分区底部说明文字与最后一行重叠、卡片左右间距与 InsetGrouped 单元格对齐、批量更新行数校验失败
- Example：AI 功能入口按 Context 能力与拾音方式判断可用性
- Example Podfile：默认改为本地路径引用 `TopStepComKit-Git` 各子模块，Persimwear（Fw）因与 AIBuds 内置 openssl 存在重复符号暂不接入

---

### 1.0.0-beta8 (2026-04-16)

#### ⚠️ 破坏性变更

- **SDK 包结构重构**：原单体 `TopStepComKit.xcframework` 和 `TopStepBleMetaKit.xcframework` 拆分为独立子框架，Podspec 各子模块依赖独立管理
- **Reminders 接口 API 重命名**（不兼容旧版）：
  - `getAllRemindersWithCompletion:` → `fetchAllRemindersWithCompletion:`
  - `updateReminder:completion:` → `setReminder:completion:`
  - `supportMaxCustomeReminders` → `maxSupportedCustomReminderCount`
- **Reminders 枚举重命名**（不兼容旧版）：`eTSReminderRepeatXxx` / `eTSReminderDayXxx` 系列全部更名为 `TSRemindersRepeatXxx`，类型 `TSReminderDays` → `TSRemindersRepeat`
- **天气模型文件重命名**：`TopStepWeather.h` → `TSWeatherModel.h`，`TSWeatherHour.h` → `TSWeatherHourModel.h`，`TSCity.h` 调整

#### ✨ 新增功能

**接口层（TopStepInterfaceKit）**
- 新增独立健康接口：`TSHeartRateInterface`、`TSBloodOxygenInterface`、`TSBloodPressureInterface`、`TSStressInterface`、`TSTemperatureInterface`、`TSSleepInterface`、`TSDailyActivityInterface`
- 新增多平台表盘模型：`TSFitDialModel`（Fit 系列）、`TSFwDialModel`（Persimwear 系列）、`TSSJDialModel`（SJWatch 系列）
- 新增天气基础模型：`TSWeatherBaseModel`、`TSWeatherDayModel`、`TSWeatherHourModel`
- 新增连接参数模型：`TSPeripheralConnectParam`

**FitCoreImp**
- 新增 `TSAutoMonitorConfigs+Fit`：自动监测配置（心率、血氧等）
- 新增 `TSFitHRDataSync`：心率历史数据同步
- 新增 `TSFitRemindersBasic` / `TSFitRemindersPersonalized`：提醒功能基础与个性化扩展
- 新增 `TSFitSyncRawResult`：数据同步原始结果模型
- 新增 `TSHRValueItem+Fit`、`TSLanguageModel+Fit`

**NpkImp**
- 新增 `TSNpkECardBag`：E 卡包支持

**TopStepToolKit**
- 新增 `TSSafeValue`：线程安全取值工具

**Example Demo**
- 新增震动功能演示页
- 新增 App 语言切换功能
- 新增多语言（国际化）支持
- 新增设备锁功能演示
- 完善提醒功能编辑器（`TSReminderEditorVC`、`TSReminderRepeatVC`）

#### 🔧 改进与修复

- 修复 Fit SDK 特定场景下的崩溃问题
- 修复运动参数单位显示错误
- 修正运动目标设置逻辑
- 重构 `TSAlarmClockInterface` / `TSAlarmClockModel`（接口完善）
- 重构 `TSSettingInterface`（接口完善）
- 重构 `TSRemindersInterface` / `TSRemindersModel`（API 命名规范化）
- 重构 `TSPeripheralDialInterface`（表盘接口大幅调整，支持多平台模型）
- 重构 `TSBleConnectInterface`（连接接口完善）
- 重构 `TSSleepDailyModel`（睡眠数据模型完善）
- 重构 `TSSportItemModel` / `TSSportSummaryModel`（运动数据模型完善）
- Example 工程：重构 VC 继承体系，统一 TabBar 显示逻辑
- Example 工程：修复 iOS 12 兼容性警告（`UIActivityIndicatorViewStyleLarge/Medium`、`UITableViewStyleInsetGrouped`、`systemImageNamed:` 均已加 `@available` 守卫）

#### 🗑️ 移除（已废弃接口/模型）

- 移除 `TSAIDeviceModel`、`TSAIManagerInterface`（AI 相关能力移至上层）
- 移除 `TSMusicInterface`、`TSMusicModel`（音乐控制能力调整）
- 移除 `TSPeripheralLockInterface`、`TSPeripheralLogInterface`
- 移除 `TSBleConnectDefines`、`TSBluetoothSystem`
- 移除 `TSCustomDial`、`TSCustomDialItem`、`TSCustomDialTime`、`TSDialDefines`（表盘模型重构替代）
- 移除 `TSFileModel`、`TSFileTransferDefines`、`TSFirmwareUpgradeInterface`
- 移除 `TSGameLockModel`、`TSScreenLockModel`、`TSAppStatusModel`、`TSAppStoreInterface`、`TSApplicationModel`
- 移除 `TSRequestModel`、`TSRespondModel`、`TSRequestTransferInterface`
- 移除 `TSPrayersInterface`
- `TopStepToolKit` 精简：移除 `NSData+Tool`、`NSFileManager+Tool`、`NSString+Tool`、`UIColor+Tool`、`UIImage+Tool`、`TSKeychain`、`TSLibArchive`、`TSTarArchive`、`TscEncoder`、`TSConnectedPeripheral`、`TSLogStorage`、`TSSqlliteManager` 等内部工具头文件

---

### 1.0.0
- 首次发布
- 支持蓝牙连接、健康数据、数据同步等核心功能
- 提供模块化集成方案，适配 Fit 系列设备

---

## 许可证

TopStepComKit-Git 使用 MIT 许可证，详情请查看 [LICENSE](LICENSE) 文件。
