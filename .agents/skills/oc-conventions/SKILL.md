---
name: oc-conventions
description: "TopStepComKit Objective-C 详细规范：类/协议/方法/属性/变量/常量/枚举/文件命名、注释(.h中英双语/.m中文)、方法编写、代码格式、类与文件组织、懒加载、Block与Notification命名、#import顺序、内存管理与dealloc、单例、日志与错误码。编写或审查 OC(.h/.m) 代码时加载。"
---

# Objective-C 开发规范 / OC Development Conventions

本文档约定 TopStepComKit 及相关工程中的 Objective-C 开发规范，便于团队统一、代码可读与维护。

| 章节 | 内容 |
|------|------|
| 一～十 | 命名规则（类、协议、方法、属性、变量、常量、枚举、文件、缩写） |
| 十一 | 注释规范（.h 详细中英双语 / .m 简单中文） |
| 十二 | 方法编写规范（单一职责、可复用、简洁、效率、参数、错误、线程） |
| 十三 | 代码格式与风格（缩进、括号、空格、空行、行宽、.m 内部代码顺序） |
| 十四 | 类创建与文件组织（何时建类、何时单独成文件） |
| 十五 | 懒加载规范 |
| 十六 | Block 与 Notification 命名 |
| 十七 | #import 与前向声明（.h 用 @class、.m 再 #import、引用顺序） |
| 十八 | 内存管理与 dealloc（属性修饰符、Block 循环引用、dealloc 清理） |
| 十九 | 单例写法（dispatch_once、命名、NS_UNAVAILABLE） |
| 二十 | 日志与错误码（日志级别与格式、NSError domain/code/userInfo） |
| 二十一 | 项目前缀与基本信息 |
| 二十二 | 技术栈与架构约定（模块结构、目录组织） |
| 二十三 | 常用构建命令 |
| 二十四 | 第三方库使用约束 |
| 二十五 | 项目特有注意事项（模拟器限制、BLE 线程、初始化时序等） |

---

## 一、总体原则

| 原则 | 说明 |
|------|------|
| **清晰优先** | 名字应能直接表达用途，宁可稍长也不要含糊缩写。 |
| **风格一致** | 同一概念在全项目内使用同一命名方式（如「配置」统一用 Config/Options）。 |
| **遵循 Cocoa** | 与 Apple 官方 [Coding Guidelines](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html) 保持一致。 |

---

## 二、类（Class）命名

- **格式**：大驼峰（PascalCase），且**每个单词首字母大写**，无下划线。
- **前缀**：对外暴露的类必须带**项目/模块前缀**，避免与系统或第三方符号冲突。

| 类型 | 规范 | 示例 |
|------|------|------|
| 普通类 | `前缀 + 名词/名词短语` | `TSKitConfigOptions`、`TSPeripheral`、`TSBaseVC` |
| 视图控制器 | `前缀 + 功能描述 + VC` | `TSPushCloudDialVC`、`TSDeviceListVC` |
| 数据模型 | `前缀 + 名词 + Model`（可选） | `TSDailyActivityGoals`、`TSMessageModel` |
| 工具/管理类 | `前缀 + 功能 + Manager/Helper/Util` | `TSConnectionHistory`、`TSFileStreamWriter` |

**本工程常用前缀**：`TS`（TopStep 对外接口与实现）、`FitCloud`/`RTK`/`WM` 等为子模块或第三方保留。

---

## 三、协议（Protocol）命名

- **格式**：大驼峰。
- **命名方式**：
  - 描述「能力」时：**形容词/名词 + 后缀**，或直接**名词**。
  - 作为委托（Delegate）时：**类名 + Delegate**。

| 类型 | 规范 | 示例 |
|------|------|------|
| 能力/接口 | 名词或形容词，可带 Interface/Protocol | `TSRequestTransferInterface`、`TSAlarmClockInterface` |
| 委托协议 | 类名 + Delegate | `TSDeviceListVCDelegate` |
| 回调协议 | 行为描述 + Delegate 或 Protocol | `RTKCharacteristicRead`、`RTKCharacteristicWrite` |

---

## 四、方法（Method）命名

- **格式**：小驼峰（camelCase），首字母小写，后续单词首字母大写。
- **语义**：方法名应读起来像一句话，能看出「谁对谁做了什么」。

### 4.1 实例方法（`-`）

| 类型 | 规范 | 示例 |
|------|------|------|
| 无参/无返回值 | 动词或动词短语 | `- (void)resetToFactory` |
| 带参 | 动词 + 介词/补语，参数名体现含义 | `- (void)initSDKWithConfigOptions:(TSKitConfigOptions *)configs completion:(void(^)(BOOL, NSError *))completion` |
| 返回 BOOL | 用 is/has/can/should 等 | `- (BOOL)isConnected`、`- (BOOL)hasPeripheral` |
| 获取对象 | 名词或 get + 名词（少用 get） | `- (TSPeripheral *)currentPeripheral` |

