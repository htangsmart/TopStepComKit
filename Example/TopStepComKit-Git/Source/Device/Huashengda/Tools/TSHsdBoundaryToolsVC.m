//
//  TSHsdBoundaryToolsVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBoundaryToolsVC.h"
#import <TopStepToolKit/TopStepToolKit.h>

typedef NS_ENUM(NSInteger, TSHsdToolKind) {
    TSHsdToolSixTasks = 0,       ///< D-21
    TSHsdToolElevenHabits,       ///< D-25
    TSHsdToolLabel33,            ///< N-06
    TSHsdToolFourIce,            ///< N-12
    TSHsdToolRanking256,         ///< N-11
    TSHsdToolTrends31,           ///< M-16
    TSHsdToolIce64,              ///< N-12
    TSHsdToolZeroIceTrends,      ///< N-12 · M-16
    TSHsdToolConcurrent,         ///< D-61
    TSHsdToolParental20,         ///< D-60
};

/// 一个工具及其最近一次结果
@interface TSHsdTool : NSObject
@property (nonatomic, assign) TSHsdToolKind kind;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caseId;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, copy, nullable) NSString *resultText;
@property (nonatomic, assign) BOOL resultOK;
@end
@implementation TSHsdTool
@end

#pragma mark - 结果块（.tool-res）

@interface TSHsdToolResultView : UIView
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdToolResultView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.layer.cornerRadius = 9.f;
    _label = [[UILabel alloc] init];
    _label.font = [TSHsdDisplay monoFontOfSize:11.f];
    _label.numberOfLines = 0;
    [self addSubview:_label];
    return self;
}
- (void)configureText:(NSString *)text style:(NSInteger)style {   // 0 进行中 / 1 ok / 2 bad
    self.label.text = text;
    UIColor *color = style == 1 ? [TSHsdDisplay statusGood] : (style == 2 ? [TSHsdDisplay statusBad] : [TSHsdDisplay textSecondary]);
    self.label.textColor = color;
    self.backgroundColor = style == 0 ? [TSHsdDisplay fill] : [color colorWithAlphaComponent:0.09f];
    [self setNeedsLayout];
}
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, ceil([self.label sizeThatFits:CGSizeMake(size.width - 18.f, CGFLOAT_MAX)].height) + 14.f);
}
- (void)layoutSubviews { [super layoutSubviews]; self.label.frame = CGRectInset(self.bounds, 9.f, 7.f); }
@end

#pragma mark - TSHsdBoundaryToolsVC

@interface TSHsdBoundaryToolsVC ()
@property (nonatomic, copy) NSArray<TSHsdTool *> *tools;
@end

@implementation TSHsdBoundaryToolsVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.tools");
    self.hue = [TSHsdDisplay hueTools];
    self.usesDock = NO;
    self.showsReloadButton = NO;
    self.chips = @[@"P1", TSLocalizedString(@"hsd.tools.chip")];
    NSArray<NSArray *> *defs = @[
        @[@(TSHsdToolSixTasks), TSLocalizedString(@"hsd.tools.six_tasks"), @"D-21"],
        @[@(TSHsdToolElevenHabits), TSLocalizedString(@"hsd.tools.eleven_habits"), @"D-25"],
        @[@(TSHsdToolLabel33), TSLocalizedString(@"hsd.tools.label33"), @"N-06"],
        @[@(TSHsdToolFourIce), TSLocalizedString(@"hsd.tools.four_ice"), @"N-12"],
        @[@(TSHsdToolRanking256), TSLocalizedString(@"hsd.tools.ranking256"), @"N-11"],
        @[@(TSHsdToolTrends31), TSLocalizedString(@"hsd.tools.trends31"), @"M-16"],
        @[@(TSHsdToolIce64), TSLocalizedString(@"hsd.tools.ice64"), @"N-12"],
        @[@(TSHsdToolZeroIceTrends), TSLocalizedString(@"hsd.tools.zero"), @"N-12 · M-16"],
        @[@(TSHsdToolConcurrent), TSLocalizedString(@"hsd.tools.concurrent"), @"D-61"],
        @[@(TSHsdToolParental20), TSLocalizedString(@"hsd.tools.parental20"), @"D-60"],
    ];
    NSMutableArray<TSHsdTool *> *tools = [NSMutableArray array];
    for (NSArray *def in defs) {
        TSHsdTool *tool = [[TSHsdTool alloc] init];
        tool.kind = [def[0] integerValue];
        tool.title = def[1];
        tool.caseId = def[2];
        [tools addObject:tool];
    }
    self.tools = tools;
}

