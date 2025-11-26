//
//  TSConnectedPeripheral+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/14.
//

#import <TopStepToolKit/TopStepToolKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSConnectedPeripheral (Npk)

/**
 * @brief Create TSConnectedPeripheral instance from TSPeripheral and TSPeripheralConnectParam
 * @chinese 根据TSPeripheral和TSPeripheralConnectParam创建TSConnectedPeripheral实例
 *
 * @param peripheral
 * [EN]: TSPeripheral object containing device information
 * [CN]: 包含设备信息的TSPeripheral对象
 *
 * @param connectParam
 * [EN]: TSPeripheralConnectParam object containing connection parameters
 * [CN]: 包含连接参数的TSPeripheralConnectParam对象
 *
 * @return
 * [EN]: New TSConnectedPeripheral instance, nil if creation fails
 * [CN]: 新的TSConnectedPeripheral实例，创建失败时返回nil
 *
 * @discussion
 * [EN]: This method creates a TSConnectedPeripheral object by extracting relevant information
 *       from TSPeripheral and TSPeripheralConnectParam. It maps device properties like
 *       MAC address, device name, user ID, and connection parameters to the appropriate
 *       fields in TSConnectedPeripheral.
 * [CN]: 此方法通过从TSPeripheral和TSPeripheralConnectParam中提取相关信息来创建TSConnectedPeripheral对象。
 *       它将设备属性（如MAC地址、设备名称、用户ID和连接参数）映射到TSConnectedPeripheral的相应字段。
 */
+ (instancetype _Nullable)connectedPeripheralWithPeripheral:(TSPeripheral *)peripheral
                                               connectParam:(TSPeripheralConnectParam *)connectParam;

@end

NS_ASSUME_NONNULL_END
