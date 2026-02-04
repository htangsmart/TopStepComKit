//
//  TSMessageModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseModel.h"
#import "TSMessageDefines.h"


NS_ASSUME_NONNULL_BEGIN
/**
 * @brief 消息通知模型
 * @discussion 用于管理设备的各类消息通知设置
 */
@interface TSMessageModel : TSKitBaseModel

/**
 * @brief 消息类型
 * @discussion 表示当前消息的类型，详见TSMessageType枚举
 */
@property (nonatomic, assign) TSMessageType type;

/**
 * @brief 是否启用
 * @discussion YES表示启用该类型的通知，NO表示禁用
 */
@property (nonatomic, assign,getter=isEnable) BOOL enable;

/**
 * @brief Create a message model with specified type
 * @chinese 根据指定的消息类型创建消息模型
 *
 * @param type 
 * EN: The message type to create model for
 * CN: 要创建模型的消息类型
 *
 * @return 
 * EN: A new TSMessageModel instance with the specified type
 * CN: 返回一个包含指定类型的TSMessageModel实例
 *
 * @discussion
 * EN: This method creates a new message model with the specified type.
 *     The enable property will be set to NO by default.
 * CN: 此方法创建一个具有指定类型的新消息模型。
 *     启用属性默认设置为NO。
 */
+ (instancetype)modelWithType:(TSMessageType)type;


/**
 * @brief Create a message model with specified type and enable status
 * @chinese 根据指定的消息类型和启用状态创建消息模型
 *
 * @param type
 * EN: The message type to create model for
 * CN: 要创建模型的消息类型
 *
 * @param enable
 * EN: Whether the message type is enabled
 * CN: 该消息类型是否启用
 *
 * @return
 * EN: A new TSMessageModel instance with the specified type and enable status
 * CN: 返回一个包含指定类型和启用状态的TSMessageModel实例
 *
 * @discussion
 * EN: This method creates a new message model with the specified type and enable status.
 * CN: 此方法创建一个具有指定类型和启用状态的新消息模型。
 */
+ (instancetype)modelWithType:(TSMessageType)type enable:(BOOL)enable ;

@end

NS_ASSUME_NONNULL_END
