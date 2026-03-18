//
//  TSWorldClockVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSWorldClockVC.h"

// ─── 预定义城市列表 ────────────────────────────────────────────────────────────

static NSArray<NSDictionary *> *TSPredefinedCities(void) {
    return @[
        @{@"id": @1,  @"name": @"北京",   @"zone": @"Asia/Shanghai",       @"utc": @(8  * 3600)},
        @{@"id": @2,  @"name": @"东京",   @"zone": @"Asia/Tokyo",          @"utc": @(9  * 3600)},
        @{@"id": @3,  @"name": @"新加坡", @"zone": @"Asia/Singapore",      @"utc": @(8  * 3600)},
        @{@"id": @4,  @"name": @"迪拜",   @"zone": @"Asia/Dubai",          @"utc": @(4  * 3600)},
        @{@"id": @5,  @"name": @"莫斯科", @"zone": @"Europe/Moscow",       @"utc": @(3  * 3600)},
        @{@"id": @6,  @"name": @"伦敦",   @"zone": @"Europe/London",       @"utc": @(0)},
        @{@"id": @7,  @"name": @"巴黎",   @"zone": @"Europe/Paris",        @"utc": @(1  * 3600)},
        @{@"id": @8,  @"name": @"纽约",   @"zone": @"America/New_York",    @"utc": @(-5 * 3600)},
        @{@"id": @9,  @"name": @"洛杉矶", @"zone": @"America/Los_Angeles", @"utc": @(-8 * 3600)},
        @{@"id": @10, @"name": @"悉尼",   @"zone": @"Australia/Sydney",    @"utc": @(10 * 3600)},
    ];
}

static NSString *const kTSClockCellID = @"kTSWorldClockCell";

// ─── TSWorldClockVC ────────────────────────────────────────────────────────────

@interface TSWorldClockVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView             *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSMutableArray<TSWorldClockModel *> *worldClocks;
@property (nonatomic, assign) NSInteger maxCount;

@end

@implementation TSWorldClockVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"世界时钟";
    self.view.backgroundColor = TSColor_Background;
    self.maxCount = 5;  // 默认，fetch 后更新

    [self ts_setupUI];
    [self ts_fetchData];
}

#pragma mark - UI Setup

- (void)ts_setupUI {
    // 右上角添加按钮
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                    target:self
                                                    action:@selector(ts_addTapped)];
    self.navigationItem.rightBarButtonItem = addBtn;

    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;
    self.tableView.alpha           = 0;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    // 加载菊花
    self.loadingIndicator = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color            = TSColor_Primary;
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],

        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];

    [self.loadingIndicator startAnimating];
}

#pragma mark - Fetch

- (void)ts_fetchData {
    id<TSWorldClockInterface> wc = [[TopStepComKit sharedInstance] worldClock];
    self.maxCount = [wc supportMaxWorldClockCount];
    if (self.maxCount <= 0) self.maxCount = 5;

    __weak typeof(self) weakSelf = self;
    [wc queryWorldClockCompletion:^(NSArray<TSWorldClockModel *> *allWorldClocks, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.worldClocks = [(allWorldClocks ?: @[]) mutableCopy];
            [weakSelf.tableView reloadData];
            [UIView animateWithDuration:0.25 animations:^{ weakSelf.tableView.alpha = 1; }];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.worldClocks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"已添加 %lu / %ld 个",
            (unsigned long)self.worldClocks.count, (long)self.maxCount];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.worldClocks.count == 0) return nil;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 52)];
    footer.backgroundColor = [UIColor clearColor];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"清空全部" forState:UIControlStateNormal];
    [btn setTitleColor:TSColor_Danger forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    [btn addTarget:self action:@selector(ts_clearAll) forControlEvents:UIControlEventTouchUpInside];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [footer addSubview:btn];

    [NSLayoutConstraint activateConstraints:@[
        [btn.centerXAnchor constraintEqualToAnchor:footer.centerXAnchor],
        [btn.centerYAnchor constraintEqualToAnchor:footer.centerYAnchor],
    ]];

    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.worldClocks.count > 0 ? 52.f : 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTSClockCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kTSClockCellID];
        cell.backgroundColor               = TSColor_Card;
        cell.selectionStyle                = UITableViewCellSelectionStyleNone;
        cell.textLabel.font                = TSFont_Body;
        cell.textLabel.textColor           = TSColor_TextPrimary;
        cell.detailTextLabel.font          = TSFont_Caption;
        cell.detailTextLabel.textColor     = TSColor_TextSecondary;

        // 右侧当前时间标签
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 22)];
        timeLabel.font      = [UIFont monospacedDigitSystemFontOfSize:15.f weight:UIFontWeightMedium];
        timeLabel.textColor = TSColor_Primary;
        timeLabel.tag       = 777;
        cell.accessoryView  = timeLabel;
    }

    TSWorldClockModel *clock = self.worldClocks[indexPath.row];
    cell.textLabel.text       = clock.cityName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  ·  %@",
                                 [self ts_utcOffsetString:clock.utcOffsetInSeconds],
                                 clock.timeZoneIdentifier];

    // 左侧图标
    cell.imageView.image = [self ts_globeIconWithColor:TSColor_Primary];

    // 右侧当前时间
    UILabel *timeLabel = (UILabel *)cell.accessoryView;
    timeLabel.text = [self ts_currentTimeWithUTCOffset:clock.utcOffsetInSeconds];
    [timeLabel sizeToFit];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *deleteAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleDestructive
                            title:@"删除"
                          handler:^(UIContextualAction *action, UIView *view, void(^done)(BOOL)) {
        [weakSelf ts_deleteClockAtIndex:indexPath.row completion:done];
    }];
    deleteAction.backgroundColor = TSColor_Danger;
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

