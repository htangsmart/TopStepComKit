//
//  TSAITTSInputCard.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSAITTSInputCard;

/**
 * @brief Input card delegate
 * @chinese 输入卡片委托
 */
@protocol TSAITTSInputCardDelegate <NSObject>

/// 文本变化（每次输入触发）
- (void)inputCardDidChangeText:(TSAITTSInputCard *)card;
/// 用户点击「示例」按钮
- (void)inputCardDidTapSample:(TSAITTSInputCard *)card;

@end

/**
 * @brief Multi-line text input card with title, sample button and char counter
 * @chinese 含标题栏、示例按钮、多行输入与字符计数的输入卡片
 */
@interface TSAITTSInputCard : UIView

/// 委托
@property (nonatomic, weak, nullable) id<TSAITTSInputCardDelegate> delegate;
/// 当前输入文本
@property (nonatomic, copy) NSString *text;
/// 是否可编辑（合成 / 播放过程中应置为 NO）
@property (nonatomic, assign) BOOL editable;
/// 文本最大长度（用于计数器与超限判定）
@property (nonatomic, assign) NSInteger maxChars;

/// 收起键盘
- (void)resignTextEditing;

/// 当前文本去前后空白
- (NSString *)trimmedText;

@end

NS_ASSUME_NONNULL_END
