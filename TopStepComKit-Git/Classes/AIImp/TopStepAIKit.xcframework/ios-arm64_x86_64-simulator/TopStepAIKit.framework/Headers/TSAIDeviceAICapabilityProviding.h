//
//  TSAIDeviceAICapabilityProviding.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAIAudioRouteDefines.h"
#import "TSAICapabilityDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Reports exact device AI capability by scene, initiator and input
 * @chinese 按场景、发起方和输入通道报告精确设备 AI 能力
 */
@protocol TSAIDeviceAICapabilityProviding <NSObject>

/**
 * @brief Return whether the exact device-coordinated AI input is supported
 * @chinese 返回是否支持指定的设备协同 AI 输入组合
 *
 * @param scene
 * EN: Device AI scene
 * CN: 设备 AI 场景
 *
 * @param initiator
 * EN: Side that initiates the session
 * CN: 会话发起方
 *
 * @param channel
 * EN: Resolved audio input channel; Unknown and Automatic are unsupported
 * CN: 已解析的音频输入通道；Unknown 和 Automatic 均按不支持处理
 *
 * @return
 * EN: Supported only when the exact combination is proven available
 * CN: 仅准确组合已被证明可用时返回 Supported
 */
- (TSAICapabilitySupport)supportForDeviceAIScene:(TSAIDeviceAIScene)scene
                                      initiator:(TSAISessionInitiator)initiator
                               audioInputChannel:(TSAIAudioInputChannel)channel;

@end

NS_ASSUME_NONNULL_END
