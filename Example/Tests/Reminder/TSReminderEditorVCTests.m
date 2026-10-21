//
//  TSReminderEditorVCTests.m
//  TopStepComKit-Git_Tests
//
//  仅验证编辑草稿和表格，不调用保存 SDK 或访问蓝牙。
//

#import <XCTest/XCTest.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "../../TopStepComKit-Git/Source/Device/TSReminder/TSReminderEditorVC.h"

// 测试声明私有方法，不增加公开 API 或重复编译生产实现。
@interface TSReminderEditorVC (Testing)
- (void)ts_selectTimeMode:(NSInteger)mode;
- (TSRemindersModel *)ts_reminderForSavingWithError:(NSString **)message;
- (void)ts_addTimePoint;
- (void)ts_reloadTimeSections;
- (void)ts_showError:(NSString *)message;
- (NSUInteger)ts_maxTimePointCount;
@end

// 对应界面模式；全天按已确认的 Period 0..1440 协议提交。
typedef NS_ENUM(NSInteger, TSReminderTestMode) {
    TSReminderTestModeAllDay,
    TSReminderTestModePeriod,
    TSReminderTestModePoint
};

@interface TSReminderTestEditorVC : TSReminderEditorVC
// 捕获校验提示，测试不展示模态弹窗。
@property (nonatomic, copy) NSString *validationMessage;
@end

@implementation TSReminderTestEditorVC

// 记录提示，保持被测删除与校验逻辑原样执行。
- (void)ts_showError:(NSString *)message {
    self.validationMessage = message;
}

// 固定可用容量，隔离宿主当前 SDK 配置。
- (NSUInteger)ts_maxTimePointCount {
    return 10;
}

@end

@interface TSReminderEditorVCTests : XCTestCase
// 原始输入和独立编辑器。
@property (nonatomic, strong) TSRemindersModel *original;
@property (nonatomic, strong) TSReminderTestEditorVC *editor;
@end

@implementation TSReminderEditorVCTests

#pragma mark - 生命周期

// UIKit 测试在主线程创建真实表格，禁止连接设备。
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    XCTAssertTrue(NSThread.isMainThread);
    self.original = [self validReminder];
    self.editor = [[TSReminderTestEditorVC alloc] initWithReminder:self.original
                                                            isNew:NO
                                                       completion:^(BOOL didSave) {
        XCTFail(@"编辑状态测试不应触发保存或删除完成");
    }];
    [self.editor loadViewIfNeeded];
    self.editor.view.frame = CGRectMake(0, 0, 390, 1600);
    [self.editor.view setNeedsLayout];
    [self.editor.view layoutIfNeeded];
    [[self tableView] layoutIfNeeded];
}

// 交付已排入主线程的 picker 配置后释放界面。
- (void)tearDown {
    [self drainMainQueue];
    self.editor = nil;
    self.original = nil;
    [super tearDown];
}

#pragma mark - 测试

// 三模式反复切换只改变选择，间隔及时间草稿独立，共用字段保持。
- (void)testSwitchingModesPreservesIndependentDraftsAndSharedFields {
    TSRemindersModel *draft = [self draft];
    draft.startTime = 560;
    draft.endTime = 1260;
    draft.interval = 90;
    draft.timePoints = @[@540, @900];
    draft.repeatDays = TSRemindersRepeatWednesday;
    draft.notes = @"Shared note";
    draft.lunchBreakDNDStartTime = 750;
    draft.lunchBreakDNDEndTime = 810;
    [self.editor setValue:@30 forKey:@"allDayInterval"];
    NSDictionary *expected = [self fieldsForModel:draft];
    for (NSNumber *mode in @[@(TSReminderTestModeAllDay), @(TSReminderTestModePoint),
                             @(TSReminderTestModePeriod), @(TSReminderTestModeAllDay)]) {
        [self.editor ts_selectTimeMode:mode.integerValue];
        XCTAssertEqualObjects([self.editor valueForKey:@"timeMode"], mode);
        XCTAssertEqualObjects([self.editor valueForKey:@"allDayInterval"], @30);
        XCTAssertEqualObjects([self fieldsForModel:draft], expected);
        [self assertTableMatchesSections];
    }
}

