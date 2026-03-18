//
//  TSBatteryVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBatteryVC.h"
#import <TopStepComKit/TopStepComKit.h>

typedef NS_ENUM(NSInteger, TSBatteryViewState) {
    TSBatteryViewStateInitial = 0,
    TSBatteryViewStateLoading,
    TSBatteryViewStateLoaded,
};

@interface TSBatteryVC ()
@property (nonatomic, strong) UIView                    *cardView;
@property (nonatomic, strong) UIImageView               *batteryIconView;
@property (nonatomic, strong) UILabel                   *percentageLabel;
@property (nonatomic, strong) UIView                    *statusBadge;
@property (nonatomic, strong) UILabel                   *statusLabel;
@property (nonatomic, strong) UILabel                   *hintLabel;
@property (nonatomic, strong) UIButton                  *fetchButton;
@property (nonatomic, strong) UIActivityIndicatorView   *spinner;
@property (nonatomic, assign) TSBatteryViewState         viewState;
@property (nonatomic, strong) TSBatteryModel            *batteryModel;
@end

@implementation TSBatteryVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电量信息";
    self.view.backgroundColor = TSColor_Background;

    [self ts_setupUI];
    [self ts_registerCallback];
    [self ts_setViewState:TSBatteryViewStateInitial];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self ts_layoutViews];
}

#pragma mark - Setup

- (void)ts_setupUI {
    [self.sourceTableview removeFromSuperview];

    // ── Card ────────────────────────────────────────────────────────────────
    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor       = TSColor_Card;
    self.cardView.layer.cornerRadius    = TSRadius_LG;
    self.cardView.layer.shadowColor     = [UIColor blackColor].CGColor;
    self.cardView.layer.shadowOpacity   = 0.07f;
    self.cardView.layer.shadowOffset    = CGSizeMake(0, 2);
    self.cardView.layer.shadowRadius    = 10;
    [self.view addSubview:self.cardView];

    // ── Battery icon ────────────────────────────────────────────────────────
    self.batteryIconView = [[UIImageView alloc] init];
    self.batteryIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.batteryIconView.tintColor   = TSColor_Success;
    [self.cardView addSubview:self.batteryIconView];

    // ── Percentage ──────────────────────────────────────────────────────────
    self.percentageLabel = [[UILabel alloc] init];
    self.percentageLabel.font          = [UIFont systemFontOfSize:80 weight:UIFontWeightThin];
    self.percentageLabel.textColor     = TSColor_TextPrimary;
    self.percentageLabel.textAlignment = NSTextAlignmentCenter;
    self.percentageLabel.text          = @"--";
    [self.cardView addSubview:self.percentageLabel];

    // ── Status badge ────────────────────────────────────────────────────────
    self.statusBadge = [[UIView alloc] init];
    self.statusBadge.layer.cornerRadius = 12;
    self.statusBadge.backgroundColor    = [TSColor_TextSecondary colorWithAlphaComponent:0.1f];
    [self.cardView addSubview:self.statusBadge];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font          = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.statusLabel.textColor     = TSColor_TextSecondary;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.statusBadge addSubview:self.statusLabel];

    // ── Hint (initial state) ────────────────────────────────────────────────
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.text          = @"点击下方按钮获取设备电量";
    self.hintLabel.font          = [UIFont systemFontOfSize:15];
    self.hintLabel.textColor     = TSColor_TextSecondary;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    [self.cardView addSubview:self.hintLabel];

    // ── Spinner ─────────────────────────────────────────────────────────────
    if (@available(iOS 13.0, *)) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.color = TSColor_Primary;
    }
    self.spinner.hidesWhenStopped = YES;
    [self.cardView addSubview:self.spinner];

    // ── Fetch button ────────────────────────────────────────────────────────
    self.fetchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.fetchButton setTitle:@"获取电量" forState:UIControlStateNormal];
    self.fetchButton.titleLabel.font    = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.fetchButton.backgroundColor    = TSColor_Primary;
    self.fetchButton.layer.cornerRadius = TSRadius_MD;
    [self.fetchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.fetchButton addTarget:self action:@selector(ts_fetchBattery) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fetchButton];
}

- (void)ts_layoutViews {
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;
    CGFloat safeTop    = self.view.safeAreaInsets.top;
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // Button
    CGFloat btnH = 54;
    CGFloat btnY = H - safeBottom - btnH - 24;
    self.fetchButton.frame = CGRectMake(16, btnY, W - 32, btnH);

    // Card
    CGFloat cardY = safeTop + 16;
    CGFloat cardH = btnY - cardY - 16;
    self.cardView.frame = CGRectMake(16, cardY, W - 32, cardH);

    // Card content — vertically center the icon + percentage + badge block
    CGFloat iconH  = 72;
    CGFloat pctH   = 96;
    CGFloat badgeH = 30;
    CGFloat gap1   = 12;
    CGFloat gap2   = 16;
    CGFloat blockH = iconH + gap1 + pctH + gap2 + badgeH;
    CGFloat blockY = (cardH - blockH) / 2.f;
    CGFloat cW     = self.cardView.bounds.size.width;

    self.batteryIconView.frame = CGRectMake((cW - 100) / 2.f, blockY, 100, iconH);
    self.percentageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.batteryIconView.frame) + gap1, cW, pctH);

    CGFloat badgeW = 160;
    self.statusBadge.frame  = CGRectMake((cW - badgeW) / 2.f, CGRectGetMaxY(self.percentageLabel.frame) + gap2, badgeW, badgeH);
    self.statusLabel.frame  = CGRectMake(0, 0, badgeW, badgeH);

    self.hintLabel.frame    = CGRectMake(0, (cardH - 22) / 2.f, cW, 22);
    self.spinner.center     = CGPointMake(cW / 2.f, cardH / 2.f);
}

