# TSAIASRFileVC 产品需求文档

> 模块：TopStepComKit-Git Example / Device / AIKit / Speech
> 接口契约：`TSAISpeechInterface.recognizeSpeechWithFileURL:config:onPartialResult:completion:`
> 文档版本：v1.0 · 2026-05-19

---

## 1. 一句话概述

> **从本地选一段音频，看着字幕"打出来"，最后拿到完整文稿。**

`TSAIASRFileVC` 是 Example 工程内验证「文件 ASR」能力的演示页。它把 `TSAISpeechInterface` 的文件流式识别接口包装成一个可肉眼观察的页面：选音频 → 配置语言/格式 → 触发识别 → 看流式累积文本逐句稳定 → 拿最终结果。

## 2. 目标用户与场景

| 角色 | 在本页要做什么 |
|------|----------------|
| **SDK 接入方** | 跑通一次"选文件 → 看识别"，验证接口可用；复制本页的调用片段到自己的 App。 |
| **SDK 测试 / QA** | 用不同语言、不同音频格式（mp3/wav/opus/裸 PCM）跑回归，验证句子分割与错误码。 |
| **产品 / Demo 演示** | 现场演示"流式打字效果"，体感对比一次性返回 vs 流式累积。 |

非目标：本页**不**做录音、不做翻译、不做长音频文件管理；这些由 `TSAIASRDeviceMicVC`、`TSAITranslateVC`、宿主 App 各自负责。

## 3. 与接口的字段对应（设计的硬约束）

| UI 控件 | 对应字段 | 取值与默认 | 约束 |
|---------|----------|-----------|------|
| **选择音频文件** | `audioFileURL : NSURL` | 必填；通过 `UIDocumentPickerVC` 选本地文件 | 必须 `isFileURL` 且文件存在，否则返回 `InvalidParam` |
| **Language** | `config.language : TSAILanguage` | 必填；默认置空，提示"请选择" | **禁止 Auto / Unknown**（接口层校验，传入会回 `InvalidParam`），支持 zh-CN / zh-TW / en-US / en-GB / ja / ko / fr / de / es / ru |
| **Audio Format** | `config.audioFormat : TSAIAudioFormat` | 默认 `None`（=嗅探）| `None` 仅对 mp3 / wav / opus 等带头格式生效；裸 PCM 必须显式选 `Pcm` |
| **Recognize 按钮** | 调用 `recognizeSpeechWithFileURL:config:onPartialResult:completion:` | — | 调用前需校验 `audioFileURL != nil && language ∈ supported`；已有任务在跑时禁用 |
| **Cancel 按钮** | `cancelRecognitionWithTaskId:` | — | 仅在 Recognizing 状态可点；触发后 completion 以 `eTSErrorUserCancelled` 回 |

> 注意：`TSAIASRFileConfig` **没有 scene 字段**——`TSAIASRScene` 只服务设备麦克风 ASR。本页不出现"场景"选择，原 `TSAIASRFileVC.m` 的 TODO 注释里写到 scene 是误写，本文档以接口头文件为准。

## 4. 页面信息架构

```
┌───────────────────────────────────────────┐
│  < Back        ASR (File)                 │  ← UINavigationBar
├───────────────────────────────────────────┤
│  ┌─ 文件区 ────────────────────────────┐  │
│  │  📄 sample-zh.mp3                  │  │
│  │  1.2 MB · 推断格式: MP3            │  │
│  │  [  Choose Audio File  ]           │  │  ← 未选时占位 "No file selected"
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 配置区 ────────────────────────────┐  │
│  │  Language          [  zh-CN  ▾ ]   │  │  ← 必填，未选高亮红框
│  │  Audio Format      [  None(嗅探)▾] │  │
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 操作区 ────────────────────────────┐  │
│  │  TaskId: 5f3e…b921 (recognizing…)  │  │  ← 仅识别中显示
│  │  ──── 进度条/呼吸点 ────            │  │
│  │  [ Recognize ]   [ Cancel ]        │  │  ← 互斥启用
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 流式文本区 (TSAIStreamTextView) ──┐  │
│  │  ✓ 大家好，欢迎来到 SDK 演示。      │  │  ← 已稳定句（粗体）
│  │  ✓ 今天我们测试文件识别。          │  │
│  │  ⋯ 现在准备开始第三                │  │  ← 当前修订句（浅色斜体）
│  └────────────────────────────────────┘  │
│                                           │
│  ┌─ 日志区 (TSAILogView) ──────────────┐  │
│  │  09:42:15  start taskId=5f3e…      │  │
│  │  09:42:16  partial #0 frag#0       │  │
│  │  09:42:18  partial #0 final ✓      │  │
│  │  09:42:22  completion ✅ dur=12.4s │  │
│  └────────────────────────────────────┘  │
└───────────────────────────────────────────┘
```

五块自上而下：**文件 → 配置 → 操作 → 流式文本 → 日志**。日志区可滚动并支持长按复制（沿用 `TSAILogView` 既有能力）。

## 5. 状态机

页面只有 4 个状态，所有控件可用性由状态推导，避免状态散落各处。

```
                 ┌──────────┐
                 │   Idle   │◀────────────────┐
                 └────┬─────┘                 │
                      │ 选好文件 + 选好语言     │
                      ▼                       │
                 ┌──────────┐                 │
                 │  Ready   │                 │
                 └────┬─────┘                 │
                      │ 点 Recognize          │
                      ▼                       │
                 ┌──────────────┐  Cancel /   │
                 │ Recognizing  │──completion─┤
                 └──────┬───────┘             │
                        │ onError             │
                        ▼                     │
                 ┌──────────┐                 │
                 │  Failed  │─── 用户改配置 ──┘
                 └──────────┘
```

