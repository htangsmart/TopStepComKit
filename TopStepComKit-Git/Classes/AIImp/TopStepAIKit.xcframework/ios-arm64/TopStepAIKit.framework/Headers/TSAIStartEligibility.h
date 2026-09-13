//
//  TSAIStartEligibility.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable result of evaluating one AI start request
 * @chinese 单次 AI 启动请求资格校验的不可变结果
 *
 * @discussion
 * [EN]: Supported always has no error. Unsupported always carries an error.
 * [CN]: Supported 必须不含错误；Unsupported 必须携带错误。
 */
@interface TSAIStartEligibility : NSObject <NSCopying>

/** @brief Binary support result @chinese 二态支持结果 */
@property (nonatomic, assign, readonly) TSAICapabilitySupport support;

/** @brief Failure reason; nil only when supported @chinese 失败原因，仅支持时为 nil */
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 * @brief Create a supported eligibility result
 * @chinese 创建支持启动的资格结果
 *
 * @return
 * EN: Supported result without an error
 * CN: 不含错误的支持结果
 */
+ (instancetype)supportedEligibility;

/**
 * @brief Create an unsupported eligibility result
 * @chinese 创建不支持启动的资格结果
 *
 * @param error
 * EN: Exact reason why the request cannot start
 * CN: 请求无法启动的准确原因
 *
 * @return
 * EN: Unsupported result carrying the error
 * CN: 携带错误的不支持结果
 */
+ (instancetype)unsupportedEligibilityWithError:(NSError *)error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