#pragma mark - State

- (void)ts_setViewState:(TSBatteryViewState)state {
    _viewState = state;

    BOOL isInitial = (state == TSBatteryViewStateInitial);
    BOOL isLoading = (state == TSBatteryViewStateLoading);
    BOOL isLoaded  = (state == TSBatteryViewStateLoaded);

    self.batteryIconView.hidden = !isLoaded;
    self.percentageLabel.hidden = !isLoaded;
    self.statusBadge.hidden     = !isLoaded;
    self.hintLabel.hidden       = !isInitial;
    self.fetchButton.enabled    = !isLoading;
    self.fetchButton.alpha      = isLoading ? 0.5f : 1.f;

    if (isLoading) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }

    if (isLoaded) {
        [self ts_updateDisplay];
    }
}

- (void)ts_updateDisplay {
    if (!self.batteryModel) return;

    NSInteger pct    = self.batteryModel.percentage;
    TSBatteryState s = self.batteryModel.chargeState;

    // ── Percentage text ──────────────────────────────────────────────────────
    self.percentageLabel.text = [NSString stringWithFormat:@"%ld%%", (long)pct];

    // ── Color ────────────────────────────────────────────────────────────────
    UIColor *levelColor;
    if (s == TSBatteryStateCharging || s == TSBatteryStateFull) {
        levelColor = TSColor_Success;
    } else if (pct > 50) {
        levelColor = TSColor_Success;
    } else if (pct > 20) {
        levelColor = TSColor_Warning;
    } else {
        levelColor = TSColor_Danger;
    }
    self.percentageLabel.textColor  = levelColor;
    self.batteryIconView.tintColor  = levelColor;

    // ── Battery icon (SF Symbol) ──────────────────────────────────────────────
    if (@available(iOS 13.0, *)) {
        NSString *symbolName;
        if (s == TSBatteryStateCharging) {
            if (@available(iOS 14.0, *)) {
                symbolName = @"battery.100.bolt";
            } else {
                symbolName = @"bolt.fill";
            }
        } else if (s == TSBatteryStateFull || pct >= 90) {
            symbolName = @"battery.100";
        } else if (pct >= 65) {
            symbolName = @"battery.75";
        } else if (pct >= 40) {
            symbolName = @"battery.50";
        } else if (pct >= 15) {
            symbolName = @"battery.25";
        } else {
            symbolName = @"battery.0";
        }
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
            configurationWithPointSize:56 weight:UIImageSymbolWeightThin];
        self.batteryIconView.image = [UIImage systemImageNamed:symbolName withConfiguration:cfg];
    }

    // ── Status text & badge color ────────────────────────────────────────────
    NSString *statusText;
    UIColor  *statusColor;
    switch (s) {
        case TSBatteryStateCharging:
            statusText  = @"正在充电";
            statusColor = TSColor_Success;
            break;
        case TSBatteryStateFull:
            statusText  = @"已充满电";
            statusColor = TSColor_Success;
            break;
        case TSBatteryStateConnectNotCharging:
            statusText  = @"已接电源，未充电";
            statusColor = TSColor_Warning;
            break;
        case TSBatteryStateUnConnectNoCharging:
            statusText  = pct <= 20 ? @"电量低，请充电" : @"未充电";
            statusColor = pct <= 20 ? TSColor_Danger : TSColor_TextSecondary;
            break;
        default:
            statusText  = @"状态未知";
            statusColor = TSColor_TextSecondary;
            break;
    }

    self.statusLabel.text            = statusText;
    self.statusLabel.textColor       = statusColor;
    self.statusBadge.backgroundColor = [statusColor colorWithAlphaComponent:0.12f];

    // Resize badge to fit text
    CGSize textSize = [statusText sizeWithAttributes:@{NSFontAttributeName: self.statusLabel.font}];
    CGFloat badgeW  = textSize.width + 32;
    CGFloat cW      = self.cardView.bounds.size.width;
    CGFloat badgeH  = self.statusBadge.bounds.size.height ?: 30;
    self.statusBadge.frame = CGRectMake((cW - badgeW) / 2.f, self.statusBadge.frame.origin.y, badgeW, badgeH);
    self.statusLabel.frame = CGRectMake(0, 0, badgeW, badgeH);
}

#pragma mark - Actions

- (void)ts_fetchBattery {
    [self ts_setViewState:TSBatteryViewStateLoading];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] getBatteryInfoCompletion:^(TSBatteryModel *batteryModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !batteryModel) {
                [weakSelf ts_setViewState:TSBatteryViewStateInitial];
                [weakSelf showAlertWithMsg:[NSString stringWithFormat:@"获取失败：%@",
                    error.localizedDescription ?: @"未知错误"]];
                return;
            }
            weakSelf.batteryModel = batteryModel;
            [weakSelf ts_setViewState:TSBatteryViewStateLoaded];
        });
    }];
}

#pragma mark - Callback

- (void)ts_registerCallback {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] battery] registerBatteryDidChanged:^(TSBatteryModel *batteryModel, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !batteryModel) return;
            weakSelf.batteryModel = batteryModel;
            if (weakSelf.viewState == TSBatteryViewStateLoaded) {
                [weakSelf ts_updateDisplay];
            }
        });
    }];
}

@end
