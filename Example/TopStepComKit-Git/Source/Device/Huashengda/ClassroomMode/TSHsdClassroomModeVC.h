//
//  TSHsdClassroomModeVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Classroom mode page
 * @chinese 课堂模式（bit30 · 0x5C / 0x5D）：主开关 + 上课时段（时间轴 + 时间对）+ 重复日（7 键 + 快捷键）
 *
 * @discussion
 * [CN]: 与家长模式同构，换一个色相。开启但一天都没选时黄色提示，不拦截。手表侧修改无主动通知（D-16）。
 */
@interface TSHsdClassroomModeVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
