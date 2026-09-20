//
//  TSMyMapsVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief "My Maps" page with local / device tabs
 * @chinese 「我的地图」页（本地/设备双 Tab）
 *
 * @discussion
 * [EN]: Lists offline maps in two tabs: local maps downloaded to the phone (single-select, can be pushed to
 *       the device or deleted) and device maps stored on the watch (multi-select, can be deleted from device).
 *       The push flow performs a connection / battery / overwrite pre-check and reports progress via an overlay,
 *       wired to TSOfflineMapsInterface pushOfflineMap:mapName:progress:success:failure: and deleteOfflineMap:.
 * [CN]: 分两个 Tab 展示离线地图：已下载到手机的本地地图（单选，可推送到设备或删除）与存储在手表上的设备地图
 *       （多选，可从设备删除）。推送流程会进行连接/电量/覆盖前置检查并通过覆盖层展示进度，对接
 *       TSOfflineMapsInterface 的 pushOfflineMap:mapName:progress:success:failure: 与 deleteOfflineMap:。
 */
@interface TSMyMapsVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