### 4.2 类方法（`+`）

| 类型 | 规范 | 示例 |
|------|------|------|
| 工厂/构造 | 类名简写或 modelWith/from | `+ (instancetype)configOptionWithSDKType:license:`、`+ (TSWristWakeUpModel *)modelWithFitCloudWWUObject:` |
| 工具方法 | 动词开头 | `+ (NSArray *)goalsModelsFromFitCloudDailyGoalObjects:` |

### 4.3 建议

- 第一个参数尽量嵌在方法名里：`startSearchPeripheral:errorHandler:` 而不是 `startSearch:peripheral:error:`。
- 回调 block 参数命名：`completion:`、`successBlock:`、`errorHandler:`、`callback:` 等语义明确的词。
- 避免在方法名中使用 `and` 连接多个动作，可拆成多个方法或改用介词。

---

## 五、属性（Property）命名

- **格式**：小驼峰。
- **语义**：名词或名词短语，布尔用 is/has/can/should 等开头。

| 类型 | 规范 | 示例 |
|------|------|------|
| 对象/值类型 | 名词 | `peripheral`、`systemInfo`、`sourceArray` |
| 布尔 | is/has/can/should + 名词/形容词 | `isSuccess`、`hasPeripheral`、`shouldAutoSave` |
| 回调 block | on + 事件 或 名词 + Block/Handler | `onPushSuccess`、`completionBlock`、`errorHandler` |

---

## 六、变量与局部命名

- **格式**：小驼峰。
- **弱引用/强引用**：`weakSelf`、`strongSelf` 已成习惯，可保留；其他局部变量要有含义。

| 类型 | 规范 | 示例 |
|------|------|------|
| 局部变量 | 名词或名词短语 | `configs`、`peripheral`、`errorCode` |
| 弱/强 self | weakSelf / strongSelf | `__weak typeof(self) weakSelf = self;` |
| 循环/临时 | 简短但可读 | `idx`、`count`、`item`（在短作用域内可接受） |

---

## 七、常量命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 宏/预编译常量 | 全大写下划线分隔（k 可选） | `#define TS_MAX_RETRY_COUNT 3`、`kTSDefaultTimeout` |
| 枚举常量 | 类型名 + 大驼峰 case 名（Apple 风格） | `TSSDKTypeUnknown`、`TSSDKTypeFIT`、`TSBleConnectionErrorTimeout` |
| 静态常量（文件内） | 小写 k + 大驼峰 或 全大写下划线 | `static const NSTimeInterval kAnimationDuration = 0.3;` |

---

## 八、枚举与类型定义

- **枚举类型名**：大驼峰，与类/协议风格一致，如 `TSSDKType`、`TSBleConnectionError`。
- **枚举值**：类型名 + 大驼峰 case 名（Apple 标准风格），类型名即前缀，天然不会与其他符号冲突。

```objc
typedef NS_ENUM(NSInteger, TSSDKType) {
    TSSDKTypeUnknown = 0,
    TSSDKTypeFIT,
    TSSDKTypeNPK,
};
typedef NS_OPTIONS(NSUInteger, TSBleConnectionError) {
    TSBleConnectionErrorTimeout = 1 << 0,
    TSBleConnectionErrorDisconnected = 1 << 1,
};
```

---

## 九、文件与扩展（Category）命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 类文件 | 与类名一致 | `TSPushCloudDialVC.h` / `TSPushCloudDialVC.m` |
| Category 文件 | 类名 + 扩展功能 | `TSDailyActivityGoals+Fit.h`、`TSAutoMonitorHRConfigs+Fit.m` |
| Category 名 | 简短名词/形容词，体现职责 | `(Fit)`、`(Npk)`、`(Storage)` |

---

## 十、缩写与禁止项

- **允许的常见缩写**：`VC`（ViewController）、`URL`、`ID`、`SDK`、`BLE`、`HR`、`BP`、`ECG` 等业界通用写法，可在命名中保留大写（如 `TSBaseVC`、`deviceID`）。
- **避免**：无约定意义的 2～3 字母缩写（如 `ptr`、`tmp`、`obj`），除非是极局部的循环变量。
- **禁止**：单字母变量（除循环中的 `i`/`j`）、拼音命名、与系统/第三方严重同名的符号。

---

## 十一、注释规范

**区分 .h 与 .m**：

- **.h 文件**（对外接口）：类、**方法**、**属性**均使用**详细注释**，中英双语，带 @brief、@param、@return、@chinese 等。
- **.m 文件**（实现与私有）：**方法**、**属性**均只需**简单注释**，一行文字说明其含义或用途即可，中文即可。

### 11.1 文件头注释

每个 .h / .m 文件顶部保留标准文件头：文件名、工程名、创建/版权信息。

```objc
//
//  TSPushCloudDialVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//
```

---

### 11.2 类 / 接口（.h）注释

