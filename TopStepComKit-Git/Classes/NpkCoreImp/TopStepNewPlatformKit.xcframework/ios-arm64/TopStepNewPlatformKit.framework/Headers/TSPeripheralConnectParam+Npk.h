//
//  TSPeripheralConnectParam+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/24.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralConnectParam (Npk)

/**
 * @brief Convert TSPeripheralConnectParam to TSBleConnectParam
 * @chinese 将TSPeripheralConnectParam转换为TSBleConnectParam对象
 *
 * @return TSBleConnectParam对象
 *         EN: TSBleConnectParam object
 *         CN: TSBleConnectParam对象
 *
 * @discussion
 * EN: Creates a TSBleConnectParam using the connection userId, authCode,
 *     optional NPK extra user profile, and automatically detected device info.
 * CN: 使用连接 userId、authCode、可选的 NPK 用户资料补充参数以及自动获取的设备信息
 *     创建 TSBleConnectParam。
 */
- (TSMetaAuthParam *)toBleConnectParam;

@end

NS_ASSUME_NONNULL_END
