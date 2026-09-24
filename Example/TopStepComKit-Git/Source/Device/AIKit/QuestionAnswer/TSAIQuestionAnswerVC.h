//
//  TSAIQuestionAnswerVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief How the question is picked up
 * @chinese 问题的拾音（输入）方式
 *
 * @discussion
 * [EN]: The question-answer capability (`TSAIFeatureQuestionAnswering`) only says whether the
 *       service can answer. The pickup is a separate choice; each mode checks its own
 *       prerequisites when selected or started, and reports a precise error otherwise.
 * [CN]: 问答能力位（`TSAIFeatureQuestionAnswering`）只表示服务能否回答；拾音方式是独立选择，
 *       各模式在选择或启动时才检查自身前提，不满足时给出精确错误。
 */
typedef NS_ENUM(NSInteger, TSAIQAInputMode) {
    /// 文字输入 · askQuestion:
    TSAIQAInputModeText = 0,
    /// 手机麦克风 · AppCapture → recognizeSpeechWithPCMData: → askQuestion: → 手机播报
    TSAIQAInputModePhoneMic,
    /// 蓝牙耳机（HFP）麦克风 · 同上
    TSAIQAInputModeHeadset,
    /// 手表拾音 · startDeviceAISessionFromAppWithRequest:（App 发起）/ 手表发起，AIKit 全流程
    TSAIQAInputModeWatch,
};

/**
 * @brief AI question-answer page: one round list, four pickup modes
 * @chinese AI 问答页面：一个轮次列表，四种拾音方式
 */
@interface TSAIQuestionAnswerVC : TSBaseVC

/**
 * @brief Create the page opened on a given pickup mode
 * @chinese 创建并定位到指定拾音方式的页面
 *
 * @param inputMode
 * EN: Initial pickup mode
 * CN: 初始拾音方式
 *
 * @return
 * EN: A page ready to push
 * CN: 可直接 push 的页面
 */
- (instancetype)initWithInputMode:(TSAIQAInputMode)inputMode;

/**
 * @brief Currently selected pickup mode
 * @chinese 当前选中的拾音方式
 */
@property (nonatomic, assign, readonly) TSAIQAInputMode inputMode;

/**
 * @brief Switch the pickup mode programmatically, e.g. when the watch starts a round
 * @chinese 以代码切换拾音方式，例如手表发起轮次时
 *
 * @param inputMode
 * EN: Target mode
 * CN: 目标方式
 */
- (void)switchToInputMode:(TSAIQAInputMode)inputMode;

@end

NS_ASSUME_NONNULL_END
