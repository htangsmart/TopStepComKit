//
//  TSAIChatFlowToggle.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Which stage the flow (continuous) mode is showing
 * @chinese 畅聊模式当前展示的主区
 */
typedef NS_ENUM(NSInteger, TSAIChatFlowStage) {
    /// 光球：240 光球 + 状态文案 + 当前轮文字
    TSAIChatFlowStageOrb = 0,
    /// 记录：本次会话的全部问答
    TSAIChatFlowStageTranscript = 1,
};

/**
 * @brief Single pill button that toggles the flow stage (orb ⇄ transcript)
 * @chinese 畅聊右上角单个胶囊按钮，在光球 ⇄ 记录之间切换
 * @discussion EN: The button always names the stage a tap will switch to.
 *             Orb showing → glass pill「记录」; transcript showing → gradient pill「光球」.
 *             Both states have an opaque fill so the button stays legible on the aurora background.
 *             CN: 按钮文案始终是「点击后会去的那一侧」。
 *             显示光球时为磨砂胶囊「记录」；显示记录时为渐变胶囊「光球」。
 *             两种状态都有不透明底，任何极光底色上都看得清。
 */
@interface TSAIChatFlowToggle : UIControl

/** @brief Stage currently showing @chinese 当前正在展示的主区 */
@property (nonatomic, assign) TSAIChatFlowStage currentStage;

/** @brief Called with the stage to switch to when tapped @chinese 点击后回调，参数为要切换到的主区 */
@property (nonatomic, copy, nullable) void (^onToggle)(TSAIChatFlowStage nextStage);

/** @brief Fixed height 30 @chinese 固定高度 30 */
+ (CGFloat)preferredHeight;

/**
 * @brief Update the showing stage
 * @chinese 更新当前展示的主区（相同值不重复动画）
 * @param stage EN: Stage now showing. CN: 当前展示的主区。
 * @param animated EN: Cross-fade the style (.25s). CN: 是否以 .25s 交叉淡入切换样式。
 */
- (void)setCurrentStage:(TSAIChatFlowStage)stage animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
