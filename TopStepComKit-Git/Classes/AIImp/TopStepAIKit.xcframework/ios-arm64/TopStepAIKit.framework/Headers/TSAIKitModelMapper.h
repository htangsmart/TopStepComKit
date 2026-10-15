//
//  TSAIKitModelMapper.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>

#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Model mapper between TopStepAIKit Contract models and AIBuds AI models
 * @chinese TopStepAIKit Contract 模型与 AIBuds AI 模型之间的映射工具
 */
@interface TSAIKitModelMapper : NSObject

/**
 * @brief Map a usage plan to the AIBuds StarBurst `usage_plan` option value
 * @chinese 将计费套餐映射为 AIBuds 星芒（StarBurst）`usage_plan` 选项取值
 *
 * @param usagePlan
 * EN: Usage plan from the Contract layer
 * CN: Contract 层的计费套餐
 *
 * @return
 * EN: `"lite"` or `"pro"`; unknown values fall back to `"lite"` so that Pro is
 *     only used when explicitly requested
 * CN: `"lite"` 或 `"pro"`；未知取值回落 `"lite"`，保证只有显式指定时才使用 Pro
 */
+ (NSString *)starburstUsagePlanValueForPlan:(TSAIUsagePlan)usagePlan;

@end

NS_ASSUME_NONNULL_END