#pragma mark - Add

- (void)ts_addTapped {
    if ((NSInteger)self.worldClocks.count >= self.maxCount) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"已达上限"
                                                     message:[NSString stringWithFormat:@"最多可添加 %ld 个世界时钟", (long)self.maxCount]
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    // 过滤掉已添加的城市（按 timeZoneIdentifier 去重）
    NSSet *addedZones = [NSSet setWithArray:[self.worldClocks valueForKey:@"timeZoneIdentifier"]];
    NSMutableArray *available = [NSMutableArray array];
    for (NSDictionary *city in TSPredefinedCities()) {
        if (![addedZones containsObject:city[@"zone"]]) {
            [available addObject:city];
        }
    }

    if (available.count == 0) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"暂无可添加城市"
                                                     message:@"预定义城市均已添加"
                                              preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择城市"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (NSDictionary *city in available) {
        NSString *title = [NSString stringWithFormat:@"%@  %@",
                           city[@"name"],
                           [self ts_utcOffsetString:[city[@"utc"] integerValue]]];
        [sheet addAction:[UIAlertAction actionWithTitle:title
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *a) {
            [weakSelf ts_addCity:city];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)ts_addCity:(NSDictionary *)city {
    UInt8 clockId      = (UInt8)[city[@"id"] integerValue];
    NSString *name     = city[@"name"];
    NSString *zone     = city[@"zone"];
    NSInteger utcSec   = [city[@"utc"] integerValue];

    TSWorldClockModel *model = [TSWorldClockModel modelWithClockId:clockId
                                                          cityName:name
                                                timeZoneIdentifier:zone
                                                utcOffsetInSeconds:utcSec];

    NSMutableArray *newList = [self.worldClocks mutableCopy];
    [newList addObject:model];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] worldClock]
     setWorldClocks:newList
         completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                weakSelf.worldClocks = newList;
                NSIndexPath *ip = [NSIndexPath indexPathForRow:(NSInteger)weakSelf.worldClocks.count - 1
                                                     inSection:0];
                [weakSelf.tableView insertRowsAtIndexPaths:@[ip]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                  withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf ts_showToast:[NSString stringWithFormat:@"已添加 %@", name]];
            } else {
                [weakSelf ts_showError:error title:@"添加失败"];
            }
        });
    }];
}

#pragma mark - Delete

- (void)ts_deleteClockAtIndex:(NSInteger)index completion:(void(^)(BOOL))done {
    TSWorldClockModel *clock = self.worldClocks[index];
    __weak typeof(self) weakSelf = self;

    [[[TopStepComKit sharedInstance] worldClock]
     deleteWorldClock:clock
           completion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                [weakSelf.worldClocks removeObjectAtIndex:index];
                NSIndexPath *ip = [NSIndexPath indexPathForRow:index inSection:0];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[ip]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                  withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf ts_showToast:[NSString stringWithFormat:@"已删除 %@", clock.cityName]];
                done(YES);
            } else {
                done(NO);
                [weakSelf ts_showError:error title:@"删除失败"];
            }
        });
    }];
}

#pragma mark - Clear All

- (void)ts_clearAll {
    UIAlertController *confirm = [UIAlertController
                                  alertControllerWithTitle:@"清空全部"
                                                   message:@"确定要删除所有世界时钟吗？"
                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [confirm addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [weakSelf ts_doDeleteAll];
    }]];
    [confirm addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:confirm animated:YES completion:nil];
}

- (void)ts_doDeleteAll {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] worldClock]
     deleteAllWorldClockCompletion:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                weakSelf.worldClocks = [NSMutableArray array];
                [weakSelf.tableView reloadData];
                [weakSelf ts_showToast:@"已清空全部时钟"];
            } else {
                [weakSelf ts_showError:error title:@"清空失败"];
            }
        });
    }];
}

#pragma mark - Helpers

- (NSString *)ts_utcOffsetString:(NSInteger)seconds {
    NSInteger absH = abs((int)seconds) / 3600;
    NSInteger absM = (abs((int)seconds) % 3600) / 60;
    NSString *sign = seconds >= 0 ? @"+" : @"-";
    return absM == 0
        ? [NSString stringWithFormat:@"UTC%@%ld", sign, (long)absH]
        : [NSString stringWithFormat:@"UTC%@%ld:%02ld", sign, (long)absH, (long)absM];
}

- (NSString *)ts_currentTimeWithUTCOffset:(NSInteger)offsetSeconds {
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:offsetSeconds];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.timeZone   = tz;
    fmt.dateFormat = @"HH:mm";
    return [fmt stringFromDate:[NSDate date]];
}

- (UIImage *)ts_globeIconWithColor:(UIColor *)color {
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    bg.backgroundColor    = color;
    bg.layer.cornerRadius = TSRadius_SM;

    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 20, 20)];
    iv.image       = [UIImage systemImageNamed:@"globe"];
    iv.tintColor   = UIColor.whiteColor;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [bg addSubview:iv];

    UIGraphicsBeginImageContextWithOptions(bg.bounds.size, NO, 0);
    [bg.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Toast / Error

- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text             = message;
    toast.font             = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor        = UIColor.whiteColor;
    toast.textAlignment    = NSTextAlignmentCenter;
    toast.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius  = 18.f;
    toast.layer.masksToBounds = YES;
    toast.alpha            = 0;

    CGFloat hPad  = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW  = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: toast.font}
                                          context:nil].size;
    CGFloat w = textSz.width  + hPad * 2;
    CGFloat h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);

    [self.view addSubview:toast];
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}

- (void)ts_showError:(NSError *)error title:(NSString *)title {
    NSString *msg = error.localizedDescription ?: @"操作失败，请重试";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
