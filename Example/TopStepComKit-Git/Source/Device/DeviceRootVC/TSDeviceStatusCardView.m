//
//  TSDeviceStatusCardView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDeviceStatusCardView.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSRootVC.h"

@interface TSDeviceStatusCardView ()

// 手表图标
@property (nonatomic, strong) UIImageView *watchIconView;
// 设备名称
@property (nonatomic, strong) UILabel *titleLabel;
// MAC 地址
@property (nonatomic, strong) UILabel *detailLabel;
// 连接状态文字
@property (nonatomic, strong) UILabel *statusLabel;
// 电池图标
@property (nonatomic, strong) UIImageView *batteryIconView;
// 电池百分比
@property (nonatomic, strong) UILabel *batteryPercentLabel;
// 右侧箭头
@property (nonatomic, strong) UILabel *arrowLabel;
// 重连按钮
@property (nonatomic, strong) UIButton *reconnectButton;

@end

@implementation TSDeviceStatusCardView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ts_setupSubviews];
    }
    return self;
}

#pragma mark - 公开方法

- (void)updateConnected:(BOOL)connected deviceName:(nullable NSString *)name macAddress:(nullable NSString *)mac battery:(nullable TSBatteryModel *)battery {
    [self ts_stopConnectingAnimation];
    self.reconnectButton.hidden = YES;

    if (connected) {
        self.titleLabel.text    = name.length > 0 ? name : TSLocalizedString(@"device.connected_default");
        self.detailLabel.text   = mac.length > 0 ? mac : @"";
        self.detailLabel.hidden = (mac.length == 0);

        self.statusLabel.text      = TSLocalizedString(@"device.connected");
        self.statusLabel.textColor = TSColor_Success;

        [self ts_updateBatteryDisplay:battery];
    } else {
        self.statusLabel.text      = TSLocalizedString(@"device.disconnected");
        self.statusLabel.textColor = TSColor_Gray;

        self.titleLabel.text            = TSLocalizedString(@"device.not_connected");
        self.detailLabel.text           = TSLocalizedString(@"device.tap_to_connect");
        self.detailLabel.hidden         = NO;
        self.batteryIconView.hidden     = YES;
        self.batteryPercentLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)updateConnecting {
    self.statusLabel.text      = TSLocalizedString(@"device.connecting");
    self.statusLabel.textColor = TSColor_Warning;

    self.titleLabel.text           = TSLocalizedString(@"device.reconnecting");
    self.detailLabel.text          = TSLocalizedString(@"device.reconnect_hint");
    self.detailLabel.hidden        = NO;
    self.batteryIconView.hidden     = YES;
    self.batteryPercentLabel.hidden = YES;
    self.reconnectButton.hidden     = YES;

    [self ts_startConnectingAnimation];
    [self setNeedsLayout];
}

- (void)updateConnectionFailed {
    [self updateConnected:NO deviceName:nil macAddress:nil battery:nil];
    self.reconnectButton.hidden = NO;
    [self setNeedsLayout];
}

- (BOOL)isReconnectButtonVisible {
    return !self.reconnectButton.hidden;
}

#pragma mark - 私有方法

/// 初始化子视图
- (void)ts_setupSubviews {
    self.backgroundColor    = TSColor_Card;
    self.layer.cornerRadius = TSRadius_MD;
    self.layer.shadowColor  = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.08f;
    self.clipsToBounds = NO;

    // 手表图标
    self.watchIconView = [[UIImageView alloc] init];
    self.watchIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.watchIconView.tintColor = TSColor_Primary;
    if (@available(iOS 13.0, *)) {
        self.watchIconView.image = [UIImage systemImageNamed:@"applewatch"];
    }
    [self addSubview:self.watchIconView];

    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font      = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = TSColor_TextPrimary;
    [self addSubview:self.titleLabel];

    // 副标题
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font      = [UIFont systemFontOfSize:12];
    self.detailLabel.textColor = TSColor_TextSecondary;
    [self addSubview:self.detailLabel];

    // 状态文字
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [self addSubview:self.statusLabel];

    // 电池图标
    self.batteryIconView = [[UIImageView alloc] init];
    self.batteryIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.batteryIconView.tintColor   = TSColor_Success;
    self.batteryIconView.hidden      = YES;
    [self addSubview:self.batteryIconView];

    // 电池百分比
    self.batteryPercentLabel = [[UILabel alloc] init];
    self.batteryPercentLabel.font      = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.batteryPercentLabel.textColor = TSColor_TextSecondary;
    self.batteryPercentLabel.hidden    = YES;
    [self addSubview:self.batteryPercentLabel];

    // 右侧箭头
    self.arrowLabel = [[UILabel alloc] init];
    self.arrowLabel.text      = @">";
    self.arrowLabel.font      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.arrowLabel.textColor = TSColor_TextSecondary;
    [self addSubview:self.arrowLabel];

    // 重连按钮
    self.reconnectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (@available(iOS 13.0, *)) {
        UIImage *icon = [[UIImage systemImageNamed:@"arrow.clockwise"]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.reconnectButton setImage:icon forState:UIControlStateNormal];
    }
    self.reconnectButton.tintColor = TSColor_Danger;
    self.reconnectButton.hidden = YES;
    [self.reconnectButton addTarget:self action:@selector(ts_reconnectTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.reconnectButton];

    [self updateConnected:NO deviceName:nil macAddress:nil battery:nil];
}

/// 更新电池显示
- (void)ts_updateBatteryDisplay:(TSBatteryModel *)battery {
    if (!battery) {
        self.batteryIconView.hidden     = YES;
        self.batteryPercentLabel.hidden = YES;
        return;
    }

    NSInteger pct = battery.percentage;
    TSBatteryState chargeState = battery.chargeState;

    // 电量颜色
    UIColor *levelColor;
    if (chargeState == TSBatteryStateCharging || chargeState == TSBatteryStateFull) {
        levelColor = TSColor_Success;
    } else if (pct > 50) {
        levelColor = TSColor_Success;
    } else if (pct > 20) {
        levelColor = TSColor_Warning;
    } else {
        levelColor = TSColor_Danger;
    }

    // 电池图标
    if (@available(iOS 13.0, *)) {
        NSString *symbolName = [self ts_batterySymbolForState:chargeState percentage:pct];
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
                                           configurationWithPointSize:18 weight:UIImageSymbolWeightRegular];
        self.batteryIconView.image     = [UIImage systemImageNamed:symbolName withConfiguration:cfg];
        self.batteryIconView.tintColor = levelColor;
        self.batteryPercentLabel.text      = [NSString stringWithFormat:@"%ld%%", (long)pct];
        self.batteryPercentLabel.textColor = levelColor;
        self.batteryIconView.hidden      = NO;
        self.batteryPercentLabel.hidden  = NO;
    } else {
        self.batteryIconView.hidden     = YES;
        self.batteryPercentLabel.hidden = YES;
    }
}

/// 根据充电状态和电量百分比返回 SF Symbol 名称
- (NSString *)ts_batterySymbolForState:(TSBatteryState)chargeState percentage:(NSInteger)pct {
    if (chargeState == TSBatteryStateCharging) {
        if (@available(iOS 14.0, *)) {
            return @"battery.100.bolt";
        }
        return @"bolt.fill";
    }
    if (chargeState == TSBatteryStateFull || pct >= 90) return @"battery.100";
    if (pct >= 65) return @"battery.75";
    if (pct >= 40) return @"battery.50";
    if (pct >= 15) return @"battery.25";
    return @"battery.0";
}

/// 重连按钮点击
- (void)ts_reconnectTapped {
    if (self.onReconnectTap) {
        self.onReconnectTap();
    }
}

/// 开始连接中闪烁动画
- (void)ts_startConnectingAnimation {
    [self.statusLabel.layer removeAllAnimations];

    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue      = @(1.0);
    opacityAnimation.toValue        = @(0.3);
    opacityAnimation.duration       = 0.8;
    opacityAnimation.repeatCount    = HUGE_VALF;
    opacityAnimation.autoreverses   = YES;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    [self.statusLabel.layer addAnimation:opacityAnimation forKey:@"connecting"];
}

/// 停止连接中动画
- (void)ts_stopConnectingAnimation {
    [self.statusLabel.layer removeAnimationForKey:@"connecting"];
    self.statusLabel.layer.opacity = 1.0;
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    // 左侧手表图标
    CGFloat watchIconW = h - 20;
    self.watchIconView.frame = CGRectMake(0, 10, watchIconW, watchIconW);

    // 右箭头
    CGFloat arrowW = 20.f;
    self.arrowLabel.frame = CGRectMake(w - arrowW - 16.f, (h - 20.f) / 2.f, arrowW, 20.f);

    // 文字区域
    CGFloat textX = CGRectGetMaxX(self.watchIconView.frame) + 10.f;
    CGFloat textW = CGRectGetMinX(self.arrowLabel.frame) - textX - 8.f;

    // 标题
    self.titleLabel.frame = CGRectMake(textX, 12.f, textW, 20.f);

    // MAC
    self.detailLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + 4.f, textW, 16.f);

    // 第三行：状态 + 电池
    CGFloat thirdRowY = CGRectGetMaxY(self.detailLabel.frame) + 6.f;

    CGSize statusSize = [self.statusLabel.text sizeWithAttributes:@{NSFontAttributeName: self.statusLabel.font}];
    self.statusLabel.frame = CGRectMake(textX, thirdRowY, statusSize.width + 4.f, 16.f);

    CGFloat batteryX = CGRectGetMaxX(self.statusLabel.frame) + 12.f;
    self.batteryIconView.frame     = CGRectMake(batteryX, thirdRowY, 24.f, 16.f);
    self.batteryPercentLabel.frame = CGRectMake(CGRectGetMaxX(self.batteryIconView.frame) + 6.f, thirdRowY, 48.f, 16.f);

    // 重连按钮
    if (!self.reconnectButton.hidden) {
        CGFloat btnSize = 20.f;
        CGFloat btnX = CGRectGetMaxX(self.statusLabel.frame) + TSSpacing_SM;
        CGFloat btnY = thirdRowY + (16.f - btnSize) / 2.f;
        self.reconnectButton.frame = CGRectMake(btnX, btnY, btnSize, btnSize);
    }
}

@end
