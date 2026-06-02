# TSAIASRDeviceMicVC 产品需求文档（PRD）

> 设备麦克风流式语音识别 · Demo 页面
> 版本 v1.0 · 2026-05-19 · 磐石

---

## 0. TL;DR

一个 Demo 页面，用于演示「**对已连接设备（耳机 / 眼镜 / 手表）的麦克风采集音频做实时流式语音识别**」这一 SDK 能力。

它和"普通手机录音 ASR"的根本区别：
- 音源是**设备端硬件麦克风**，不是手机麦克风。
- SDK 内部完成 3 件事：① 激活设备 AI 能力、② 打开设备麦克风、③ 把音频帧桥接到识别管道。调用方只需要给 config 和回调。
- **没有自然结束点** —— 调用方必须显式 `stop`（冲刷拿最终结果）或 `cancel`（丢弃）。

---

## 1. 背景与目标

### 1.1 背景

- TopStepComKit 已对外暴露 `TSAISpeechInterface`，其中包含「文件 ASR」「设备麦克风 ASR」「TTS」三类能力。
- 「设备麦克风 ASR」是 **AI 录音 / AI 对话** 系列功能的入口，用于把可穿戴设备变成"远程拾音 + 实时转写"的麦克风。
- 当前 Example 工程的 `TSAIASRDeviceMicVC.m` 仅有占位代码，需要一个完整的 Demo 把整条链路跑通，便于：
  - 集成方理解能力边界与回调时序；
  - QA 验证「stop / cancel / 中断」三类结束路径；
  - 调试设备端音频落盘文件与场景模型选择。

### 1.2 目标

| 类型 | 目标 |
|------|------|
| **核心** | 跑通「**配置 → 启动 → 流式识别中 → stop/cancel → 最终结果 + 录音回放**」全流程。 |
| **核心** | 直观展示流式识别的"句子稳定/未稳定"状态变化。 |
| **核心** | 清晰区分 `stop` 与 `cancel` 的语义差异。 |
| **辅助** | 暴露原始日志，便于一线排查。 |
| **非目标** | 不做发音人选择（属 TTS）；不做长时录音的本地文件管理；不做多设备并发。 |

### 1.3 受众

- **App 集成方研发** —— 通过 Demo 学习 API 用法。
- **SDK QA** —— 验证 SDK 行为与文档一致。
- **PM / 设计** —— 体感真实交互流，确认产品形态。

---

## 2. 关键概念与术语

| 概念 | 含义 |
|------|------|
| 设备麦克风 ASR | 对已连接设备（耳机 / 眼镜 / 手表）的麦克风采集音频做流式识别。 |
| taskId | SDK 同步返回的客户端 UUID，用于关联 partial / completion，并支持 stop / cancel。 |
| Partial 中间结果 | `TSAIASRPartialResult`，累积识别文本，不是新增片段。 |
| 句子稳定 | `partial.isSentenceFinal == YES`，当前句不再修订。 |
| stop | 冲刷已缓冲音频 → 通过 completion 下发**最终结果**。 |
| cancel | 关闭音频流 → completion 携带**取消错误**，结果作废。 |
| 离线降级 | `offlineFallbackEnabled = YES` 时，在线不可用允许回落到端侧离线引擎。 |
| 场景 | `TSAIASRScene`，提示后端选用更匹配的声学模型（`OnSite` / `Call`）。 |
| 录音落盘 | 会话结束后 `result.recordedAudioFileURL` 指向的可播放音频文件。 |

---

## 3. 用户故事 / 使用场景

### US-1 工程师快速验证

> 作为接入方研发，我打开 Demo 页 → 选语言 → 点 Start → 对着耳机说话 → 看到屏幕上文字实时滚动出来 → 点 Stop → 看到最终结果文本 + 一段可播放的 MP3。

### US-2 QA 验证三种结束路径

> 作为 QA，我连续做三次会话：分别用「Stop」「Cancel」「等待 15 秒静音超时（被底层关闭）」三种方式结束，确认 completion 回调和 result 字段符合预期。

### US-3 一线排障

> 作为支持工程师，客户报告"识别不出来"。我让客户复现，把日志区的内容截图发回，根据日志里的 taskId、partial 计数、duration、`isOfflineRecognition`、`recordedAudioFormat` 等定位到是网络问题还是设备端没拾到音。

---

## 4. 功能边界

### 4.1 必须支持（Must）

