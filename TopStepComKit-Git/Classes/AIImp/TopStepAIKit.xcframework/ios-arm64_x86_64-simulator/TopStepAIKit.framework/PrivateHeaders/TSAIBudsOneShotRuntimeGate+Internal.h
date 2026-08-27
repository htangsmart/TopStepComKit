//
//  TSAIBudsOneShotRuntimeGate+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Process-wide AIBuds one-shot capability @chinese AIBuds 进程级一次性能力 */
typedef NS_ENUM(NSInteger, TSAIBudsOneShotCapability) {
    TSAIBudsOneShotCapabilityInterpretation = 0,
    TSAIBudsOneShotCapabilityRecognition,
    TSAIBudsOneShotCapabilityTranslation,
    TSAIBudsOneShotCapabilitySynthesis,
};

/**
 * @brief Process-wide ownership gate for AIBuds class-level APIs
 * @chinese AIBuds 类方法入口的进程级所有权门禁
 */
@interface TSAIBudsOneShotRuntimeGate : NSObject

/** @brief Acquire an idle capability @chinese 获取空闲能力所有权 */
+ (BOOL)acquireCapability:(TSAIBudsOneShotCapability)capability
                   taskId:(NSString *)taskId;

/** @brief Release only when taskId owns the capability @chinese 仅由所有者释放能力 */
+ (void)releaseCapability:(TSAIBudsOneShotCapability)capability
                   taskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
