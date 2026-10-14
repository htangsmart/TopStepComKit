//
//  TSHsdUsageVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Usage statistics page
 * @chinese 使用统计（bit33 · 0x63 / 0x64 / 0x65）：应用 | 游戏 分段、日期条（设备 / 推算来源）、当天总数与排序条形、重置
 *
 * @discussion
 * [CN]: 首次切到分段才读取；空天 / 空数组 / 分包不连续各有专门表现（D-30 – D-33、D-37）。重置后自动重读两类并汇报。
 */
@interface TSHsdUsageVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
