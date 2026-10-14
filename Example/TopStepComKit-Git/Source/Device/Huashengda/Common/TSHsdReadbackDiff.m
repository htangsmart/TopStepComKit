//
//  TSHsdReadbackDiff.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdReadbackDiff.h"
#import "TSHsdDisplay.h"
#import "TSHsdSheet.h"
#import "TSRootVC.h"

@implementation TSHsdDiffItem

+ (instancetype)itemWithField:(NSString *)field sent:(NSString *)sent read:(NSString *)read {
    TSHsdDiffItem *item = [[TSHsdDiffItem alloc] init];
    item.field = field;
    item.sent = sent;
    item.read = read;
    return item;
}

@end

@implementation TSHsdReadbackDiff

#pragma mark - 工具

static NSString *TSHsdBool(BOOL value) {
    return value ? TSLocalizedString(@"general.on") : TSLocalizedString(@"general.off");
}

static NSString *TSHsdInt(NSInteger value) {
    return [NSString stringWithFormat:@"%ld", (long)value];
}

static NSString *TSHsdStr(NSString *_Nullable value) {
    return value.length ? value : @"∅";
}

static void TSHsdAddIfDiff(NSMutableArray<TSHsdDiffItem *> *items, NSString *field, NSString *sent, NSString *read) {
    if (![sent isEqualToString:read]) {
        [items addObject:[TSHsdDiffItem itemWithField:field sent:sent read:read]];
    }
}

#pragma mark - 家长模式 / 课堂模式

+ (NSArray<TSHsdDiffItem *> *)diffParental:(TSHsdParentalModeModel *)sent read:(nullable TSHsdParentalModeModel *)read {
    NSMutableArray<TSHsdDiffItem *> *items = [NSMutableArray array];
    if (!read) {
        [items addObject:[TSHsdDiffItem itemWithField:TSLocalizedString(@"hsd.diff.whole_model") sent:@"…" read:@"nil"]];
        return items;
    }
    TSHsdAddIfDiff(items, @"enabled", TSHsdBool(sent.isEnabled), TSHsdBool(read.isEnabled));
    TSHsdAddIfDiff(items, @"timeSettingEnabled", TSHsdBool(sent.isTimeSettingEnabled), TSHsdBool(read.isTimeSettingEnabled));
    TSHsdAddIfDiff(items, @"enterSettingEnabled", TSHsdBool(sent.isEnterSettingEnabled), TSHsdBool(read.isEnterSettingEnabled));
    TSHsdAddIfDiff(items, @"alarmSettingEnabled", TSHsdBool(sent.isAlarmSettingEnabled), TSHsdBool(read.isAlarmSettingEnabled));
    TSHsdAddIfDiff(items, @"gameDurationEnabled", TSHsdBool(sent.isGameDurationEnabled), TSHsdBool(read.isGameDurationEnabled));
    TSHsdAddIfDiff(items, @"gameStartMinute", [TSHsdDisplay timeStringForMinute:sent.gameStartMinute], [TSHsdDisplay timeStringForMinute:read.gameStartMinute]);
    TSHsdAddIfDiff(items, @"gameEndMinute", [TSHsdDisplay timeStringForMinute:sent.gameEndMinute], [TSHsdDisplay timeStringForMinute:read.gameEndMinute]);
    return items;
}

/// 时段的一行文字：08:00–20:00 · 工作日
static NSString *TSHsdPeriodText(TSHsdParentalControlPeriodModel *_Nullable period) {
    if (!period) { return @"nil"; }
    return [NSString stringWithFormat:@"%@–%@ · %@", [TSHsdDisplay timeStringForMinute:period.startMinute],
            [TSHsdDisplay timeStringForMinute:period.endMinute], [TSHsdDisplay repeatString:period.repeatOptions]];
}