- (void)reload {}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];
    [blocks addObject:[self banner:TSLocalizedString(@"hsd.tools.banner") warn:NO]];
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.tools.sec.params") right:nil]];
    [blocks addObject:[self card:[self ts_rowsForRange:NSMakeRange(0, 8)]]];
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.tools.sec.stress") right:nil]];
    [blocks addObject:[self card:[self ts_rowsForRange:NSMakeRange(8, 2)]]];
    return blocks;
}

- (NSArray<UIView *> *)ts_rowsForRange:(NSRange)range {
    NSMutableArray<UIView *> *rows = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    for (NSUInteger i = range.location; i < NSMaxRange(range) && i < self.tools.count; i++) {
        TSHsdTool *tool = self.tools[i];
        TSHsdRowView *row = [self row];
        row.topAligned = YES;
        row.title = tool.title;
        row.subtitle = [NSString stringWithFormat:TSLocalizedString(@"hsd.tools.case_format"), tool.caseId];
        if (tool.running || tool.resultText.length) {
            TSHsdToolResultView *result = [[TSHsdToolResultView alloc] init];
            [result configureText:tool.running ? TSLocalizedString(@"hsd.tools.running") : tool.resultText style:tool.running ? 0 : (tool.resultOK ? 1 : 2)];
            row.extraView = result;
        }
        TSHsdCTAButton *run = [[TSHsdCTAButton alloc] init];
        run.small = YES;
        run.soft = YES;
        [run setTitle:TSLocalizedString(@"hsd.tools.run") symbol:nil];
        run.enabled = !tool.running;
        run.onTap = ^{ [weakSelf ts_run:tool]; };
        row.rightView = run;
        [rows addObject:row];
    }
    return rows;
}

#pragma mark - 运行

- (void)ts_run:(TSHsdTool *)tool {
    if (tool.running) { return; }
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    tool.running = YES;
    tool.resultText = nil;
    [self render];
    switch (tool.kind) {
        case TSHsdToolSixTasks: [self ts_runTaskTool:tool count:6 labelBytes:5]; break;
        case TSHsdToolLabel33: [self ts_runTaskTool:tool count:1 labelBytes:33]; break;
        case TSHsdToolElevenHabits: [self ts_runHabitTool:tool]; break;
        case TSHsdToolFourIce: [self ts_runIceTool:tool labels:@[@"A", @"B", @"C", @"D"]]; break;
        case TSHsdToolIce64: [self ts_runIceTool:tool labels:@[[self ts_stringWithBytes:64]]]; break;
        case TSHsdToolRanking256: [self ts_runTrendTool:tool count:1 ranking:256]; break;
        case TSHsdToolTrends31: [self ts_runTrendTool:tool count:31 ranking:1]; break;
        case TSHsdToolZeroIceTrends: [self ts_runZeroTool:tool]; break;
        case TSHsdToolConcurrent: [self ts_runConcurrentTool:tool]; break;
        case TSHsdToolParental20: [self ts_runParentalLoop:tool]; break;
    }
}

/// 由 ASCII 字符组成的指定字节数字符串
- (NSString *)ts_stringWithBytes:(NSUInteger)bytes {
    return [@"" stringByPaddingToLength:bytes withString:@"x" startingAtIndex:0];
}

