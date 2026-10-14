//
//  TSHsdWeekdayView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 一个快捷键：标题 + 对应的重复位
@interface TSHsdWeekdayPreset : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) TSAlarmRepeat value;
+ (instancetype)presetWithTitle:(NSString *)title value:(TSAlarmRepeat)value;
/// 「工作日 / 每天 / 周末」（课堂模式）
+ (NSArray<TSHsdWeekdayPreset *> *)classroomPresets;
/// 「仅一次 / 工作日 / 每天」（任务、习惯）
+ (NSArray<TSHsdWeekdayPreset *> *)taskPresets;
@end

/**
 * @brief 7 weekday keys + shortcut presets (.wd + .presets)
 * @chinese 周一到周日 7 个圆形日期键（bit0 = 周一，直接读写 TSAlarmRepeat）+ 下方快捷键；放在卡片内使用
 */
@interface TSHsdWeekdayView : UIView

@property (nonatomic, assign) TSAlarmRepeat repeat;
@property (nonatomic, strong) UIColor *hue;
/// 快捷键；为空则不显示快捷键行
@property (nonatomic, copy, nullable) NSArray<TSHsdWeekdayPreset *> *presets;
@property (nonatomic, copy, nullable) void (^onChange)(TSAlarmRepeat repeat);

@end

NS_ASSUME_NONNULL_END
