# TSAIInterpreterVC 产品需求文档

> 模块：TopStepComKit-Git Example / Device / AIKit / Interpreter
> 接口契约：`TSAIInterpreterInterface.startInterpretationWithConfig:onContent:onEvent:completion:` / `stopInterpretationWithTaskId:`
> 文档版本：v1.0 · 2026-05-19

---

## 1. 一句话概述

> **戴上耳机，按下话筒，对方说一句、屏幕实时打一句原文，紧跟一句译文，耳朵里同时听到中文配音。**

`TSAIInterpreterVC` 是 Example 工程内验证「设备同声传译」能力的演示页。它把 `TSAIInterpreterInterface` 的单向长会话管线（**设备麦克风 → ASR → MT → TTS**）包装成一个可肉眼观察的页面：选语言对 → 按下话筒 → 看原文 / 译文双栏字幕逐句"打"出来 → 拿到会话档案。

## 2. 目标用户与场景

| 角色 | 在本页要做什么 |
|------|----------------|
| **SDK 接入方** | 跑通"按下话筒 → 看双栏字幕 → 拿 report"全链路，对照本页代码集成到自家 App。 |
| **SDK 测试 / QA** | 跑不同语言对、Auto 源语、TTS 开关、autoPlayVoice 开关；制造中断（来电、断蓝牙）验证 endReason。 |
| **产品 / Demo 演示** | 现场演示"听一句、字幕一句、耳机播一句"，体感同传体验。 |

非目标：本页 **不** 做录音保存、**不** 做翻译记录的本地数据库、**不** 做与第三方翻译服务的对比；这些由宿主 App 负责。

## 3. 与接口的字段对应（设计的硬约束）

### 3.1 Config → UI 控件

| UI 控件 | 对应字段 | 默认 | 约束 |
|---------|----------|------|------|
| **源语言下拉**（左侧胶囊）| `config.sourceLanguage : TSAILanguage` | `Auto` | 允许 `Auto`；选 `Auto` 时启动后等 `LanguageDetected` 事件回填胶囊文本 |
| **目标语言下拉**（右侧胶囊）| `config.targetLanguage : TSAILanguage` | `zh-CN`（中文）| **禁止 `Auto` / `Unknown`**，下拉列表直接屏蔽 |
| **互换按钮**（中间 ⇄）| 同时交换两个 `TSAILanguage` 值 | — | 会话进行中**禁用**（语言不可热切，需 stop 后重启）|
| **Settings 抽屉 → Voice Output** | `config.enableVoiceOutput : BOOL` | `YES` | 关闭后整个 TTS 链不产出，下面两项灰显 |
| **Settings 抽屉 → Auto Play On Device** | `config.autoPlayVoice : BOOL` | `YES` | 关闭后 SDK 不送到设备扬声器；App 仍可拿 AudioChunk 自行播放 |
| **Settings 抽屉 → Speaker** | `config.speakerId : NSString` | `nil`（后端默认）| 仅当 Voice Output = ON 时可编辑 |

### 3.2 调用动作 → 按钮

| 按钮 | 调用 | 启用条件 |
|------|------|---------|
| **▶ Start**（大圆按钮，灰）| `startInterpretationWithConfig:onContent:onEvent:completion:` | 状态 = Idle 且 targetLanguage 已选 |
| **■ Stop**（大圆按钮，红，呼吸动画）| `stopInterpretationWithTaskId:` | 状态 = Running |

> **同传没有 cancel**——接口刻意只暴露 stop，且 stop = 冲刷最后一段 utterance 后再下发 report。UI 不要提供"丢弃当前会话"的入口，避免与契约语义冲突。

## 4. 三种内容流的渲染语义（最关键的设计约束）

`onContent` 回调 3 类 payload，**字段语义截然不同**，UI 渲染必须区分对待：

