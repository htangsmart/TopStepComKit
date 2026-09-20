//
//  TSFitGPSLocationService.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/7/10.
//

#import <Foundation/Foundation.h>
#import <FitCloudGPSAccelerate/FitCloudGPSAccelerate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief GPS location provider for FitCloudGPSAccelerate
 * @chinese 为 FitCloudGPSAccelerate 提供定位的服务
 *
 * @discussion
 * [EN]: FitCloudGPSAccelerate requires a location service to pick the EPO region. This class fetches
 *       a coarse one-shot location via CoreLocation. It requests When-In-Use authorization if the
 *       permission is not determined yet, and fails when denied/restricted.
 * [CN]: FitCloudGPSAccelerate 需要定位服务来选择 EPO 区域。本类用 CoreLocation 获取一次粗略定位。
 *       未授权时会请求 When-In-Use 权限；被拒绝/受限时返回失败。
 */
@interface TSFitGPSLocationService : NSObject <GPSLocationInfoRequestService>

@end

NS_ASSUME_NONNULL_END