// 全天只编码提交副本，保留时段、时间点草稿及共用设置。
- (void)testAllDaySaveEncodesFullDayAndPreservesOtherDrafts {
    NSDictionary *originalFields = [self fieldsForModel:self.original];
    TSRemindersModel *draft = [self draft];
    draft.startTime = 560;
    draft.endTime = 1260;
    draft.interval = 90;
    draft.timePoints = @[@900, @540];
    draft.repeatDays = TSRemindersRepeatWorkday;
    draft.lunchBreakDNDStartTime = 750;
    draft.lunchBreakDNDEndTime = 810;
    [self.editor setValue:@30 forKey:@"allDayInterval"];
    NSDictionary *draftFields = [self fieldsForModel:draft];
    [self.editor ts_selectTimeMode:TSReminderTestModeAllDay];
    NSString *message = nil;
    TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(saved);
    XCTAssertNil(message);
    XCTAssertNotEqual(saved, draft);
    XCTAssertEqual(saved.timeType, TSReminderTimeTypePeriod);
    XCTAssertEqual(saved.startTime, 0);
    XCTAssertEqual(saved.endTime, 1440);
    XCTAssertEqual(saved.interval, 30);
    XCTAssertEqual(saved.timePoints.count, 0u);
    XCTAssertEqual(saved.repeatDays, TSRemindersRepeatWorkday);
    XCTAssertTrue(saved.isLunchBreakDNDEnabled);
    XCTAssertEqual(saved.lunchBreakDNDStartTime, 750);
    XCTAssertEqual(saved.lunchBreakDNDEndTime, 810);
    XCTAssertEqualObjects([self fieldsForModel:draft], draftFields);
    XCTAssertEqualObjects([self fieldsForModel:self.original], originalFields);

    [self.editor ts_selectTimeMode:TSReminderTestModePeriod];
    TSRemindersModel *period = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(period);
    XCTAssertNil(message);
    XCTAssertEqual(period.startTime, 560);
    XCTAssertEqual(period.endTime, 1260);
    XCTAssertEqual(period.interval, 90);
    XCTAssertEqual(period.repeatDays, saved.repeatDays);
    XCTAssertEqual(period.lunchBreakDNDStartTime, saved.lunchBreakDNDStartTime);
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    TSRemindersModel *point = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(point);
    XCTAssertNil(message);
    XCTAssertEqualObjects(point.timePoints, (@[@540, @900]));
    XCTAssertEqual(point.repeatDays, saved.repeatDays);
    XCTAssertEqual(point.lunchBreakDNDEndTime, saved.lunchBreakDNDEndTime);
    XCTAssertEqualObjects([self fieldsForModel:draft], draftFields);
}

// 只有 Period 的精确 0..1440 范围识别为全天，不误认 23:59 或 Point。
- (void)testReadbackRecognizesOnlyExactAllDayPeriod {
    NSArray<NSDictionary *> *cases = @[
        @{@"type": @(TSReminderTimeTypePeriod), @"start": @0, @"end": @1440,
          @"mode": @(TSReminderTestModeAllDay)},
        @{@"type": @(TSReminderTimeTypePeriod), @"start": @0, @"end": @1439,
          @"mode": @(TSReminderTestModePeriod)},
        @{@"type": @(TSReminderTimeTypePeriod), @"start": @1, @"end": @1440,
          @"mode": @(TSReminderTestModePeriod)},
        @{@"type": @(TSReminderTimeTypePoint), @"start": @0, @"end": @1440,
          @"mode": @(TSReminderTestModePoint)}
    ];
    for (NSDictionary *values in cases) {
        TSRemindersModel *readback = [self validReminder];
        readback.timeType = [values[@"type"] integerValue];
        readback.startTime = [values[@"start"] integerValue];
        readback.endTime = [values[@"end"] integerValue];
        readback.interval = 75;
        NSDictionary *originalFields = [self fieldsForModel:readback];
        TSReminderTestEditorVC *editor = [[TSReminderTestEditorVC alloc]
            initWithReminder:readback isNew:NO completion:^(BOOL didSave) {
                XCTFail(@"回读识别不应触发 SDK 完成回调");
            }];
        XCTAssertEqualObjects([editor valueForKey:@"timeMode"], values[@"mode"]);
        if ([values[@"mode"] integerValue] == TSReminderTestModeAllDay) {
            XCTAssertEqualObjects([editor valueForKey:@"allDayInterval"], @75);
        }
        XCTAssertEqualObjects([self fieldsForModel:readback], originalFields);
    }
}

