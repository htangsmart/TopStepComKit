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
// 横向滚动的电池胶囊容器
@property (nonatomic, strong) UIScrollView *batteryScrollView;
// 当前各部件电池模型
@property (nonatomic, copy) NSArray<TSBatteryModel *> *currentBatteries;
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

- (void)updateConnected:(BOOL)connected
             deviceName:(nullable NSString *)name
             macAddress:(nullable NSString *)mac
              batteries:(nullable NSArray<TSBatteryModel *> *)batteries {
    [self ts_stopConnectingAnimation];
    self.reconnectButton.hidden = YES;

    if (connected) {
        self.titleLabel.text    = name.length > 0 ? name : TSLocalizedString(@"device.connected_default");
        self.detailLabel.text   = mac.length > 0 ? mac : @"";
        self.detailLabel.hidden = (mac.length == 0);

        self.statusLabel.text      = TSLocalizedString(@"device.connected");
        self.statusLabel.textColor = TSColor_Success;

        self.currentBatteries = batteries ?: @[];
        [self ts_rebuildBatteryCapsules];
    } else {
        self.statusLabel.text      = TSLocalizedString(@"device.disconnected");
        self.statusLabel.textColor = TSColor_Gray;

        self.titleLabel.text         = TSLocalizedString(@"device.not_connected");
        self.detailLabel.text        = TSLocalizedString(@"device.tap_to_connect");
        self.detailLabel.hidden      = NO;
        self.currentBatteries        = @[];
        [self ts_rebuildBatteryCapsules];
    }
    [self setNeedsLayout];
}

- (void)applyBatteryUpdate:(TSBatteryModel *)battery {
    if (!battery) return;

    NSMutableArray<TSBatteryModel *> *merged = [NSMutableArray arrayWithArray:self.currentBatteries];
    NSInteger idx = [self ts_indexOfBatteryMatching:battery in:merged];
    if (idx == NSNotFound) {
        [merged addObject:battery];
    } else {
        merged[idx] = battery;
    }
    self.currentBatteries = merged;
    [self ts_rebuildBatteryCapsules];
    [self setNeedsLayout];
}

- (void)updateConnecting {
    self.statusLabel.text      = TSLocalizedString(@"device.connecting");
    self.statusLabel.textColor = TSColor_Warning;

    self.titleLabel.text          = TSLocalizedString(@"device.reconnecting");
    self.detailLabel.text         = TSLocalizedString(@"device.reconnect_hint");
    self.detailLabel.hidden       = NO;
    self.currentBatteries         = @[];
    [self ts_rebuildBatteryCapsules];
    self.reconnectButton.hidden   = YES;

    [self ts_startConnectingAnimation];
    [self setNeedsLayout];
}

- (void)updateConnectionFailed {
    [self updateConnected:NO deviceName:nil macAddress:nil batteries:nil];
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

    // 电池胶囊横向滚动容器
    self.batteryScrollView = [[UIScrollView alloc] init];
    self.batteryScrollView.showsHorizontalScrollIndicator = NO;
    self.batteryScrollView.showsVerticalScrollIndicator   = NO;
    self.batteryScrollView.scrollEnabled                  = YES;
    self.batteryScrollView.clipsToBounds                  = YES;
    self.batteryScrollView.backgroundColor                = [UIColor clearColor];
    [self addSubview:self.batteryScrollView];

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

    [self updateConnected:NO deviceName:nil macAddress:nil batteries:nil];
}

/// 重建电池胶囊（清空 scrollView 子视图后按 currentBatteries 顺序追加）
- (void)ts_rebuildBatteryCapsules {
    for (UIView *sub in self.batteryScrollView.subviews) {
        [sub removeFromSuperview];
    }
    if (self.currentBatteries.count == 0) {
        self.batteryScrollView.hidden = YES;
        return;
    }
    self.batteryScrollView.hidden = NO;
    for (TSBatteryModel *battery in self.currentBatteries) {
        UIView *capsule = [self ts_createCapsuleForBattery:battery];
        [self.batteryScrollView addSubview:capsule];
    }
}

