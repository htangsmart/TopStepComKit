//
//  TSKitBaseInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2024/12/27.
//

#import <Foundation/Foundation.h>
#import "TSComEnumDefines.h"
#import "TSKitConfigOptions.h"



NS_ASSUME_NONNULL_BEGIN


/**
 * @brief operation completion callback
 * @chinese 操作完成回调
 *
 * @param isSuccess
 * EN: Whether the operation was successful
 * CN: 是否操作成功
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为nil
 */
typedef void(^TSCompletionBlock)(BOOL isSuccess, NSError * _Nullable error);


/**
 * @brief Base interface protocol for all Kit classes
 * @chinese 基础接口协议，所有Kit的基类都需要遵循此协议
 * 
 * @discussion 
 * EN: This protocol defines the basic methods that all Kits must implement
 * CN: 该协议定义了所有Kit必须实现的基础方法
 */
@protocol TSKitBaseInterface <NSObject>


/**
 * @brief Check if the current device supports this feature
 * @chinese 检查当前设备是否支持此功能
 *
 * @return 
 * [EN]: YES if the device supports this feature, NO otherwise
 * [CN]: 如果设备支持此功能返回YES，否则返回NO
 */
- (BOOL)isSupport;


@optional
/**
 * @brief Set the delegate for this Kit
 * @chinese 设置此Kit的代理
 *
 * @param delegate 
 * [EN]: The object that acts as the delegate of this Kit
 * [CN]: 作为此Kit代理的对象
 */
- (void)setKitDelegate:(id)delegate;

/**
 * @brief Clear all resources and reset the Kit to its initial state
 * @chinese 清除所有资源并将Kit重置为初始状态
 *
 * @discussion
 * [EN]: This method should be called when the Kit is no longer needed to prevent memory leaks
 * [CN]: 当不再需要此Kit时应调用此方法以防止内存泄漏
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