| contentType | `text` | `audioChunk` | UI 行为 |
|-------------|--------|-------------|---------|
| **OriginalText** | 累积值 | — | `bubble[utteranceIndex].original.text = content.text`（**整段覆盖**，不要 append）|
| **TranslatedText** | 累积值 | — | `bubble[utteranceIndex].translated.text = content.text`（**整段覆盖**）|
| **AudioChunk** | — | 增量字节 | `playbackBuffer.append(content.audioChunk)`（**追加**到播放缓冲）|

> 文本与音频的语义混用 = 重复播放 / 显示乱码 / 闪烁。**实现时一定要按表分发，不要复用同一个累加器。**

`utteranceIndex` 把同一句话的三种回调归一气泡：

```
utterance #0 ──┬── OriginalText(累积)   → 左栏顶部气泡（说话人侧，灰底）
               ├── TranslatedText(累积) → 右栏顶部气泡（译文侧，蓝底）
               └── AudioChunk(增量)     → 喇叭图标 + 播放进度（默认 SDK 自动播）

utterance #1 ──┬── ……
```

## 5. 页面信息架构

```
┌───────────────────────────────────────────┐
│  < Back     AI Interpreter         ⚙️     │  ← UINavigationBar
├───────────────────────────────────────────┤
│  ┌─ 语言条 ─────────────────────────────┐ │
│  │  [ English (auto) ▾ ]  ⇄  [ 中文 ▾ ] │ │  ← Auto 时副标识 "(auto)"
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 状态条 ─────────────────────────────┐ │
│  │  ●●●  Listening…   taskId=5f3e…     │ │  ← 麦克风电平动画 + 会话状态
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 字幕区（双栏，按 utterance 成对滚动）┐│
│  │  #0  ──────────────────────────────  ││
│  │   ▸ Hello, nice to meet you today.  ││  ← 左栏 OriginalText (源)
│  │   ◂ 你好，今天很高兴见到你。           ││  ← 右栏 TranslatedText (目标)
│  │      🔊 ▮▮▮▮▮ (已播放)               ││  ← AudioChunk 播放进度
│  │  #1  ──────────────────────────────  ││
│  │   ▸ Let's talk about the proj…  ⋯   ││  ← 当前未稳定（浅色）
│  │   ◂ 我们来聊聊那个项                 ││
│  │  #2  …                               ││
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 底部操作 ───────────────────────────┐ │
│  │           ┌─────────┐                │ │
│  │   📜      │   ⏺/⏹   │     ⚙️         │ │  ← 左:历史 中:Start/Stop 右:设置
│  │           └─────────┘                │ │
│  └────────────────────────────────────┘  │
└───────────────────────────────────────────┘

⚙️ Settings 抽屉（半屏 Bottom Sheet）：
┌───────────────────────────────────────┐
│  ────                                  │
│  Voice Output (TTS)         [  on  ]   │  ← enableVoiceOutput
│  Auto Play on Device        [  on  ]   │  ← autoPlayVoice（依赖上一项）
│  Voice (Speaker)          [ xiaogang ▾]│  ← speakerId
│  ──────────────────────────────────    │
│  📋 Logs / Events                       │  ← 展开内嵌 TSAILogView
│       09:42:15 SessionStarted          │
│       09:42:18 LanguageDetected: en    │
│       09:42:20 UtteranceStarted #0     │
│       09:42:23 UtteranceEnded   #0     │
│       09:42:25 PlaybackStarted  #0     │
│       09:42:27 PlaybackEnded    #0     │
└───────────────────────────────────────┘
```

四块自上而下：**语言条 → 状态条 → 字幕双栏 → 底部圆形按钮**。`Settings` 与 `Logs` 收纳进抽屉，避免主页面噪声。

## 6. 状态机

页面只有 4 个状态，所有控件可用性由状态推导：

```
                 ┌──────────┐
                 │   Idle   │◀────────────────┐
                 └────┬─────┘                 │
                      │ 选好 targetLang        │
                      ▼                       │
                 ┌──────────┐                 │
                 │  Ready   │                 │
                 └────┬─────┘                 │
                      │ 点 ⏺ Start            │
                      ▼                       │
                 ┌──────────────┐  Stop /     │
                 │   Running    │──completion─┤
                 └──────┬───────┘  (Interrupt)│
                        │ onException        │
                        ▼                     │
                 ┌──────────┐                 │
                 │  Failed  │── 用户改配置 ───┘
                 └──────────┘
```

