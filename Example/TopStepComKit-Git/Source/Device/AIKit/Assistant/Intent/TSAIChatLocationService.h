//
//  TSAIChatLocationService.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// 定位服务错误域
FOUNDATION_EXTERN NSErrorDomain const TSAIChatLocationErrorDomain;

/**
 * @brief Location service error codes
 * @chinese 定位服务错误码
 */
typedef NS_ENUM(NSInteger, TSAIChatLocationErrorCode) {
    /// 用户拒绝 / 受限 (Permission denied or restricted)
    TSAIChatLocationErrorCodePermissionDenied = 1,
    /// 权限未决定且本次不允许申请 (Not determined and prompting is not allowed)
    TSAIChatLocationErrorCodePermissionNotDetermined = 2,
    /// 系统定位服务已关闭 (Location services disabled system-wide)
    TSAIChatLocationErrorCodeServicesDisabled = 3,
    /// 定位失败 / 超时 (Fix failed or timed out)
    TSAIChatLocationErrorCodeFixFailed = 4,
};

/**
 * @brief Location fetch completion
 * @chinese 定位完成回调
 *
 * @param location EN: Resolved location, nil on failure. CN: 定位结果，失败时为 nil。
 * @param placeName EN: Human-readable place ("广东省深圳市南山区科技园") or a "GPS(lat,lng)" fallback. CN: 可读地名（省市区街道），逆地理失败时为 "GPS(lat,lng)"。
 * @param error EN: Error in TSAIChatLocationErrorDomain on failure. CN: 失败时的错误（TSAIChatLocationErrorDomain）。
 */
typedef void (^TSAIChatLocationFetchBlock)(CLLocation *_Nullable location,
                                           NSString *_Nullable placeName,
                                           NSError *_Nullable error);

/**
 * @brief One-shot location + reverse-geocoding service for AI chat
 * @chinese AI 对话用的一次性定位 + 逆地理服务
 *
 * @discussion
 * [EN]: Wraps CLLocationManager / CLGeocoder: optional permission prompt,
 *       single in-flight fix shared by concurrent callers, 2-minute cache,
 *       and a fixed timeout so a request can never hang the caller.
 *       All callbacks are delivered on the main thread.
 * [CN]: 封装 CLLocationManager / CLGeocoder：可选权限申请、并发请求合并为一次定位、
 *       2 分钟缓存、固定超时保证调用方不会挂住。所有回调在主线程。
 */
@interface TSAIChatLocationService : NSObject

/**
 * @brief Shared instance
 * @chinese 共享实例
 */
+ (instancetype)sharedService;

/**
 * @brief Current authorization status
 * @chinese 当前定位授权状态
 */
@property (nonatomic, assign, readonly) CLAuthorizationStatus authorizationStatus;

/**
 * @brief Whether the App may use location right now (whenInUse / always granted)
 * @chinese 当前是否已获得可用的定位权限
 */
@property (nonatomic, assign, readonly) BOOL isAuthorized;

/**
 * @brief Last successful location, if any (regardless of age)
 * @chinese 最近一次成功的定位（不考虑时效）
 */
@property (nonatomic, strong, readonly, nullable) CLLocation *lastLocation;

/**
 * @brief Place name of the last successful location
 * @chinese 最近一次成功定位的地名
 */
@property (nonatomic, copy, readonly, nullable) NSString *lastPlaceName;

/**
 * @brief Fetch the current location and place name
 * @chinese 获取当前位置与地名
 *
 * @param allowPrompt
 * EN: YES to show the system permission prompt when the status is notDetermined;
 *     NO fails silently with PermissionNotDetermined
 * CN: 权限未决定时是否弹系统授权框；NO 时直接以 PermissionNotDetermined 失败
 *
 * @param completion
 * EN: Called once on the main thread
 * CN: 主线程回调一次
 */
- (void)fetchLocationAllowingPrompt:(BOOL)allowPrompt
                         completion:(TSAIChatLocationFetchBlock)completion;

/**
 * @brief Open the App's page in system Settings (for denied permission)
 * @chinese 打开系统设置中本 App 的页面（权限被拒绝时引导用户）
 */
- (void)openSystemSettings;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
