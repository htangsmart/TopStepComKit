//
//  TSPushCloudDialVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Push cloud watch face view controller
 * @chinese 推送云端表盘页
 *
 * @discussion
 * [EN]: Select a local file (.dial / .bin / .zip / .tar) via system File picker,
 *       preview by filename from bundle or placeholder, then push to device with
 *       progress. On success: toast then pop and refresh list; on failure: toast
 *       and "重新开始" button.
 *
 * [CN]: 通过系统文件选择器选择本地表盘文件（.dial/.bin/.zip/.tar），按文件名从工程查找预览图或占位图，
 *       然后推送到设备并显示进度。成功：Toast 后 pop 并刷新列表；失败：Toast 且按钮变为「重新开始」。
 */
@interface TSPushCloudDialVC : TSBaseVC

/**
 * @brief Callback when push succeeds, before popping (e.g. refresh list on parent)
 * @chinese 推送成功时回调（在 pop 之前），可由列表页设置以刷新数据
 */
@property (nonatomic, copy, nullable) void(^onPushSuccess)(void);

@end

NS_ASSUME_NONNULL_END