+ (NSArray<TSHsdDiffItem *> *)diffParentalControl:(TSHsdParentalControlModel *)sent read:(nullable TSHsdParentalControlModel *)read {
    NSMutableArray<TSHsdDiffItem *> *items = [NSMutableArray array];
    if (!read) {
        [items addObject:[TSHsdDiffItem itemWithField:TSLocalizedString(@"hsd.diff.whole_model") sent:@"…" read:@"nil"]];
        return items;
    }
    TSHsdAddIfDiff(items, @"enabled", TSHsdBool(sent.isEnabled), TSHsdBool(read.isEnabled));
    TSHsdAddIfDiff(items, @"items.count", TSHsdInt(sent.items.count), TSHsdInt(read.items.count));
    NSMutableDictionary<NSNumber *, TSHsdParentalControlItemModel *> *readByFunction = [NSMutableDictionary dictionary];
    for (TSHsdParentalControlItemModel *item in read.items) { readByFunction[@(item.function)] = item; }
    for (TSHsdParentalControlItemModel *s in sent.items) {
        NSString *name = [TSHsdDisplay parentalFunctionName:s.function];
        TSHsdParentalControlItemModel *r = readByFunction[@(s.function)];
        if (!r) {
            [items addObject:[TSHsdDiffItem itemWithField:name sent:TSHsdBool(s.isEnabled) read:@"nil"]];
            continue;
        }
        [readByFunction removeObjectForKey:@(s.function)];
        TSHsdAddIfDiff(items, [name stringByAppendingString:@".enabled"], TSHsdBool(s.isEnabled), TSHsdBool(r.isEnabled));
        TSHsdAddIfDiff(items, [name stringByAppendingString:@".mode"], [TSHsdDisplay parentalControlModeName:s.mode], [TSHsdDisplay parentalControlModeName:r.mode]);
        TSHsdAddIfDiff(items, [name stringByAppendingString:@".periods.count"], TSHsdInt(s.periods.count), TSHsdInt(r.periods.count));
        NSUInteger n = MAX(s.periods.count, r.periods.count);
        for (NSUInteger i = 0; i < n; i++) {
            TSHsdParentalControlPeriodModel *sp = i < s.periods.count ? s.periods[i] : nil;
            TSHsdParentalControlPeriodModel *rp = i < r.periods.count ? r.periods[i] : nil;
            TSHsdAddIfDiff(items, [NSString stringWithFormat:@"%@.periods[%lu]", name, (unsigned long)i], TSHsdPeriodText(sp), TSHsdPeriodText(rp));
        }
    }
    for (NSNumber *function in readByFunction) {
        [items addObject:[TSHsdDiffItem itemWithField:[TSHsdDisplay parentalFunctionName:function.integerValue] sent:@"nil" read:TSHsdBool(readByFunction[function].isEnabled)]];
    }
    return items;
}

+ (NSArray<TSHsdDiffItem *> *)diffClassroom:(TSHsdClassroomModeModel *)sent read:(nullable TSHsdClassroomModeModel *)read {
    NSMutableArray<TSHsdDiffItem *> *items = [NSMutableArray array];
    if (!read) {
        [items addObject:[TSHsdDiffItem itemWithField:TSLocalizedString(@"hsd.diff.whole_model") sent:@"…" read:@"nil"]];
        return items;
    }
    TSHsdAddIfDiff(items, @"enabled", TSHsdBool(sent.isEnabled), TSHsdBool(read.isEnabled));
    TSHsdAddIfDiff(items, @"startMinute", [TSHsdDisplay timeStringForMinute:sent.startMinute], [TSHsdDisplay timeStringForMinute:read.startMinute]);
    TSHsdAddIfDiff(items, @"endMinute", [TSHsdDisplay timeStringForMinute:sent.endMinute], [TSHsdDisplay timeStringForMinute:read.endMinute]);
    TSHsdAddIfDiff(items, @"repeatOptions", [TSHsdDisplay repeatString:sent.repeatOptions], [TSHsdDisplay repeatString:read.repeatOptions]);
    return items;
}

#pragma mark - 任务

