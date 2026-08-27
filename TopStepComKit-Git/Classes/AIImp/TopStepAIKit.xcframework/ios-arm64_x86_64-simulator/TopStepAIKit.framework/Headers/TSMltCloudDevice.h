//
//  TSMltCloudDevice.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/7/24.
//

#import <Foundation/Foundation.h>
#import <AIBuds/AIBuds-Swift.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief MltCloud device bridge object
 * @chinese MltCloud 设备桥接对象
 *
 * @discussion
 * [EN]: Adapts a TopStep device bridge to AIBudsMltCloudDevice. The concrete
 *       business kit owns the real device lifecycle.
 * [CN]: 将 TopStep 设备桥接适配为 AIBudsMltCloudDevice。具体业务 Kit
 *       负责真实设备生命周期。
 */
@interface TSMltCloudDevice : NSObject<AIBudsMltCloudDevice>

/**
 * @brief Device identifier
 * @chinese 设备标识
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Create a MltCloud device bridge
 * @chinese 创建 MltCloud 设备桥接对象
 *
 * @param identifier
 * EN: Device identifier
 * CN: 设备标识
 *
 * @return
 * EN: A MltCloud device bridge instance
 * CN: MltCloud 设备桥接对象
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
