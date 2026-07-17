//
//  TSBatteryVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBatteryVC.h"

#import <TopStepComKit/TopStepComKit.h>

#pragma mark - TSBatteryCell

@interface TSBatteryCell : UITableViewCell

- (void)applyTitle:(NSString *)title
           battery:(TSBatteryModel *)battery
        isOverview:(BOOL)isOverview;

@end

@interface TSBatteryCell ()
// 左侧部件图标
@property (nonatomic, strong) UIImageView *partIconView;
// 部件名/总览标题
@property (nonatomic, strong) UILabel *partNameLabel;
// 充电状态副标题
@property (nonatomic, strong) UILabel *stateLabel;
// 电池小图标
@property (nonatomic, strong) UIImageView *batteryIconView;
// 百分比文字
@property (nonatomic, strong) UILabel *percentLabel;
@end

@implementation TSBatteryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;
        [self ts_setupSubviews];
    }
    return self;
}

- (void)ts_setupSubviews {
    self.partIconView = [[UIImageView alloc] init];
    self.partIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.partIconView.tintColor = TSColor_Primary;
    [self.contentView addSubview:self.partIconView];

    self.partNameLabel = [[UILabel alloc] init];
    self.partNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.partNameLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.partNameLabel];

    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.font = [UIFont systemFontOfSize:13];
    self.stateLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:self.stateLabel];

    self.batteryIconView = [[UIImageView alloc] init];
    self.batteryIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.batteryIconView];

    self.percentLabel = [[UILabel alloc] init];
    self.percentLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
    self.percentLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.percentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = CGRectGetWidth(self.contentView.bounds);
    CGFloat H = CGRectGetHeight(self.contentView.bounds);

    CGFloat iconSize = 32.f;
    self.partIconView.frame = CGRectMake(TSSpacing_MD, (H - iconSize) / 2.f, iconSize, iconSize);

    CGFloat percentW = 72.f;
    CGFloat batteryW = 26.f;
    CGFloat rightX = W - TSSpacing_MD;
    self.percentLabel.frame = CGRectMake(rightX - percentW, (H - 28.f) / 2.f, percentW, 28.f);
    self.batteryIconView.frame = CGRectMake(CGRectGetMinX(self.percentLabel.frame) - batteryW - 4.f,
                                            (H - 20.f) / 2.f, batteryW, 20.f);

    CGFloat textX = CGRectGetMaxX(self.partIconView.frame) + TSSpacing_SM + 4.f;
    CGFloat textW = CGRectGetMinX(self.batteryIconView.frame) - textX - TSSpacing_SM;
    self.partNameLabel.frame = CGRectMake(textX, H / 2.f - 20.f, textW, 20.f);
    self.stateLabel.frame    = CGRectMake(textX, H / 2.f + 2.f, textW, 16.f);
}

- (void)applyTitle:(NSString *)title
           battery:(TSBatteryModel *)battery
        isOverview:(BOOL)isOverview {
    NSInteger pct = battery.percentage;
    TSBatteryState state = battery.chargeState;

    self.partNameLabel.text = title;
    self.percentLabel.text  = [NSString stringWithFormat:@"%ld%%", (long)pct];

    UIColor *levelColor = [self ts_levelColorForPercentage:pct state:state];
    self.percentLabel.textColor    = levelColor;
    self.batteryIconView.tintColor = levelColor;
    self.partIconView.tintColor    = isOverview ? TSColor_Primary : levelColor;

    if (@available(iOS 13.0, *)) {
        NSString *partSymbol = @"battery.100";
        UIImageSymbolConfiguration *partCfg = [UIImageSymbolConfiguration
                                               configurationWithPointSize:24 weight:UIImageSymbolWeightRegular];
        self.partIconView.image = [UIImage systemImageNamed:partSymbol withConfiguration:partCfg];

        NSString *batterySymbol = [self ts_batterySymbolForState:state percentage:pct];
        UIImageSymbolConfiguration *batCfg = [UIImageSymbolConfiguration
                                              configurationWithPointSize:18 weight:UIImageSymbolWeightRegular];
        self.batteryIconView.image = [UIImage systemImageNamed:batterySymbol withConfiguration:batCfg];
    }

    self.stateLabel.text = [self ts_stateTextForState:state percentage:pct];
}