/// 预期被拦截：INVALID_PARAM 视为通过
- (void)ts_finishExpectedReject:(TSHsdTool *)tool entry:(TSHsdCallLogEntry *)entry success:(BOOL)success error:(nullable NSError *)error startedAt:(NSDate *)startedAt {
    __weak typeof(self) weakSelf = self;
    [self onMain:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        NSTimeInterval ms = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000;
        [self finishCall:entry success:success error:error result:success ? @"success（未拦截）" : nil];
        tool.running = NO;
        if (success) {
            tool.resultOK = NO;
            tool.resultText = [NSString stringWithFormat:TSLocalizedString(@"hsd.tools.not_intercepted_format"), ms];
        } else {
            BOOL intercepted = (error.code == eTSErrorInvalidParam || error.code == eTSErrorParamError || error.code == eTSErrorParamSizeError);
            tool.resultOK = intercepted;
            tool.resultText = [NSString stringWithFormat:@"%@ · %@ · %.0f ms", intercepted ? TSLocalizedString(@"hsd.tools.intercepted") : [TSHsdErrorText messageForError:error],
                               [TSHsdErrorText detailForError:error], ms];
        }
        [self render];
    }];
}

- (void)ts_runTaskTool:(TSHsdTool *)tool count:(NSUInteger)count labelBytes:(NSUInteger)labelBytes {
    TSHsdTaskInfoModel *info = [[TSHsdTaskInfoModel alloc] init];
    info.totalCoins = 0;
    NSMutableArray<TSHsdTaskModel *> *tasks = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        TSHsdTaskModel *t = [[TSHsdTaskModel alloc] init];
        t.taskId = i + 1;
        t.label = [self ts_stringWithBytes:labelBytes];
        t.enabled = YES;
        t.repeatOptions = TSAlarmRepeatEveryday;
        t.coins = 1;
        t.timeEnabled = YES;
        t.minuteOfDay = 480;
        [tasks addObject:t];
    }
    info.tasks = tasks;
    NSDate *start = [NSDate date];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setTaskInfo:completion:" params:[NSString stringWithFormat:@"tasks=%lu label=%luB", (unsigned long)count, (unsigned long)labelBytes]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setTaskInfo:info completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf ts_finishExpectedReject:tool entry:entry success:isSuccess error:error startedAt:start];
    }];
}

- (void)ts_runHabitTool:(TSHsdTool *)tool {
    NSMutableArray<TSHsdHabitModel *> *habits = [NSMutableArray array];
    for (NSUInteger i = 0; i < 11; i++) {
        TSHsdHabitModel *h = [[TSHsdHabitModel alloc] init];
        h.habitId = i + 1;
        h.type = TSHsdHabitTypeSport;
        h.minuteOfDay = 1080;
        h.duration = 30;
        h.repeatOptions = TSAlarmRepeatEveryday;
        h.taskDays = 21;
        [habits addObject:h];
    }
    NSDate *start = [NSDate date];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setHabits:completion:" params:@"habits=11"];
    __weak typeof(self) weakSelf = self;
    [self.hsd setHabits:habits completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf ts_finishExpectedReject:tool entry:entry success:isSuccess error:error startedAt:start];
    }];
}

- (void)ts_runIceTool:(TSHsdTool *)tool labels:(NSArray<NSString *> *)labels {
    NSDate *start = [NSDate date];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setIceLabels:completion:" params:[NSString stringWithFormat:@"labels=%lu first=%luB", (unsigned long)labels.count, (unsigned long)[TSHsdDisplay utf8Length:labels.firstObject]]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setIceLabels:labels completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf ts_finishExpectedReject:tool entry:entry success:isSuccess error:error startedAt:start];
    }];
}

- (void)ts_runTrendTool:(TSHsdTool *)tool count:(NSUInteger)count ranking:(NSInteger)ranking {
    NSMutableArray<TSHsdGameRankingTrendModel *> *trends = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        TSHsdGameRankingTrendModel *m = [[TSHsdGameRankingTrendModel alloc] init];
        m.gameType = (TSHsdGameType)(i % 25);
        m.ranking = ranking;
        m.trend = TSHsdRankingTrendUnchanged;
        [trends addObject:m];
    }
    NSDate *start = [NSDate date];
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setGameRankingTrends:completion:" params:[NSString stringWithFormat:@"trends=%lu ranking=%ld", (unsigned long)count, (long)ranking]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setGameRankingTrends:trends completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf ts_finishExpectedReject:tool entry:entry success:isSuccess error:error startedAt:start];
    }];
}

