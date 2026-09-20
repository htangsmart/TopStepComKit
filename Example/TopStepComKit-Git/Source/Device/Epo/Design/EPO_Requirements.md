# EPO 推送功能 Demo 需求文档

> 版本：v0.2（已对齐真实 SDK 接口 `TSEpoInterface`）
> 归属：TopStepComKit Example / Device 模块
> 目标页：`TSEpoViewController`
> 状态：待评审，评审通过后进入开发

---

## 一、背景与目标

SDK 新增 EPO（Extended Prediction Orbit，扩展预测轨道 / GNSS 星历）推送能力。EPO 是预测的卫星轨道数据，用于加速设备 GPS 冷启动定位，有有效期，需定期更新到设备。

本需求为 **Example 工程的验证 Demo**：

1. 在设备功能首页（`TSViewController`）「离线地图」项下方，新增「EPO 星历」入口。
2. 新建 `TSEpoViewController`，覆盖 `TSEpoInterface` 的全部能力：能力检查、四种来源更新、取消、状态查询、清除。

Demo 定位 = **SDK 能力验证 + 开发者调试**。

---

## 二、真实接口对齐（`TSEpoInterface`）

> 路径：`TopStepInterfaceKit/Classes/Source/TSEpo/`

### 2.1 接口方法

| 方法 | 用途 |
|------|------|
| `- (BOOL)isSupportEpo` | 能力检查，其他方法前先调 |
| `- (void)updateEpoWithSource:forceUpdate:progress:success:failure:` | **唯一的更新入口**，来源由 `TSEpoSource` 建模 |
| `- (void)cancelEpoUpdate:` | 取消进行中的更新 |
| `- (void)fetchEpoTimeInfo:` | 查询设备 EPO 时间信息（调试） |
| `- (void)clearEpo:` | 清除设备 EPO 信息（调试） |

### 2.2 来源模型 `TSEpoSource`（四种互斥来源）

由专用工厂方法创建，四种互斥、不可能非法组合：

| 工厂方法 | 类型 | 语义 | App 协议负担 |
|---------|------|------|-------------|
| `+ builtinServer` | `eTSEpoSourceBuiltinServer` | SDK 内置服务器，全自动 | **无**（最省心，默认） |
| `+ customServerWithBaseURL:` | `eTSEpoSourceCustomServer` | 自定义服务器地址（响应格式须与内置一致），下载合并仍由 SDK 做 | 低（只需服务器） |
| `+ fileURLs:types:` | `eTSEpoSourceFileURLs` | App 自备各星座星历文件（本地/远程 URL）+ 星座类型数组，SDK 合并后推送 | 高（须懂 EPO 格式） |
| `+ binFile:` | `eTSEpoSourceBinFile` | App 已按设备格式合并好的最终 bin，SDK 仅推送 | **最重**（须产出完整合并布局+CRC32） |

> `updateEpoWithSource:` 的 source 传 `nil` 等价于 `builtinServer`。

### 2.3 星座类型 `TSEpoType`（fileURLs 用）

原始值必须与设备协议一致，**切勿重排**：

| 值 | 枚举 | 星座 |
|----|------|------|
| 0 | `eTSEpoTypeGPS` | GPS / 美国 |
| 1 | `eTSEpoTypeGLO` | GLONASS / 俄罗斯 |
| 2 | `eTSEpoTypeGALILEO` | Galileo / 欧盟 |
| 3 | `eTSEpoTypeBEIDOU` | 北斗 / 中国 |
| 4 | `eTSEpoTypeIRN` | NavIC / 印度 |
| 5 | `eTSEpoTypeQZSS` | QZSS / 日本 |

### 2.4 `forceUpdate` 参数（关键）

| 取值 | 行为 | 使用场景 |
|------|------|---------|
| `NO` | 若设备当天已更新，failure 回调返回 `eTSErrorNotNecessary` | 自动/定时触发 |
| `YES` | 无条件强制更新 | 用户手动点击 |

⚠️ **`eTSErrorNotNecessary` 不是真失败**：设备星历已是最新。接入方**必须把它当成功/已最新处理，不向用户报错**。binFile 来源无此检查。