在 `@interface` 或 `@protocol` 上方用块注释说明该类/协议的职责，建议中英双语：**@brief / @chinese** 必选，**@discussion** 可选（用于补充行为、使用场景等）。

```objc
/**
 * @brief Push cloud watch face view controller
 * @chinese 推送云端表盘页
 *
 * @discussion
 * [EN]: Select a local file (.dial / .bin / .zip / .tar) via system File picker,
 *       preview by filename from bundle or placeholder, then push to device with progress.
 * [CN]: 通过系统文件选择器选择本地表盘文件，按文件名查找预览图或占位图，然后推送到设备并显示进度。
 */
@interface TSPushCloudDialVC : TSBaseVC
```

---

### 11.3 方法注释

#### .h 中的方法（对外接口）：详细注释，中英双语

使用 **@brief**、**@chinese**、**@param**、**@return** 等，每个参数与返回值都应有 EN/CN 说明。

| 标签 | 说明 |
|------|------|
| @brief | 英文简短描述方法作用 |
| @chinese | 中文简短描述 |
| @param 参数名 | 该参数含义，EN 与 CN 各一行 |
| @return | 返回值含义，EN 与 CN 各一行；void 可省略 |

示例：

```objc
/**
 * @brief Convert FitCloudWWUObject to TSWristWakeUpModel
 * @chinese 将 FitCloudWWUObject 转换为 TSWristWakeUpModel
 *
 * @param wwuObject
 * EN: FitCloudWWUObject object to be converted
 * CN: 需要转换的 FitCloudWWUObject 对象
 *
 * @return
 * EN: Converted TSWristWakeUpModel object, nil if conversion fails
 * CN: 转换后的 TSWristWakeUpModel 对象，转换失败时返回 nil
 */
+ (nullable TSWristWakeUpModel *)modelWithFitCloudWWUObject:(nullable FitCloudWWUObject *)wwuObject;
```

#### .m 中的方法（实现）：简单注释，一行中文即可

只需一行文字说清方法作用，便于阅读实现与排查问题。

```objc
/**
 * 恢复出厂设置
 */
- (void)resetToFactoryWithCompletion:(TSCompletionBlock)completion {
    // ...
}

/**
 * 调整年龄值（有效范围 3-120）
 */
- (void)adjustAge:(NSInteger)delta {
    // ...
}
```

---

### 11.4 属性注释

#### .h 中的属性（对外接口）：详细注释，中英双语

使用 **@brief**、**@chinese** 必选；**@discussion**、**@note** 可选，用于说明取值范围、默认值、使用注意等。

- **@discussion**：详细说明含义或使用场景，用 `[EN]` / `[CN]` 区分中英文。
- **@note**：有效范围、单位、默认值、特殊约定等。

示例：

```objc
/**
 * @brief Callback when push succeeds, before popping (e.g. refresh list on parent)
 * @chinese 推送成功时回调（在 pop 之前），可由列表页设置以刷新数据
 */
@property (nonatomic, copy, nullable) void(^onPushSuccess)(void);

/**
 * @brief Maximum value for triggering a warning when resting heart rate exceeds this value.
 * @chinese 当静息心率超过此值时触发警告的最大值。
 *
 * @discussion
 * [EN]: Used by health module to decide when to alert the user.
 * [CN]: 健康模块据此判断何时对用户进行提醒。
 *
 * @note
 * [EN]: Valid range is 60-100.
 * [CN]: 有效范围为 60-100。
 */
@property (nonatomic, assign) CGFloat restHeartRateMax;
```

#### .m 中的属性（私有/实现用）：简单注释，一行中文即可

一行说明属性含义或用途，可用 `//` 或 `/** */` 单行。

示例：

```objc
// 用户 ID 卡片（无 userId 时隐藏）
@property (nonatomic, strong) UIView *userIdCard;
```

---

### 11.5 注释原则小结

| 位置 | 语言 | 要求 |
|------|------|------|
| .h 类/协议 | 中英双语 | @brief、@chinese；可选 @discussion |
| .h 方法 | 中英双语 | @brief、@chinese、@param、@return |
| .h 属性 | 中英双语 | @brief、@chinese；可选 @discussion、@note |
| .m 方法 | 中文 | 一行简单文字说明方法内容 |
| .m 属性 | 中文 | 一行简单文字说明属性含义或用途 |

- **.h**：对外接口，类、方法、属性均用详细注释（中英双语），便于 SDK 与多端协作。
- **.m**：实现与私有部分，方法、属性均只需**简单注释**，一行中文说明即可。
- 复杂逻辑、边界条件、临时方案可在实现处增加行内注释说明原因。

---

## 十二、方法编写规范

在命名与注释之外，编写方法实现时建议遵循以下原则，保证可读、可维护、可复用且高效。

### 12.1 核心原则（必选）

