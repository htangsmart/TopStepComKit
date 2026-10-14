//
//  TSAIChatRoundView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSAIChatRoundModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TSAIChatRoundView;

/**
 * @brief Round view interactions
 * @chinese 轮视图交互回调
 */
@protocol TSAIChatRoundViewDelegate <NSObject>

/** @brief AI bubble tapped while speaking → interrupt @chinese 播放中点击 AI 气泡 → 打断 */
- (void)roundViewDidTapSpeakingBubble:(TSAIChatRoundView *)roundView;

/** @brief A done bubble was long-pressed @chinese 已完成气泡被长按 */
- (void)roundView:(TSAIChatRoundView *)roundView didLongPressBubble:(UIView *)bubble isUserBubble:(BOOL)isUserBubble;

/** @brief Retry tapped on an error round @chinese 出错轮点击「重试」 */
- (void)roundViewDidTapRetry:(TSAIChatRoundView *)roundView;

@end

/**
 * @brief One round: user bubble (right) + AI bubble (left), seven round states (spec §3.2)
 * @chinese 一轮：用户气泡（右）+ AI 气泡（左），七种轮状态（规范 §3.2）
 */
@interface TSAIChatRoundView : UIView

/** @brief Bound model @chinese 绑定的模型 */
@property (nonatomic, strong, readonly) TSAIChatRoundModel *model;

/** @brief Delegate @chinese 代理 */
@property (nonatomic, weak, nullable) id<TSAIChatRoundViewDelegate> delegate;

/**
 * @brief Create for a model
 * @chinese 以模型创建
 */
- (instancetype)initWithModel:(TSAIChatRoundModel *)model;

/**
 * @brief Re-render from the model (streaming refresh; no entrance replay)
 * @chinese 按模型重绘（流式刷新，不重放入场动画）
 */
- (void)refresh;

/**
 * @brief Pop in bubbles that have not appeared yet
 * @chinese 对尚未入场的气泡播放弹性入场
 */
- (void)playEntranceIfNeeded;

/**
 * @brief Height for a width
 * @chinese 指定宽度下的高度
 */
- (CGFloat)heightForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