### 2.5 状态模型 `TSEpoTimeInfo`

| 字段 | 说明 |
|------|------|
| `validTimestamp` / `validDate` | 星历有效**截止**时间（UTC 秒 / NSDate） |
| `updateTimestamp` / `updateDate` | 上次更新时间 |

⚠️ 模型**只给两个时间点**。「是否过期」「剩余天数」需 **App 自行用 `validDate` 与当前时间计算**。

### 2.6 进度与回调

- 进度 `progress` 回调 0–100，SDK 内部「下载 → 合并 → 推送落盘」统一映射为一条进度。
- 复用 `TSFileTransferProgressBlock / SuccessBlock / FailureBlock`（与 FileOTA 同一套）。

---

## 三、页面结构（TSEpoViewController）

```
┌─────────────────────────────────┐
│ ① 状态卡片                        │
│   有效性(App 算) · 有效期至 · 上次更新 │
│   [刷新]              [清除 EPO]   │
├─────────────────────────────────┤
│ ② 更新区                          │
│   ┌───────────────────────────┐  │
│   │  一键更新 (builtinServer)   │  │ ← 主按钮，突出
│   └───────────────────────────┘  │
│   强制更新(forceUpdate) [开关]     │
│   ▸ 高级来源（可展开）             │
│      · 自定义服务器 customServer   │
│      · 自备星座文件 fileURLs       │
│      · 自备 bin 文件 binFile       │
├─────────────────────────────────┤
│ ③ 操作日志控制台                   │
└─────────────────────────────────┘
```

更新进行中，②区整体切进度态（进度环+状态文案+取消）。

---

## 四、功能详述

### 4.1 状态卡片（①）

进页自动 `fetchEpoTimeInfo:`，展示：

| 展示项 | 数据来源 |
|--------|---------|
| 有效性标识（有效/即将过期/已过期/未知） | **App 用 `validDate` 与当前时间计算** |
| 有效期至 | `validDate` 格式化 |
| 上次更新 | `updateDate` 格式化 |

有效性计算规则（App 侧，阈值暂定）：

| 状态 | 颜色 | 条件 |
|------|------|------|
| 有效 | `TSColor_Success` | `validDate - now > 2 天` |
| 即将过期 | `TSColor_Warning` | `0 < validDate - now ≤ 2 天` |
| 已过期 | `TSColor_Danger` | `validDate ≤ now` |
| 未知 | `TSColor_TextSecondary` | 查询失败 / 无数据 |

- 右上「刷新」：手动重查。
- 「清除 EPO」（`clearEpo:`）：调试用，二次确认后清除，成功则状态转「未知」并日志记录。

### 4.2 更新区（②）

#### 主入口：一键更新
- 大按钮，直接调 `updateEpoWithSource:builtinServer forceUpdate:(开关值)`。
- 传 `nil` 与 `builtinServer` 等价，实现用显式 `builtinServer` 更清晰。

#### forceUpdate 开关
- 位于主按钮下方，默认 **ON**（用户手动点击语义）。
- 关闭时演示：当天已更新会回 `eTSErrorNotNecessary`，Demo **当成功**处理，Toast/日志提示「已是最新，无需更新」。

#### 高级来源（默认折叠，`▸` 展开）
标注「需了解 EPO 协议，调试用」：

| 项 | 交互 | source 构造 |
|----|------|------------|
| 自定义服务器 | 弹窗输 baseURL | `customServerWithBaseURL:` |
| 自备星座文件 | 选 1+ 文件 + 指定星座类型 | `fileURLs:types:` |
| 自备 bin 文件 | 文件选择器选 .bin | `binFile:` |

> ⚠️ Demo 无法生成合法的 fileURLs/binFile 内容，这两项主要验证「能构造 source + 触发 + 错误回显」，不保证设备侧成功。UI 上对这两项加说明文案。

所有来源共用同一 `updateEpoWithSource:` 与同一进度/结果 UI。

### 4.3 进度态