1. 选择**识别语言**（不允许 `Auto` / `Unknown`）。
2. 切换**场景**（`Unknown` / `OnSite` / `Call`）。
3. 切换**离线降级开关**（`offlineFallbackEnabled`）。
4. 切换**期望录音格式**（`outputAudioFormat`，默认 MP3）。
5. **Start** 启动会话，立刻显示 taskId（短码）。
6. 流式显示 partial 结果，用不同视觉表达「已稳定句」与「正在修订句」。
7. **Stop** 主动结束 → 渲染最终 result（文本 + 时长 + 实际录音格式 + 是否离线 + 是否中断）。
8. **Cancel** 主动丢弃 → 渲染取消提示。
9. 支持**回放**录音文件（`recordedAudioFileURL`）。
10. 完整日志（partial 计数、句序号、关键回调、错误 domain/code/message）。
11. `viewWillDisappear` / `dealloc` 自动 cancel 进行中任务，防泄漏。

### 4.2 不做（Won't）

- 多任务并发：底层同一时刻只允许一个设备麦克风 ASR 任务。
- 编辑 / 复制 / 分享识别文本 —— Demo 范畴外。
- 录音文件二次上传 —— Demo 范畴外。
- 自定义降噪、VAD 参数 —— SDK 未暴露。

---

## 5. 信息架构

```
TSAIASRDeviceMicVC
├── 顶部状态栏（设备连接 + 任务状态徽章）
├── 配置卡片
│   ├── 识别语言（必选）
│   ├── 场景（Unknown / OnSite / Call）
│   ├── 离线降级（Switch）
│   └── 期望录音格式（None/PCM/Opus/MP3/WAV）
├── 任务 Meta 行
│   └── 状态文案 + taskId（短码）+ 计时
├── 主操作区（三按钮）
│   ├── Start
│   ├── Stop（冲刷 → 最终结果）
│   └── Cancel（丢弃）
├── 流式识别结果区
│   ├── 已稳定文本（深色，常规字重）
│   └── 当前修订中文本（浅色，斜体；isSentenceFinal=NO）
├── 最终结果卡片（仅 Stop 成功后展示）
│   ├── 累积文本
│   ├── 时长 / 起止时间
│   ├── 场景回填 / 在线还是离线 / 是否被中断
│   └── 录音回放（▶ / ⏸ / 进度条）
└── 日志区（开发者视角）
```

---

## 6. 状态机

### 6.1 8 个状态

| 状态 | 触发 | 退出 |
|------|------|------|
| **Idle** | 进入页面 / 上次会话清理完成 | 点 Start → Starting |
| **Unsupported** | `aiSpeech == nil` 或 `isSupport == NO` | 不可退出（提示用户） |
| **Starting** | 同步调用 `recognizeSpeechWithDeviceMicConfig:`，等首个回调 | 收到首个 partial → Recognizing；启动失败 → Failed |
| **Recognizing** | 持续接收 partial | 用户点 Stop → Stopping；点 Cancel → Cancelling；底层 onError → Failed |
| **Stopping** | 调 `stopDeviceMicRecognitionWithTaskId:`，等 completion | completion 成功 → Finished；带错误 → Failed |
| **Cancelling** | 调 `cancelRecognitionWithTaskId:`，等 completion | completion → Cancelled |
| **Finished** | Stop 成功，最终结果渲染完毕 | 点 Start → Starting |
| **Failed** | 底层 onError / Stop 时报错 | 点 Start → Starting |
| **Cancelled** | Cancel 完成 | 点 Start → Starting |

### 6.2 状态转移图

```
              ┌──────────────┐
   首次进入 ─►│   Idle       │
              └─┬────────────┘
                │ Start
                ▼
              ┌──────────────┐ onError       ┌───────┐
              │  Starting    │──────────────►│Failed │◄─┐
              └─┬────────────┘               └───┬───┘  │
                │ 首个 partial                    │ Start │
                ▼                                ▼      │
              ┌──────────────┐ Stop  ┌──────────┐       │
              │ Recognizing  │──────►│ Stopping │──────►│Finished│
              └─┬────────────┘       └──────────┘ 成功   └────────┘
                │ Cancel             │ 失败 ─────────────►Failed
                ▼                    │
              ┌──────────────┐       │
              │ Cancelling   │       │
              └─┬────────────┘       │
                ▼                    ▼
              ┌──────────────┐
              │  Cancelled   │
              └──────────────┘
```

### 6.3 各状态下的按钮可用性