#pragma mark - 文案与图标

/// 充电状态文字
- (NSString *)ts_stateTextForState:(TSBatteryState)state percentage:(NSInteger)pct {
    switch (state) {
        case TSBatteryStateCharging:            return TSLocalizedString(@"battery.charging");
        case TSBatteryStateFull:                return TSLocalizedString(@"battery.full");
        case TSBatteryStateConnectNotCharging:  return TSLocalizedString(@"battery.connected_not_charging");
        case TSBatteryStateUnConnectNoCharging: return pct <= 20 ? TSLocalizedString(@"battery.low_please_charge")
                                                                : TSLocalizedString(@"battery.not_charging");
        default:                                return TSLocalizedString(@"battery.status_unknown");
    }
}

/// 电量颜色
- (UIColor *)ts_levelColorForPercentage:(NSInteger)pct state:(TSBatteryState)state {
    if (state == TSBatteryStateCharging || state == TSBatteryStateFull) return TSColor_Success;
    if (pct > 50) return TSColor_Success;
    if (pct > 20) return TSColor_Warning;
    return TSColor_Danger;
}

/// 电池图标 SF Symbol
- (NSString *)ts_batterySymbolForState:(TSBatteryState)state percentage:(NSInteger)pct {
    if (state == TSBatteryStateCharging) {
        if (@available(iOS 14.0, *)) return @"battery.100.bolt";
        return @"bolt.fill";
    }
    if (state == TSBatteryStateFull || pct >= 90) return @"battery.100";
    if (pct >= 65) return @"battery.75";
    if (pct >= 40) return @"battery.50";
    if (pct >= 15) return @"battery.25";
    return @"battery.0";
}

@end

#pragma mark - TSBatteryVC

typedef NS_ENUM(NSInteger, TSBatteryViewState) {
    TSBatteryViewStateInitial = 0,
    TSBatteryViewStateLoading,
    TSBatteryViewStateLoaded,
    TSBatteryViewStateEmpty,
};

static NSString * const kTSBatteryCellID = @"TSBatteryCell";

@interface TSBatteryVC ()
// 所有部件电池数据，按 SDK 返回顺序保留
@property (nonatomic, strong) NSMutableArray<TSBatteryModel *> *batteries;
// 当前视图状态
@property (nonatomic, assign) TSBatteryViewState viewState;
// 下拉刷新控件
@property (nonatomic, strong) UIRefreshControl *refreshControl;
// 首次加载的居中 spinner
@property (nonatomic, strong) UIActivityIndicatorView *centerSpinner;
@end

@implementation TSBatteryVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"battery.page_title");
    self.view.backgroundColor = TSColor_Background;
    self.batteries = [NSMutableArray array];

    [self ts_rebuildTableView];
    [self ts_setupAccessory];
    [self ts_registerCallback];
    [self ts_setViewState:TSBatteryViewStateLoading];
    [self ts_fetchAllBatteries];
}

#pragma mark - Setup

/// 重建为 InsetGrouped 样式的 tableView
- (void)ts_rebuildTableView {
    [self.sourceTableview removeFromSuperview];

    UITableView *grouped;
    if (@available(iOS 13.0, *)) {
        grouped = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    } else {
        grouped = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    }
    grouped.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    grouped.delegate         = self;
    grouped.dataSource       = self;
    grouped.backgroundColor  = TSColor_Background;
    grouped.rowHeight        = 64.f;
    if (@available(iOS 15.0, *)) {
        grouped.sectionHeaderTopPadding = 0;
    }
    [grouped registerClass:[TSBatteryCell class] forCellReuseIdentifier:kTSBatteryCellID];
    [self.view addSubview:grouped];
    self.sourceTableview = grouped;
}

/// 下拉刷新 + 居中 spinner
- (void)ts_setupAccessory {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:TSLocalizedString(@"battery.pull_to_refresh")];
    [self.refreshControl addTarget:self action:@selector(ts_onPullRefresh) forControlEvents:UIControlEventValueChanged];
    self.sourceTableview.refreshControl = self.refreshControl;

    if (@available(iOS 13.0, *)) {
        self.centerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        self.centerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.centerSpinner.color = TSColor_Primary;
    }
    self.centerSpinner.hidesWhenStopped = YES;
    [self.view addSubview:self.centerSpinner];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.centerSpinner.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

