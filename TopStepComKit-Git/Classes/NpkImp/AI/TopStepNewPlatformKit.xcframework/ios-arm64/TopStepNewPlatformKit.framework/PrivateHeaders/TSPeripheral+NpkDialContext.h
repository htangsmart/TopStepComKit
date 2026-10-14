//
//  TSPeripheral+NpkDialContext.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK-private dial request context attached to a peripheral
 * @chinese 绑定到外设的 NPK 私有表盘请求上下文
 */
@interface TSPeripheral (NpkDialContext)

/** @brief PB dial platform, 0 for W30 and 1 for 579X @chinese PB 表盘平台，0 为 W30，1 为 579X */
@property (nonatomic, assign) NSInteger npkDialPlatform;

/** @brief PB dial feature bits @chinese PB 表盘特性位 */
@property (nonatomic, assign) NSUInteger npkDialFeatures;

@end

NS_ASSUME_NONNULL_END
