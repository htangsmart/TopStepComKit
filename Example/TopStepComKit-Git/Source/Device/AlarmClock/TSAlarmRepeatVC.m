//
//  TSAlarmRepeatVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSAlarmRepeatVC.h"
#import "TSBaseVC.h"

// ─── 重复选项 Cell ─────────────────────────────────────────────────────────
@interface TSRepeatOptionCell : UITableViewCell
@end

@implementation TSRepeatOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.backgroundColor = TSColor_Card;
    self.textLabel.font = [UIFont systemFontOfSize:17];
    self.textLabel.textColor = TSColor_TextPrimary;

    return self;
}

@end

// ─── TSAlarmRepeatVC ───────────────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSRepeatOption) {
    TSRepeatOptionNever = 0,
    TSRepeatOptionMonday,
    TSRepeatOptionTuesday,
    TSRepeatOptionWednesday,
    TSRepeatOptionThursday,
    TSRepeatOptionFriday,
    TSRepeatOptionSaturday,
    TSRepeatOptionSunday,
    TSRepeatOptionCount
};

@interface TSAlarmRepeatVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *optionTitles;
@end

@implementation TSAlarmRepeatVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"重复";
    self.view.backgroundColor = TSColor_Background;

    self.optionTitles = @[@"永不", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日"];

    // 添加完成按钮
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(ts_done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    [self ts_setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }

    self.tableView.frame = CGRectMake(0, topOffset,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - topOffset);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 返回时触发回调
    if (self.isMovingFromParentViewController && self.onRepeatChanged) {
        self.onRepeatChanged(self.selectedRepeat);
    }
}

#pragma mark - Actions

- (void)ts_done {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setup

- (void)ts_setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    [self.view addSubview:self.tableView];
}

#pragma mark - Helpers

- (BOOL)isOptionSelected:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        return self.selectedRepeat == TSAlarmRepeatNone;
    }

    // 周一~周日对应 bit 0~6
    TSAlarmRepeat dayBit = (1 << (option - 1));
    return (self.selectedRepeat & dayBit) != 0;
}

- (void)toggleOption:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        // 选择"永不"，清空所有重复
        self.selectedRepeat = TSAlarmRepeatNone;
    } else {
        // 切换某一天
        TSAlarmRepeat dayBit = (1 << (option - 1));

        if (self.selectedRepeat & dayBit) {
            // 取消选中
            self.selectedRepeat &= ~dayBit;
        } else {
            // 选中
            self.selectedRepeat |= dayBit;

            // 如果之前是"永不"，现在有选中的天，需要清除"永不"状态
            // （实际上 TSAlarmRepeatNone = 0，不需要特殊处理）
        }
    }

    [self.tableView reloadData];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TSRepeatOptionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"kTSRepeatOptionCell";
    TSRepeatOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TSRepeatOptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    cell.textLabel.text = self.optionTitles[option];

    // 显示勾选状态
    if ([self isOptionSelected:option]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = TSColor_Primary;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    [self toggleOption:option];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    // 显示当前选择的汇总
    if (self.selectedRepeat == TSAlarmRepeatNone) {
        return @"闹钟只会响一次";
    } else if (self.selectedRepeat == TSAlarmRepeatEveryday) {
        return @"闹钟每天都会响";
    } else if (self.selectedRepeat == TSAlarmRepeatWorkday) {
        return @"闹钟在工作日响（周一至周五）";
    } else if (self.selectedRepeat == TSAlarmRepeatWeekend) {
        return @"闹钟在周末响（周六和周日）";
    } else {
        // 自定义选择
        NSMutableArray *days = [NSMutableArray array];
        if (self.selectedRepeat & TSAlarmRepeatMonday)    [days addObject:@"周一"];
        if (self.selectedRepeat & TSAlarmRepeatTuesday)   [days addObject:@"周二"];
        if (self.selectedRepeat & TSAlarmRepeatWednesday) [days addObject:@"周三"];
        if (self.selectedRepeat & TSAlarmRepeatThursday)  [days addObject:@"周四"];
        if (self.selectedRepeat & TSAlarmRepeatFriday)    [days addObject:@"周五"];
        if (self.selectedRepeat & TSAlarmRepeatSaturday)  [days addObject:@"周六"];
        if (self.selectedRepeat & TSAlarmRepeatSunday)    [days addObject:@"周日"];

        if (days.count > 0) {
            return [NSString stringWithFormat:@"闹钟在 %@ 响", [days componentsJoinedByString:@"、"]];
        }
    }

    return nil;
}

@end
