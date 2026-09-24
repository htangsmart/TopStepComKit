//
//  TSAIInterpreterLineCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIInterpreterUtteranceUI;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Which side of the utterance a transcript panel renders
 * @chinese 字幕面板渲染 utterance 的哪一侧
 */
typedef NS_ENUM(NSInteger, TSAIInterpreterLineRole) {
    /// 源语言面板：渲染原文（ASR）
    TSAIInterpreterLineRoleSource = 0,
    /// 目标语言面板：渲染译文（MT）+ TTS 音频状态
    TSAIInterpreterLineRoleTarget = 1,
};

/**
 * @brief Table cell rendering one side (original or translated) of an utterance
 * @chinese 渲染 utterance 单侧（原文或译文）的字幕行
 *
 * @discussion
 * [EN]: One row = one utterance in one panel. Layout: a 30pt index gutter
 *       (`#N`, monospaced) + the text. Target rows additionally show an
 *       audio-status line (speaker glyph + byte counter) when `showAudio` is on.
 *       Streaming (non-final) text is drawn in a secondary color with a
 *       trailing cursor; the latest row and the paired row get a tinted
 *       background. Use `heightForUtterance:role:showAudio:cellWidth:` to drive
 *       `tableView:heightForRowAtIndexPath:`.
 * [CN]: 一行 = 一个面板中的一段 utterance。布局为 30pt 序号栏（`#N`，等宽字体）
 *       + 正文。目标面板的行在 `showAudio` 打开时额外显示一行音频状态
 *       （喇叭 + 字节计数）。流式（未 final）文本用次级颜色 + 尾部光标绘制；
 *       最新一行与配对高亮行带底色。配合类方法
 *       `heightForUtterance:role:showAudio:cellWidth:` 计算行高。
 */
@interface TSAIInterpreterLineCell : UITableViewCell

/**
 * @brief Bind a utterance UI model to this cell
 * @chinese 将 UI 模型绑定到 cell
 *
 * @param utterance
 * EN: UI model populated from streaming callbacks
 * CN: 由流式回调填充的 UI 模型
 *
 * @param role
 * EN: Which side to render (source → originalText, target → translatedText)
 * CN: 渲染哪一侧（源 → 原文，目标 → 译文）
 *
 * @param showAudio
 * EN: Whether the audio status line is visible (target role only)
 * CN: 是否显示音频状态行（仅目标面板生效）
 *
 * @param isLatest
 * EN: Whether this is the newest utterance of a running session (tinted background)
 * CN: 是否为进行中会话的最新一句（带浅色底）
 *
 * @param isPaired
 * EN: Whether this row is the user-selected paired row (stronger tint + border)
 * CN: 是否为用户点选的配对行（更强的底色 + 描边）
 */
- (void)bindWithUtterance:(TSAIInterpreterUtteranceUI *)utterance
                     role:(TSAIInterpreterLineRole)role
                showAudio:(BOOL)showAudio
                 isLatest:(BOOL)isLatest
                 isPaired:(BOOL)isPaired;

/**
 * @brief Compute the row height for a given UI model, role and cell width
 * @chinese 根据 UI 模型、面板角色与 cell 宽度计算行高
 *
 * @param utterance
 * EN: UI model
 * CN: UI 模型
 *
 * @param role
 * EN: Which side to measure (decides the text and the font)
 * CN: 度量哪一侧（决定文本与字体）
 *
 * @param showAudio
 * EN: Whether to reserve space for the audio status line (target role only)
 * CN: 是否预留音频状态行空间（仅目标面板生效）
 *
 * @param cellWidth
 * EN: Effective cell width (table view bounds width)
 * CN: 实际 cell 宽度（表格 bounds 宽度）
 *
 * @return
 * EN: Row height in points
 * CN: 行高（pt）
 */
+ (CGFloat)heightForUtterance:(TSAIInterpreterUtteranceUI *)utterance
                         role:(TSAIInterpreterLineRole)role
                    showAudio:(BOOL)showAudio
                    cellWidth:(CGFloat)cellWidth;

@end

NS_ASSUME_NONNULL_END