| 原则 | 说明 |
|------|------|
| **单一职责** | 一个方法只做一件事，便于理解、测试与修改。若一件事可拆成多个步骤，优先拆成多个小方法或私有方法。 |
| **可复用** | 通用逻辑抽成独立方法或工具类，避免复制粘贴；参数化差异部分，便于在不同调用处复用。 |
| **简洁易懂** | 实现尽量简短清晰，逻辑分层明确；避免过深嵌套、过长方法，复杂判断可提取为命名良好的布尔方法或子方法。 |
| **效率** | 避免不必要的循环、重复计算、重复 IO；集合操作注意复杂度，大数组/频繁调用处优先考虑更优算法或缓存。 |

### 12.2 参数与返回值

| 要点 | 说明 |
|------|------|
| **参数数量** | 参数不宜过多（建议 ≤ 4）；过多时用配置对象/模型封装（如 `TSKitConfigOptions`），便于扩展与阅读。 |
| **语义清晰** | 返回值与参数含义明确；可选类型用 `nullable`/`nonnull` 标注，block 回调中成功/失败、error 区分清楚。 |
| **避免魔法值** | 数字、字符串等具业务含义的常量应提取为常量、枚举或只读属性，避免在方法内硬编码。 |

### 12.3 错误与边界

| 要点 | 说明 |
|------|------|
| **入参校验** | 对入参做合理校验（nil、越界、非法值），早返回或走错误分支，避免静默错误或崩溃。 |
| **错误传递** | 异步或可能失败的操作通过 completion 的 `NSError` 或 `BOOL success` 明确传递，便于调用方处理。 |
| **边界与异常路径** | 考虑空集合、空字符串、0、负数等边界；异常路径（如网络失败、解析失败）有明确处理，不吞错。 |

### 12.4 副作用与线程

| 要点 | 说明 |
|------|------|
| **副作用可控** | 方法若会修改状态（属性、单例、全局量），应在注释或命名中体现；纯计算类逻辑尽量无副作用，便于测试与复用。 |
| **线程约定** | 明确方法/回调是在主线程还是后台线程执行；涉及 UI 的回到主线程，耗时操作避免阻塞主线程。 |
| **Block 与内存** | 在 block 内使用 self 时注意循环引用，使用 `__weak`/`__strong`；block 属性根据是否需要持有用 `copy`。 |

### 12.5 长度与复杂度

| 要点 | 说明 |
|------|------|
| **方法长度** | 单方法行数建议控制在可读范围内（如数十行内）；过长时按步骤拆成多个私有方法，主方法只做「编排」。 |
| **圈复杂度** | 分支与循环不宜过多；复杂条件可提取为 `- (BOOL)isValidXXX`、`- (BOOL)shouldDoXXX` 等语义化方法。 |

### 12.6 小结

- **必选**：单一职责、可复用、简洁易懂、效率。
- **推荐**：参数与返回值设计合理、入参校验与错误传递、边界与异常路径处理、副作用与线程约定清晰、方法长度与圈复杂度可控。
- 与**命名规范**、**注释规范**一起使用，便于团队协作与长期维护。

---

## 十三、代码格式与风格

统一缩进、括号、空格与换行，便于阅读与 diff，减少无意义格式争议。

### 13.1 缩进与空格

| 项目 | 约定 |
|------|------|
| **缩进** | 使用 **4 个空格** 为一层缩进，不使用 Tab（或全工程统一 Tab，与 Xcode 设置一致）。 |
| **行尾** | 行末不留空格；文件以换行符结尾。 |
| **缩进单位** | 大括号、条件/循环、方法体、block 体均按层级递增 4 空格。 |

### 13.2 大括号（K&R 风格）

- **左大括号 `{`**：与声明/关键字同一行，后换行；右大括号 `}` 单独一行。
- **单行分支**：若 `if`/`else`/`for`/`while` 体仅一行，仍建议写大括号，避免后续加行时出错。

```objc
// 推荐
- (void)example {
    if (condition) {
        doSomething();
    } else {
        doOther();
    }
}

// 不推荐：左大括号单独占行（Allman 风格与本规范不一致）
- (void)avoid
{
}
```

### 13.3 空格

| 位置 | 约定 |
|------|------|
| **运算符两侧** | 二元运算符两侧各留一空格：`a + b`、`count < 10`、`result = x`。 |
| **关键字后** | `if`、`for`、`while`、`switch` 后留一空格再写括号。 |
| **方法声明/实现** | `-`/`+` 与返回类型之间留一空格；参数类型与 `*` 之间无空格（如 `(NSString *)name`）。 |
| **逗号、分号后** | 逗号后留一空格；分号后不强制（如 for 循环内可 `i++;`）。 |
| **类型与括号** | 类型与 `(` 之间留一空格：`(void)`、`(NSInteger)count`。 |

```objc
- (void)methodWithParam1:(NSString *)param1 param2:(NSInteger)param2 {
    NSInteger result = param2 + 1;
    if (result > 0) {
        [self doSomethingWith:param1];
    }
}
```

