---
sidebar_position: 9
title: 运动
---

# 运动 (TSSport)

TSSport 模块提供了运动活动数据的完整管理功能，包括从设备同步运动数据、详细指标查询、心率数据分析等。支持超过100种运动类型，并提供丰富的性能指标（距离、步数、卡路里、心率区间等）。

## 前提条件

1. 已成功初始化 TopStepComKit SDK
2. 已建立与设备的连接
3. 设备支持运动数据记录功能
4. 用户已授予相关健康数据权限

## 数据模型

### TSSportModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `summary` | `TSSportSummaryModel *` | 运动活动总结数据，包含整体统计和成就 |
| `sportItems` | `NSArray<TSSportItemModel *> *` | 运动活动详细数据项数组，每项代表特定时间点或片段的指标 |
| `heartRateItems` | `NSArray<TSHRValueItem *> *` | 心率数据数组，提供整个活动过程中的连续心率监测 |

### TSSportDailyModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `sportRecords` | `NSArray<TSSportModel *> *` | 当天的运动活动记录数组 |
| `sportCount` | `NSUInteger` | 当天运动活动总数，从 sportRecords.count 推导 |
| `totalDuration` | `NSTimeInterval` | 所有运动活动的总时长（秒），通过累加所有活动的时长计算 |
| `maxHeartRate` | `UInt8` | 当天所有运动中的最高心率（BPM），从各活动的最高心率推导 |
| `minHeartRate` | `UInt8` | 当天所有运动中的最低心率（BPM），从各活动的最低心率推导 |

### TSSportSummaryModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据记录的开始时间戳（Unix 秒级） |
| `endTime` | `NSTimeInterval` | 数据记录的结束时间戳（Unix 秒级） |
| `duration` | `double` | 数据记录的持续时间（秒） |
| `userID` | `NSString *` | 进行运动活动的用户的唯一标识符 |
| `macAddress` | `NSString *` | 记录运动活动的设备的MAC地址 |
| `sportID` | `long` | 运动活动会话的唯一标识符 |
| `type` | `TSSportTypeEnum` | 运动活动的类型（跑步、骑行、游泳等） |
| `steps` | `UInt32` | 运动活动期间的总步数 |
| `distance` | `UInt32` | 运动活动期间的总距离（米） |
| `calorie` | `UInt32` | 运动活动期间消耗的总卡路里（小卡） |
| `maxHrValue` | `UInt8` | 运动活动期间的最高心率（BPM） |
| `minHrValue` | `UInt8` | 运动活动期间的最低心率（BPM） |
| `avgHrValue` | `UInt8` | 运动活动期间的平均心率（BPM） |
| `maxPace` | `float` | 运动活动期间的最高配速（s/km） |
| `minPace` | `float` | 运动活动期间的最低配速（s/km） |
| `avgPace` | `float` | 运动活动期间的平均配速（s/km） |
| `maxSpeed` | `float` | 运动活动期间的最高速度（m/s） |
| `minSpeed` | `float` | 运动活动期间的最低速度（m/s） |
| `avgSpeed` | `float` | 运动活动期间的平均速度（m/s） |
| `maxCadence` | `UInt8` | 运动活动期间的最高步频（步/分钟） |
| `minCadence` | `UInt8` | 运动活动期间的最低步频（步/分钟） |
| `avgCadence` | `UInt8` | 运动活动期间的平均步频（步/分钟） |
| `warmHrDuration` | `UInt32` | `热身心率区间的持续时间（秒），HR < (220-年龄) * 0.6` |
| `fatBurnHrDuration` | `UInt32` | `脂肪燃烧心率区间的持续时间（秒），(220-年龄) * 0.6 ≤ HR < (220-年龄) * 0.7` |
| `aerobicHrDuration` | `UInt32` | `有氧心率区间的持续时间（秒），(220-年龄) * 0.7 ≤ HR < (220-年龄) * 0.8` |
| `anaerobicHrDuration` | `UInt32` | `无氧心率区间的持续时间（秒），(220-年龄) * 0.8 ≤ HR < (220-年龄) * 0.9` |
| `extremeHrDuration` | `UInt32` | `极限心率区间的持续时间（秒），HR ≥ (220-年龄) * 0.9` |
| `warmHrRatio` | `UInt8` | 热身心率区间时间占比（0-100） |
| `fatBurnHrRatio` | `UInt8` | 脂肪燃烧心率区间时间占比（0-100） |
| `aerobicHrRatio` | `UInt8` | 有氧心率区间时间占比（0-100） |
| `anaerobicHrRatio` | `UInt8` | 无氧心率区间时间占比（0-100） |
| `extremeHrRatio` | `UInt8` | 极限心率区间时间占比（0-100） |
| `displayConfigs` | `NSData *` | 显示配置位图，若为 nil 表示设备不支持该功能 |

