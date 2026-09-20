//
//  TSFitPeripheralAIAbilityResolver.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FitCloudAllConfigObject;
@class TSPeripheralAIAbility;

/**
 * @brief Resolve Fit firmware fields into the unified peripheral AI ability
 * @chinese 将 Fit 固件字段解析为统一外设 AI 能力
 */
@interface TSFitPeripheralAIAbilityResolver : NSObject

/**
 * @brief Resolve an ability from one FitCloud configuration snapshot
 * @chinese 从同一个 FitCloud 配置快照解析能力
 * @param allConfig EN: FitCloud configuration snapshot. CN: FitCloud 配置快照。
 * @return EN: A nonnull ability. CN: 非空能力对象。
 */
+ (TSPeripheralAIAbility *)abilityWithAllConfig:(nullable FitCloudAllConfigObject *)allConfig;

@end

NS_ASSUME_NONNULL_END