| 状态 | Start | Stop | 语言条可改 | Settings 可改 |
|------|-------|------|----------|-------------|
| Idle | 禁用（targetLang 未选）| 禁用 | ✅ | ✅ |
| Ready | ✅ 启用 | 禁用 | ✅ | ✅ |
| Running | 禁用 | ✅ 启用 | ❌（互换按钮也禁）| ❌ |
| Failed | ✅ 启用（重试）| 禁用 | ✅ | ✅ |

## 7. 关键交互流

### 7.1 主流程：默认 Auto 源语 + 中文目标语

| 步骤 | 用户动作 | 页面反馈 | SDK 调用 / 回调 |
|------|---------|---------|----------------|
| 1 | 进入页面 | 语言条显示 `[ Auto ▾ ] ⇄ [ 中文 ▾ ]`；Start 启用；字幕区空 | — |
| 2 | 点 Start | 圆按钮切换到 ■ 红色呼吸态；状态条 "Connecting…" | `startInterpretation...` 同步返回 taskId |
| 3 | （回调）| 状态条 "Listening…" + 电平动画 | `onEvent: SessionStarted` |
| 4 | （回调）| 左语言胶囊文字更新为 "English (auto)" | `onEvent: LanguageDetected, detectedLanguage = en-US` |
| 5 | 对方开始说话 | 字幕区新增 #0 气泡组；电平柱变高；左栏文本逐渐显现 | `onEvent: UtteranceStarted #0` → 多次 `onContent: OriginalText` |
| 6 | （持续）| 右栏译文同步出现（与原文略有延迟）| 多次 `onContent: TranslatedText` |
| 7 | （持续）| 喇叭进度条增长；耳机里听到中文 | 多次 `onContent: AudioChunk`；SDK 自动播放 |
| 8 | 一句结束 | #0 全部气泡变粗体 + ✓ 标记 | `OriginalText.isTextFinal=YES` + `TranslatedText.isTextFinal=YES` + `AudioChunk.isAudioFinal=YES` + `onEvent: UtteranceEnded #0` |
| 9 | 对方继续 | #1 气泡组新增，重复 5–8 | utteranceIndex 递增 |
| 10 | 点 ■ Stop | 圆按钮置灰，状态条 "Finishing…"（等冲刷）| `stopInterpretationWithTaskId:` |
| 11 | （回调）| 状态条隐藏；字幕全部固化；底部弹出"Session ended · 2 utterances · 12.4s"卡片 | `completion(report, nil)`，`endReason = UserStop` |

### 7.2 切换语言对：stop 后用对调 config 重启（模拟"双向"）

| 步骤 | 用户动作 | 页面反馈 | SDK 调用 |
|------|---------|---------|---------|
| 1 | 会话进行中点 ⇄ 互换 | 按钮置灰，不响应 | — |
| 2 | 用户先点 ■ Stop | 等 completion 回调收尾 | `stop...` |
| 3 | 状态回 Idle，点 ⇄ | 两侧语言胶囊互换 | — |
| 4 | 重新点 ⏺ Start | 新会话开始，新 taskId | `start...` |

> 这是协议层"单向"在 App 层的标准玩法。本页不在底部加 "Bidirectional" 开关——避免给开发者错觉。

### 7.3 中断流程（来电 / 蓝牙断开）

| 触发 | 页面反馈 | SDK 回调 |
|------|---------|---------|
| 系统来电中断 AudioSession | 状态条变橙 "Interrupted"；圆按钮置灰；底部弹"Session interrupted"卡片，含已稳定 utterances | `completion(report, nil)`，`endReason = Interrupted` |
| 设备 BLE 断开 | 状态条变红 "Device disconnected"；同上 | `onEvent: BleDisconnected` → `completion(report, nil)`，`endReason = Interrupted` |
| 网络异常（仍可恢复）| 顶部 Toast "Network unstable"，不打断会话 | `onEvent: NetworkError`，会话继续 |

