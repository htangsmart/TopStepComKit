//
//  TSEpoViewController.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO(GNSS ephemeris) management page
 * @chinese EPO(GNSS 星历) 管理页
 *
 * @discussion
 * [EN]: Demo page for the SDK EPO push capability. It shows the device EPO status (validity computed
 *       from validDate), a one-tap update via the built-in server, a forceUpdate switch, and a
 *       collapsible "advanced sources" area (customServer / fileURLs / binFile). All sources go through
 *       the single [TSEpoInterface updateEpoWithSource:forceUpdate:progress:success:failure:] entry and
 *       share one total-progress ring. A bottom console logs every operation for debugging.
 * [CN]: SDK EPO 推送能力的演示页。展示设备 EPO 状态(有效性由 validDate 计算)、通过内置服务器的一键更新、
 *       强制更新开关，以及可折叠的「高级来源」区(customServer / fileURLs / binFile)。所有来源统一走
 *       [TSEpoInterface updateEpoWithSource:forceUpdate:progress:success:failure:] 入口，共用一个总进度环。
 *       底部控制台记录每次操作，便于调试。
 */
@interface TSEpoViewController : TSBaseVC <UIDocumentPickerDelegate>

@end

NS_ASSUME_NONNULL_END