| 状态 | Start | Stop | Cancel | 配置区 |
|------|:-----:|:----:|:------:|:-----:|
| Idle / Finished / Cancelled / Failed | ✅（须先选语言）| ❌ | ❌ | ✅ |
| Starting | ❌ | ❌ | ✅ | ❌ |
| Recognizing | ❌ | ✅ | ✅ | ❌ |
| Stopping / Cancelling | ❌ | ❌ | ❌（按钮转为 loading）| ❌ |
| Unsupported | ❌ | ❌ | ❌ | ❌ |

---

## 7. 原型图（线框）

> 移动端 375×812 视区。所有圆角 12pt，主色蓝 `#0A84FF`，成功绿 `#34C759`，警告橙 `#FF9500`，危险红 `#FF3B30`。

### 7.1 Idle / 首次进入

```
┌─────────────────────────────────────────┐
│   ‹                设备麦克风 ASR        │  ← 导航栏
├─────────────────────────────────────────┤
│  🎧 已连接设备：W1 Earbuds       [Idle]  │  ← 顶部状态栏（徽章灰色）
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 配置                                │ │
│ │ ─────────────────────────────────── │ │
│ │ 识别语言    [简体中文 ▼]            │ │
│ │ 场景        [未指定 ▼]              │ │
│ │ 离线降级    ◯——●  关                │ │
│ │ 录音格式    [MP3 ▼]                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│  状态: 空闲                              │  ← 任务 Meta（灰）
│                                         │
│ ┌─────────┐ ┌──────┐ ┌──────┐           │
│ │  Start  │ │ Stop │ │Cancel│           │  ← 三按钮（Stop/Cancel 灰）
│ └─────────┘ └──────┘ └──────┘           │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 流式识别结果                        │ │
│ │ ─────────────────────────────────── │ │
│ │   等待开始 …                        │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 日志                                │ │
│ │ ─────────────────────────────────── │ │
│ │ ready.                              │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 7.2 Recognizing 中（流式累积）

```
│  🎧 已连接设备：W1 Earbuds   [Recognizing]│  ← 徽章蓝色 + 脉冲点
│                                          │
│ ┌─配置（已禁用，半透明）──────────────┐  │
│ │ 识别语言    简体中文                │  │
│ │ 场景        现场（OnSite）          │  │
│ │ 离线降级    关                      │  │
│ │ 录音格式    MP3                     │  │
│ └─────────────────────────────────────┘  │
│                                          │
│  状态: 识别中 · taskId=8f3a…2b1c · 00:07 │
│                                          │
│ ┌──────┐ ┌─────────┐ ┌───────┐           │
│ │ Start│ │  Stop   │ │ Cancel│           │  ← Stop/Cancel 高亮
│ └──────┘ └─────────┘ └───────┘           │
│                                          │
│ ┌─流式识别结果────────────────────────┐  │
│ │ 我今天去了北京站，准备坐高铁         │  ← 已稳定（深色）
│ │ 然后又转地铁去了天                   │  ← 修订中（浅色斜体）
│ │ ●                                    │  ← 录音脉冲指示
│ └─────────────────────────────────────┘  │
│                                          │
│ ┌─日志────────────────────────────────┐  │
│ │ ▶ start lang=zh-CN scene=onSite     │  │
│ │   taskId=8f3a…2b1c                  │  │
│ │ partial #1 s#0 f#0 final=N len=4    │  │
│ │ partial #2 s#0 f#1 final=N len=8    │  │
│ │ partial #3 s#0 f#2 final=Y len=14   │  │
│ │ partial #4 s#1 f#0 final=N len=18   │  │
│ └─────────────────────────────────────┘  │
```

### 7.3 Finished（Stop 成功）

```
│  🎧 已连接设备：W1 Earbuds      [Finished]│
│                                          │
│ ┌─配置（恢复可点）─────────────────┐    │
│ │ ……                                │    │
│ └────────────────────────────────────┘    │
│                                          │
│ ┌─Start─┐ ┌─Stop ─┐ ┌─Cancel┐            │
│                                          │
│ ┌─最终结果─────────────────────────┐    │
│ │ 我今天去了北京站，准备坐高铁，然  │    │
│ │ 后又转地铁去了天安门广场。        │    │
│ │ ──────────────────────────────── │    │
│ │ 时长 12.4s · 在线识别 · 现场场景  │    │
│ │ 起止 14:23:08 → 14:23:20         │    │
│ │ ──────────────────────────────── │    │
│ │ 录音 MP3 · 96 KB                 │    │
│ │ ┌──────────────────────────────┐ │    │
│ │ │ ▶ ━━━━●━━━━━━━━  00:05/00:12 │ │    │
│ │ └──────────────────────────────┘ │    │
│ └────────────────────────────────────┘    │
│                                          │
│ ┌─日志────────────────────────────────┐  │
│ │ ▶ stop requested                    │  │
│ │ ✓ done duration=12.4s text.len=24   │  │
│ │   recorded=MP3 96KB offline=N int=N │  │
│ └─────────────────────────────────────┘  │
```

### 7.4 Failed（识别中报错）

```
│  🎧 已连接设备：W1 Earbuds        [Failed]│  ← 徽章红色
│                                          │
│ ┌─流式识别结果（已停止）──────────────┐  │
│ │ ⚠ 网络异常                           │  │  ← 红色标题
│ │                                      │  │
│ │ domain=com.topstepbudskit.aiSpeech   │  │
│ │ code=-1009                           │  │
│ │ msg=The Internet connection appears  │  │
│ │      to be offline.                  │  │
│ └─────────────────────────────────────┘  │
```

### 7.5 Unsupported

```
│  ⚠ 当前设备不支持 AI 语音能力             │  ← 顶部红 banner
│                                          │
│  请连接支持 AI 能力的耳机/眼镜后重试。   │
│                                          │
│  整页所有按钮置灰、配置只读                │
```

---

## 8. 关键交互流程（时序）

### 8.1 正常 Stop 路径

```
User       VC         SDK                        Device
  │  点 Start │                                     │
  │──────────►│ recognizeSpeechWithDeviceMicConfig: │
  │           │────────────────────────────────────►│ 激活 AI / 开麦
  │           │◄── taskId（同步返回）               │
  │           │  state→Starting                     │
  │           │                                     │
  │           │◄─ partial #1 (s#0,f#0,final=N) ─────│
  │           │  state→Recognizing                  │
  │           │◄─ partial #2 (s#0,f#1,final=N) ─────│
  │           │◄─ partial #3 (s#0,f#0,final=Y) ─────│ 第 0 句封板
  │           │◄─ partial #4 (s#1,f#0,final=N) ─────│ 进入第 1 句
  │  点 Stop  │                                     │
  │──────────►│ stopDeviceMicRecognitionWithTaskId: │
  │           │────────────────────────────────────►│ 关麦 + 冲刷
  │           │  state→Stopping                     │
  │           │                                     │
  │           │◄── completion(result, nil) ─────────│
  │           │  state→Finished                     │
  │           │  渲染最终文本 + 录音回放            │