/// 0 条 ICE + 0 条趋势：两次调用，结果合并显示
- (void)ts_runZeroTool:(TSHsdTool *)tool {
    NSDate *start = [NSDate date];
    TSHsdCallLogEntry *iceEntry = [self beginCall:@"huashengda.setIceLabels:completion:" params:@"labels=0"];
    __weak typeof(self) weakSelf = self;
    [self.hsd setIceLabels:@[] completion:^(BOOL iceOK, NSError *iceError) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            [self finishCall:iceEntry success:iceOK error:iceError result:nil];
            TSHsdCallLogEntry *trendEntry = [self beginCall:@"huashengda.setGameRankingTrends:completion:" params:@"trends=0"];
            [self.hsd setGameRankingTrends:@[] completion:^(BOOL trendOK, NSError *trendError) {
                [weakSelf onMain:^{
                    __strong typeof(weakSelf) self = weakSelf;
                    if (!self) { return; }
                    [self finishCall:trendEntry success:trendOK error:trendError result:nil];
                    NSTimeInterval ms = [[NSDate date] timeIntervalSinceDate:start] * 1000;
                    BOOL iceIntercepted = !iceOK && iceError.code == eTSErrorInvalidParam;
                    BOOL trendIntercepted = !trendOK && trendError.code == eTSErrorInvalidParam;
                    tool.running = NO;
                    tool.resultOK = iceIntercepted && trendIntercepted;
                    tool.resultText = [NSString stringWithFormat:@"ICE: %@\ntrends: %@\n%.0f ms",
                                       iceOK ? TSLocalizedString(@"hsd.tools.not_intercepted_short") : [TSHsdErrorText detailForError:iceError],
                                       trendOK ? TSLocalizedString(@"hsd.tools.not_intercepted_short") : [TSHsdErrorText detailForError:trendError], ms];
                    [self render];
                }];
            }];
        }];
    }];
}

/// 并发：同时发起 fetchHabits（0x61）与 fetchAppUsage（0x63）
- (void)ts_runConcurrentTool:(TSHsdTool *)tool {
    NSDate *start = [NSDate date];
    __block NSString *habitResult = nil, *usageResult = nil;
    __weak typeof(self) weakSelf = self;
    void (^finishIfDone)(void) = ^{
        if (!habitResult || !usageResult) { return; }
        NSTimeInterval ms = [[NSDate date] timeIntervalSinceDate:start] * 1000;
        tool.running = NO;
        tool.resultOK = ![habitResult hasPrefix:@"✗"] && ![usageResult hasPrefix:@"✗"];
        tool.resultText = [NSString stringWithFormat:@"0x61 %@\n0x63 %@\n%.0f ms", habitResult, usageResult, ms];
        [weakSelf render];
    };
    TSHsdCallLogEntry *habitEntry = [self beginCall:@"huashengda.fetchHabits:" params:TSLocalizedString(@"hsd.tools.concurrent_tag")];
    TSHsdCallLogEntry *usageEntry = [self beginCall:@"huashengda.fetchAppUsage:" params:TSLocalizedString(@"hsd.tools.concurrent_tag")];
    [self.hsd fetchHabits:^(NSArray<TSHsdHabitModel *> *habits, NSError *error) {
        [weakSelf onMain:^{
            [weakSelf finishCall:habitEntry success:(error == nil) error:error result:[NSString stringWithFormat:@"%lu habits", (unsigned long)habits.count]];
            habitResult = error ? [@"✗ " stringByAppendingString:[TSHsdErrorText detailForError:error]] : [NSString stringWithFormat:@"✓ %lu habits", (unsigned long)habits.count];
            finishIfDone();
        }];
    }];
    [self.hsd fetchAppUsage:^(NSArray<TSHsdDailyUsageModel *> *days, NSError *error) {
        [weakSelf onMain:^{
            [weakSelf finishCall:usageEntry success:(error == nil) error:error result:[NSString stringWithFormat:@"%lu days", (unsigned long)days.count]];
            usageResult = error ? [@"✗ " stringByAppendingString:[TSHsdErrorText detailForError:error]] : [NSString stringWithFormat:@"✓ %lu days", (unsigned long)days.count];
            finishIfDone();
        }];
    }];
}

