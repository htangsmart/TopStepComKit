//
//  TSViewController.h
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Posted on the main thread whenever today's activity snapshot is updated
 * @chinese 当天活动数据快照更新时在主线程发出
 *
 * @discussion
 * [EN]: The device root page is the single place that registers
 *       TSDailyActivityInterface registerCurrentActivityDidChanged: (re-registering overrides the
 *       previous callback, so pages must not register by themselves). It forwards every device report,
 *       plus the baseline fetched via syncTodayDailyExerciseDataCompletion: after registration and when
 *       the app returns to the foreground, through this notification. The sender is the TSViewController.
 *       userInfo: TSDailyActivityReportActivityUserInfoKey (TSActivityDailyModel),
 *                 TSDailyActivityReportIsFromDeviceUserInfoKey (NSNumber BOOL).
 * [CN]: 设备 Tab 根页是唯一注册 TSDailyActivityInterface registerCurrentActivityDidChanged: 的地方
 *       （重复注册会覆盖上一个回调，其他页面不要自行注册）。它把每次设备上报，以及注册后 / 回到前台时通过
 *       syncTodayDailyExerciseDataCompletion: 补拉的基线数据，统一通过本通知转发。object 为 TSViewController。
 *       userInfo：TSDailyActivityReportActivityUserInfoKey（TSActivityDailyModel）、
 *                 TSDailyActivityReportIsFromDeviceUserInfoKey（NSNumber BOOL）。
 */
FOUNDATION_EXTERN NSNotificationName const TSDailyActivityReportDidUpdateNotification;

/**
 * @brief userInfo key: today's activity snapshot (TSActivityDailyModel)
 * @chinese userInfo key：当天活动数据快照（TSActivityDailyModel）
 */
FOUNDATION_EXTERN NSString * const TSDailyActivityReportActivityUserInfoKey;

/**
 * @brief userInfo key: YES when the snapshot was pushed by the device, NO when fetched as a baseline
 * @chinese userInfo key：YES 表示设备主动上报，NO 表示 App 主动同步得到的基线
 */
FOUNDATION_EXTERN NSString * const TSDailyActivityReportIsFromDeviceUserInfoKey;

@interface TSViewController : TSBaseVC

@end

NS_ASSUME_NONNULL_END
