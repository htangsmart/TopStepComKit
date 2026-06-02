# TSAIChatVC 设计文档

> 模块：AIKit / Assistant
> 配套 SDK 接口：`TSAIAssistantInterface.startChatWithConfig:onContent:onEvent:completion:`
> 文档日期：2026-05-19

---

## 文件清单

| 文件 | 内容 | 适合阅读 |
|------|------|----------|
| [PRD.md](./PRD.md) | 完整产品需求文档：背景、用户、功能范围、SDK 字段映射、错误处理、验收清单、文件拆分建议 | 产品 / 开发 / QA |
| [Prototype.md](./Prototype.md) | 状态机（Mermaid）+ 4 个核心时序图 + 8 张 ASCII 线框图 + 实现拆解步骤 | 开发 |
| [demo.html](./demo.html) | iPhone 框架 + 单页交互演示，6 个场景按钮一键演示 SDK 回调流 | 全员（直接浏览器打开） |

## 推荐阅读顺序

1. **先开 [demo.html](./demo.html)** 跑一遍 6 个场景，建立直观感受。
2. **再读 [PRD.md](./PRD.md)** 第 4、5、7 节，理解功能边界与 SDK 字段映射。
3. **最后看 [Prototype.md](./Prototype.md)** 第 1、2 节状态机和时序，开始动手写代码时按第 5 节的拆解步骤推进。

## 核心约束（一行版）

- **状态机**：`Idle → Listening ⇄ Thinking ⇄ Speaking → Ended`，三轮态循环，4 种结束触发跳出。
- **回调分流**：`onContent` 高频内容（文本累积、音频增量、意图），`onEvent` 低频会话事件，`completion` 仅一次报告。
- **不变量**：`text` 累积值直接赋值 UI；`audioChunk` 增量值必须 append 到播放缓冲。

## 目标代码位置

```
Example/TopStepComKit-Git/Source/Device/AIKit/Assistant/
├── TSAIChatVC.h / .m            # 已有空壳，本设计的实现目标
├── View/                        # 待新建
└── Sheet/                       # 待新建
```

## 演示截图（demo.html）

- iPhone 14 Pro 尺寸（390×844）
- 左侧黑色面板：6 个场景按钮 + 重置 / 主动 stop + 实时 State / Round / TaskId 监视
- iPhone 屏幕：完整 NavBar、对话流、麦克风按钮（4 态动效）、ConfigSheet、LogSheet、ReportDialog

## 关联资源

- 接口：`TopStepInterfaceKit/Classes/Source/TSAIKit/TSAIAssistant/TSAIAssistantInterface.h`
- 模型：`TopStepInterfaceKit/Classes/Source/TSAIKit/TSAIAssistant/Model/TSAIChat*.h`
- 实现（Buds，Chat 部分待实现）：`TopStepBudsKit/Classes/Source/TSAIAssistant/TSBudsAIAssistant.m`
