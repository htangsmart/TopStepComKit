//
//  TSReminderRepeatVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSReminderRepeatVC.h"
#import "TSBaseVC.h"

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

@interface TSReminderRepeatVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *optionTitles;
@end

@implementation TSReminderRepeatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"重复";
    self.view.backgroundColor = TSColor_Background;

    self.optionTitles = @[@"永不", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日"];

    [self ts_setupTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if (@available(iOS 11.0, *)) {
        topOffset = self.view.safeAreaInsets.top;
    }
    self.tableView.frame = CGRectMake(0, topOffset, self.view.bounds.size.width, self.view.bounds.size.height - topOffset);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController && self.onDaysChanged) {
        self.onDaysChanged(self.selectedDays);
    }
}

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

- (BOOL)isOptionSelected:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        return self.selectedDays == 0;
    }
    TSReminderDays dayBit = (1 << (option - 1));
    return (self.selectedDays & dayBit) != 0;
}

- (void)toggleOption:(TSRepeatOption)option {
    if (option == TSRepeatOptionNever) {
        self.selectedDays = 0;
    } else {
        TSReminderDays dayBit = (1 << (option - 1));
        if (self.selectedDays & dayBit) {
            self.selectedDays &= ~dayBit;
        } else {
            self.selectedDays |= dayBit;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = TSColor_Card;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = TSColor_TextPrimary;
    }

    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    cell.textLabel.text = self.optionTitles[option];

    if ([self isOptionSelected:option]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = TSColor_Primary;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSRepeatOption option = (TSRepeatOption)indexPath.row;
    [self toggleOption:option];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.selectedDays == 0) {
        return @"提醒只会响一次";
    } else if (self.selectedDays == eTSReminderRepeatEveryday) {
        return @"提醒每天都会响";
    } else if (self.selectedDays == eTSReminderRepeatWorkday) {
        return @"提醒在工作日响（周一至周五）";
    } else if (self.selectedDays == eTSReminderRepeatWeekday) {
        return @"提醒在周末响（周六和周日）";
    } else {
        NSMutableArray *days = [NSMutableArray array];
        if (self.selectedDays & eTSReminderDayMonday)    [days addObject:@"周一"];
        if (self.selectedDays & eTSReminderDayTuesday)   [days addObject:@"周二"];
        if (self.selectedDays & eTSReminderDayWednesday) [days addObject:@"周三"];
        if (self.selectedDays & eTSReminderDayThursday)  [days addObject:@"周四"];
        if (self.selectedDays & eTSReminderDayFriday)    [days addObject:@"周五"];
        if (self.selectedDays & eTSReminderDaySaturday)  [days addObject:@"周六"];
        if (self.selectedDays & eTSReminderDaySunday)    [days addObject:@"周日"];
        if (days.count > 0) {
            return [NSString stringWithFormat:@"提醒在 %@ 响", [days componentsJoinedByString:@"、"]];
        }
    }
    return nil;
}

@end