### 13.4 空行

| 位置 | 约定 |
|------|------|
| **方法之间** | 同一 `@implementation` 内，方法之间空 **1 行**，便于视觉分段。 |
| **逻辑块之间** | 同一方法内，不同逻辑块之间可空 1 行；连续同类代码可不空行。 |
| **文件头与代码** | 文件头注释与 `#import`、`#import` 与 `@interface`/`@implementation` 之间空 1 行。 |

### 13.5 行宽与换行

| 项目 | 约定 |
|------|------|
| **行宽** | 单行建议不超过 **120 字符**（可依团队习惯改为 100）；超长时换行。 |
| **换行缩进** | 换行后续行相对首行多缩进一层（4 空格），或与上一行参数/表达式左对齐。 |

**方法声明/实现过长时**：参数列表可按参数换行，冒号对齐或续行缩进。

```objc
- (void)longMethodWithFirstParam:(NSString *)first
                     secondParam:(NSInteger)second
                      thirdParam:(NSArray *)third {
    // ...
}
```

**方法调用过长时**：同上，按参数换行，保持可读。

```objc
[self doSomethingWithFirst:obj1
                    second:obj2
                     third:obj3];
```

### 13.6 属性与对齐

| 项目 | 约定 |
|------|------|
| **属性声明** | 每行一个属性；若为对齐可对类型与名称做列对齐，但不强制。 |
| **顺序** | 建议按类型分组：原子性 → 内存语义 → 读写 → 类型 → 名称；或简单按逻辑分组。 |

```objc
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, assign) NSInteger count;
```

### 13.7 .m 文件内部代码顺序

`@implementation` 内建议按以下顺序组织代码，用 `#pragma mark` 分段，便于查找与阅读：

| 顺序 | 内容 | 说明 |
|------|------|------|
| 1 | **生命周期** | `init`、`viewDidLoad`、`viewWillAppear`、`viewDidDisappear`、`dealloc` 等 |
| 2 | **公开方法** | .h 中声明的对外方法实现 |
| 3 | **私有方法** | 仅在本类使用的辅助方法 |
| 4 | **Delegate** | 各类 delegate、dataSource、回调方法（如 `UITableViewDelegate`） |
| 5 | **属性（懒加载 Getter）** | 放最后，属于基础设施代码，不干扰核心逻辑阅读 |

```objc
@interface TSExampleVC ()
// 私有属性写在扩展里
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation TSExampleVC

#pragma mark - 生命周期
- (void)viewDidLoad { ... }
- (void)dealloc { ... }

#pragma mark - 公开方法
- (void)refreshData { ... }

#pragma mark - 私有方法
- (void)setupUI { ... }
- (void)loadData { ... }

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { ... }

#pragma mark - 属性（懒加载）
- (UIView *)contentView { ... }
- (UITableView *)tableView { ... }

@end
```

### 13.8 小结

- **缩进**：4 空格；**大括号**：K&R，单行分支也写大括号。
- **空格**：运算符两侧、关键字后、类型与括号间按上表。
- **空行**：方法间空 1 行；逻辑块、文件头与代码间适当空行。
- **行宽**：建议 ≤120 字符；过长则按参数/表达式换行并缩进。
- **.m 内顺序**：生命周期 → 公开方法 → 私有方法 → delegate → 属性（懒加载 Getter）。
- 与 Xcode 格式化及团队习惯保持一致即可。

---

## 十四、类创建与文件组织规范

何时新建类、何时不建类、何时单独成文件，按下面原则判断，避免过度设计或结构混乱。

### 14.1 什么时候需要创建类

满足以下一种或多种时，建议**创建类**：

| 情况 | 说明 |
|------|------|
| **独立职责** | 有一块清晰职责（如「管理连接」「解析某协议」「某业务配置」），和现有类职责不重叠，适合单独成类。 |
| **可复用** | 逻辑会在多处或多种场景使用，抽成类便于复用和测试。 |
| **有状态与行为** | 既有数据又有对数据的操作，且生命周期明确（如某 Manager、某 Model + 行为）。 |
| **对外接口** | 需要给其他模块或 SDK 使用者调用的类型，应有独立类并在 .h 中声明。 |
| **协议实现** | 实现某协议的一整套逻辑，且可能替换或测试，适合单独类型（或扩展）。 |

典型例子：业务 Model、网络/连接管理类、独立工具类、自定义 View、某功能的 Presenter/Helper。

### 14.2 什么时候可以不创建类

以下情况**不必新建类**，可优先用方法、Category 或内联实现：

