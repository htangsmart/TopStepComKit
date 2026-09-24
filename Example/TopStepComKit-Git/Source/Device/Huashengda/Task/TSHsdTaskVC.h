//
//  TSHsdTaskVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Task & reward page
 * @chinese 任务与奖励（bit31 · 0x5E / 0x5F / 0x60）：金币卡 + 任务列表（≤5）+ 添加；整表保存前静默回读、保存后回读比对
 *
 * @discussion
 * [CN]: 产品方案 §4.3。保存 = 静默 fetchTaskInfo（讨论点 A）→ 确认 → setTaskInfo → fetchTaskInfo 比对。
 *       兑换无论成败都重新读取；兑换成功但回读失败时明确提示，不误报为兑换失败。
 */
@interface TSHsdTaskVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