### TSSportItemModel

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `**基本信息**` |  |  |
| `userID` | `NSString *` | 进行运动活动的用户的唯一标识符 |
| `macAddress` | `NSString *` | 记录运动活动的设备的MAC地址 |
| `sportID` | `long` | 运动活动会话的唯一标识符 |
| `type` | `UInt16` | 运动活动的类型 |
| `**基本指标**` |  |  |
| `distance` | `NSInteger` | 运动过程中覆盖的总距离（米） |
| `steps` | `NSInteger` | 运动过程中的总步数 |
| `calories` | `NSInteger` | 运动过程中消耗的卡路里（小卡） |
| `pace` | `NSInteger` | 当前运动的配速（s/km） |
| `cadence` | `NSInteger` | 运动过程中的步频（步/分钟） |
| `speed` | `NSInteger` | 运动过程中的速度（m/min） |
| `**游泳指标**` |  |  |
| `swimStyle` | `int` | 游泳姿势（1=自由泳, 2=蛙泳, 3=仰泳, 4=蝶泳） |
| `swimLaps` | `int` | 完成的游泳趟数 |
| `swimStrokes` | `int` | 总划水次数 |
| `swimStrokeFreq` | `int` | 游泳划水频率（次/分钟） |
| `swolf` | `int` | 游泳效率指数（SWOLF），分数越低效率越高 |
| `**跳绳指标**` |  |  |
| `jumpCount` | `int` | 成功跳跃的总次数 |
| `jumpBkCount` | `int` | 跳绳活动中发生中断的次数 |
| `jumpConsCount` | `int` | 不间断连续跳绳的最高次数 |
| `**椭圆机指标**` |  |  |
| `elCount` | `int` | 椭圆机运动中的总步数 |
| `elFrequecy` | `int` | 椭圆机当前的步频（步/分钟） |
| `elMaxFrequecy` | `int` | 椭圆机运动中达到的最高步频（步/分钟） |
| `elMinFrequecy` | `int` | 椭圆机运动中记录的最低步频（步/分钟） |
| `**划船机指标**` |  |  |
| `rowCount` | `int` | 划船运动完成的总划桨次数 |
| `rowFrequecy` | `int` | 划船当前的频率（次/分钟） |
| `rowMaxFrequecy` | `int` | 划船运动中达到的最高频率（次/分钟） |
| `rowMinFrequecy` | `int` | 划船运动中记录的最低频率（次/分钟） |

## 枚举与常量

### TSSportTypeEnum - 运动类型枚举