| 情况 | 建议 |
|------|------|
| **仅一处使用的简单逻辑** | 用当前类的一个或几个私有方法即可，不必为「只调一次」的逻辑单独建类。 |
| **纯数据、无行为** | 若只是几个字段的临时组装，可用字典、已有 Model 或轻量结构；只有需要强类型和复用再考虑新 Model 类。 |
| **仅对现有类做能力扩展** | 用 **Category**（如 `NSString+TSFormat`）而不是为一点扩展新建子类。 |
| **一次性流程、无复用** | 在当前 VC 或现有类里用方法串起来即可，不必为「一个流程」单独建类，除非流程很重或要复用。 |

原则：**能用一个或几个方法说清楚的，不必为了「面向对象」而建类。**

### 14.3 什么时候必须单独成文件（.h + .m）

以下情况应**为类单独建 .h / .m 文件**：

| 情况 | 说明 |
|------|------|
| **对外暴露** | 在 SDK 或模块的公开头文件中声明、供外部调用，必须独立文件并在 .h 中声明。 |
| **多处在工程内引用** | 被多个 .m 或模块引用，单独文件便于依赖清晰、编译与维护。 |
| **类体量较大** | 属性、方法较多，单独文件可读性更好，符合单一职责。 |
| **协议 + 实现** | 若某协议有独立实现类且可能多处使用或替换，建议单独文件。 |

同一目录下类名与文件名一致，如 `TSUserInfoVC` → `TSUserInfoVC.h` / `TSUserInfoVC.m`。

### 14.4 什么时候可以写在同一文件

以下情况可以**不单独建文件**，写在当前 .m 或与宿主类同文件：

| 情况 | 说明 |
|------|------|
| **仅本 .m 使用的私有类** | 在 .m 顶部用 `@interface XXX ()` 或私有 `@interface PrivateHelper : NSObject`，仅本文件可见，无需 .h。 |
| **仅当前类用的 delegate 实现** | 如某个 VC 自己实现 `UITableViewDelegate`，方法直接写在该 VC 的 .m 里即可（参见 13.7 的 delegate 区）。 |
| **体量很小的辅助类** | 仅少量属性和一两个方法、且只被当前类使用，可放在同一 .m 的 `@implementation` 前或后，保持短小。 |
| **仅本模块用的扩展** | Category 实现若只被本模块引用，可写在对应类的 +Category 的 .m 里（如 `TSModel+Internal.m`）。 |

注意：同一 .m 里若有多个类，建议用 `#pragma mark` 分段，并保持「谁使用谁」关系清晰。

### 14.5 小结

| 问题 | 结论 |
|------|------|
| **何时创建类？** | 有独立职责、可复用、有状态与行为、或需对外接口/协议实现时创建类；否则优先用方法或 Category。 |
| **何时单独成文件？** | 对外暴露、多处引用、体量较大或协议独立实现时单独 .h/.m；仅本文件用的私有类、小辅助类可写在同一 .m。 |

---

## 十五、懒加载规范

属性初始化优先使用**懒加载**（Getter 重写），延迟创建到首次访问时，避免在 `viewDidLoad` 或 `init` 中大段初始化代码堆积。

### 15.1 适用场景

| 适合懒加载 | 不适合懒加载 |
|------------|-------------|
| UI 控件（UILabel、UIButton、UITableView 等） | 必须在 init 时就确定的值（如固定配置） |
| 数据源数组/字典（如 `sourceArray`） | 需要外部传入的依赖 |
| Manager、工具对象等 | 创建后立即被使用且无条件必需 |

### 15.2 写法约定

- 在 **Getter** 中判空并初始化，不在 `viewDidLoad` / `init` 中集中创建。
- Getter 内只做**创建与基础配置**，不做业务逻辑、网络请求等。
- 使用 `_属性名` 直接访问 ivar，避免在 Getter 内递归调用自身。

```objc
// 懒加载 UITableView
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

// 懒加载数据源
- (NSMutableArray *)sourceArray {
    if (!_sourceArray) {
        _sourceArray = [NSMutableArray array];
    }
    return _sourceArray;
}
```

### 15.3 注意事项

- Getter 内**禁止调用 `self.属性名`**（会递归），必须用 `_属性名`。
- 布局代码（Frame 设置）可放在 Getter 内，也可在 `viewDidLoad` 中统一设置，团队内保持一致即可。
- 若属性可能被置为 nil 后重新访问，懒加载会重新创建，确认这是期望的行为。

---

## 十六、Block 与 Notification 命名

### 16.1 Block typedef 命名

| 格式 | 说明 |
|------|------|
| `TS + 功能描述 + Block` | 如 `TSCompletionBlock`、`TSProgressBlock`、`TSSearchResultBlock` |

```objc
typedef void(^TSCompletionBlock)(BOOL success, NSError * _Nullable error);
typedef void(^TSProgressBlock)(CGFloat progress);
typedef void(^TSSearchResultBlock)(TSPeripheral * _Nonnull peripheral);
```

- Block typedef 集中放在公共头文件或对应模块的头文件中，避免分散定义。
- 参数含义在 typedef 处或使用处的注释中说明。

### 16.2 Notification 命名

