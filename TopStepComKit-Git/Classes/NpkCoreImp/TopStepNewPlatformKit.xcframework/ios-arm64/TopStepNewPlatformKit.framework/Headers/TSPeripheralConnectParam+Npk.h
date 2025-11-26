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
 * @param userInfo 用户信息（可选）
 *        EN: User information (optional)
 *        CN: 用户信息（可选）
 *
 * @return TSBleConnectParam对象
 *         EN: TSBleConnectParam object
 *         CN: TSBleConnectParam对象
 *
 * @discussion
 * EN: Creates a TSBleConnectParam using device info from TSPeripheralConnectParam.
 *     Uses the brand, model, and systemVersion from self if available.
 *     Falls back to automatic device detection if properties are nil.
 * CN: 使用TSPeripheralConnectParam中的设备信息创建TSBleConnectParam。
 *     如果可用，将使用self中的品牌、型号和系统版本。
 *     如果属性为nil，则回退到自动设备检测。
 */
- (TSMetaAuthParam *)toBleConnectParamWithUserInfo:(nullable TSMetaUserModel *)userInfo;

@end

NS_ASSUME_NONNULL_END