// 全天保存后重新进入编辑器仍识别为全天，二次提交保持相同载荷。
- (void)testAllDaySaveRoundTripRestoresModeAndPayload {
    [self.editor setValue:@45 forKey:@"allDayInterval"];
    [self draft].repeatDays = 0;
    [self draft].isLunchBreakDNDEnabled = NO;
    [self.editor ts_selectTimeMode:TSReminderTestModeAllDay];
    NSString *message = nil;
    TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(saved);
    XCTAssertNil(message);
    TSReminderTestEditorVC *restored = [[TSReminderTestEditorVC alloc]
        initWithReminder:saved isNew:NO completion:^(BOOL didSave) {
            XCTFail(@"往返测试不应触发 SDK 完成回调");
        }];
    XCTAssertEqualObjects([restored valueForKey:@"timeMode"], @(TSReminderTestModeAllDay));
    XCTAssertEqualObjects([restored valueForKey:@"allDayInterval"], @45);
    TSRemindersModel *resaved = [restored ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(resaved);
    XCTAssertNil(message);
    XCTAssertNotEqual(resaved, saved);
    XCTAssertEqualObjects([self fieldsForModel:resaved], [self fieldsForModel:saved]);
    XCTAssertEqual(resaved.startTime, 0);
    XCTAssertEqual(resaved.endTime, 1440);
    XCTAssertEqual(resaved.interval, 45);
    XCTAssertEqual(resaved.repeatDays, 0);
    XCTAssertFalse(resaved.isLunchBreakDNDEnabled);
}

// 时段保存不被隐藏的时间点或全天间隔阻塞。
- (void)testPeriodSaveUsesOnlySelectedModeDraft {
    TSRemindersModel *draft = [self draft];
    draft.interval = 90;
    draft.timePoints = @[];
    [self.editor setValue:@(-1) forKey:@"allDayInterval"];
    [self.editor ts_selectTimeMode:TSReminderTestModePeriod];
    NSString *message = nil;
    TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(saved);
    XCTAssertNil(message);
    XCTAssertNotEqual(saved, draft);
    XCTAssertEqual(saved.timeType, TSReminderTimeTypePeriod);
    XCTAssertEqual(saved.startTime, 480);
    XCTAssertEqual(saved.endTime, 1200);
    XCTAssertEqual(saved.interval, 90);
    XCTAssertEqual(saved.timePoints.count, 0u);
    XCTAssertEqual(saved.repeatDays, 0);
}

// 时段允许结束于 24:00，接近午夜的短时段也保留原始分钟值。
- (void)testPeriodSaveAcceptsLateAndEndOfDayBoundaries {
    [self.editor ts_selectTimeMode:TSReminderTestModePeriod];
    NSArray<NSArray<NSNumber *> *> *cases = @[
        @[@480, @1400, @60], @[@480, @1440, @60],
        @[@1400, @1440, @30], @[@0, @1439, @60]
    ];
    for (NSArray<NSNumber *> *values in cases) {
        TSRemindersModel *draft = [self draft];
        draft.startTime = values[0].integerValue;
        draft.endTime = values[1].integerValue;
        draft.interval = values[2].integerValue;
        NSString *message = nil;
        TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
        XCTAssertNotNil(saved);
        XCTAssertNil(message);
        XCTAssertEqual(saved.timeType, TSReminderTimeTypePeriod);
        XCTAssertEqual(saved.startTime, draft.startTime);
        XCTAssertEqual(saved.endTime, draft.endTime);
        XCTAssertEqual(saved.interval, draft.interval);
        XCTAssertEqualObjects([self.editor valueForKey:@"timeMode"], @(TSReminderTestModePeriod));
    }
}

// 全天忽略隐藏模式错误，但仍校验全天间隔和共用 DND。
- (void)testAllDayIgnoresHiddenDraftErrorsButValidatesActiveSettings {
    TSRemindersModel *draft = [self draft];
    draft.startTime = 1440;
    draft.endTime = -1;
    draft.interval = 0;
    draft.timePoints = @[@1440, @1440];
    NSDictionary *draftFields = [self fieldsForModel:draft];
    [self.editor ts_selectTimeMode:TSReminderTestModeAllDay];
    for (NSNumber *interval in @[@1, @30, @1440]) {
        [self.editor setValue:interval forKey:@"allDayInterval"];
        NSString *message = nil;
        TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
        XCTAssertNotNil(saved);
        XCTAssertNil(message);
        XCTAssertEqual(saved.interval, interval.integerValue);
        XCTAssertEqual(saved.startTime, 0);
        XCTAssertEqual(saved.endTime, 1440);
        XCTAssertEqual(saved.timePoints.count, 0u);
        XCTAssertEqualObjects([self fieldsForModel:draft], draftFields);
    }
    for (NSNumber *interval in @[@(-1), @0, @1441]) {
        [self.editor setValue:interval forKey:@"allDayInterval"];
        NSString *message = nil;
        XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
        XCTAssertGreaterThan(message.length, 0u);
    }
    [self.editor setValue:@30 forKey:@"allDayInterval"];
    draft.lunchBreakDNDStartTime = 900;
    draft.lunchBreakDNDEndTime = 800;
    NSString *message = nil;
    XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
    XCTAssertGreaterThan(message.length, 0u);
}

// 时间点保存忽略隐藏时段错误，只对提交副本排序，保留合法边界。
- (void)testPointSaveSortsCopyWithoutChangingDraft {
    TSRemindersModel *draft = [self draft];
    draft.timePoints = @[@1439, @0, @720];
    draft.startTime = 1320;
    draft.endTime = 480;
    draft.interval = -1;
    [self.editor setValue:@(-1) forKey:@"allDayInterval"];
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    NSString *message = nil;
    TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(saved);
    XCTAssertNil(message);
    XCTAssertEqual(saved.timeType, TSReminderTimeTypePoint);
    XCTAssertEqual(saved.startTime, 0);
    XCTAssertEqual(saved.endTime, 0);
    XCTAssertEqual(saved.interval, 0);
    XCTAssertEqualObjects(saved.timePoints, (@[@0, @720, @1439]));
    XCTAssertEqualObjects(draft.timePoints, (@[@1439, @0, @720]));
    XCTAssertEqual(saved.repeatDays, 0);
}

// 空列表、重复点和非法分钟均阻止生成提交模型。
- (void)testPointSaveRejectsEmptyDuplicateAndInvalidMinutes {
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    for (NSArray<NSNumber *> *points in @[@[], @[@540, @540], @[@(-1)], @[@1440]]) {
        [self draft].timePoints = points;
        NSString *message = nil;
        XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
        XCTAssertGreaterThan(message.length, 0u);
        XCTAssertEqualObjects([self draft].timePoints, points);
    }
}

// 时段起止及间隔边界按当前模式校验。
- (void)testPeriodSaveRejectsInvalidBoundsAndInterval {
    [self.editor ts_selectTimeMode:TSReminderTestModePeriod];
    NSArray<NSArray<NSNumber *> *> *cases = @[
        @[@(-1), @1200, @60], @[@480, @1441, @60], @[@600, @600, @30],
        @[@720, @480, @30], @[@480, @720, @0], @[@480, @540, @61]
    ];
    for (NSArray<NSNumber *> *values in cases) {
        TSRemindersModel *draft = [self draft];
        draft.startTime = values[0].integerValue;
        draft.endTime = values[1].integerValue;
        draft.interval = values[2].integerValue;
        NSString *message = nil;
        XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
        XCTAssertGreaterThan(message.length, 0u);
    }
}

// DND 启用时校验，关闭后允许保留尚未修正的隐藏时间。
- (void)testDNDValidationDependsOnSharedSwitch {
    for (NSNumber *mode in @[@(TSReminderTestModeAllDay), @(TSReminderTestModePeriod),
                             @(TSReminderTestModePoint)]) {
        [self.editor ts_selectTimeMode:mode.integerValue];
        TSRemindersModel *draft = [self draft];
        draft.isLunchBreakDNDEnabled = YES;
        draft.lunchBreakDNDStartTime = 900;
        draft.lunchBreakDNDEndTime = 800;
        NSString *message = nil;
        XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
        XCTAssertGreaterThan(message.length, 0u);
        draft.isLunchBreakDNDEnabled = NO;
        message = nil;
        TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
        XCTAssertNotNil(saved);
        XCTAssertNil(message);
        XCTAssertFalse(saved.isLunchBreakDNDEnabled);
        XCTAssertEqual(draft.lunchBreakDNDStartTime, 900);
        XCTAssertEqual(draft.lunchBreakDNDEndTime, 800);
    }
}

// 失败和成功构造提交副本均不修改传入模型的十四字段。
- (void)testEditingAndPreparingSaveNeverMutatesOriginal {
    NSDictionary *originalFields = [self fieldsForModel:self.original];
    TSRemindersModel *draft = [self draft];
    XCTAssertNotEqual(draft, self.original);
    draft.reminderId = @"40";
    draft.reminderName = @"Edited reminder";
    draft.enabled = NO;
    draft.reminderType = TSReminderTypeUnknown;
    draft.repeatDays = TSRemindersRepeatWeekend;
    draft.timeType = TSReminderTimeTypePoint;
    draft.startTime = 100;
    draft.endTime = 200;
    draft.interval = 10;
    draft.timePoints = @[@600, @600];
    draft.notes = @"Edited notes";
    draft.isLunchBreakDNDEnabled = NO;
    draft.lunchBreakDNDStartTime = 100;
    draft.lunchBreakDNDEndTime = 200;
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    NSString *message = nil;
    XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
    XCTAssertEqualObjects([self fieldsForModel:self.original], originalFields);
    draft.timePoints = @[@600, @480];
    message = nil;
    TSRemindersModel *saved = [self.editor ts_reminderForSavingWithError:&message];
    XCTAssertNotNil(saved);
    XCTAssertNotEqual(saved, draft);
    saved.reminderName = @"Changed submitted copy";
    saved.timePoints = @[@900];
    XCTAssertEqualObjects(draft.reminderName, @"Edited reminder");
    XCTAssertEqualObjects(draft.timePoints, (@[@600, @480]));
    XCTAssertEqualObjects([self fieldsForModel:self.original], originalFields);
}

// 重复添加保留既有点且每次选择未使用的合法分钟。
- (void)testAddingPointsAlwaysChoosesUnusedMinute {
    [self draft].timePoints = @[@480, @540];
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    for (NSUInteger i = 0; i < 4; i++) {
        NSArray<NSNumber *> *before = [self draft].timePoints;
        [UIView performWithoutAnimation:^{
            [self.editor ts_addTimePoint];
        }];
        NSArray<NSNumber *> *after = [self draft].timePoints;
        NSSet<NSNumber *> *unique = [NSSet setWithArray:after];
        XCTAssertEqual(after.count, before.count + 1);
        XCTAssertEqual(unique.count, after.count);
        XCTAssertTrue([[NSSet setWithArray:before] isSubsetOfSet:unique]);
        for (NSNumber *minutes in after) {
            XCTAssertGreaterThanOrEqual(minutes.integerValue, 0);
            XCTAssertLessThan(minutes.integerValue, 1440);
        }
        [self assertTableMatchesSections];
    }
}

// 达到容量后不新增，已有超限草稿不能绕过保存校验。
- (void)testPointCapacityRejectsAddingAndSavingTooMany {
    NSMutableArray<NSNumber *> *points = [NSMutableArray array];
    for (NSInteger minute = 0; minute < 10; minute++) {
        [points addObject:@(minute)];
    }
    [self draft].timePoints = points;
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    [self.editor ts_addTimePoint];
    XCTAssertEqualObjects([self draft].timePoints, points);
    XCTAssertGreaterThan(self.editor.validationMessage.length, 0u);
    [points addObject:@10];
    [self draft].timePoints = points;
    NSString *message = nil;
    XCTAssertNil([self.editor ts_reminderForSavingWithError:&message]);
    XCTAssertGreaterThan(message.length, 0u);
}

// 删除前面的点会关闭原 picker，最后一个时间点不能删除。
- (void)testDeletingPointClosesPickerAndPreservesLastPoint {
    [self draft].timePoints = @[@480, @600];
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    [self tapCellWithIdentifier:@"TimePointCell" section:1 occurrence:1];
    XCTAssertEqual([self pickerCountInSection:1], 1u);
    [self deleteFirstTimePoint];
    XCTAssertEqualObjects([self draft].timePoints, (@[@600]));
    XCTAssertEqual([self pickerCountInSection:1], 0u);
    [self assertTableMatchesSections];
    [self deleteFirstTimePoint];
    XCTAssertEqualObjects([self draft].timePoints, (@[@600]));
    XCTAssertGreaterThan(self.editor.validationMessage.length, 0u);
    [self assertTableMatchesSections];
}

// DND picker 展开时通过真实 segment 切模式，两个分区均正确刷新。
- (void)testModeControlClosesExpandedDNDPicker {
    [self tapCellWithIdentifier:@"DNDStartCell" section:3 occurrence:0];
    XCTAssertEqual([self pickerCountInSection:3], 1u);
    NSIndexPath *segmentPath = [self pathForCellIdentifier:@"SegmentCell" section:1 occurrence:0];
    UITableViewCell *segmentCell = [self cellAtPath:segmentPath];
    UISegmentedControl *segment = [segmentCell valueForKey:@"segment"];
    XCTAssertEqual(segment.numberOfSegments, 3);
    [UIView performWithoutAnimation:^{
        segment.selectedSegmentIndex = TSReminderTestModePoint;
        [segment sendActionsForControlEvents:UIControlEventValueChanged];
    }];
    XCTAssertEqualObjects([self.editor valueForKey:@"timeMode"], @(TSReminderTestModePoint));
    XCTAssertEqual([self pickerCountInSection:3], 0u);
    XCTAssertEqual([self pickerCountInSection:1], 0u);
    [self assertTableMatchesSections];
}

// 时间 picker 展开时切 DND 开关，不留下 section 1 的旧 picker。
- (void)testDNDSwitchClosesExpandedTimePicker {
    [self tapCellWithIdentifier:@"PeriodStartCell" section:1 occurrence:0];
    XCTAssertEqual([self pickerCountInSection:1], 1u);
    [self changeDNDSwitch:NO];
    XCTAssertFalse([self draft].isLunchBreakDNDEnabled);
    XCTAssertEqual([self pickerCountInSection:1], 0u);
    [self assertTableMatchesSections];
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    [self tapCellWithIdentifier:@"TimePointCell" section:1 occurrence:0];
    [self changeDNDSwitch:YES];
    XCTAssertTrue([self draft].isLunchBreakDNDEnabled);
    XCTAssertEqual([self pickerCountInSection:1], 0u);
    [self assertTableMatchesSections];
}

// 两个 section 相互展开时只保留目标 picker，UIKit 行数与数据源一致。
- (void)testPickerSwitchAcrossSectionsKeepsOnlyOnePicker {
    [self tapCellWithIdentifier:@"PeriodStartCell" section:1 occurrence:0];
    [self tapCellWithIdentifier:@"DNDStartCell" section:3 occurrence:0];
    XCTAssertEqual([self pickerCountInSection:1], 0u);
    XCTAssertEqual([self pickerCountInSection:3], 1u);
    [self assertTableMatchesSections];
    [self tapCellWithIdentifier:@"PeriodEndCell" section:1 occurrence:0];
    XCTAssertEqual([self pickerCountInSection:1], 1u);
    XCTAssertEqual([self pickerCountInSection:3], 0u);
    [self assertTableMatchesSections];
}

// 24:00 仅属于时段结束边界，其他时间输入的午夜始终是 0 分钟。
- (void)testMidnightPickerConversionAppliesOnlyToPeriodEnd {
    [self draft].endTime = 1440;
    [self.editor ts_selectTimeMode:TSReminderTestModePeriod];
    [self tapCellWithIdentifier:@"PeriodEndCell" section:1 occurrence:0];
    [self drainMainQueue];
    NSIndexPath *pickerPath = [self pathForCellIdentifier:@"PickerCell" section:1 occurrence:0];
    UIDatePicker *picker = [[self cellAtPath:pickerPath] valueForKey:@"picker"];
    NSDateComponents *displayed = [[NSCalendar currentCalendar]
        components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:picker.date];
    XCTAssertEqual(displayed.hour, 0);
    XCTAssertEqual(displayed.minute, 0);
    [self changeActivePickerInSection:1 toMinutes:1380];
    XCTAssertEqual([self draft].endTime, 1380);
    [self changeActivePickerInSection:1 toMinutes:0];
    XCTAssertEqual([self draft].endTime, 1440);

    [self tapCellWithIdentifier:@"PeriodStartCell" section:1 occurrence:0];
    [self changeActivePickerInSection:1 toMinutes:0];
    XCTAssertEqual([self draft].startTime, 0);
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    [self tapCellWithIdentifier:@"TimePointCell" section:1 occurrence:0];
    [self changeActivePickerInSection:1 toMinutes:0];
    XCTAssertEqualObjects([self draft].timePoints.firstObject, @0);

    [self tapCellWithIdentifier:@"DNDStartCell" section:3 occurrence:0];
    [self changeActivePickerInSection:3 toMinutes:0];
    XCTAssertEqual([self draft].lunchBreakDNDStartTime, 0);
    [self tapCellWithIdentifier:@"DNDEndCell" section:3 occurrence:0];
    [self changeActivePickerInSection:3 toMinutes:0];
    XCTAssertEqual([self draft].lunchBreakDNDEndTime, 0);
    XCTAssertEqual([self draft].endTime, 1440);
    [self assertTableMatchesSections];
}

// 旧路径的异步 picker 配置在快切和删除后不能访问普通 cell 或改错草稿。
- (void)testPendingPickerConfigurationSurvivesModeChangeAndDeletion {
    [self tapCellWithIdentifier:@"PeriodStartCell" section:1 occurrence:0];
    [self.editor ts_selectTimeMode:TSReminderTestModePoint];
    [self deleteFirstTimePoint];
    [self drainMainQueue];
    XCTAssertEqualObjects([self draft].timePoints, (@[@600]));
    XCTAssertEqual([self draft].startTime, 480);
    XCTAssertEqual([self pickerCountInSection:1], 0u);
    XCTAssertEqual([self pickerCountInSection:3], 0u);
    [self assertTableMatchesSections];
}

#pragma mark - 私有方法

// 合法输入同时保留时段与时间点数据，repeat=0 原样参与回归。
- (TSRemindersModel *)validReminder {
    TSRemindersModel *reminder = [[TSRemindersModel alloc] init];
    reminder.reminderId = @"32";
    reminder.reminderName = @"Desk stretch";
    reminder.enabled = YES;
    reminder.reminderType = TSReminderTypeCustom;
    reminder.repeatDays = 0;
    reminder.timeType = TSReminderTimeTypePeriod;
    reminder.startTime = 480;
    reminder.endTime = 1200;
    reminder.interval = 60;
    reminder.timePoints = @[@540, @600];
    reminder.notes = @"Original note";
    reminder.isLunchBreakDNDEnabled = YES;
    reminder.lunchBreakDNDStartTime = 720;
    reminder.lunchBreakDNDEndTime = 840;
    return reminder;
}

// 取出真实编辑草稿，无需公开测试属性。
- (TSRemindersModel *)draft {
    return [self.editor valueForKey:@"reminder"];
}

// 读取真实 UITableView，用其缓存行数校验刷新完整性。
- (UITableView *)tableView {
    return [self.editor valueForKey:@"tableView"];
}

// 全字段比较用于防止取消或失败前的修改污染调用方模型。
- (NSDictionary<NSString *, id> *)fieldsForModel:(TSRemindersModel *)model {
    return [model dictionaryWithValuesForKeys:@[
        @"reminderId", @"reminderName", @"enabled", @"reminderType", @"repeatDays", @"timeType",
        @"startTime", @"endTime", @"interval", @"timePoints", @"notes",
        @"isLunchBreakDNDEnabled", @"lunchBreakDNDStartTime", @"lunchBreakDNDEndTime"
    ]];
}

// 优先读取已展示 cell；不可见行由真实数据源配置，不复制私有行枚举。
- (UITableViewCell *)cellAtPath:(NSIndexPath *)path {
    UITableView *tableView = [self tableView];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
    return cell ?: [tableView.dataSource tableView:tableView cellForRowAtIndexPath:path];
}

// 以语义化 cell 标识查找行，避免硬编码私有 row type 数字。
- (NSIndexPath *)pathForCellIdentifier:(NSString *)identifier
                              section:(NSInteger)section
                           occurrence:(NSUInteger)occurrence {
    UITableView *tableView = [self tableView];
    NSUInteger matched = 0;
    NSInteger count = [tableView.dataSource tableView:tableView numberOfRowsInSection:section];
    for (NSInteger row = 0; row < count; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        if ([[self cellAtPath:path].reuseIdentifier isEqualToString:identifier]) {
            if (matched == occurrence) {
                return path;
            }
            matched++;
        }
    }
    XCTFail(@"未找到 %@，section=%ld，occurrence=%lu",
            identifier, (long)section, (unsigned long)occurrence);
    return nil;
}

// 走真实 UITableView delegate，保留展开、删除、刷新逻辑。
- (void)tapCellWithIdentifier:(NSString *)identifier
                     section:(NSInteger)section
                  occurrence:(NSUInteger)occurrence {
    NSIndexPath *path = [self pathForCellIdentifier:identifier section:section occurrence:occurrence];
    UITableView *tableView = [self tableView];
    [UIView performWithoutAnimation:^{
        [tableView.delegate tableView:tableView didSelectRowAtIndexPath:path];
        [tableView layoutIfNeeded];
    }];
}

// 直接调用系统表格编辑回调，不绕过最后一项保护。
- (void)deleteFirstTimePoint {
    NSIndexPath *path = [self pathForCellIdentifier:@"TimePointCell" section:1 occurrence:0];
    UITableView *tableView = [self tableView];
    [UIView performWithoutAnimation:^{
        [tableView.dataSource tableView:tableView
                   commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:path];
        [tableView layoutIfNeeded];
    }];
}

// 通过控件 action 覆盖 DND 开关实际绑定的刷新路径。
- (void)changeDNDSwitch:(BOOL)enabled {
    NSIndexPath *path = [self pathForCellIdentifier:@"SwitchCell" section:3 occurrence:0];
    UISwitch *toggle = [[self cellAtPath:path] valueForKey:@"toggle"];
    [UIView performWithoutAnimation:^{
        toggle.on = enabled;
        [toggle sendActionsForControlEvents:UIControlEventValueChanged];
        [[self tableView] layoutIfNeeded];
    }];
}

// 通过真实 UIDatePicker action 设置分钟，不依赖私有行枚举或直接改草稿。
- (void)changeActivePickerInSection:(NSInteger)section toMinutes:(NSInteger)minutes {
    NSIndexPath *path = [self pathForCellIdentifier:@"PickerCell" section:section occurrence:0];
    UIDatePicker *picker = [[self cellAtPath:path] valueForKey:@"picker"];
    XCTAssertTrue([picker isKindOfClass:UIDatePicker.class]);
    NSDate *date = [[NSCalendar currentCalendar]
        dateBySettingHour:minutes / 60 minute:minutes % 60 second:0 ofDate:NSDate.date options:0];
    XCTAssertNotNil(date);
    [UIView performWithoutAnimation:^{
        [picker setDate:date animated:NO];
        [picker sendActionsForControlEvents:UIControlEventValueChanged];
        [[self tableView] layoutIfNeeded];
    }];
}

// 以 cell 类型的既有复用标识检查 picker 数量。
- (NSUInteger)pickerCountInSection:(NSInteger)section {
    UITableView *tableView = [self tableView];
    NSInteger rows = [tableView.dataSource tableView:tableView numberOfRowsInSection:section];
    NSUInteger count = 0;
    for (NSInteger row = 0; row < rows; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        if ([[self cellAtPath:path].reuseIdentifier isEqualToString:@"PickerCell"]) {
            count++;
        }
    }
    return count;
}

// 同时核对 UIKit 和数据源，防止仅修改 sections 的测试假通过。
- (void)assertTableMatchesSections {
    UITableView *tableView = [self tableView];
    [tableView layoutIfNeeded];
    NSArray<NSArray *> *sections = [self.editor valueForKey:@"sections"];
    XCTAssertEqual(tableView.numberOfSections, (NSInteger)sections.count);
    for (NSInteger section = 0; section < (NSInteger)sections.count; section++) {
        XCTAssertEqual([tableView numberOfRowsInSection:section], (NSInteger)sections[section].count);
    }
}

// 使用主线程事件边界，不用固定延迟等待异步配置。
- (void)drainMainQueue {
    XCTestExpectation *drained = [self expectationWithDescription:@"picker configuration delivered"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [drained fulfill];
    });
    [self waitForExpectations:@[drained] timeout:2];
}

@end
