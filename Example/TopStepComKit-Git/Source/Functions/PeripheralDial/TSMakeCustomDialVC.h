//
//  TSMakeCustomDialVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Make and push custom watch face entry view controller
 * @chinese 制作并推送自定义表盘入口控制器
 *
 * @discussion
 * [EN]: Entry coordinator for the custom dial creation flow.
 *       Shows an action sheet for source selection (camera / photo library / video),
 *       then navigates through crop/edit pages to the final TSDialEditorVC.
 *       Must be presented inside a UINavigationController.
 * [CN]: 自定义表盘制作流程的入口协调器。
 *       弹出来源选择 ActionSheet（拍照 / 相册 / 视频），
 *       再依次跳转裁剪/编辑页，最终到达 TSDialEditorVC。
 *       必须在 UINavigationController 内呈现。
 */
@interface TSMakeCustomDialVC : TSBaseVC

/**
 * @brief Callback invoked after the custom dial is successfully pushed to the device.
 * @chinese 自定义表盘成功推送到设备后的回调。
 *
 * @discussion
 * [EN]: Called on the main thread after the navigation controller is dismissed.
 *       Use this to refresh the parent page.
 * [CN]: 在导航控制器 dismiss 之后在主线程调用，用于刷新父页面。
 */
@property (nonatomic, copy, nullable) void(^onPushSuccess)(void);

@end

NS_ASSUME_NONNULL_END
