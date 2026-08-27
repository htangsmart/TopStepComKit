//
//  TSAIKitErrorMapper.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>

#import "TSAIContractDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Error mapper from AIBuds AI errors to TopStep errors
 * @chinese AIBuds AI 错误到 TopStep 错误的映射工具
 */
@interface TSAIKitErrorMapper : NSObject

/**
 * @brief Convert an AIBuds error to a TopStep error
 * @chinese 将 AIBuds 错误转换为 TopStep 错误
 *
 * @param error
 * EN: Error returned by AIBuds SDK
 * CN: AIBuds SDK 返回的错误
 *
 * @return
 * EN: Error exposed to TopStep callers
 * CN: 暴露给 TopStep 调用方的错误
 */
+ (nullable NSError *)topStepErrorFromAIBudsError:(nullable NSError *)error;

/**
 * @brief Convert an AIBuds error using a stable fallback semantic
 * @chinese 使用稳定的兜底语义转换 AIBuds 错误
 *
 * @param error EN: Optional AIBuds error. CN: 可选的 AIBuds 错误。
 * @param defaultCode EN: Fallback unified code. CN: 兜底统一错误码。
 * @param description EN: Fallback description. CN: 兜底错误描述。
 * @return EN: Stable TopStepAIKit error. CN: 稳定的 TopStepAIKit 错误。
 */
+ (NSError *)topStepErrorFromAIBudsError:(nullable NSError *)error
                             defaultCode:(TSAIErrorCode)defaultCode
                             description:(NSString *)description;

/**
 * @brief Convert an image-generation error through the unified AIBuds boundary
 * @chinese 通过 AIBuds 统一边界转换图片生成错误
 *
 * @param error EN: Optional error returned by AIBudsAISDK. CN: AIBudsAISDK 返回的可选错误。
 * @param defaultCode EN: Fallback unified code. CN: 兜底统一错误码。
 * @param description EN: Fallback description. CN: 兜底错误描述。
 * @return EN: Stable TopStepAIKit error. CN: 稳定的 TopStepAIKit 错误。
 */
+ (NSError *)topStepImageGenerationErrorFromAIBudsError:(nullable NSError *)error
                                             defaultCode:(TSAIErrorCode)defaultCode
                                             description:(NSString *)description;

/**
 * @brief Create a unified TopStepAIKit error
 * @chinese 创建统一 TopStepAIKit 错误
 *
 * @param code EN: Unified error code. CN: 统一错误码。
 * @param description EN: Error description. CN: 错误描述。
 * @param underlyingError EN: Optional original error. CN: 可选原始错误。
 * @return EN: Stable TopStepAIKit error. CN: 稳定的 TopStepAIKit 错误。
 */
+ (NSError *)errorWithCode:(TSAIErrorCode)code
               description:(NSString *)description
           underlyingError:(nullable NSError *)underlyingError;

@end

NS_ASSUME_NONNULL_END
