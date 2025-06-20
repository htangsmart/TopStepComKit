//
//  TSSJPeripheralFind.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/3/18.
//

#import <TopStepSJWatchKit/TopStepSJWatchKit.h>
#import <TopStepInterfaceKit/TSPeripheralFindInterface.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Peripheral find interface implementation
 * @chinese 外设查找接口实现
 *
 * @discussion
 * EN: This class implements the TSPeripheralFindInterface protocol for SJ devices.
 *     It provides functionality to find the peripheral device and handle device-initiated find phone requests.
 * CN: 该类实现了SJ设备的TSPeripheralFindInterface协议。
 *     提供查找外设和处理设备发起的查找手机请求的功能。
 */
@interface TSSJPeripheralFind : TSSJKitBase<TSPeripheralFindInterface>

@end

NS_ASSUME_NONNULL_END