#pragma mark - State

- (void)ts_setViewState:(TSBatteryViewState)state {
    _viewState = state;

    if (state == TSBatteryViewStateLoading && self.batteries.count == 0) {
        [self.centerSpinner startAnimating];
    } else {
        [self.centerSpinner stopAnimating];
    }

    if (state == TSBatteryViewStateEmpty) {
        [self showEmptyViewWithTitle:TSLocalizedString(@"battery.empty") subtitle:nil];
    } else {
        [self hideEmptyView];
    }
}

#pragma mark - Data

/// 拉取所有部件电池（getAllBatteriesInfoCompletion）
- (void)ts_fetchAllBatteries {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] getBatteryInfoCompletion:^(TSBatteryModel *batteryModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;

            [strongSelf.refreshControl endRefreshing];

            if (error || batteryModel == nil) {
                [strongSelf ts_setViewState:strongSelf.batteries.count > 0 ? TSBatteryViewStateLoaded : TSBatteryViewStateInitial];
                [strongSelf showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"battery.get_failed"),
                    error.localizedDescription ?: TSLocalizedString(@"general.unknown_error")]];
                return;
            }

            [strongSelf.batteries removeAllObjects];
            [strongSelf.batteries addObject:batteryModel];

            if (strongSelf.batteries.count == 0) {
                [strongSelf ts_setViewState:TSBatteryViewStateEmpty];
            } else {
                [strongSelf ts_setViewState:TSBatteryViewStateLoaded];
            }
            [strongSelf.sourceTableview reloadData];
        });
    }];
}

/// 增量更新单个部件
- (void)ts_applyBatteryUpdate:(TSBatteryModel *)updated {
    if (!updated) return;
    NSInteger idx = [self ts_indexOfBatteryMatching:updated];
    if (idx == NSNotFound) {
        // 部件可能是新增（未上报过），整体重拉一次
        [self ts_fetchAllBatteries];
        return;
    }
    self.batteries[idx] = updated;
    [self.sourceTableview reloadData];
}

/// 按 part 匹配现有项的索引
- (NSInteger)ts_indexOfBatteryMatching:(TSBatteryModel *)target {
    // beta9 SDK 为单电池，命中唯一一节
    return self.batteries.count > 0 ? 0 : NSNotFound;
}

/// 取最低电量的部件作为"设备电量"展示
- (TSBatteryModel *)ts_overviewBattery {
    TSBatteryModel *lowest = nil;
    for (TSBatteryModel *b in self.batteries) {
        if (!lowest || b.percentage < lowest.percentage) {
            lowest = b;
        }
    }
    return lowest;
}

#pragma mark - Actions

/// 下拉刷新触发
- (void)ts_onPullRefresh {
    [self ts_fetchAllBatteries];
}

#pragma mark - Callback

/// 注册电量变化监听（多电池设备每个部件变化时各回调一次）
- (void)ts_registerCallback {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] registerBatteryDidChanged:^(TSBatteryModel *batteryModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !batteryModel) return;
            [weakSelf ts_applyBatteryUpdate:batteryModel];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.batteries.count == 0) return 0;
    return self.batteries.count > 1 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    return (NSInteger)self.batteries.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return TSLocalizedString(@"battery.device");
    return TSLocalizedString(@"battery.section.parts");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSBatteryCell *cell = [tableView dequeueReusableCellWithIdentifier:kTSBatteryCellID forIndexPath:indexPath];
    if (indexPath.section == 0) {
        TSBatteryModel *overview = [self ts_overviewBattery];
        [cell applyTitle:TSLocalizedString(@"battery.device") battery:overview isOverview:YES];
    } else {
        TSBatteryModel *battery = self.batteries[indexPath.row];
        [cell applyTitle:[self ts_displayNameForBattery:battery] battery:battery isOverview:NO];
    }
    return cell;
}

#pragma mark - 私有方法

/// 部件展示名称
- (NSString *)ts_displayNameForBattery:(TSBatteryModel *)battery {
    // beta9 SDK 为单电池，无部件区分
    return TSLocalizedString(@"battery.device");
}

@end
