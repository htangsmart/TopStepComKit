//
//  TSUgreenVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief UGREEN customer features page
 * @chinese 绿联定制页（设备页「定制功能」→ 绿联定制）
 *
 * @discussion
 * [EN]: One page for TSUgreenInterface: desktop-stand mode, always-on pages, triple-press function,
 *       lyrics theme and color, with a screen preview drawn from the connected device's screenInfo.
 *       Saving always fetches the latest config, applies only the edited fields, writes the whole
 *       config and reads it back for a field-by-field comparison.
 * [CN]: 对应 TSUgreenInterface 的单个页面：桌搭模式、常亮页面、充电盒三击、歌词主题与颜色，
 *       顶部按已连接设备的 screenInfo 画屏端预览。保存时依次「读取最新 → 只替换改过的字段 →
 *       整包写入 → 回读逐字段比对」，不会覆盖设备端在编辑期间的改动。UI 与交互以 prototypes/ugreen/index.html 为准。
 */
@interface TSUgreenVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