```

### 8.2 Cancel 路径

```
  ……（识别中）
  │ 点 Cancel │
  │──────────►│ cancelRecognitionWithTaskId:        │
  │           │  → 立刻清状态 + state→Cancelling     │
  │           │  → 调 stopAIChat                    │
  │           │────────────────────────────────────►│ 关麦
  │           │  → 立刻 completion(nil, cancelErr)  │
  │           │  state→Cancelled                    │
  │           │  渲染"已取消"提示                   │
  │
  注：底层迟到的 partial / onFinish 会因 taskId 不匹配被丢弃。
```

### 8.3 中断（来电）路径

```
  ……（识别中）
  │           │  ◄── 系统中断 / 设备断连              │
  │           │  ◄── completion(result, err) ────────│
  │           │  result.isStoppedByInterruption=YES │
  │           │  state→Failed（保留中断前已识别文本）│
```

### 8.4 再次进入页面

`viewWillDisappear` 自动 cancel 当前任务；重新进入是干净的 Idle。

---

## 9. UI 细节与设计令牌

### 9.1 颜色

| 用途 | Light | Dark |
|------|-------|------|
| 主色（按钮 / 链接） | `#0A84FF` | `#0A84FF` |
| 成功（Finished 徽章） | `#34C759` | `#30D158` |
| 警告（Cancelled / Stopping） | `#FF9500` | `#FF9F0A` |
| 危险（Failed / Cancel 按钮） | `#FF3B30` | `#FF453A` |
| 已稳定文字 | `#1C1C1E` | `#F2F2F7` |
| 修订中文字 | `#8E8E93` | `#8E8E93` |
| 卡片背景 | `#F8F8F8` | `#1C1C1E` |
| 描边 | `#E5E5EA` | `#3A3A3C` |