| 枚举值 | 十六进制值 | 说明 |
|--------|-----------|------|
| `TSSportTypeOutdoorCycling` | 0x01 | 户外骑行 |
| `TSSportTypeOutdoorRunning` | 0x05 | 户外跑步 |
| `TSSportTypeIndoorRunning` | 0x09 | 室内跑步 |
| `TSSportTypeOutdoorWalking` | 0x0D | 户外健走 |
| `TSSportTypeClimbing` | 0x11 | 登山 |
| `TSSportTypeBasketball` | 0x15 | 篮球 |
| `TSSportTypeSwimming` | 0x19 | 游泳 |
| `TSSportTypeBadminton` | 0x1D | 羽毛球 |
| `TSSportTypeFootball` | 0x21 | 足球 |
| `TSSportTypeElliptical` | 0x25 | 椭圆机 |
| `TSSportTypeYoga` | 0x29 | 瑜伽 |
| `TSSportTypePingPong` | 0x2D | 乒乓球 |
| `TSSportTypeRopeSkipping` | 0x31 | 跳绳 |
| `TSSportTypeRowing` | 0x35 | 划船机 |
| `TSSportTypeLazyBike` | 0x39 | 懒人车 |
| `TSSportTypeFitnessBike` | 0x3D | 健身车 |
| `TSSportTypeFreeTraining` | 0x41 | 自由训练 |
| `TSSportTypeTennis` | 0x45 | 网球 |
| `TSSportTypeBaseball` | 0x49 | 棒球 |
| `TSSportTypeRugby` | 0x4D | 橄榄球 |
| `TSSportTypeCricket` | 0x51 | 板球 |
| `TSSportTypeFreeSports` | 0x55 | 自由运动 |
| `TSSportTypeStrengthTraining` | 0x59 | 力量训练 |
| `TSSportTypeIndoorWalking` | 0x5D | 室内走路 |
| `TSSportTypeIndoorCycling` | 0x61 | 室内骑行 |
| `TSSportTypeDumbbell` | 0x65 | 哑铃 |
| `TSSportTypeDance` | 0x69 | 舞蹈 |
| `TSSportTypeHulaHoop` | 0x6D | 呼啦圈 |
| `TSSportTypeGolf` | 0x71 | 高尔夫 |
| `TSSportTypeLongJump` | 0x75 | 跳远 |
| `TSSportTypeSitUp` | 0x79 | 仰卧起坐 |
| `TSSportTypeVolleyball` | 0x7D | 排球 |
| `TSSportTypeParkour` | 0x81 | 跑酷 |
| `TSSportTypeHiking` | 0x85 | 徒步 |
| `TSSportTypeHockey` | 0x89 | 曲棍球 |
| `TSSportTypeBoating` | 0x8D | 划船 |
| `TSSportTypeHIIT` | 0x91 | HIIT高强度间歇训练 |
| `TSSportTypeSoftball` | 0x95 | 垒球 |
| `TSSportTypeTrailRunning` | 0x99 | 越野跑 |
| `TSSportTypeSkiing` | 0x9D | 滑雪 |
| `TSSportTypeTreadmill` | 0xA1 | 漫步机 |
| `TSSportTypeRelaxation` | 0xA5 | 整理放松 |
| `TSSportTypeCrossTraining` | 0xA9 | 交叉训练 |
| `TSSportTypePilates` | 0xAD | 普拉提 |
| `TSSportTypeCrossMatch` | 0xB1 | 交叉配合 |
| `TSSportTypeFunctionalTraining` | 0xB5 | 功能性训练 |
| `TSSportTypePhysicalTraining` | 0xB9 | 体能训练 |
| `TSSportTypeMixedCardio` | 0xBD | 混合有氧 |
| `TSSportTypeLatinDance` | 0xC1 | 拉丁舞 |
| `TSSportTypeStreetDance` | 0xC5 | 街舞 |
| `TSSportTypeFreeSparring` | 0xC9 | 自由搏击 |
| `TSSportTypeBallet` | 0xCD | 芭蕾 |
| `TSSportTypeAustralianFootball` | 0xD1 | 澳式足球 |
| `TSSportTypeBowling` | 0xD5 | 保龄球 |
| `TSSportTypeSquash` | 0xD9 | 壁球 |
| `TSSportTypeCurling` | 0xDD | 冰壶 |
| `TSSportTypeSnowboarding` | 0xE1 | 单板滑雪 |
| `TSSportTypeFishing` | 0xE5 | 钓鱼 |
| `TSSportTypeFrisbee` | 0xE9 | 飞盘 |
| `TSSportTypeAlpineSkiing` | 0xED | 高山滑雪 |
| `TSSportTypeCoreTraining` | 0xF1 | 核心训练 |
| `TSSportTypeSkating` | 0xF5 | 滑冰 |
| `TSSportTypeFitnessGaming` | 0xF9 | 健身游戏 |
| `TSSportTypeAerobics` | 0xFD | 健身操 |
| `TSSportTypeGroupCallisthenics` | 0x0101 | 团体操 |
| `TSSportTypeKickBoxing` | 0x0105 | 搏击操 |
| `TSSportTypeFencing` | 0x0109 | 击剑 |
| `TSSportTypeStairClimbing` | 0x010D | 爬楼 |
| `TSSportTypeAmericanFootball` | 0x0111 | 美式橄榄球 |
| `TSSportTypeFoamRolling` | 0x0115 | 泡沫轴筋膜放松 |
| `TSSportTypePickleball` | 0x0119 | 匹克球 |
| `TSSportTypeBoxing` | 0x011D | 拳击 |
| `TSSportTypeTaekwondo` | 0x0121 | 跆拳道 |
| `TSSportTypeKarate` | 0x0125 | 空手道 |
| `TSSportTypeFlexibility` | 0x0129 | 柔韧度 |
| `TSSportTypeHandball` | 0x012D | 手球 |
| `TSSportTypeHandcar` | 0x0131 | 手摇车 |
| `TSSportTypeMeditation` | 0x0135 | 舒缓冥想类运动 |
| `TSSportTypeWrestling` | 0x0139 | 摔跤 |
| `TSSportTypeStepping` | 0x013D | 踏步 |
| `TSSportTypeTaiChi` | 0x0141 | 太极 |
| `TSSportTypeGymnastics` | 0x0145 | 体操 |
| `TSSportTypeTrackAndField` | 0x0149 | 田径 |
| `TSSportTypeMartialArts` | 0x014D | 武术 |
| `TSSportTypeLeisureSports` | 0x0151 | 休闲运动 |
| `TSSportTypeSnowSports` | 0x0155 | 雪上运动 |
| `TSSportTypeLacrosse` | 0x0159 | 长曲棍球 |
| `TSSportTypeHorizontalBar` | 0x015D | 单杠 |
| `TSSportTypeParallelBars` | 0x0161 | 双杠 |
| `TSSportTypeRollerSkating` | 0x0165 | 轮滑 |
| `TSSportTypeDarts` | 0x0169 | 飞镖 |
| `TSSportTypeArchery` | 0x016D | 射箭 |
| `TSSportTypeHorseRiding` | 0x0171 | 骑马 |
| `TSSportTypeShuttlecock` | 0x0175 | 毽球 |
| `TSSportTypeIceHockey` | 0x0179 | 冰球 |
| `TSSportTypeAbdominalTraining` | 0x017D | 腰腹训练 |
| `TSSportTypeVO2MaxTest` | 0x0181 | 最大摄氧量测试 |
| `TSSportTypeJudo` | 0x0185 | 柔道 |
| `TSSportTypeTrampolining` | 0x0189 | 蹦床 |
| `TSSportTypeSkateboard` | 0x018D | 滑板 |
| `TSSportTypeHoverBoard` | 0x0191 | 平衡车 |
| `TSSportTypeInlineSkating` | 0x0195 | 溜旱冰 |
| `TSSportTypeTreadmillRunning` | 0x0199 | 跑步机 |
| `TSSportTypeDiving` | 0x019D | 跳水 |
| `TSSportTypeSurfing` | 0x01A1 | 冲浪 |
| `TSSportTypeSnorkeling` | 0x01A5 | 浮潜 |
| `TSSportTypePullUp` | 0x01A9 | 引体向上 |
| `TSSportTypePushUp` | 0x01AD | 俯卧撑 |
| `TSSportTypePlank` | 0x01B1 | 平板支撑 |
| `TSSportTypeRockClimbing` | 0x01B5 | 攀岩 |
| `TSSportTypeHighJump` | 0x01B9 | 跳高 |
| `TSSportTypeBungeeJumping` | 0x01BD | 蹦极 |
| `TSSportTypeNationalDance` | 0x01C1 | 民族舞 |
| `TSSportTypeHunting` | 0x01C5 | 打猎 |
| `TSSportTypeShooting` | 0x01C9 | 射击 |
| `TSSportTypeMarathon` | 0x01CD | 马拉松 |
| `TSSportTypeSpinningBike` | 0x01D1 | 动感单车 |
| `TSSportTypePoolSwimming` | 0x01D5 | 泳池游泳 |
| `TSSportTypeOpenWaterSwimming` | 0x01D9 | 开放水域游泳 |
| `TSSportTypeBallroomDance` | 0x01DD | 交际舞 |
| `TSSportTypeZumba` | 0x01E1 | 尊巴 |
| `TSSportTypeJazzDance` | 0x01E5 | 爵士舞 |
| `TSSportTypeStepMachine` | 0x01E9 | 踏步机 |
| `TSSportTypeStairMachine` | 0x01ED | 爬楼机 |
| `TSSportTypeCroquet` | 0x01F1 | 门球 |
| `TSSportTypeWaterPolo` | 0x01F5 | 水球 |
| `TSSportTypeWallBall` | 0x01F9 | 墙球 |
| `TSSportTypeBilliards` | 0x01FD | 台球 |
| `TSSportTypeSepakTakraw` | 0x0201 | 藤球 |
| `TSSportTypeStretching` | 0x0205 | 拉伸 |
| `TSSportTypeFreeGymnastics` | 0x0209 | 自由体操 |
| `TSSportTypeBarbell` | 0x020D | 杠铃 |
| `TSSportTypeWeightlifting` | 0x0211 | 举重 |
| `TSSportTypeDeadlift` | 0x0215 | 硬拉 |
| `TSSportTypeBurpee` | 0x0219 | 波比跳 |
| `TSSportTypeJumpingJack` | 0x021D | 开合跳 |
| `TSSportTypeUpperBodyTraining` | 0x0221 | 上肢训练 |
| `TSSportTypeLowerBodyTraining` | 0x0225 | 下肢训练 |
| `TSSportTypeBackTraining` | 0x0229 | 背部训练 |
| `TSSportTypeBeachBuggy` | 0x022D | 沙滩车 |
| `TSSportTypeParagliding` | 0x0231 | 滑翔伞 |
| `TSSportTypeFlyAKite` | 0x0235 | 放风筝 |
| `TSSportTypeTugOfWar` | 0x0239 | 拔河 |
| `TSSportTypeTriathlon` | 0x023D | 铁人三项 |
| `TSSportTypeSnowmobile` | 0x0241 | 雪地摩托 |
| `TSSportTypeSnowCar` | 0x0245 | 雪车 |
| `TSSportTypeSled` | 0x0249 | 雪橇 |
| `TSSportTypeSkiBoard` | 0x024D | 滑雪板 |
| `TSSportTypeCrossCountrySkiing` | 0x0251 | 越野滑雪 |
| `TSSportTypeIndoorSkating` | 0x0255 | 室内滑冰 |
| `TSSportTypeKabaddi` | 0x0259 | 卡巴迪 |
| `TSSportTypeMuayThai` | 0x025D | 泰拳 |
| `TSSportTypeKickboxing` | 0x0261 | 踢拳 |
| `TSSportTypeRacing` | 0x0265 | 赛车 |
| `TSSportTypeIndoorFitness` | 0x0269 | 室内健身 |
| `TSSportTypeOutdoorSoccer` | 0x026D | 户外足球 |
| `TSSportTypeBellyDance` | 0x0271 | 肚皮舞 |
| `TSSportTypeSquareDance` | 0x0275 | 广场舞 |