| 格式 | 说明 |
|------|------|
| `TS + 模块/对象 + Did/Will + 事件 + Notification` | 如 `TSBleDidConnectNotification`、`TSDataSyncWillStartNotification` |

```objc
FOUNDATION_EXTERN NSNotificationName const TSBleDidConnectNotification;
FOUNDATION_EXTERN NSNotificationName const TSBleDidDisconnectNotification;
FOUNDATION_EXTERN NSNotificationName const TSDataSyncDidFinishNotification;
```

- 通知名使用 `FOUNDATION_EXTERN NSNotificationName const` 声明在 .h，在 .m 中赋值。
- `userInfo` 中的 key 同样使用 `TS` 前缀 + 描述：如 `TSNotificationKeyPeripheral`、`TSNotificationKeyError`。

---

## 十七、#import 与前向声明

### 17.1 .h 中优先使用前向声明

在 .h 文件中，若只需要类名或协议名（用于属性类型、参数类型、返回类型等），使用 `@class` / `@protocol` 前向声明，**不要 `#import` 具体头文件**。这样可以：

- 减少头文件间的编译依赖，加快编译速度。
- 避免循环引用（A.h import B.h，B.h import A.h）。

```objc
// TSDeviceListVC.h — 推荐：前向声明
@class TSPeripheral;
@protocol TSDeviceListVCDelegate;

@interface TSDeviceListVC : TSBaseVC
@property (nonatomic, weak) id<TSDeviceListVCDelegate> delegate;
- (void)showPeripheral:(TSPeripheral *)peripheral;
@end

// 不推荐：在 .h 中直接 #import
#import "TSPeripheral.h"          // 不必要，增加编译依赖
#import "TSDeviceListVCDelegate.h" // 不必要
```

### 17.2 .m 中再 #import 实现

在 .m 文件中，`#import` 所有实际需要使用的头文件（访问属性、调用方法、遵循协议等）。

```objc
// TSDeviceListVC.m
#import "TSDeviceListVC.h"
#import "TSPeripheral.h"
#import "TSDeviceListVCDelegate.h"
```

### 17.3 #import 顺序

按以下分组排列，组与组之间空一行，便于查找：

| 顺序 | 分组 | 示例 |
|------|------|------|
| 1 | **本类头文件** | `#import "TSDeviceListVC.h"` |
| 2 | **系统框架** | `#import <UIKit/UIKit.h>`、`#import <CoreBluetooth/CoreBluetooth.h>` |
| 3 | **第三方库** | `#import <FitCloudKit/FitCloudKit.h>` |
| 4 | **本工程其他头文件** | `#import "TSPeripheral.h"`、`#import "TSBaseVC.h"` |

```objc
#import "TSDeviceListVC.h"

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import <FitCloudKit/FitCloudKit.h>

#import "TSPeripheral.h"
#import "TSConnectionHistory.h"
```

### 17.4 小结

- **.h**：用 `@class` / `@protocol` 前向声明，减少编译依赖，避免循环引用。
- **.m**：`#import` 所有需要的头文件。
- **顺序**：本类头文件 → 系统框架 → 第三方库 → 本工程其他头文件，组间空一行。

---

## 十八、内存管理与 dealloc

在 ARC 环境下，大部分内存管理由编译器处理，但以下场景仍需手动关注，尤其在 BLE 回调密集的 SDK 项目中。

### 18.1 属性内存语义

| 类型 | 修饰符 | 说明 |
|------|--------|------|
| 对象（强持有） | `strong` | 默认；拥有对象生命周期。 |
| 委托 / 父级引用 | `weak` | 避免循环引用；delegate 属性必须用 `weak`。 |
| Block 属性 | `copy` | Block 默认在栈上，`copy` 确保移到堆上，延长生命周期。 |
| 基本类型 | `assign` | `NSInteger`、`CGFloat`、`BOOL` 等值类型。 |
| 不可变字符串 | `copy` | 防止外部传入可变字符串后被意外修改。 |

### 18.2 Block 与循环引用

- 在 block 中引用 self 时，使用 `__weak` / `__strong` 打断循环引用。
- 若 block 是临时使用（如方法参数中的 completion），通常不会造成循环引用，无需 weak。
- 若 block 被 self 强持有（如属性），则必须 weak。

```objc
__weak typeof(self) weakSelf = self;
[self doSomethingWithCompletion:^{
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    [strongSelf updateUI];
}];
```

### 18.3 dealloc 中的清理

以下资源必须在 `dealloc` 中手动清理，ARC 不会自动处理：

| 需要清理的资源 | 示例 |
|---------------|------|
| **NSNotificationCenter 观察者** | `[[NSNotificationCenter defaultCenter] removeObserver:self]` |
| **KVO 观察** | `[obj removeObserver:self forKeyPath:@"xxx"]` |
| **NSTimer** | `[self.timer invalidate]` |
| **CFType / C 资源** | `CFRelease(ref)` 等 |

