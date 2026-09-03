//
//  TSOfflineMapVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Offline-map region selection page
 * @chinese 离线地图圈选页
 *
 * @discussion
 * [EN]: The main entry of the offline-map feature. It shows a full map with a fixed-size center circle
 *       representing the download range. The user pinches the map to change the real-world radius covered
 *       by the fixed circle (1-20 km), searches for a place, or recenters on the current location. Two
 *       bottom buttons let the user download the circled region to the phone (with a naming dialog) or open
 *       the "My Maps" page. The download is wired to TSOfflineMapsInterface downloadOfflineMapWithRegion:.
 * [CN]: 离线地图功能的主入口。展示整张地图，中心有一个固定大小的圆表示下载范围。用户双指缩放地图以改变固定圆
 *       覆盖的真实地理半径（1-20 公里），可搜索地点，或回到当前定位。底部两个按钮分别用于将圈选区域下载到手机
 *       （带命名弹窗）或打开「我的地图」页。下载对接 TSOfflineMapsInterface 的 downloadOfflineMapWithRegion:。
 */
@interface TSOfflineMapVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