### 9.2 字号

| 元素 | 字号 / 字重 |
|------|------------|
| 导航栏标题 | 17 / Semibold |
| 卡片标题 | 14 / Medium |
| 流式识别正文 | 17 / Regular（已稳定）/ Italic（修订中）|
| 状态徽章 | 11 / Semibold |
| 日志 | 11 / Monospaced |

### 9.3 间距

水平左右各 12pt；卡片间 12pt；卡片内 padding 12pt；行间距 8pt。

### 9.4 录音回放

- 进度条：高 4pt，圆角 2pt，主色填充。
- 播放按钮：32×32 圆形，主色背景白色图标，仅 Finished 状态出现。
- 不实现导出/分享按钮（Demo 范畴外）。

---

## 10. 异常与边界

| 场景 | 处理 |
|------|------|
| 未选语言点 Start | Start 按钮置灰，提示「请先选择识别语言」。 |
| `aiSpeech == nil` 或 `isSupport == NO` | 进入 **Unsupported** 状态，整页只读。 |
| 同时只能跑一个任务 | 底层会以 `eTSErrorIsBusy` 拒绝；Demo 不暴露这个分支，因为 UI 层已禁用按钮。 |
| 切到后台 / 离开页面 | `viewWillDisappear` 自动 cancel；下次回来从 Idle 开始。 |
| 录音文件不存在 | 回放区显示「无录音文件」灰条，不可点。 |
| Stop 时已经超过会话超时（15s 静音） | 底层会主动 finish；UI 收到 completion 走 Finished 路径，看到的是底层"自动结束"的结果。这种情况和"用户主动 Stop"对外行为一致。 |
| Cancel 后底层迟到 partial / finish | taskId 不匹配，VC 直接丢弃。日志可记一行 `dropped late callback`。 |

---

## 11. 与 SDK 接口的精确映射

| UI 控件 | 对应字段 |
|---------|---------|
| 「识别语言」选择器 | `TSAIASRDeviceMicConfig.language`（不允许 Auto/Unknown）|
| 「场景」选择器 | `TSAIASRDeviceMicConfig.scene` |
| 「离线降级」开关 | `TSAIASRDeviceMicConfig.offlineFallbackEnabled` |
| 「录音格式」选择器 | `TSAIASRDeviceMicConfig.outputAudioFormat` |
| 「Start」按钮 | `recognizeSpeechWithDeviceMicConfig:onPartialResult:completion:` |
| 「Stop」按钮 | `stopDeviceMicRecognitionWithTaskId:` |
| 「Cancel」按钮 | `cancelRecognitionWithTaskId:` |
| 流式文本区 | `TSAIASRPartialResult.text`（累积），`isSentenceFinal` 决定样式 |
| 最终结果区 | `TSAIASRDeviceMicResult` 全字段（text / duration / scene / isOfflineRecognition / isStoppedByInterruption / recordedAudioFileURL / recordedAudioFormat） |

---

## 12. 验收清单（DoD）

- [ ] Idle → Start → Recognizing → Stop → Finished：文本正确、录音可播放。
- [ ] Idle → Start → Recognizing → Cancel → Cancelled：completion 携带取消错误，结果作废。
- [ ] Idle → Start（未连设备）→ Failed：错误 domain/code/message 完整展示。
- [ ] 流式过程中 `isSentenceFinal=NO` 文字浅色斜体，=YES 后变深色常规。
- [ ] 离开页面会自动 cancel，再次进入是干净 Idle。
- [ ] Unsupported 状态整页只读，提示语正确。
- [ ] 日志包含：start / taskId / 每条 partial / stop or cancel / completion 摘要。
- [ ] 配置区在 Recognizing/Stopping/Cancelling 状态下不可编辑。
- [ ] 同一 taskId 在 partial 与 result 中能对得上。

---

## 13. 交付物

| 交付 | 路径 |
|------|------|
| 本 PRD（含原型图、状态机、交互） | `docs/TSAIASRDeviceMicVC-PRD.md` |
| 可交互 HTML 原型（模拟全流程） | `docs/TSAIASRDeviceMicVC-prototype.html` |
| iOS 实现（Demo VC） | `TSAIASRDeviceMicVC.h/.m`（后续开发） |

---

## 14. 修订记录

| 版本 | 日期 | 变更 | 作者 |
|------|------|------|------|
| v1.0 | 2026-05-19 | 初版 | 磐石 |