- 单一总进度环 0–100% + 状态文案（可随「下载中/推送中」变）+ 取消按钮（`cancelEpoUpdate:`）。
- 不区分下载/推送两段进度条。

### 4.4 结果处理

| 回调 | 处理 |
|------|------|
| success | Toast「更新成功」+ 刷新①状态 + 日志 + 回入口态 |
| failure（`eTSErrorNotNecessary`） | **当成功**：Toast「已是最新，无需更新」+ 日志(info) + 回入口态 |
| failure（其他 error） | Toast 错误信息 + 日志(err，含 code) + 回入口态 |
| cancel | Toast「已取消」+ 日志 + 回入口态 |

### 4.5 操作日志控制台（③）

- 时间戳 + 操作 + 结果滚动文本，深色终端风。
- 记录来源类型、forceUpdate 值、error code，便于调试。
- 「清空」按钮，仅内存留存。

---

## 五、状态机

```
   Idle 入口态 ──点击任一来源──▶ Pushing 进度态
      ▲                              │
      │      success / notNecessary / │
      └──────  failure / cancel  ◀────┘
          (Toast + 刷新状态卡 + 日志)
```

```objc
typedef NS_ENUM(NSInteger, TSEpoUpdateState) {
    TSEpoUpdateStateIdle = 0,   // 入口态
    TSEpoUpdateStatePushing,    // 更新中
};
```

---

## 六、UI 设计规范（对齐现有 Example）

| 元素 | 规范 |
|------|------|
| 背景 | `TSColor_Background` |
| 卡片 | `TSColor_Card`，圆角 12，阴影 opacity 0.05 |
| 主按钮 | `TSColor_Primary`，高 52，圆角 26，`TSFont_H2` 白字 |
| 进度环 | 外径 140，线宽 8，底 `TSColor_Separator`，前景 `TSColor_Primary` |
| 主/次文字 | `TSColor_TextPrimary` / `TSColor_TextSecondary` |
| 卡片内边距 | 16 |
| 布局 | 纯 frame，继承 `TSBaseVC` 的 `initData/setupViews/layoutViews` |
| 国际化 | 全部文案 `TSLocalizedString` |

---

## 七、入口改动（TSViewController）

在离线地图 `TSValueModel`（约 478 行）后新增：

```objc
TSValueModel *m = [TSValueModel valueWithName:TSLocalizedString(@"device.menu.epo")
                                      kitType:eTSKitEpo
                                       vcName:NSStringFromClass([TSEpoViewController class])
                                     iconName:@"location.fill.viewfinder"
                                    iconColor:TSColor_Teal
                                     subtitle:TSLocalizedString(@"device.menu.epo.sub")];
m.enabled = hasDevice && [[[TopStepComKit sharedInstance] epo] isSupportEpo];
```

需在 `TSValueModel.h` 的 `TSKitType` 枚举末尾追加 `eTSKitEpo`。

---

## 八、文件结构（计划）

```
Source/Device/Epo/
├── VC/
│   ├── TSEpoViewController.h
│   └── TSEpoViewController.m
├── View/
│   ├── TSEpoStatusCard.h/.m       # 状态卡片（①，含过期计算）
│   └── TSEpoConsoleView.h/.m      # 日志控制台（③）
└── Design/
    ├── EPO_Requirements.md        # 本文档
    └── EPO_Prototype.html         # HTML 交互原型
```

> VC 若能控制在 800 行内，子视图较轻时可暂不拆，评审定。

---

## 九、待讨论问题

1. 主入口图标选型：`location.fill.viewfinder` vs `antenna.radiowaves.left.and.right`。
2. 「即将过期」阈值（暂定 2 天）是否合适。
3. 高级来源（fileURLs/binFile）在 Demo 里既然造不出合法数据，是否只保留 customServer + binFile 触发验证，fileURLs 仅留一个"构造 source"演示？
4. `TopStepComKit` 主入口获取 epo 实例的属性名（如 `[[TopStepComKit sharedInstance] epo]`）需与实现层确认。
5. 进度状态文案是否需要随「下载/合并/推送」阶段细分。
