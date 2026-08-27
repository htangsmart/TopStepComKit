//
//  TSStarBurstDevice.h
//  TopStepAIKit
//
//  Created by 磐石 on 2026/7/24.
//

#import <Foundation/Foundation.h>
#import <AIBuds/AIBuds-Swift.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSStarBurstDeviceDataSender)(NSData *data);
typedef void(^TSStarBurstDeviceAuthResultBlock)(BOOL success, NSError * _Nullable error);

/**
 * @brief StarBurst device bridge object
 * @chinese StarBurst 设备桥接对象
 *
 * @discussion
 * [EN]: Adapts a TopStep device bridge to AIBudsStarBurstDevice. The concrete
 *       business kit provides how bridge data is sent to the real device.
 * [CN]: 将 TopStep 设备桥接适配为 AIBudsStarBurstDevice。具体业务 Kit
 *       提供桥接数据发送到真实设备的实现。
 */
@interface TSStarBurstDevice : NSObject<AIBudsStarBurstDevice>

/**
 * @brief Device identifier
 * @chinese 设备标识
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Callback for sending StarBurst bridge data
 * @chinese 发送 StarBurst 桥接数据的回调
 */
@property (nonatomic, copy, nullable) TSStarBurstDeviceDataSender dataSender;

/**
 * @brief Callback for StarBurst authentication result
 * @chinese StarBurst 认证结果回调
 */
@property (nonatomic, copy, nullable) TSStarBurstDeviceAuthResultBlock authResultBlock;

/**
 * @brief Create a StarBurst device bridge
 * @chinese 创建 StarBurst 设备桥接对象
 *
 * @param identifier
 * EN: Device identifier
 * CN: 设备标识
 *
 * @return
 * EN: A StarBurst device bridge instance
 * CN: StarBurst 设备桥接对象
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
