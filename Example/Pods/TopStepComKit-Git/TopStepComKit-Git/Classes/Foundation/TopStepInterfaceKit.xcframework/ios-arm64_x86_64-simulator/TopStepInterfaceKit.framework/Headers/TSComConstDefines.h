//
//  TSComConstDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Notification posted when device unbinding is successful
 * @chinese 设备解绑成功时发送的通知
 *
 * @discussion
 * [EN]: This notification is posted when a device is successfully unbound.
 *       The notification does not contain a userInfo dictionary.
 * [CN]: 当设备成功解绑时会发送此通知。
 *       该通知不包含 userInfo 字典。
 */
FOUNDATION_EXPORT NSNotificationName const TSBleDeviceUnbindSuccessNotification;



@interface TSComConstDefines : NSObject

@end

NS_ASSUME_NONNULL_END
