//
//  TSAIChatAgentSelector.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/28.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Chat agent entry { agentId, speakerId, displayName }
 * @chinese 对话智能体条目 { agentId, speakerId, 展示名称 }
 *
 * @discussion
 * [EN]: Bundles the two IDs that together identify a chat persona — `agentId`
 *       drives the LLM role and `speakerId` drives the TTS voice. Kept
 *       separate from `TSAITTSSpeakerEntry` because Chat scenarios bind both
 *       fields, while TTS-only scenarios need just `speakerId`.
 * [CN]: 把共同定义一个对话角色的两个 ID 打包：`agentId` 决定 LLM 人设，
 *       `speakerId` 决定 TTS 音色。与 `TSAITTSSpeakerEntry` 保持独立，
 *       因为 Chat 场景同时绑定两个字段，而纯 TTS 场景只需要 `speakerId`。
 */
@interface TSAIChatAgentEntry : NSObject

/**
 * @brief Agent identifier (LLM persona)
 * @chinese AI 角色标识（LLM 人设）
 */
@property (nonatomic, copy) NSString *agentId;

/**
 * @brief TTS speaker identifier (voice)
 * @chinese TTS 发音人标识（音色）
 */
@property (nonatomic, copy) NSString *speakerId;

/**
 * @brief Display name shown on the chip (e.g. "🇨🇳 中文助手")
 * @chinese chip 上展示的名称（如 "🇨🇳 中文助手"）
 */
@property (nonatomic, copy) NSString *displayName;

/**
 * @brief Convenience initializer
 * @chinese 便捷构造方法
 *
 * @param agentId
 * EN: Agent identifier; must be non-empty
 * CN: AI 角色 ID，必须非空
 *
 * @param speakerId
 * EN: TTS speaker identifier; may be empty string
 * CN: TTS 发音人 ID，允许为空字符串
 *
 * @param displayName
 * EN: User-facing chip label
 * CN: 展示给用户的 chip 文案
 *
 * @return
 * EN: A new entry with the given fields
 * CN: 包含传入字段的新 entry
 */
+ (instancetype)entryWithAgentId:(NSString *)agentId
                       speakerId:(NSString *)speakerId
                     displayName:(NSString *)displayName;

@end

@class TSAIChatAgentSelector;

/**
 * @brief Agent selector delegate
 * @chinese 智能体选择器委托
 */
@protocol TSAIChatAgentSelectorDelegate <NSObject>

/**
 * @brief Called when a chip is tapped (chip selection only emits intent;
 *        host must write back via `-setSelectedEntry:`)
 * @chinese chip 被点击时回调（chip 仅发出意图，宿主需要通过
 *         `-setSelectedEntry:` 写回选中态）
 */
- (void)agentSelector:(TSAIChatAgentSelector *)selector
       didSelectEntry:(TSAIChatAgentEntry *)entry;

/**
 * @brief Called when the "Custom…" button is tapped; host should present an
 *        alert collecting name / agentId / speakerId then call
 *        `-appendCustomEntry:` and `-setSelectedEntry:`
 * @chinese 「自定义…」按钮被点击时回调；宿主应弹 alert 收集 name / agentId
 *         / speakerId，然后调用 `-appendCustomEntry:` 与 `-setSelectedEntry:`
 */
- (void)agentSelectorDidRequestCustomEntry:(TSAIChatAgentSelector *)selector;

@end

/**
 * @brief Horizontal agent chip selector for TSAIChatConfigSheet
 * @chinese 用于 TSAIChatConfigSheet 的横向智能体 chip 选择器
 *
 * @discussion
 * [EN]: Card view containing a header (section label + "Custom…" button), a
 *       horizontally scrolling chip list (one chip per entry, showing only
 *       `displayName`), and a monospace footer line displaying the currently
 *       selected entry's `agentId · speakerId`. Selection state is owned by
 *       the host.
 * [CN]: 卡片视图，包含标题栏（区域名 + 「自定义…」按钮）、横向滚动的 chip
 *       列表（每个 chip 仅展示 `displayName`），以及一行 monospace 副标题
 *       显示当前选中条目的 `agentId · speakerId`。选中态由宿主管理。
 */
@interface TSAIChatAgentSelector : UIView

/**
 * @brief Delegate to receive chip-tap / custom-tap intents
 * @chinese 接收 chip 点击与自定义点击意图的委托
 */
@property (nonatomic, weak, nullable) id<TSAIChatAgentSelectorDelegate> delegate;

/**
 * @brief Currently selected entry; nil if nothing selected
 * @chinese 当前选中的条目；未选中时为 nil
 */
@property (nonatomic, strong, nullable, readonly) TSAIChatAgentEntry *selectedEntry;

/**
 * @brief Reset entries (preset + custom merged by host) and rebuild chips
 * @chinese 重置 entry 列表（宿主合并的预设 + 自定义）并重建 chip
 *
 * @param entries
 * EN: Ordered entries to display as chips
 * CN: 用作 chip 顺序展示的条目数组
 */
- (void)setEntries:(NSArray<TSAIChatAgentEntry *> *)entries;

/**
 * @brief Set the selected entry; refreshes chip highlight and ID footer
 * @chinese 设置选中条目；刷新 chip 高亮与 ID 副标题
 */
- (void)setSelectedEntry:(nullable TSAIChatAgentEntry *)entry;

/**
 * @brief Append a custom entry to the existing list (does not change
 *        selection — caller should follow with `-setSelectedEntry:`)
 * @chinese 在现有列表末尾追加一个自定义 entry（不改变选中态，
 *         调用方应紧接调用 `-setSelectedEntry:`）
 */
- (void)appendCustomEntry:(TSAIChatAgentEntry *)entry;

@end

NS_ASSUME_NONNULL_END