| 状态 | Recognize | Cancel | 配置区可编辑 | 文件可重选 |
|------|-----------|--------|------------|----------|
| Idle | 禁用 | 禁用 | ✅ | ✅ |
| Ready | ✅ 启用 | 禁用 | ✅ | ✅ |
| Recognizing | 禁用 | ✅ 启用 | ❌ | ❌ |
| Failed | ✅ 启用（重试） | 禁用 | ✅ | ✅ |

## 6. 关键交互流

### 6.1 主流程：选文件 → 识别 → 看流式 → 拿结果

| 步骤 | 用户动作 | 页面反馈 | SDK 调用 / 回调 |
|------|---------|---------|----------------|
| 1 | 点 "Choose Audio File" | 弹出 `UIDocumentPickerVC`（限 audio UTI）| — |
| 2 | 选 `sample-zh.mp3` | 文件区显示文件名、大小、推断格式；状态 → Ready | 校验 `isFileURL` + `fileExistsAtPath:` |
| 3 | 下拉选 Language = 简体中文 | 配置项打勾 | — |
| 4 | 点 Recognize | 按钮置灰，显示 "recognizing…"，文本区清空 | 同步拿到 `taskId`，日志写一条 start |
| 5 | (流式) | 文本区每 200~500ms 刷新累积文本；当前句浅色，封板后变粗体 | `onPartialResult` 多次回调，`partial.text` 直接赋值 |
| 6 | (完成) | 文本区固化全部为粗体；操作区显示总耗时；状态 → Idle | `completion(result, nil)` |

### 6.2 取消流程

| 步骤 | 用户动作 | 页面反馈 | SDK 调用 |
|------|---------|---------|---------|
| 1 | 识别中点 Cancel | 按钮立刻置灰避免重复点 | `cancelRecognitionWithTaskId:` |
| 2 | (回调) | 流式文本停止刷新，保留最后一帧；日志写 "cancelled by user"；状态 → Idle | `completion(nil, eTSErrorUserCancelled)` |

### 6.3 错误流程

| 触发 | 页面反馈 |
|------|---------|
| 文件不存在 / 非 file URL | Toast "File not found"，状态保持 Idle |
| Language = Auto/Unknown | UI 已禁止选中；理论上不会发生，兜底 Toast |
| 语言不支持 | Toast "Language not supported"，日志写 `eTSErrorNotSupport` |
| 任务正在跑 (`eTSErrorIsBusy`) | Toast "Another recognition in progress"（理论上 UI 已禁，兜底）|
| 解码失败 / 网络错误 | 状态 → Failed，日志写完整 error，文本区保留已识别内容 |

### 6.4 边界 & 防呆

| 场景 | 处理 |
|------|------|
| 选了文件再换文件 | 直接替换；若处于 Recognizing 则 Cancel 选项不可点新文件（按钮置灰）|
| 在识别中返回上一页 | `viewWillDisappear` 调 `cancelRecognitionWithTaskId:`，避免后台空跑 |
| 选了 `.pcm` 但 Audio Format 留 None | 识别前 Toast 提示 "PCM 需要显式指定格式"，按钮置灰 |
| `partial.text` 与上次相同 | 不刷新 UI，避免无意义抖动 |

## 7. 流式文本区渲染规则

接口契约 `partial.text` 是**累积文本**而非新增片段，且尾句可能多次修订（"我去北" → "我去北京" → "我去背景"）。渲染要点：

1. **整段 `label.text = partial.text`**，不要手动拼接。
2. 按 `\n` 或 `。！？` 把已封板部分（前 N−1 句）和当前句拆开渲染：
   - 已封板 → 粗体 + 默认色
   - 当前句 → 浅色 + 斜体；`isSentenceFinal=YES` 时翻成粗体并换行
3. 自动滚到底部，但用户手动上滑后停止 auto-scroll（避免抢光标）。
4. 视觉上"正在识别"用一个 1Hz 呼吸圆点提示，不要用 spinner 抢用户注意。

## 8. 日志区输出规范

| 事件 | 日志格式 |
|------|---------|
| 启动 | `HH:mm:ss  start taskId={short8} lang={code} fmt={fmt} file={name}` |
| partial | `HH:mm:ss  partial s#{sentenceNo} f#{fragmentNo} final={Y/N} len={len}` （只打 length，不打全文）|
| 完成 | `HH:mm:ss  ✅ done dur={duration}s len={textLen}` |
| 取消 | `HH:mm:ss  🟡 cancelled by user` |
| 错误 | `HH:mm:ss  ❌ {domain}:{code} {localizedDescription}` |

> 日志全程**不打识别文本内容**——避免开发者把含隐私的测试音频识别文本提交到 issue。

## 9. 不做什么（划清边界）

- 不内置音频播放器（不在本次范围；用户可在 Files App 试听）
- 不做长音频分段上传（接口本身就是单文件流式，分段是 SDK 内部行为）
- 不做"自动识别语言"（接口禁止 Auto）
- 不做结果导出到剪贴板/文件（首版只演示）；后续可加"复制全文"按钮

## 10. 验收 Checklist

- [ ] 未选文件时 Recognize 按钮置灰
- [ ] 未选语言时 Recognize 按钮置灰，Language 下拉显示红色边框
- [ ] 选 PCM 文件但未指定 Format → 按钮置灰 + Toast
- [ ] 识别中再次点击文件区无响应
- [ ] 流式 partial 至少出现 1 次（用 ≥10s 音频测）
- [ ] 取消后 completion 在 ≤500ms 内回调
- [ ] 识别中切到后台再切回 UI 状态正确
- [ ] 识别中 pop 不崩溃、不内存泄漏

---

附：HTML 可交互原型见同目录 `prototype.html`。
