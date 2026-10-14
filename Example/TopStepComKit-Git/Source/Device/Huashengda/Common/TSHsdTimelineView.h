//
//  TSHsdTimelineView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 24-hour timeline
 * @chinese 24 小时时间轴：轨道上高亮 [start, end) 区间，跨天自动拆成两段；右上角显示时长
 */
@interface TSHsdTimelineView : UIView

/// 开始分钟 [0, 1439]
@property (nonatomic, assign) NSInteger startMinute;
/// 结束分钟 [0, 1439]
@property (nonatomic, assign) NSInteger endMinute;
/// 色相
@property (nonatomic, strong) UIColor *hue;
/// 左上角标题，如「允许游戏」「静默时段」
@property (nonatomic, copy, nullable) NSString *caption;
/// 是否置灰（主开关关闭时）
@property (nonatomic, assign) BOOL dimmed;

/// 固定高度
+ (CGFloat)viewHeight;

/// 区间时长（分钟），跨天按 1440 补
+ (NSInteger)spanMinutesFrom:(NSInteger)start to:(NSInteger)end;

@end

NS_ASSUME_NONNULL_END