```objc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
}
```

### 18.4 小结

- delegate 用 `weak`，Block 属性用 `copy`，字符串属性用 `copy`。
- block 内引用 self：被 self 持有的 block 必须用 `__weak`/`__strong`；临时 block 不必。
- dealloc 中移除通知、KVO、定时器等，ARC 不自动处理的资源。

---

## 十九、单例写法

项目中 `[TopStepComKit sharedInstance]` 等单例已在使用，统一写法如下。

### 19.1 标准写法

使用 `dispatch_once` + 重写 `allocWithZone:` / `copyWithZone:` / `mutableCopyWithZone:`，彻底保证唯一性：

```objc
// .h
@interface TSBluetoothManager : NSObject <NSCopying, NSMutableCopying>

+ (instancetype)sharedInstance;

@end

// .m
static TSBluetoothManager *_manager = nil;

@implementation TSBluetoothManager

#pragma mark - 单例实现

/// 获取单例实例
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}

/// 重写 allocWithZone 以确保单例模式
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

/// 实现 NSCopying 协议
- (id)copyWithZone:(struct _NSZone *)zone {
    return [[self class] sharedInstance];
}

/// 实现 NSMutableCopying 协议
- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[self class] sharedInstance];
}

#pragma mark - 初始化

/// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化配置
    }
    return self;
}

@end
```

### 19.2 命名约定

| 项目 | 约定 |
|------|------|
| **类方法名** | 统一使用 `sharedInstance`，或 `sharedXXX`（如 `sharedManager`）。 |
| **静态变量** | 文件顶部声明，如 `static TSBluetoothManager *_manager = nil;`。 |

### 19.3 要点说明

| 要点 | 说明 |
|------|------|
| **`dispatch_once`** | 保证线程安全，只创建一次。 |
| **`allocWithZone:`** | 拦截 `alloc`，`[[XXX alloc] init]` 也返回单例。 |
| **`copyWithZone:` / `mutableCopyWithZone:`** | 拦截 `copy` / `mutableCopy`，防止产生新实例。 |
| **`[super allocWithZone:NULL]`** | 在 `sharedInstance` 中调用 super 版本才能真正创建对象，避免递归。 |

### 19.4 注意事项

- **不要在单例的 `init` 中做耗时操作**，避免阻塞首次访问。
- **不要滥用单例**：只有全局唯一且需要共享状态的对象才适合做单例（如连接管理、SDK 入口）。
- 单例生命周期与 App 一致，注意其持有的对象不会被释放。

---

## 二十、日志与错误码

### 20.1 日志规范

| 项目 | 约定 |
|------|------|
| **日志工具** | 优先使用项目内的日志模块（如 `[[TopStepComKit sharedInstance] log]`），而非裸用 `NSLog`。 |
| **日志级别** | 按严重程度使用：`Error`（错误）> `Warning`（警告）> `Info`（关键流程）> `Debug`（调试细节）。 |
| **内容要求** | 包含**模块/类名 + 方法名 + 关键参数/状态**，便于定位问题。 |
| **禁止事项** | 日志中**不打印**密钥、Token、用户密码等敏感信息；Release 包关闭 Debug 级别日志。 |

```objc
// 推荐：包含类名、方法、关键参数
NSLog(@"[TSBluetoothManager] connectToPeripheral: mac=%@, state=%ld", mac, (long)state);

// 不推荐：无上下文，难以定位
NSLog(@"连接了");
```

### 20.2 NSError 约定

| 项目 | 约定 |
|------|------|
| **domain** | 使用项目前缀 + 模块名：如 `TSBleErrorDomain`、`TSDataSyncErrorDomain`。 |
| **code** | 每个模块定义枚举，值不重叠：如 `TSBleErrorTimeout = 1001`。 |
| **userInfo** | 至少包含 `NSLocalizedDescriptionKey`，便于上层展示或排查。 |

```objc
// 定义 domain
FOUNDATION_EXTERN NSErrorDomain const TSBleErrorDomain;

// 定义 code 枚举
typedef NS_ENUM(NSInteger, TSBleErrorCode) {
    TSBleErrorTimeout       = 1001,
    TSBleErrorDisconnected  = 1002,
    TSBleErrorUnsupported   = 1003,
};

// 创建 NSError
NSError *error = [NSError errorWithDomain:TSBleErrorDomain
                                     code:TSBleErrorTimeout
                                 userInfo:@{NSLocalizedDescriptionKey: @"连接超时"}];
```

### 20.3 小结

- 日志用项目日志模块，包含模块/类名/方法/参数，不打敏感信息。
- NSError 统一 domain（`TS + 模块 + ErrorDomain`）、code（枚举，`e` 前缀）、userInfo（至少含描述）。

---

以上开发规范适用于 TopStepComKit 及其 Example 工程的新增与重构代码，历史代码可在修改时逐步对齐。

---
