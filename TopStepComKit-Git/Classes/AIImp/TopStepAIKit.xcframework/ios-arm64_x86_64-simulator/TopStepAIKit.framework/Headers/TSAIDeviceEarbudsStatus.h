//
//  TSAIDeviceEarbudsStatus.h
//  TopStepAIKit
//
//  Created by Claude on 2026/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Wear state of the companion earbuds reported by the charging case
 * @chinese 充电仓上报的配套耳机佩戴状态
 *
 * @discussion
 * EN: Only for products made of a charging case plus independent classic-Bluetooth earbuds.
 *     Unknown values are reported as NO with isKnown = NO.
 * CN: 仅适用于「充电仓 + 独立经典蓝牙耳机」的产品。状态未知时各字段为 NO，isKnown 为 NO。
 */
@interface TSAIDeviceEarbudsStatus : NSObject <NSCopying>

/** @brief Whether the case reported a definite state @chinese 充电仓是否上报了确定的状态 */
@property (nonatomic, assign, readonly, getter=isKnown) BOOL known;

/** @brief Left earbud connected to the case @chinese 左耳已连接 */
@property (nonatomic, assign, readonly, getter=isLeftConnected) BOOL leftConnected;

/** @brief Right earbud connected to the case @chinese 右耳已连接 */
@property (nonatomic, assign, readonly, getter=isRightConnected) BOOL rightConnected;

/** @brief Left earbud placed in the case @chinese 左耳在仓内 */
@property (nonatomic, assign, readonly, getter=isLeftInCase) BOOL leftInCase;

/** @brief Right earbud placed in the case @chinese 右耳在仓内 */
@property (nonatomic, assign, readonly, getter=isRightInCase) BOOL rightInCase;

/** @brief At least one earbud is connected and out of the case @chinese 至少一只耳机已连接且不在仓内 */
@property (nonatomic, assign, readonly) BOOL hasEarbudOutOfCase;

/**
 * @brief Create a status
 * @chinese 创建耳机状态
 */
+ (instancetype)statusWithLeftConnected:(BOOL)leftConnected
                         rightConnected:(BOOL)rightConnected
                             leftInCase:(BOOL)leftInCase
                            rightInCase:(BOOL)rightInCase;

/**
 * @brief Status whose values are unknown
 * @chinese 状态未知
 */
+ (instancetype)unknownStatus;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
