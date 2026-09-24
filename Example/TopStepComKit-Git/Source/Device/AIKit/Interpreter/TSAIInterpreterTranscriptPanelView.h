//
//  TSAIInterpreterTranscriptPanelView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSAIInterpreterLineCell.h"

@class TSAIInterpreterUtteranceUI;
@class TSAIInterpreterTranscriptPanelView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Delegate for user actions inside a transcript panel
 * @chinese 字幕面板用户操作的委托
 */
@protocol TSAIInterpreterTranscriptPanelViewDelegate <NSObject>

/**
 * @brief User tapped a row; the owner decides how to pair-highlight
 * @chinese 用户点击了一行；由持有者决定如何做配对高亮
 *
 * @param panel
 * EN: The panel that received the tap
 * CN: 收到点击的面板
 *
 * @param utteranceIndex
 * EN: `TSAIInterpreterUtteranceUI.index` of the tapped row
 * CN: 被点击行对应的 `TSAIInterpreterUtteranceUI.index`
 */
- (void)transcriptPanel:(TSAIInterpreterTranscriptPanelView *)panel
 didSelectUtteranceIndex:(NSInteger)utteranceIndex;

/**
 * @brief User tapped the expand / restore button in the header
 * @chinese 用户点击了头部的放大 / 还原按钮
 *
 * @param panel
 * EN: The panel whose button was tapped
 * CN: 按钮所属的面板
 */
- (void)transcriptPanelDidTapExpand:(TSAIInterpreterTranscriptPanelView *)panel;

@end

/**
 * @brief One half of the split transcript: header + line table + "jump to latest" pill
 * @chinese 分栏字幕的一半：头部 + 字幕行表 + 「回到最新」胶囊
 *
 * @discussion
 * [EN]: Renders one side (source or target) of the shared `utterances` array.
 *       The panel owns only view state: whether it follows the newest row
 *       (`followsLatest`, cleared when the user scrolls up and restored by
 *       the pill or by scrolling back to the bottom), and which row is
 *       pair-highlighted (`pairedIndex`). Data mutation stays in the owner;
 *       the owner calls `insertRowAtPosition:` / `reloadRowAtPosition:` /
 *       `reloadData` after changing the array.
 *       All methods must be called on the main thread.
 * [CN]: 渲染共享 `utterances` 数组的一侧（源或目标）。面板只持有视图状态：
 *       是否跟随最新行（`followsLatest`，用户上滑时清除，点胶囊或滚回底部时恢复）、
 *       以及配对高亮的行（`pairedIndex`）。数据修改留在持有者；持有者改完数组后
 *       调用 `insertRowAtPosition:` / `reloadRowAtPosition:` / `reloadData`。
 *       所有方法必须在主线程调用。
 */
@interface TSAIInterpreterTranscriptPanelView : UIView

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param role
 * EN: Which side this panel renders
 * CN: 该面板渲染哪一侧
 *
 * @return
 * EN: A configured panel
 * CN: 配置好的面板
 */
- (instancetype)initWithRole:(TSAIInterpreterLineRole)role NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/**
 * @brief Which side this panel renders
 * @chinese 该面板渲染哪一侧
 */
@property (nonatomic, assign, readonly) TSAIInterpreterLineRole role;

/**
 * @brief Delegate for taps
 * @chinese 点击事件委托
 */
@property (nonatomic, weak, nullable) id<TSAIInterpreterTranscriptPanelViewDelegate> delegate;

/**
 * @brief Shared, owner-managed utterance list (held by reference, not copied)
 * @chinese 由持有者管理的共享 utterance 列表（按引用持有，不拷贝）
 *
 * @note
 * [EN]: Pass the owner's mutable array so both panels see the same objects.
 * [CN]: 传入持有者的可变数组，使两个面板看到同一批对象。
 */
@property (nonatomic, strong, nullable) NSArray<TSAIInterpreterUtteranceUI *> *utterances;

/**
 * @brief Whether target rows show the audio status line
 * @chinese 目标面板的行是否显示音频状态
 */
@property (nonatomic, assign) BOOL showAudio;

/**
 * @brief Whether the newest row gets the "latest" tint (on while a session runs)
 * @chinese 最新行是否带「最新」底色（会话进行中为 YES）
 */
@property (nonatomic, assign) BOOL highlightsLatest;

/**
 * @brief Pair-highlighted utterance index, `NSNotFound` for none
 * @chinese 配对高亮的 utterance index，无则为 `NSNotFound`
 */
@property (nonatomic, assign) NSInteger pairedIndex;

/**
 * @brief Whether the header button shows the "restore" glyph
 * @chinese 头部按钮是否显示「还原」图标
 */
@property (nonatomic, assign) BOOL expanded;

/**
 * @brief Set the header title and the language text next to it
 * @chinese 设置头部标题与旁边的语言文字
 *
 * @param title
 * EN: e.g. "原文" / "译文"
 * CN: 如「原文」/「译文」
 *
 * @param languageText
 * EN: Language display name, may be nil
 * CN: 语言展示名，可为 nil
 */
- (void)setTitle:(NSString *)title languageText:(nullable NSString *)languageText;

/**
 * @brief Set the trailing header text (count on the source panel, TTS badge on the target)
 * @chinese 设置头部右侧文字（源面板为句数，目标面板为 TTS 徽标）
 *
 * @param text
 * EN: Text, nil hides the label
 * CN: 文字，nil 隐藏
 *
 * @param color
 * EN: Text color
 * CN: 文字颜色
 */
- (void)setTrailingText:(nullable NSString *)text color:(UIColor *)color;

/**
 * @brief Placeholder shown while there are no rows
 * @chinese 无行时显示的占位文案
 *
 * @param text
 * EN: Placeholder text
 * CN: 占位文案
 */
- (void)setPlaceholderText:(NSString *)text;

/**
 * @brief Reload everything (after clearing or reconciling the array)
 * @chinese 整体刷新（清空或以 report 校正数组后）
 */
- (void)reloadData;

/**
 * @brief Insert one row after the owner inserted an item into the array
 * @chinese 持有者向数组插入一项后，插入对应行
 *
 * @param position
 * EN: Array position of the inserted item
 * CN: 插入项在数组中的位置
 */
- (void)insertRowAtPosition:(NSUInteger)position;

/**
 * @brief Reload one row after its model changed; scrolls to it when following
 * @chinese 模型变化后刷新对应行；跟随模式下滚到该行
 *
 * @param position
 * EN: Array position of the changed item
 * CN: 变化项在数组中的位置
 */
- (void)reloadRowAtPosition:(NSUInteger)position;

/**
 * @brief Scroll so the row for `utteranceIndex` is visible (used for pair highlighting)
 * @chinese 滚动使 `utteranceIndex` 对应的行可见（用于配对高亮）
 *
 * @param utteranceIndex
 * EN: `TSAIInterpreterUtteranceUI.index`
 * CN: `TSAIInterpreterUtteranceUI.index`
 */
- (void)scrollToUtteranceIndex:(NSInteger)utteranceIndex;

@end

NS_ASSUME_NONNULL_END
