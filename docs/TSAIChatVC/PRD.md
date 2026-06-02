# TSAIChatVC 产品需求文档（PRD）

> 模块：AIKit / Assistant
> 版本：v1.0（首版，配合 SDK `TSAIAssistantInterface` 1.0）
> 文档日期：2026-05-19
> 责任人：磐石

---

## 1. 一句话定位

**TSAIChatVC 是一个端到端的语音对话页：用户戴着设备说话，App 实时显示问答内容、播放 AI 回复音频，支持多轮对话、用户打断、自动超时。**

---

## 2. 背景与目标

### 2.1 背景

`TSAIAssistantInterface` 在 1.0 版本提供了两类能力：

| 能力 | 形态 | 已有 Example |
|------|------|--------------|
| 文本总结（Summary） | 单次流式，文本进 / 文本出 | `TSAISummaryVC` |
| 语音对话（Chat） | 长会话，由设备麦克风音频驱动，多轮问答 | **本次新增 TSAIChatVC** |

文本总结侧重「一锤子买卖 + 流式拼接」，语音对话则是状态机驱动的多轮交互——两者的 UI 交互模型完全不同，必须单独设计。

### 2.2 目标

| 维度 | 目标 |
|------|------|
| **接入演示** | 为 SDK 集成方提供**可复制粘贴**的最小可用范式：如何调 `startChatWithConfig:`、如何分发 `onContent` / `onEvent`、如何处理 `completion`。 |
| **交互验证** | 真机回归 Buds 设备麦克风→ASR→LLM→TTS 的完整链路，覆盖正常结束、超时、打断、断连、网络异常 5 条主路径。 |
| **可视化调试** | 把 `TSAIChatContent`（高频）和 `TSAIChatEvent`（低频）双流分屏可视化，便于排查"回调没回来"或"回调字段不对"的问题。 |

### 2.3 非目标

- **不做**：完整生产级 ChatBot UI（头像、表情、消息气泡阴影、长按操作菜单等都不做）。
- **不做**：会话历史持久化（关闭页面即丢弃，下次重新 start）。
- **不做**：多会话并行（SDK 一次只允许一个会话进行，UI 同样单会话）。

---

## 3. 用户与场景

### 3.1 主要用户

| 角色 | 场景 |
|------|------|
| **SDK 集成方开发** | 在自己 App 里要做语音助手，需要先在 Example 里跑通看效果，再照着抄。 |
| **测试 / QA** | 真机回归 AI 链路，需要把所有事件、所有内容字段都看到，便于报 bug 时贴日志。 |
| **产品 / 演示** | 给客户 / 内部 demo 时，能直接打开页面、按下按钮、看到端到端效果。 |

### 3.2 典型用户故事

> **故事 1（最短路径）**：用户进入页面 → 点麦克风 → 对设备说"今天天气怎么样" → 看到文字"今天天气怎么样" → 看到 AI 回答"今天北京晴" → 听到 AI 语音 → 自动停在空闲态等下一句。

> **故事 2（被打断）**：AI 正在播放回答 → 用户开口说话 → AI 立即停播 → 新一轮提问开始。

> **故事 3（无输入超时）**：用户按下麦克风后 15 秒不说话也没 AI 播放 → 会话自动结束，弹 toast 「会话已超时结束」。

> **故事 4（断连）**：会话进行中设备 BLE 断开 → 收到 `BleDisconnected` 事件 → 提示用户「设备已断开」并自动结束会话。

---

## 4. 功能范围

### 4.1 必做（P0）

| # | 功能 | 对应 SDK |
|---|------|----------|
| F1 | 启动 / 停止会话 | `startChatWithConfig:` / `stopChatWithTaskId:` |
| F2 | 实时显示用户问句（ASR 累积文本） | `onContent` + `contentType = Question` |
| F3 | 实时显示 AI 回复（LLM 累积文本） | `onContent` + `contentType = Answer` |
| F4 | 播放 AI 回复 PCM 音频 | `onContent` + `contentType = AudioChunk` |
| F5 | 状态指示（空闲 / 聆听 / 思考 / 播放 / 出错） | `onEvent` 全 9 种事件类型 |
| F6 | 多轮问答分组显示（按 `roundIndex` 分组） | `TSAIChatContent.roundIndex` |
| F7 | 调试日志面板（双流分屏：Content / Event） | 同 F2~F5 |
| F8 | 会话报告展示（结束后弹层显示 `TSAIChatReport`） | `completion` 回调 |