+ (NSArray<TSHsdDiffItem *> *)diffTaskInfo:(TSHsdTaskInfoModel *)sent read:(nullable TSHsdTaskInfoModel *)read {
    NSMutableArray<TSHsdDiffItem *> *items = [NSMutableArray array];
    if (!read) {
        [items addObject:[TSHsdDiffItem itemWithField:TSLocalizedString(@"hsd.diff.whole_model") sent:@"…" read:@"nil"]];
        return items;
    }
    TSHsdAddIfDiff(items, @"totalCoins", TSHsdInt(sent.totalCoins), TSHsdInt(read.totalCoins));
    TSHsdAddIfDiff(items, @"tasks.count", TSHsdInt(sent.tasks.count), TSHsdInt(read.tasks.count));

    NSMutableDictionary<NSNumber *, TSHsdTaskModel *> *readById = [NSMutableDictionary dictionary];
    for (TSHsdTaskModel *task in read.tasks) { readById[@(task.taskId)] = task; }

    for (TSHsdTaskModel *s in sent.tasks) {
        NSString *prefix = [NSString stringWithFormat:@"task#%ld.", (long)s.taskId];
        TSHsdTaskModel *r = readById[@(s.taskId)];
        if (!r) {
            [items addObject:[TSHsdDiffItem itemWithField:[prefix stringByAppendingString:@"*"] sent:TSHsdStr(s.label) read:TSLocalizedString(@"hsd.diff.missing")]];
            continue;
        }
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"label"], TSHsdStr(s.label), TSHsdStr(r.label));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"minuteOfDay"], [TSHsdDisplay timeStringForMinute:s.minuteOfDay], [TSHsdDisplay timeStringForMinute:r.minuteOfDay]);
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"enabled"], TSHsdBool(s.isEnabled), TSHsdBool(r.isEnabled));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"repeatOptions"], [TSHsdDisplay repeatString:s.repeatOptions], [TSHsdDisplay repeatString:r.repeatOptions]);
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"type"], TSHsdInt(s.type), TSHsdInt(r.type));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"coins"], TSHsdInt(s.coins), TSHsdInt(r.coins));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"taskDescription"], TSHsdStr(s.taskDescription), TSHsdStr(r.taskDescription));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"timeEnabled"], TSHsdBool(s.isTimeEnabled), TSHsdBool(r.isTimeEnabled));
        // state 由手表维护，不计入
        [readById removeObjectForKey:@(s.taskId)];
    }
    for (NSNumber *extraId in readById) {
        [items addObject:[TSHsdDiffItem itemWithField:[NSString stringWithFormat:@"task#%@.*", extraId] sent:TSLocalizedString(@"hsd.diff.missing") read:TSHsdStr(readById[extraId].label)]];
    }
    return items;
}

#pragma mark - 习惯

+ (NSArray<TSHsdDiffItem *> *)diffHabits:(NSArray<TSHsdHabitModel *> *)sent read:(nullable NSArray<TSHsdHabitModel *> *)read {
    NSMutableArray<TSHsdDiffItem *> *items = [NSMutableArray array];
    if (!read) {
        [items addObject:[TSHsdDiffItem itemWithField:TSLocalizedString(@"hsd.diff.whole_model") sent:@"…" read:@"nil"]];
        return items;
    }
    TSHsdAddIfDiff(items, @"habits.count", TSHsdInt(sent.count), TSHsdInt(read.count));

    NSMutableDictionary<NSNumber *, TSHsdHabitModel *> *readById = [NSMutableDictionary dictionary];
    for (TSHsdHabitModel *habit in read) { readById[@(habit.habitId)] = habit; }

    for (TSHsdHabitModel *s in sent) {
        NSString *prefix = [NSString stringWithFormat:@"habit#%ld.", (long)s.habitId];
        TSHsdHabitModel *r = readById[@(s.habitId)];
        if (!r) {
            [items addObject:[TSHsdDiffItem itemWithField:[prefix stringByAppendingString:@"*"] sent:TSHsdStr(s.label) read:TSLocalizedString(@"hsd.diff.missing")]];
            continue;
        }
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"type"], TSHsdInt(s.type), TSHsdInt(r.type));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"label"], TSHsdStr(s.label), TSHsdStr(r.label));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"minuteOfDay"], [TSHsdDisplay timeStringForMinute:s.minuteOfDay], [TSHsdDisplay timeStringForMinute:r.minuteOfDay]);
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"duration"], TSHsdInt(s.duration), TSHsdInt(r.duration));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"repeatOptions"], [TSHsdDisplay repeatString:s.repeatOptions], [TSHsdDisplay repeatString:r.repeatOptions]);
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"taskDays"], TSHsdInt(s.taskDays), TSHsdInt(r.taskDays));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"associatedFunction"], TSHsdInt(s.associatedFunction), TSHsdInt(r.associatedFunction));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"remindDuration"], TSHsdInt(s.remindDuration), TSHsdInt(r.remindDuration));
        TSHsdAddIfDiff(items, [prefix stringByAppendingString:@"remindAdvance"], TSHsdInt(s.remindAdvance), TSHsdInt(r.remindAdvance));
        // state / reachGoalDays / maxReachGoalDays / latestAchieveGoal* / achieveGoalRepeat 由手表维护，不计入
        [readById removeObjectForKey:@(s.habitId)];
    }
    for (NSNumber *extraId in readById) {
        [items addObject:[TSHsdDiffItem itemWithField:[NSString stringWithFormat:@"habit#%@.*", extraId] sent:TSLocalizedString(@"hsd.diff.missing") read:TSHsdStr(readById[extraId].label)]];
    }
    return items;
}

#pragma mark - 面板

+ (void)presentDiff:(NSArray<TSHsdDiffItem *> *)items from:(UIViewController *)presenter {
    [TSHsdSheet presentDiffFrom:presenter items:items];
}

@end
