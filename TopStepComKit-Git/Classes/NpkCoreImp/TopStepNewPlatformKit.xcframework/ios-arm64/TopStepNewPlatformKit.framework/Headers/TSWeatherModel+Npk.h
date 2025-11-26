//
//  TSWeatherModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/2.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/TopStepBleMetaKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWeatherModel (Npk)

/**
 * @brief Convert to TSMetaWeatherModel
 * @chinese 转换为 TSMetaWeatherModel
 *
 * @discussion
 * [EN]: Convert current TSWeatherModel to protobuf model used by BLE meta layer.
 * [CN]: 将当前 TSWeatherModel 转换为 BLE Meta 层使用的 Protobuf 模型。
 */
- (nullable TSMetaWeatherModel *)toMetaWeatherModel;

@end

NS_ASSUME_NONNULL_END