### 4.2 建议（P1）

| # | 功能 | 说明 |
|---|------|------|
| F9 | 配置面板（语言 / Agent / Speaker / VAD 参数） | 对应 `TSAIChatConfig` 全字段 |
| F10 | 指令意图展示（`Intent` 类型 content） | 把 `intentId` / `query` / `value` 列出来 |
| F11 | 一键复制最近一次会话报告 JSON | 方便贴 bug 单 |

### 4.3 不做（NP）

- 历史会话列表
- 多语种 UI 切换
- 自定义角色头像 / 主题

---

## 5. 核心交互（功能流程）

> 状态机和时序图详见 [Prototype.md](./Prototype.md)。这里只说**用户视角**。

### 5.1 主会话状态（用户能感知的 5 态）

| 状态 | 触发 | 用户看到 | 用户能做 |
|------|------|----------|----------|
| **Idle 空闲** | 进入页面 / 上一会话已结束 | 大圆按钮（麦克风图标）+ 提示语「点击开始对话」 | 点按钮启动 |
| **Listening 聆听中** | `SessionStarted` + `UserSpeechStarted` | 大圆按钮变波纹动画 + 「正在聆听…」+ 实时 Question 文本 | 再点按钮 → stop |
| **Thinking 思考中** | `UserSpeechEnded` 后到 `Answer` 首次到达前 | 三点闪烁动画 + 「思考中…」 | 再点按钮 → stop |
| **Speaking 回复中** | `AIPlaybackStarted` | 波形动画 + Answer 文本流式追加 + 听到 TTS 音频 | 说话打断 / 点按钮 → stop |
| **Ended 已结束** | `completion` 回调 | 弹层显示 `TSAIChatReport` | 关闭弹层 → 回到 Idle |

> Listening / Thinking / Speaking 三态切换是会话内的**轮次**循环，不会回到 Idle。只有 stop / timeout / error / disconnect 才会进 Ended。

### 5.2 触发-反馈表

| 用户触发 | App 行为 | SDK 调用 / 回调 |
|----------|----------|-----------------|
| 点击麦克风按钮（Idle 时） | 进入 Listening，打开音频流 | `startChatWithConfig:` → 收到 `SessionStarted` |
| 点击麦克风按钮（非 Idle 时） | 优雅结束会话 | `stopChatWithTaskId:` → `completion` `endReason=UserStop` |
| 对设备说话 | UI 切到 Listening，文字流式更新 | `onContent` Question 持续 |
| 停止说话 0.8 秒 | UI 切到 Thinking | `UserSpeechEnded` 事件 |
| LLM 出文 | UI 切到 Speaking，文本+音频流 | `onContent` Answer + AudioChunk |
| 再次开口（AI 播放中） | TTS 立即停止，新一轮 Question 开始 | `AIPlaybackInterrupted` + 新 `roundIndex` |
| 长时间不说话 | 超时弹 toast，会话结束 | `AutoEnding` → `Timeout` |
| BLE 断开 | toast「设备已断开」，会话结束 | `BleDisconnected` → 错误结束 |
| 网络异常 | toast「网络异常」，会话结束 | `NetworkError` → 错误结束 |

---

## 6. 信息架构

```
TSAIChatVC（主页）
├── 顶部 NavBar
│   ├── 返回
│   ├── 标题「AI 语音对话」
│   └── ⚙️ 配置入口（弹层 → ConfigSheet，对应 TSAIChatConfig）
│
├── 中间内容区（按状态切换）
│   ├── Idle      → 引导插图 + 「点击开始对话」
│   └── Active    → 多轮问答列表（按 roundIndex 分组）
│        ├── Round 0：Q（用户）/ A（AI）
│        ├── Round 1：Q / A
│        └── ...
│
├── 底部交互区
│   ├── 麦克风状态按钮（Idle / Listening / Thinking / Speaking 四态）
│   ├── 状态文字（同上）
│   └── 「日志」入口（弹层 → LogSheet）
│
└── 浮层
    ├── ConfigSheet     —— 修改 TSAIChatConfig 字段
    ├── LogSheet        —— Content 流 / Event 流双 Tab
    └── ReportDialog    —— 会话结束弹层（TSAIChatReport）
```

