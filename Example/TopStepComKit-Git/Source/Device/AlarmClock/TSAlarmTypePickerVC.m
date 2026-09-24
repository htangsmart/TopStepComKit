//
//  TSAlarmTypePickerVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAlarmTypePickerVC.h"
#import "TSBaseVC.h"

#pragma mark - TSAlarmTypeDisplay

@implementation TSAlarmTypeDisplay

/// 与 TSAlarmType 0–22 一一对应的 SF Symbol
+ (NSArray<NSString *> *)ts_symbolNames {
    static NSArray<NSString *> *names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[@"drop.fill",             // 0  喝水
                  @"alarm.fill",            // 1  闹钟
                  @"figure.stand",          // 2  久坐
                  @"mouth.fill",            // 3  刷牙
                  @"cup.and.saucer.fill",   // 4  早餐
                  @"pencil.and.outline",    // 5  作业
                  @"fork.knife",            // 6  午餐
                  @"figure.run",            // 7  运动
                  @"sunrise.fill",          // 8  起床
                  @"moon.zzz.fill",         // 9  睡觉
                  @"backpack.fill",         // 10 上学
                  @"house.fill",            // 11 回家
                  @"book.fill",             // 12 读书
                  @"shower.fill",           // 13 洗澡
                  @"party.popper.fill",     // 14 聚会
                  @"gamecontroller.fill",   // 15 玩游戏
                  @"tent.fill",             // 16 露营
                  @"headphones",            // 17 听音乐
                  @"paintpalette.fill",     // 18 画画
                  @"figure.dance",          // 19 跳舞
                  @"camera.fill",           // 20 摄影
                  @"pawprint.fill",         // 21 遛狗
                  @"film.fill"];            // 22 看电影
    });
    return names;
}

+ (NSString *)nameForType:(TSAlarmType)type {
    if (type < 0 || type > TSAlarmTypeMaxValue) {
        return [NSString stringWithFormat:TSLocalizedString(@"alarm.type.unknown_format"), (long)type];
    }
    // 宏参数里不能带逗号，先拼好 key 再传
    NSString *key = [NSString stringWithFormat:@"alarm.type.%ld", (long)type];
    return TSLocalizedString(key);
}

+ (NSString *)symbolNameForType:(TSAlarmType)type {
    if (type < 0 || type > TSAlarmTypeMaxValue) { return @"questionmark.circle"; }
    return [self ts_symbolNames][type];
}

+ (UIImage *)iconForType:(TSAlarmType)type {
    if (@available(iOS 13.0, *)) {
        // 个别符号只在较新的系统上存在，取不到时退回通用图标
        UIImage *image = [UIImage systemImageNamed:[self symbolNameForType:type]];
        return image ?: [UIImage systemImageNamed:@"bell.fill"];
    }
    return nil;
}

@end

#pragma mark - TSAlarmTypePickerVC

@interface TSAlarmTypePickerVC () <UITableViewDelegate, UITableViewDataSource>

/// 类型列表
@property (nonatomic, strong) UITableView *tableView;
/// 不支持的类型集合（由 supportedTypes 推导，便于 O(1) 判断）
@property (nonatomic, strong) NSSet<NSNumber *> *supportedSet;

@end

@implementation TSAlarmTypePickerVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"alarm.type");
    self.view.backgroundColor = TSColor_Background;
    self.supportedSet = self.supportedTypes ? [NSSet setWithArray:self.supportedTypes] : nil;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.done")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(ts_done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = self.view.safeAreaInsets.top;
    self.tableView.frame = CGRectMake(0, topOffset,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - topOffset);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 与重复选择页一致：返回时回调
    if (self.isMovingFromParentViewController && self.onTypeChanged) {
        self.onTypeChanged(self.selectedType);
    }
}

#pragma mark - 私有方法

- (void)ts_done {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 判断某个类型是否在设备支持集合内；未查询到集合时视为全部支持
 */
- (BOOL)ts_isTypeSupported:(TSAlarmType)type {
    return !self.supportedSet || [self.supportedSet containsObject:@(type)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TSAlarmTypeMaxValue + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSAlarmTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightRegular];
        cell.tintColor = TSColor_Primary;
    }

    TSAlarmType type = (TSAlarmType)indexPath.row;
    BOOL supported = [self ts_isTypeSupported:type];

    cell.textLabel.text = [TSAlarmTypeDisplay nameForType:type];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)type];
    cell.imageView.image = [TSAlarmTypeDisplay iconForType:type];
    cell.imageView.tintColor = supported ? TSColor_Primary : TSColor_TextSecondary;
    cell.textLabel.textColor = supported ? TSColor_TextPrimary : TSColor_TextSecondary;
    cell.detailTextLabel.textColor = TSColor_TextSecondary;
    cell.contentView.alpha = supported ? 1.f : 0.45f;
    cell.selectionStyle = supported ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    cell.accessoryType = (type == self.selectedType) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (!self.supportedSet) {
        return TSLocalizedString(@"alarm.type.footer.all");
    }
    return [NSString stringWithFormat:TSLocalizedString(@"alarm.type.footer.supported_format"),
            (unsigned long)self.supportedSet.count];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSAlarmType type = (TSAlarmType)indexPath.row;
    if (![self ts_isTypeSupported:type]) { return; }
    self.selectedType = type;
    [tableView reloadData];
}

#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorColor = TSColor_Separator;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

@end
