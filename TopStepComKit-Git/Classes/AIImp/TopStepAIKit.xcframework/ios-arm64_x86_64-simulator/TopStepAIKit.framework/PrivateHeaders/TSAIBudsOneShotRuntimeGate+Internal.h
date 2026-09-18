//
//  TSAIBudsOneShotRuntimeGate+Internal.h
//  TopStepAIKit
//
//  Created by Codex on 2026/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Posted after a runtime lease is actually released @chinese 真实释放运行时租约后发布 */
FOUNDATION_EXPORT NSNotificationName const TSAIBudsOneShotRuntimeDidReleaseNotification;

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

/** @brief Query an owned capability @chinese 查询能力是否已被占用
 * @param capability EN: Capability. CN: 能力类型。
 * @return EN: Whether occupied. CN: 是否被占用。
 */
+ (BOOL)isCapabilityOccupied:(TSAIBudsOneShotCapability)capability;

/** @brief Acquire an idle capability @chinese 获取空闲能力所有权 */
+ (BOOL)acquireCapability:(TSAIBudsOneShotCapability)capability
                   taskId:(NSString *)taskId;

/** @brief Release only when taskId owns the capability @chinese 仅由所有者释放能力 */
+ (void)releaseCapability:(TSAIBudsOneShotCapability)capability
                   taskId:(NSString *)taskId;

@end

NS_ASSUME_NONNULL_END
