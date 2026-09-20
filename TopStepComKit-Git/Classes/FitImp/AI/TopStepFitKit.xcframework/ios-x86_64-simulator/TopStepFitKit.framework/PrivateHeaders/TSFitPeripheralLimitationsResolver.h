//
//  TSFitPeripheralLimitationsResolver.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FitCloudCapacity;

/**
 * @brief Resolve Fit capacities into unified peripheral limitations
 * @chinese 将 Fit 设备容量解析为统一外设限制
 */
@interface TSFitPeripheralLimitationsResolver : NSObject

/**
 * @brief Resolve the maximum UTF-8 byte count for AI response text
 * @chinese 解析 AI 应答文本最大 UTF-8 字节数
 * @param capacities EN: FitCloud device capacities. CN: FitCloud 设备容量。
 * @return EN: Reported nonnegative value, or the unified default.
 * CN: 上报的非负值，缺失或非法时返回统一默认值。
 */
+ (NSUInteger)maxAIResponseTextBytesWithCapacities:(nullable NSArray<FitCloudCapacity *> *)capacities;

@end

NS_ASSUME_NONNULL_END
