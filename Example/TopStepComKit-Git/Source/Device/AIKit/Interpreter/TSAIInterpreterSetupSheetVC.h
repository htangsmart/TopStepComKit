//
//  TSAIInterpreterSetupSheetVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIInterpretationRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Pre-session setup sheet: pickup → languages → voice → Start
 * @chinese 同传开始前的设置抽屉：拾音设备 → 语言 → 译文语音 → 开始
 *
 * @discussion
 * [EN]: Mirrors the product flow "choose the microphone source, choose both
 *       languages, tap Start". Pickup availability and the language list come
 *       from `TSAIContext.interpretation`; the Start button is enabled only
 *       when `eligibilityForRequest:` says the request can start, and the
 *       reason is shown inline otherwise. The sheet never starts the session
 *       itself — it hands the request back through `onStart`.
 * [CN]: 对应产品流程「选拾音设备 → 选双方语言 → 点开始」。拾音设备可用性与语言
 *       列表来自 `TSAIContext.interpretation`；仅当 `eligibilityForRequest:`
 *       判定可启动时「开始」可点，否则原因内联展示。抽屉本身不启动会话，
 *       通过 `onStart` 把请求交回宿主。
 */
@interface TSAIInterpreterSetupSheetVC : UIViewController

/**
 * @brief Called with the confirmed request; the sheet dismisses itself first
 * @chinese 用户确认后回调请求；抽屉先自行关闭
 */
@property (nonatomic, copy, nullable) void (^onStart)(TSAIInterpretationRequest *request);

/**
 * @brief Build the sheet pre-filled with a previous request (nil = defaults)
 * @chinese 用上一次的请求预填抽屉（nil 表示默认值）
 */
- (instancetype)initWithInitialRequest:(nullable TSAIInterpretationRequest *)request;

@end

NS_ASSUME_NONNULL_END
