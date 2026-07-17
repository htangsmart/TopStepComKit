//
//  TSAppStatusModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/11/18.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief App status model
 * @chinese App状态模型
 *
 * @discussion
 * [EN]: This model contains the current status and permissions of the application.
 *       Used to synchronize app state with connected devices.
 * [CN]: 该模型包含应用程序的当前状态和权限信息。
 *       用于与连接的设备同步应用状态。
 */
@interface TSAppStatusModel : TSKitBaseModel

/**
 * @brief Whether the app is in foreground
 * @chinese 应用是否在前台
 *
 * @discussion
 * [EN]: Indicates whether the application is currently active in the foreground.
 *       YES means the app is visible and active, NO means it's in background or inactive.
 * [CN]: 表示应用当前是否在前台活跃状态。
 *       YES表示应用可见且活跃，NO表示应用在后台或非活跃状态。
 */
@property (nonatomic, assign) BOOL isForeground;

/**
 * @brief Whether the app has SMS permission
 * @chinese 应用是否有短信权限
 *
 * @discussion
 * [EN]: Indicates whether the application has permission to send SMS messages.
 *       YES means SMS permission is granted, NO means it's denied or not requested.
 * [CN]: 表示应用是否具有发送短信的权限。
 *       YES表示已授予短信权限，NO表示被拒绝或未请求。
 *
 * @note
 * [EN]: This permission is required for sending SMS notifications from connected devices.
 * [CN]: 从连接的设备发送短信通知需要此权限。
 */
@property (nonatomic, assign) BOOL hasSMSPermission;

/**
 * @brief Whether the app has location permission
 * @chinese 应用是否有定位权限
 *
 * @discussion
 * [EN]: Indicates whether the application has location access permission.
 *       YES means location permission is granted (always or when in use),
 *       NO means it's denied or not determined.
 * [CN]: 表示应用是否具有位置访问权限。
 *       YES表示已授予定位权限（始终允许或使用时允许），
 *       NO表示被拒绝或未确定。
 *
 * @note
 * [EN]: Location permission is required for activity tracking and GPS-related features.
 * [CN]: 活动跟踪和GPS相关功能需要定位权限。
 */
@property (nonatomic, assign) BOOL hasLocationPermission;

/**
 * @brief Whether the app has camera permission
 * @chinese 应用是否有相机权限
 *
 * @discussion
 * [EN]: Indicates whether the application has camera access permission.
 *       YES means camera permission is granted,
 *       NO means it's denied or not determined.
 * [CN]: 表示应用是否具有相机访问权限。
 *       YES表示已授予相机权限，
 *       NO表示被拒绝或未确定。
 *
 * @note
 * [EN]: Camera permission is required for taking photos or recording videos.
 * [CN]: 拍照或录制视频需要相机权限。
 */
@property (nonatomic, assign) BOOL hasCameraPermission;

#pragma mark - Class Methods

/**
 * @brief Check if app has location permission
 * @chinese 检查应用是否有定位权限
 *
 * @return YES if location permission is granted, NO otherwise
 * @chinese 如果已授予定位权限返回YES，否则返回NO
 */
+ (BOOL)hasLocationPermission;

/**
 * @brief Check if app is in foreground
 * @chinese 检查应用是否在前台
 *
 * @return YES if app is active in foreground, NO otherwise
 * @chinese 如果应用在前台活跃返回YES，否则返回NO
 */
+ (BOOL)isAppInForeground;

/**
 * @brief Check if app has SMS permission
 * @chinese 检查应用是否有短信权限
 *
 * @return YES if SMS permission is granted, NO otherwise
 * @chinese 如果已授予短信权限返回YES，否则返回NO
 *
 * @note
 * [EN]: iOS does not provide a direct API to check SMS permission, this method always returns NO.
 * [CN]: iOS没有提供直接检查短信权限的API，此方法总是返回NO。
 */
+ (BOOL)hasSMSPermission;

/**
 * @brief Check if app has camera permission
 * @chinese 检查应用是否有相机权限
 *
 * @return YES if camera permission is granted, NO otherwise
 * @chinese 如果已授予相机权限返回YES，否则返回NO
 *
 * @discussion
 * [EN]: Checks the camera authorization status using AVFoundation framework.
 *       Returns YES only when permission is explicitly granted (AVAuthorizationStatusAuthorized).
 * [CN]: 使用AVFoundation框架检查相机授权状态。
 *       仅在明确授予权限时（AVAuthorizationStatusAuthorized）返回YES。
 *
 * @note
 * [EN]: Camera permission is required for taking photos or recording videos.
 * [CN]: 拍照或录制视频需要相机权限。
 */
+ (BOOL)hasCameraPermission;

/**
 * @brief Get current app status
 * @chinese 获取当前应用状态
 *
 * @return TSAppStatusModel instance with current app status and permissions
 * @chinese 返回包含当前应用状态和权限信息的TSAppStatusModel实例
 */
+ (instancetype)currentAppStatus;

@end

NS_ASSUME_NONNULL_END