### TSSportDisplayMetric - 运动显示指标枚举

| 枚举值 | 值 | 说明 |
|--------|-----|------|
| `TSSportDisplayMetricDuration` | 1 | 持续时间 |
| `TSSportDisplayMetricHeartRate` | 2 | 心率 |
| `TSSportDisplayMetricSteps` | 3 | 步数 |
| `TSSportDisplayMetricDistance` | 4 | 距离 |
| `TSSportDisplayMetricCalories` | 5 | 卡路里 |
| `TSSportDisplayMetricAvgSpeed` | 6 | 平均速度 |
| `TSSportDisplayMetricAvgPace` | 7 | 平均配速 |
| `TSSportDisplayMetricAvgCadence` | 8 | 平均步频 |
| `TSSportDisplayMetricAvgStride` | 9 | 平均步幅 |
| `TSSportDisplayMetricTotalAscent` | 10 | 累计上升 |
| `TSSportDisplayMetricTotalDescent` | 11 | 累计下降 |
| `TSSportDisplayMetricSwimLaps` | 12 | 游泳趟数 |
| `TSSportDisplayMetricSwimStrokes` | 13 | 游泳划水次数 |
| `TSSportDisplayMetricSwimStyle` | 14 | 泳姿 |
| `TSSportDisplayMetricSwimStrokeRate` | 15 | 游泳划水频率 |
| `TSSportDisplayMetricSwimEfficiency` | 16 | 游泳效率(SWOLF) |
| `TSSportDisplayMetricTriggerCount` | 17 | 触发次数 |
| `TSSportDisplayMetricTriggerRate` | 18 | 触发频率 |
| `TSSportDisplayMetricInterruptionCount` | 19 | 中断次数 |
| `TSSportDisplayMetricContinuousCount` | 20 | 连续次数 |