/// 连续 20 次家长模式读 → 写：每次写回上一次读到的原值，压测通信，不改变手表上的设置（D-60）
/// 进阶版（isSupportParentalControl，NPK）走 fetchParentalControl / setParentalControl，基础版走 fetchParentalMode / setParentalMode
- (void)ts_runParentalLoop:(TSHsdTool *)tool {
    NSDate *start = [NSDate date];
    [self ts_parentalLoopStep:0 okCount:0 failCount:0 lastError:nil lastModel:nil tool:tool startedAt:start];
}

- (void)ts_parentalLoopStep:(NSInteger)step okCount:(NSInteger)ok failCount:(NSInteger)fail lastError:(nullable NSError *)lastError
                  lastModel:(nullable id)lastModel tool:(TSHsdTool *)tool startedAt:(NSDate *)start {
    if (step >= 20) {
        NSTimeInterval ms = [[NSDate date] timeIntervalSinceDate:start] * 1000;
        tool.running = NO;
        tool.resultOK = (fail == 0);
        tool.resultText = [NSString stringWithFormat:TSLocalizedString(@"hsd.tools.loop_result_format"), (long)ok, (long)fail, ms,
                           lastError ? [TSHsdErrorText detailForError:lastError] : @"-"];
        [self render];
        return;
    }
    __weak typeof(self) weakSelf = self;
    BOOL advanced = [self.hsd isSupportParentalControl];
    BOOL isRead = (step % 2 == 0) || !lastModel;   // 没有读到过就继续读，绝不写入编造的值
    NSString *stepTag = [NSString stringWithFormat:@"#%ld", (long)(step + 1)];
    NSString *writeTag = [NSString stringWithFormat:@"#%ld · %@", (long)(step + 1), TSLocalizedString(@"hsd.tools.write_back")];
    void (^next)(BOOL, NSError *, id) = ^(BOOL success, NSError *error, id model) {
        [weakSelf onMain:^{
            [weakSelf ts_parentalLoopStep:step + 1 okCount:ok + (success ? 1 : 0) failCount:fail + (success ? 0 : 1)
                                lastError:error ?: lastError lastModel:model ?: lastModel tool:tool startedAt:start];
        }];
    };
    if (isRead && advanced) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalControl:" params:stepTag];
        [self.hsd fetchParentalControl:^(TSHsdParentalControlModel *model, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && model != nil) error:error result:nil];
            next(error == nil && model != nil, error, [model copy]);
        }];
    } else if (isRead) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalMode:" params:stepTag];
        [self.hsd fetchParentalMode:^(TSHsdParentalModeModel *model, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && model != nil) error:error result:nil];
            next(error == nil && model != nil, error, [model copy]);
        }];
    } else if (advanced) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setParentalControl:completion:" params:writeTag];
        [self.hsd setParentalControl:[lastModel copy] completion:^(BOOL isSuccess, NSError *error) {
            [weakSelf finishCall:entry success:isSuccess error:error result:nil];
            next(isSuccess, error, nil);
        }];
    } else {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setParentalMode:completion:" params:writeTag];
        [self.hsd setParentalMode:[lastModel copy] completion:^(BOOL isSuccess, NSError *error) {
            [weakSelf finishCall:entry success:isSuccess error:error result:nil];
            next(isSuccess, error, nil);
        }];
    }
}

@end
