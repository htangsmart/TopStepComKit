//
//  TSAIQAComposerView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIQAComposerView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Callbacks of the text composer
 * @chinese 文字输入区的回调
 */
@protocol TSAIQAComposerViewDelegate <NSObject>

/**
 * @brief Send button tapped with non-empty text
 * @chinese 点击发送且文本非空
 *
 * @param composer
 * EN: Source view
 * CN: 来源视图
 *
 * @param text
 * EN: Trimmed question text
 * CN: 去除首尾空白后的问题文本
 */
- (void)composerView:(TSAIQAComposerView *)composer didSubmitText:(NSString *)text;

/**
 * @brief Stop button tapped while streaming
 * @chinese 流式回答中点击了停止
 *
 * @param composer
 * EN: Source view
 * CN: 来源视图
 */
- (void)composerViewDidTapStop:(TSAIQAComposerView *)composer;

/**
 * @brief The preferred height changed because the text grew or shrank
 * @chinese 因文本增减导致推荐高度变化
 *
 * @param composer
 * EN: Source view
 * CN: 来源视图
 */
- (void)composerViewDidChangeHeight:(TSAIQAComposerView *)composer;

@end

/**
 * @brief Bottom composer of the text mode: hint line, growing text view and send / stop button
 * @chinese 文字模式底部输入区：提示行、自增高输入框与发送 / 停止按钮
 */
@interface TSAIQAComposerView : UIView

/**
 * @brief Interaction delegate
 * @chinese 交互代理
 */
@property (nonatomic, weak, nullable) id<TSAIQAComposerViewDelegate> delegate;

/**
 * @brief Whether an answer is streaming; switches the send button to a stop button
 * @chinese 是否正在流式回答；为 YES 时发送键变为停止键
 */
@property (nonatomic, assign) BOOL streaming;

/**
 * @brief Whether input is allowed at all
 * @chinese 是否允许输入
 */
@property (nonatomic, assign) BOOL inputEnabled;

/**
 * @brief Hint shown above the field; nil hides the line
 * @chinese 输入框上方的提示；nil 时隐藏
 */
@property (nonatomic, copy, nullable) NSString *hint;

/**
 * @brief Current text
 * @chinese 当前文本
 */
@property (nonatomic, copy) NSString *text;

/**
 * @brief Height excluding the safe-area inset
 * @chinese 不含安全区的高度
 *
 * @return
 * EN: Height in points
 * CN: 高度（pt）
 */
- (CGFloat)contentHeight;

/**
 * @brief Dismiss the keyboard
 * @chinese 收起键盘
 */
- (void)dismissKeyboard;

@end

NS_ASSUME_NONNULL_END
