//
//  TSHsdParentalModeVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Basic parental mode page (FitCloud)
 * @chinese 家长模式（基础版）：主开关 + 三个「允许」开关 + 限制游戏时段（时间轴 + 开始 / 结束）
 *
 * @discussion
 * [EN]: Backed by fetchParentalMode: / setParentalMode:completion: (isSupportParentalMode, FitCloud).
 *       NPK devices use the advanced variant TSHsdParentalControlVC (isSupportParentalControl).
 * [CN]: 走 fetchParentalMode: / setParentalMode:completion:（isSupportParentalMode，FitCloud）；
 *       NPK 设备使用进阶版 TSHsdParentalControlVC（isSupportParentalControl）。
 *       显式保存 + 自动回读比对（产品方案 §3.2、§4.2）。结束早于开始时标「次日」，不拦截（D-14）。
 */
@interface TSHsdParentalModeVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