### 7.4 错误流程

| 触发 | 页面反馈 |
|------|---------|
| `targetLanguage = Unknown` 进入 start | Toast "Please pick a target language"；按钮已置灰，兜底 |
| 语言对不支持（接口返回 `eTSErrorNotSupport`）| Toast "Language pair not supported"；状态 → Failed |
| 已有会话在跑（`eTSErrorIsBusy`）| 理论不可达（UI 已禁），日志写一条兜底 |
| 启动失败（completion 拿到 `report=nil, error≠nil`）| 状态 → Failed；底部红色卡片显示 error 描述 |

### 7.5 边界 & 防呆

| 场景 | 处理 |
|------|------|
| 用户在 #1 还在流式中就点 Stop | 圆按钮立刻置灰显示 "Finishing…"；等 completion，#1 会被冲刷下发为最终态 |
| 用户在 Settings 抽屉里关掉 Voice Output | 抽屉关闭后会话不重启；改动**仅影响下次** start；本次会话继续按旧 config 跑（含已经 enable 的 TTS）|
| 用户切到后台再回前台 | 由 AudioSession 中断接管，走 7.3 中断流程 |
| 用户连续点 ⏺ ⏺ | 第二次点击在 Running 状态下已置灰，不响应 |
| `OriginalText.text` 比上一次短（MT 修订）| 直接覆盖，不要做 "diff append"——这是 ASR/MT 流式修订的正常行为 |
| AudioChunk 来了但 autoPlayVoice=NO | 喇叭图标显示，不画进度条；App 自行处理（首版可仅 dump 长度到日志）|

## 8. 字幕区渲染规则

接口契约里 `OriginalText.text` 与 `TranslatedText.text` 都是**累积值**，且尾段可能被修订。渲染要点：

1. **整段 `bubble.text = content.text`**，不要手动 append。
2. 文本视觉态：
   - `isTextFinal = NO` → 灰色斜体 + 末尾呼吸点 `⋯`
   - `isTextFinal = YES` → 黑色正体 + 前缀 `✓`（仅一次，封板态）
3. 双栏布局：源语左对齐（灰底气泡），译文右对齐（蓝底气泡），同一 utterance 上下贴齐、共享 `#index` 标识。
4. 新 utterance 出现时自动滚到底部；用户主动上滑后停止 auto-scroll，右下角浮一个"↓ 新内容"按钮。
5. 视觉上"正在说话"用 3 根呼吸柱表示麦克风电平（UI 假动画，不真接电平数据），避免用 spinner。

## 9. AudioChunk 处理规则

| 配置组合 | UI 行为 | App 责任 |
|---------|--------|---------|
| `enableVoiceOutput=NO` | 喇叭区域不显示 | — |
| `enableVoiceOutput=YES, autoPlayVoice=YES` | 喇叭图标 + 静态 "▮▮▮ playing" 文字（不真画波形）| 0 — SDK 自动播 |
| `enableVoiceOutput=YES, autoPlayVoice=NO` | 喇叭图标 + "App handles audio"小字 | App 须**追加** `audioChunk` 到自己的 PCM 缓冲（注意是增量，不是累积）|

> 默认场景（耳机同传）走第二种；本演示页**首版仅演示前两种**，第三种留日志即可，不在 UI 真画波形（避免与音频细节耦合，让接口契约保持清晰）。

## 10. Settings 抽屉里的日志输出规范

抽屉下方内嵌 `TSAILogView`，记录所有 `onEvent` + completion + 显著 onContent 节点（不打文本内容）：