## 回调类型

| 回调签名 | 说明 |
|--------|------|
| `void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error)` | 运动数据同步完成回调。返回同步的运动活动数据数组或错误信息 |

## 接口方法

### 同步指定时间范围内的运动历史数据

```objc
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error))completion;
```

同步设备上指定时间范围内的所有运动活动数据，包括详细指标和心率信息。

**参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `startTime` | `NSTimeInterval` | 数据同步的开始时间戳（Unix秒级） |
| `endTime` | `NSTimeInterval` | 数据同步的结束时间戳（Unix秒级） |
| `completion` | `void (^)(NSArray<TSSportModel *> *_Nullable, NSError *_Nullable)` | 同步完成的回调块，返回运动数据数组或错误 |

**代码示例**

```objc
id<TSSportInterface> sport = [TopStepComKit sharedInstance].sport;

// 定义时间范围：最近7天
NSDate *now = [NSDate date];
NSDate *sevenDaysAgo = [now dateByAddingTimeInterval: -7 * 24 * 60 * 60];

NSTimeInterval startTime = [sevenDaysAgo timeIntervalSince1970];
NSTimeInterval endTime = [now timeIntervalSince1970];

// 同步运动数据
[sport syncHistoryDataFormStartTime:startTime
                                    endTime:endTime
                                 completion:^(NSArray<TSSportModel *> * _Nullable sports, NSError * _Nullable error) {
    if (error) {
        TSLog(@"同