/// 创建单个电池胶囊：图标 + 百分比文字，圆角胶囊背景
- (UIView *)ts_createCapsuleForBattery:(TSBatteryModel *)battery {
    NSInteger pct = battery.percentage;
    TSBatteryState state = battery.chargeState;
    UIColor *levelColor = [self ts_levelColorForPercentage:pct state:state];

    UIView *capsule = [[UIView alloc] init];
    capsule.backgroundColor    = [levelColor colorWithAlphaComponent:0.12f];
    capsule.layer.cornerRadius = 9.f;

    UIImageView *icon = [[UIImageView alloc] init];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.tintColor   = levelColor;
    if (@available(iOS 13.0, *)) {
        NSString *symbol = [self ts_batterySymbolForState:state percentage:pct];
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
                                           configurationWithPointSize:13 weight:UIImageSymbolWeightRegular];
        icon.image = [UIImage systemImageNamed:symbol withConfiguration:cfg];
    }
    [capsule addSubview:icon];

    UILabel *label = [[UILabel alloc] init];
    label.font      = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    label.textColor = levelColor;
    label.text      = [NSString stringWithFormat:@"%@ %ld%%",
                       [self ts_shortNameForPart:battery.part],
                       (long)pct];
    [capsule addSubview:label];

    // 测量并设置子视图布局（capsule 自身宽高在 layoutSubviews 中按内容计算）
    CGSize textSize = [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    CGFloat iconW = 14.f, iconGap = 3.f, sideInset = 8.f;
    CGFloat capsuleW = sideInset + iconW + iconGap + ceil(textSize.width) + sideInset;
    CGFloat capsuleH = 18.f;
    capsule.frame = CGRectMake(0, 0, capsuleW, capsuleH);

    icon.frame  = CGRectMake(sideInset, (capsuleH - 14.f) / 2.f, iconW, 14.f);
    label.frame = CGRectMake(CGRectGetMaxX(icon.frame) + iconGap, 0, ceil(textSize.width), capsuleH);

    return capsule;
}

/// 充电状态色
- (UIColor *)ts_levelColorForPercentage:(NSInteger)pct state:(TSBatteryState)state {
    if (state == TSBatteryStateCharging || state == TSBatteryStateFull) return TSColor_Success;
    if (pct > 50) return TSColor_Success;
    if (pct > 20) return TSColor_Warning;
    return TSColor_Danger;
}

/// 部件简短名（卡片空间小，使用单字/缩写）
- (NSString *)ts_shortNameForPart:(TSBatteryPart)part {
    switch (part) {
        case TSBatteryPartMain:         return TSLocalizedString(@"battery.part.main");
        case TSBatteryPartLeft:         return TSLocalizedString(@"battery.part.left");
        case TSBatteryPartRight:        return TSLocalizedString(@"battery.part.right");
        case TSBatteryPartCase:         return TSLocalizedString(@"battery.part.case");
        case TSBatteryPartMic:          return TSLocalizedString(@"battery.part.mic");
        case TSBatteryPartMainSpeaker:  return TSLocalizedString(@"battery.part.main_speaker");
        case TSBatteryPartSideSpeaker:  return TSLocalizedString(@"battery.part.side_speaker");
        case TSBatteryPartOther:        return TSLocalizedString(@"battery.part.other");
        default:                        return TSLocalizedString(@"battery.part.other");
    }
}

/// 根据充电状态和电量百分比返回 SF Symbol 名称
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

/// 按 part 匹配数组中的索引
- (NSInteger)ts_indexOfBatteryMatching:(TSBatteryModel *)target in:(NSArray<TSBatteryModel *> *)array {
    for (NSInteger idx = 0; idx < (NSInteger)array.count; idx++) {
        if (array[idx].part == target.part) return idx;
    }
    return NSNotFound;
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

    // 第三行：状态 + 电池滚动
    CGFloat thirdRowY = CGRectGetMaxY(self.detailLabel.frame) + 6.f;

    CGSize statusSize = [self.statusLabel.text sizeWithAttributes:@{NSFontAttributeName: self.statusLabel.font}];
    CGFloat statusW = MIN(statusSize.width + 4.f, textW);
    self.statusLabel.frame = CGRectMake(textX, thirdRowY, statusW, 18.f);

    // 重连按钮（仅未隐藏时占位）
    CGFloat scrollX = CGRectGetMaxX(self.statusLabel.frame) + 12.f;
    if (!self.reconnectButton.hidden) {
        CGFloat btnSize = 20.f;
        self.reconnectButton.frame = CGRectMake(scrollX, thirdRowY - 1.f, btnSize, btnSize);
        scrollX += btnSize + 8.f;
    }

    CGFloat scrollW = CGRectGetMinX(self.arrowLabel.frame) - scrollX - 4.f;
    if (scrollW < 0) scrollW = 0;
    self.batteryScrollView.frame = CGRectMake(scrollX, thirdRowY - 1.f, scrollW, 20.f);

    [self ts_layoutBatteryCapsules];
}

/// 在 batteryScrollView 中横向排布所有胶囊
- (void)ts_layoutBatteryCapsules {
    CGFloat x = 0;
    CGFloat gap = 6.f;
    CGFloat capsuleH = CGRectGetHeight(self.batteryScrollView.bounds);
    if (capsuleH <= 0) capsuleH = 18.f;
    CGFloat y = (CGRectGetHeight(self.batteryScrollView.bounds) - capsuleH) / 2.f;
    if (y < 0) y = 0;

    for (UIView *capsule in self.batteryScrollView.subviews) {
        CGFloat cw = CGRectGetWidth(capsule.bounds);
        capsule.frame = CGRectMake(x, y, cw, capsuleH);
        x += cw + gap;
    }
    if (x > 0) x -= gap;
    self.batteryScrollView.contentSize = CGSizeMake(x, capsuleH);
}

@end