---

## 7. 数据与 SDK 字段映射

### 7.1 `TSAIChatConfig` 在 UI 上的映射

| Config 字段 | UI 控件 | 默认值 | 备注 |
|-------------|---------|--------|------|
| `languageHint` | 下拉（zh-CN / en-US / ja-JP / nil 跟随系统） | nil | BCP-47 |
| `initialPrompt` | 多行文本框 | nil | 占位提示 "User's name is John." |
| `agentId` | 文本框 | nil | 占位 "ZNT002" |
| `speakerId` | 文本框 | nil | 占位 "xiaogang" |
| `enableVoiceOutput` | Switch | YES | 关闭后只走文本，不播音频 |
| `allowUserInterrupt` | Switch | YES | 关闭后 AI 播放期间无法打断 |
| `silenceBeforeReplyInterval` | Slider 0.3~2.0s 步长 0.1 | 0.8 | VAD 静默阈值 |
| `autoEndSessionTimeout` | Slider 5~60s 步长 5 | 15.0 | 超时自动结束 |

### 7.2 `TSAIChatContent` 的渲染规则

| contentType | UI 行为 |
|-------------|---------|
| `Question` | 找到当前 `roundIndex` 对应行（无则新建），把 `text` **整体赋值**到 Q 气泡。`isTextFinal=YES` 时停止刷新该气泡。 |
| `Answer` | 同上，渲染到 A 气泡。`isTextFinal=YES` 时本轮 A 气泡定稿。 |
| `AudioChunk` | **append** `audioChunk` 到播放缓冲（`audioFormat` 默认 16kHz / 16bit / mono / PCM-LE）。`isAudioFinal=YES` 时刷新播放队列尾。 |
| `Intent` | 在该轮 A 气泡下方追加一行 chip：`[intent.type] query → value`。 |

> 关键不变量：**`text` 是累积值**（直接赋值给 UI），**`audioChunk` 是增量值**（必须 append）。混用会重复播放或显示错乱。

### 7.3 `TSAIChatEvent` 到 UI 状态的映射

| eventType | UI 行为 |
|-----------|---------|
| `SessionStarted` | 切到 Listening，开始呼吸动画 |
| `UserSpeechStarted` | 波纹动画加强 |
| `UserSpeechEnded` | 切到 Thinking |
| `AIPlaybackStarted` | 切到 Speaking，启动播放波形 |
| `AIPlaybackEnded` | 回到 Listening 等下一句 |
| `AIPlaybackInterrupted` | 立即停止播放，切到 Listening |
| `NetworkError` | toast「网络异常」+ 红色横幅 |
| `BleDisconnected` | toast「设备已断开」+ 灰化输入区 |
| `AutoEnding` | toast「无输入，即将结束」 |

### 7.4 `TSAIChatReport` 报告展示

| 字段 | 展示 |
|------|------|
| `taskId` | monospace 显示完整 UUID，长按复制 |
| `startTime` / `endTime` | "HH:mm:ss" |
| `duration` | "%.1f 秒" |
| `roundCount` | "共 %ld 轮" |
| `endReason` | 中文枚举：用户结束 / 超时 / 取消 / 出错 |

---

## 8. 错误处理

| 错误情形 | 来源 | App 表现 |
|----------|------|----------|
| start 时设备未连接 | `completion` 立刻带 error 返回 | toast「请先连接设备」，按钮回 Idle |
| 会话进行中 BLE 断开 | `BleDisconnected` 事件 | 红色横幅 + 自动结束 + 报告弹层 |
| 会话进行中网络异常 | `NetworkError` 事件 | 红色横幅 + 自动结束 + 报告弹层 |
| 用户长时间不说话 | `AutoEnding` → `Timeout` | toast 提示 + 报告弹层 |
| 会话已结束再点 stop | `stopChatWithTaskId:` 是 no-op | 无副作用，UI 保持 |

> 所有错误均通过统一的 `_handleSessionEnd:reason:error:` 收口，不在多处分散提示。

---

## 9. 性能与体验指标

