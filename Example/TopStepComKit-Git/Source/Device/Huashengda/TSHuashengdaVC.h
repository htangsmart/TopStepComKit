//
//  TSHuashengdaVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Huashengda customization overview
 * @chinese 华盛达定制总览页：深色设备卡（7 段能力条 + 能力明细）+ 按「管控 / 成长 / 洞察 / 安全」分组的 Bento 功能卡（带手表当前状态摘要）+ 边界测试工具
 *
 * @discussion
 * [CN]: 入口在设备菜单（TSDeviceMenuBuilder.featureItems），comKit.huashengda 非 nil 即可进入。
 *       进入时顺序读取家长模式 / 课堂模式 / 任务 / 习惯 4 个轻量接口生成摘要（读过的不重复读，某个失败只影响那一张卡）；
 *       不支持的能力显示为虚线占位卡，点击只弹说明。
 */
@interface TSHuashengdaVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