| 事件 | 日志格式 |
|------|---------|
| 启动 | `HH:mm:ss  ▶ start taskId={short8} src={code|auto} dst={code} tts={Y/N}` |
| SessionStarted | `HH:mm:ss  🟢 SessionStarted` |
| LanguageDetected | `HH:mm:ss  🌐 LanguageDetected: {code}` |
| UtteranceStarted | `HH:mm:ss  🎤 UtteranceStarted #{idx}` |
| UtteranceEnded | `HH:mm:ss  🎤 UtteranceEnded   #{idx}` |
| PlaybackStarted | `HH:mm:ss  🔊 PlaybackStarted  #{idx}` |
| PlaybackEnded | `HH:mm:ss  🔊 PlaybackEnded    #{idx}` |
| NetworkError | `HH:mm:ss  ⚠️  NetworkError`（不打断会话）|
| BleDisconnected | `HH:mm:ss  ❌ BleDisconnected` |
| onContent 文本最终 | `HH:mm:ss  📝 #{idx} {Orig/Trans} final len={len}`（**不打全文**）|
| AudioChunk 最终 | `HH:mm:ss  🎵 #{idx} audio final bytes={total}` |
| completion 正常 | `HH:mm:ss  ✅ done dur={sec}s utt={count} reason={UserStop/Interrupted}` |
| completion 错误 | `HH:mm:ss  ❌ {domain}:{code} {localizedDescription}` |

> 日志**全程不打识别 / 译文内容**——避免开发者把含隐私的测试录音文本提交到 issue。

## 11. Report 卡片（会话结束后弹出）

`completion(report, nil)` 回来后，底部弹出一个总结卡片（不强制保存，仅演示 report 字段）：

```
┌──────────────────────────────────────┐
│  Session Ended                       │
│  ──────────────────────────────────  │
│  Duration       12.4s                │
│  Utterances     3                    │
│  Source → Target   English → 中文    │
│  TTS / AutoPlay    On / On           │
│  End Reason     UserStop             │
│  [ View Utterances ]   [ Dismiss ]   │
└──────────────────────────────────────┘
```

点 **View Utterances** 进入只读列表页（每条显示原文 + 译文 + 起始时间），证明 `report.utterances` 可直接持久化为"翻译记录"。

## 12. 不做什么（划清边界）

- 不做"翻译记录"数据库（仅在弹层里展示一次 utterances 列表，退出页面即清空）
- 不做发音人试听 / 列表（speakerId 是字符串输入框 + 几个 preset 按钮，首版够用）
- 不做"自动断句阈值"调节 UI（VAD 由 SDK 内部控制，协议没暴露）
- 不做"双向面对面"模式开关（如 §7.2，靠 stop+swap+start 模拟）
- 不在 UI 真画 PCM 波形（首版仅展示是否在播）

## 13. 验收 Checklist

- [ ] Idle 状态 Start 按钮：未选 targetLanguage 时置灰
- [ ] Running 状态：互换按钮、语言下拉、Settings 抽屉的 3 项全部禁用
- [ ] Auto 源语：启动后 ≤2s 内左语言胶囊文字更新为检测出的具体语言
- [ ] OriginalText 多次回调：UI 不闪烁、不重复（验证整段覆盖）
- [ ] TranslatedText 出现 "回改"（短了几个字）：UI 正确显示更短的版本
- [ ] AudioChunk autoPlayVoice=YES：耳机听到译文，喇叭进度条增长
- [ ] AudioChunk autoPlayVoice=NO：日志里能看到 bytes 累计，UI 不播
- [ ] Stop 后 ≤500ms 内 completion 回调，report.endReason = UserStop
- [ ] Stop 时若 #N 还在流式中：report.utterances 包含 #N 的最终文本
- [ ] 来电中断：endReason = Interrupted，report.utterances 包含已完成段
- [ ] BLE 断开：onEvent: BleDisconnected → endReason = Interrupted
- [ ] 切换语言对：必须先 Stop 再点 ⇄；Running 时点 ⇄ 无响应
- [ ] 日志区**不含**任何识别 / 译文原文
- [ ] 退出页面（pop）触发 stop，无内存泄漏

---

附：HTML 可交互原型见同目录 `prototype.html`。