| 指标 | 目标 | 备注 |
|------|------|------|
| start 到首次 Question 文本到达 | < 1.5s | 受设备链路 + ASR 后端影响 |
| Question 文本刷新延迟 | < 200ms | 流式 ASR 体感即时 |
| Question 结束到 Answer 首字 | < 1.5s | LLM 首 token 时延 |
| AudioChunk 播放卡顿 | < 1% 帧丢失 | 16kHz PCM，缓冲区 ≥ 200ms |
| 单会话内存增长 | < 30 MB | 文本/音频均流式消费，不无限堆积 |

---

## 10. 验收清单

### 功能（P0 全部必过）

- [ ] 进入页面默认 Idle，按钮可点。
- [ ] 点麦克风成功 start，UI 进入 Listening。
- [ ] 对设备说一句话，Q 气泡实时刷新（≥3 次中间态）。
- [ ] 停说后 ~0.8s 进入 Thinking。
- [ ] AI 回复文本流式追加，听到 TTS 音频。
- [ ] 多轮（≥3 轮）正常工作，`roundIndex` 按 0/1/2 分组渲染。
- [ ] AI 播放期间说话能打断，新一轮立刻开始。
- [ ] 长时间不说话触发超时，弹报告，`endReason=Timeout`。
- [ ] 主动 stop 弹报告，`endReason=UserStop`。
- [ ] 会话中拔走设备，UI 收到 `BleDisconnected`，弹报告。
- [ ] 关闭页面（pop）会自动 stop 当前会话，无残留。

### 体验

- [ ] 五态切换有清晰视觉差异（颜色 + 图标 + 动效）。
- [ ] 任意状态下页面无卡顿，无主线程阻塞日志。
- [ ] LogSheet Content / Event 双 Tab 实时刷新，可上下滚动查阅。

### 代码规范（参照 CLAUDE.md）

- [ ] 文件头四件套齐全。
- [ ] `.h` 公共方法 / 属性中英双语 `@brief / @chinese`。
- [ ] `.m` 内 `#pragma mark -` 按 生命周期 / 公开 / 私有 / Delegate / 懒加载 顺序。
- [ ] 无 `NSLog`，使用 `TSLog`。
- [ ] BLE / SDK 回调内更新 UI 已显式 `dispatch_async(main)`。
- [ ] 单文件 ≤ 800 行，超出拆分（Card / View 已独立成文件）。

---

## 11. 文件拆分建议

```
Source/Device/AIKit/Assistant/Chat/
├── TSAIChatVC.h / .m                  # 主控制器，编排状态机
├── View/
│   ├── TSAIChatRoundCell.h / .m       # 单轮 Q/A 双气泡 cell
│   ├── TSAIChatMicButton.h / .m       # 大圆麦克风按钮（4 态动效）
│   ├── TSAIChatStatusLabel.h / .m     # 状态文字（5 态文案）
│   └── TSAIChatLogSheet.h / .m        # 双 Tab 日志面板
├── Sheet/
│   ├── TSAIChatConfigSheet.h / .m     # TSAIChatConfig 编辑面板
│   └── TSAIChatReportDialog.h / .m    # 会话结束弹层
└── Audio/
    └── （复用 Common/TSAIAudioPlayer）
```

> 主 VC 只编排，不渲染。每个独立子组件 ≤ 200 行。

---

## 12. 后续迭代候选

| 方向 | 说明 |
|------|------|
| 历史会话列表 | 持久化 `TSAIChatReport` + Q/A 文本 |
| 文本输入 | 在无法语音时用键盘补打字（需 SDK 增加文本入口） |
| 角色市场 | `agentId` 不再裸字符串，改为带头像的卡片选择 |
| 离线降级 | 网络异常时进入只读模式，不强制结束 |

---

## 13. 关联文档

- 接口定义：`TopStepInterfaceKit/Classes/Source/TSAIKit/TSAIAssistant/TSAIAssistantInterface.h`
- 数据模型：`Model/TSAIChatConfig.h`、`TSAIChatContent.h`、`TSAIChatEvent.h`、`TSAIChatReport.h`、`TSAIChatIntent.h`
- 实现参考（仅 Summary 部分已实现，Chat 暂为占位）：`TopStepBudsKit/Classes/Source/TSAIAssistant/TSBudsAIAssistant.m`
- 原型：[Prototype.md](./Prototype.md)
- 交互演示：[demo.html](./demo.html)
