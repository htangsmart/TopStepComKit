/**
 * @file TSSJBleConnect.h
 * @brief 三嘉手表蓝牙连接管理类
 * @details 该类负责处理三嘉手表的蓝牙设备搜索、连接、断开等操作
 * @author 磐石
 * @date 2025/1/9
 */

#import "TSSJKitBase.h"
#import <TopStepInterfaceKit/TSBleConnectInterface.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class TSSJBleConnect
 * @brief 三嘉手表蓝牙连接管理类
 * @details 该类继承自TSSJKitBase并实现TSBleConnectInterface协议，
 *          提供了蓝牙设备的搜索、连接、断开等功能的实现
 */
@interface TSSJBleConnect : TSSJKitBase<TSBleConnectInterface>

@end

NS_ASSUME_NONNULL_END
