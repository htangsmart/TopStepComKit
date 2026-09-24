//
//  TSAIInterpreterSplitView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIInterpreterUtteranceUI;
@class TSAIInterpreterTranscriptPanelView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Top / bottom split transcript: source panel above, target panel below
 * @chinese 上下分栏字幕区：上为源语言面板，下为目标语言面板
 *
 * @discussion
 * [EN]: Hosts two `TSAIInterpreterTranscriptPanelView`s and a draggable divider.
 *       - Divider: pan to resize (ratio clamped to 25%–75%), double-tap to
 *         reset; the ratio persists in `NSUserDefaults`.
 *       - Expand: a panel's header button switches it to 78% and back.
 *       - Pairing: tapping a row in either panel highlights the row with the
 *         same `utteranceIndex` in both panels and scrolls it into view;
 *         tapping it again clears the highlight.
 *       Data flow: the owner mutates `utterances` and then calls
 *       `insertUtteranceAtPosition:` / `reloadUtteranceAtPosition:` /
 *       `reloadAllData`; the split view fans the call out to both panels
 *       and refreshes the source panel's line counter.
 *       All methods must be called on the main thread.
 * [CN]: 承载两个 `TSAIInterpreterTranscriptPanelView` 与一根可拖拽分隔条。
 *       - 分隔条：拖动调比例（限制 25%–75%），双击复位；比例存入 `NSUserDefaults`。
 *       - 放大：面板头部按钮把该面板切到 78%，再点还原。
 *       - 配对：点击任一面板的行，两面板中同 `utteranceIndex` 的行同时高亮并滚入视野；
 *         再点一次取消。
 *       数据流：持有者修改 `utterances` 后调用 `insertUtteranceAtPosition:` /
 *       `reloadUtteranceAtPosition:` / `reloadAllData`，由本视图分发给两个面板，
 *       并刷新源面板的句数。所有方法必须在主线程调用。
 */
@interface TSAIInterpreterSplitView : UIView

/**
 * @brief Upper panel rendering original text
 * @chinese 上方面板，渲染原文
 */
@property (nonatomic, strong, readonly) TSAIInterpreterTranscriptPanelView *sourcePanel;

/**
 * @brief Lower panel rendering translated text + audio status
 * @chinese 下方面板，渲染译文与音频状态
 */
@property (nonatomic, strong, readonly) TSAIInterpreterTranscriptPanelView *targetPanel;

/**
 * @brief Shared, owner-managed utterance list, forwarded to both panels by reference
 * @chinese 由持有者管理的共享 utterance 列表，按引用转发给两个面板
 */
@property (nonatomic, strong, nullable) NSArray<TSAIInterpreterUtteranceUI *> *utterances;

/**
 * @brief Whether the target panel shows per-row audio status (`enableVoiceOutput`)
 * @chinese 目标面板是否显示每行的音频状态（对应 `enableVoiceOutput`）
 */
@property (nonatomic, assign) BOOL showAudio;

/**
 * @brief Whether the newest row is tinted (YES while a session is in flight)
 * @chinese 最新行是否带底色（会话进行中为 YES）
 */
@property (nonatomic, assign) BOOL highlightsLatest;

/**
 * @brief Set the language text shown in the source panel header
 * @chinese 设置源面板头部显示的语言文字
 *
 * @param text
 * EN: Display name (e.g. "English · auto"), nil clears
 * CN: 展示名（如「英语 · 自动识别」），nil 清空
 */
- (void)setSourceLanguageText:(nullable NSString *)text;

/**
 * @brief Set the language text shown in the target panel header
 * @chinese 设置目标面板头部显示的语言文字
 *
 * @param text
 * EN: Display name, nil clears
 * CN: 展示名，nil 清空
 */
- (void)setTargetLanguageText:(nullable NSString *)text;

/**
 * @brief Set the TTS badge on the target panel header
 * @chinese 设置目标面板头部的 TTS 徽标
 *
 * @param text
 * EN: Badge text, nil hides the badge
 * CN: 徽标文字，nil 隐藏
 */
- (void)setTargetBadgeText:(nullable NSString *)text;

/**
 * @brief Reload both panels and clear the pair highlight
 * @chinese 整体刷新两个面板并清除配对高亮
 */
- (void)reloadAllData;

/**
 * @brief Insert the row for an item the owner just added to `utterances`
 * @chinese 为持有者刚加入 `utterances` 的项插入行
 *
 * @param position
 * EN: Array position of the new item
 * CN: 新项在数组中的位置
 */
- (void)insertUtteranceAtPosition:(NSUInteger)position;

/**
 * @brief Reload the rows for a changed item in both panels
 * @chinese 在两个面板中刷新某个已变化项的行
 *
 * @param position
 * EN: Array position of the changed item
 * CN: 变化项在数组中的位置
 */
- (void)reloadUtteranceAtPosition:(NSUInteger)position;

@end

NS_ASSUME_NONNULL_END
