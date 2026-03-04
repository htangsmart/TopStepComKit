//
//  TSPeripheralFindVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/10.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralFindVC.h"
#import <AudioToolbox/AudioToolbox.h>

// ── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kRadarCenterSize   = 64.f;  // 中心图标容器直径
static const CGFloat kRadarRingCount    = 3;     // 雷达扩散圆环数量
static const CGFloat kRadarMaxRadius    = 140.f; // 雷达最大扩散半径
static const CGFloat kActionBtnH        = 52.f;  // 主操作按钮高度
static const CGFloat kActionBtnW        = 200.f; // 主操作按钮宽度
static const NSTimeInterval kRingDelay  = 0.4;   // 每个圆环的动画延迟间隔（秒）
static const NSTimeInterval kRingDuration = 2.0; // 单个圆环一次扩散时长

// ── 查找状态枚举 ──────────────────────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSFindState) {
    TSFindStateIdle    = 0,  // 未查找
    TSFindStateScanning,     // 查找中
    TSFindStateFound,        // 设备已找到
};

// ── 私有接口 ──────────────────────────────────────────────────────────────────
@interface TSPeripheralFindVC ()

// 雷达动画区域容器（圆形，主视图居中）
@property (nonatomic, strong) UIView       *radarContainerView;

// 雷达中心图标（手表图标背景圆）
@property (nonatomic, strong) UIView       *radarCenterView;
@property (nonatomic, strong) UILabel      *radarIconLabel;

// 雷达扩散圆环（动态创建，存储在数组中）
@property (nonatomic, strong) NSMutableArray<UIView *> *radarRings;

// 主操作按钮（查找设备 / 结束查找）
@property (nonatomic, strong) UIButton     *actionButton;

// 状态说明文案
@property (nonatomic, strong) UILabel      *statusLabel;

// 设备找手机弹窗容器（全屏遮罩）
@property (nonatomic, strong) UIView       *findPhoneOverlay;

// 弹窗卡片
@property (nonatomic, strong) UIView       *findPhoneCard;

// 弹窗中心波纹容器
@property (nonatomic, strong) UIView       *phoneRippleContainer;
@property (nonatomic, strong) UILabel      *phoneIconLabel;

// 弹窗标题与副标题
@property (nonatomic, strong) UILabel      *findPhoneTitleLabel;
@property (nonatomic, strong) UILabel      *findPhoneSubtitleLabel;

// 弹窗「找到了」按钮
@property (nonatomic, strong) UIButton     *foundPhoneButton;

// 当前查找状态
@property (nonatomic, assign) TSFindState  findState;

// 是否正在循环震动（设备找手机时使用）
@property (nonatomic, assign) BOOL         isVibratingForPhone;

@end

// ── 实现 ──────────────────────────────────────────────────────────────────────
@implementation TSPeripheralFindVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCallbacks];
}

#pragma mark - Override Base Setup

/**
 * 初始化数据
 */
- (void)initData {
    [super initData];
    self.title     = @"查找设备";
    _findState     = TSFindStateIdle;
    _radarRings    = [NSMutableArray array];
    _isVibratingForPhone = NO;
}

/**
 * 构建视图层级（不使用父类 tableView）
 */
- (void)setupViews {
    // 雷达容器（需最先加入，位于按钮下方）
    [self.view addSubview:self.radarContainerView];
    [self buildRadarRings];
    [self.radarContainerView addSubview:self.radarCenterView];
    [self.radarCenterView addSubview:self.radarIconLabel];

    // 状态文案 & 操作按钮
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.actionButton];

    // 设备找手机遮罩（默认隐藏）
    [self.view addSubview:self.findPhoneOverlay];
    [self.findPhoneOverlay addSubview:self.findPhoneCard];
    [self buildPhoneRippleRings];
    [self.findPhoneCard addSubview:self.phoneRippleContainer];
    [self.phoneRippleContainer addSubview:self.phoneIconLabel];
    [self.findPhoneCard addSubview:self.findPhoneTitleLabel];
    [self.findPhoneCard addSubview:self.findPhoneSubtitleLabel];
    [self.findPhoneCard addSubview:self.foundPhoneButton];
}

/**
 * Frame 布局
 */
- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset = self.ts_navigationBarTotalHeight;
    if (topInset <= 0) topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, 24.f);
    CGFloat contentH = screenH - topInset - bottomInset;

    // 雷达容器：水平居中，位于内容区上半部分
    CGFloat radarDiam = kRadarMaxRadius * 2;
    CGFloat radarX    = (screenW - radarDiam) / 2.f;
    CGFloat radarY    = topInset + contentH * 0.1f;
    self.radarContainerView.frame = CGRectMake(radarX, radarY, radarDiam, radarDiam);

    // 雷达中心圆
    CGFloat centerX = (radarDiam - kRadarCenterSize) / 2.f;
    CGFloat centerY = (radarDiam - kRadarCenterSize) / 2.f;
    self.radarCenterView.frame       = CGRectMake(centerX, centerY, kRadarCenterSize, kRadarCenterSize);
    self.radarCenterView.layer.cornerRadius = kRadarCenterSize / 2.f;
    self.radarIconLabel.frame        = self.radarCenterView.bounds;

    // 扩散圆环（初始与中心同大小，在动画中扩散）
    for (UIView *ring in self.radarRings) {
        ring.frame  = CGRectMake(centerX, centerY, kRadarCenterSize, kRadarCenterSize);
        ring.layer.cornerRadius = kRadarCenterSize / 2.f;
    }

    // 状态文案：雷达容器下方 20pt
    CGFloat statusY = CGRectGetMaxY(self.radarContainerView.frame) + 20.f;
    self.statusLabel.frame = CGRectMake(40.f, statusY, screenW - 80.f, 24.f);

    // 操作按钮：底部 SafeArea 上方
    CGFloat btnX = (screenW - kActionBtnW) / 2.f;
    CGFloat btnY = screenH - bottomInset - kActionBtnH - 24.f;
    self.actionButton.frame = CGRectMake(btnX, btnY, kActionBtnW, kActionBtnH);
    self.actionButton.layer.cornerRadius = kActionBtnH / 2.f;

    // 设备找手机遮罩（全屏）
    self.findPhoneOverlay.frame = self.view.bounds;

    // 弹窗卡片：水平居中，垂直居中偏上一点
    CGFloat cardW = screenW - 60.f;
    CGFloat cardH = 340.f;
    CGFloat cardX = (screenW - cardW) / 2.f;
    CGFloat cardY = (screenH - cardH) / 2.f - 20.f;
    self.findPhoneCard.frame = CGRectMake(cardX, cardY, cardW, cardH);

    // 弹窗内波纹容器
    CGFloat rippleDiam = 120.f;
    CGFloat rippleX    = (cardW - rippleDiam) / 2.f;
    self.phoneRippleContainer.frame = CGRectMake(rippleX, 28.f, rippleDiam, rippleDiam);

    // 弹窗中心图标
    self.phoneIconLabel.frame = self.phoneRippleContainer.bounds;

    // 弹窗标题
    CGFloat titleY = CGRectGetMaxY(self.phoneRippleContainer.frame) + 20.f;
    self.findPhoneTitleLabel.frame = CGRectMake(16.f, titleY, cardW - 32.f, 26.f);

    // 弹窗副标题
    CGFloat subtitleY = CGRectGetMaxY(self.findPhoneTitleLabel.frame) + 8.f;
    self.findPhoneSubtitleLabel.frame = CGRectMake(16.f, subtitleY, cardW - 32.f, 36.f);

    // 弹窗按钮
    CGFloat foundBtnW = cardW - 48.f;
    CGFloat foundBtnH = 50.f;
    CGFloat foundBtnX = (cardW - foundBtnW) / 2.f;
    CGFloat foundBtnY = cardH - foundBtnH - 24.f;
    self.foundPhoneButton.frame = CGRectMake(foundBtnX, foundBtnY, foundBtnW, foundBtnH);
    self.foundPhoneButton.layer.cornerRadius = foundBtnH / 2.f;
}

#pragma mark - Build Subviews

/**
 * 创建雷达扩散圆环（添加到 radarContainerView，在中心视图下方）
 */
- (void)buildRadarRings {
    for (NSInteger i = 0; i < kRadarRingCount; i++) {
        UIView *ring          = [[UIView alloc] init];
        ring.backgroundColor  = [TSColor_Primary colorWithAlphaComponent:0.0f];
        ring.layer.borderColor = TSColor_Primary.CGColor;
        ring.layer.borderWidth = 1.5f;
        ring.clipsToBounds     = YES;
        [self.radarRings addObject:ring];
        [self.radarContainerView addSubview:ring];
    }
}

/**
 * 创建设备找手机弹窗中的波纹圆环
 */
- (void)buildPhoneRippleRings {
    for (NSInteger i = 0; i < kRadarRingCount; i++) {
        UIView *ring          = [[UIView alloc] init];
        ring.backgroundColor  = [TSColor_Warning colorWithAlphaComponent:0.0f];
        ring.layer.borderColor = TSColor_Warning.CGColor;
        ring.layer.borderWidth = 1.5f;
        ring.clipsToBounds     = YES;
        ring.tag               = 2000 + i;
        [self.phoneRippleContainer addSubview:ring];
    }
}

#pragma mark - Callbacks

/**
 * 注册 SDK 回调
 */
- (void)registerCallbacks {
    __weak typeof(self) weakSelf = self;

    // 设备被找到（手机查找设备时设备响应）
    [[[TopStepComKit sharedInstance] peripheralFind] registerPeripheralHasBeenFound:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            TSLog(@"设备已被找到");
            [weakSelf onPeripheralFound];
        });
    }];

    // 设备发起查找手机
    [[[TopStepComKit sharedInstance] peripheralFind] registerPeripheralFindPhone:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            TSLog(@"设备正在查找手机");
            [weakSelf showFindPhoneOverlay];
        });
    }];

    // 设备停止查找手机
    [[[TopStepComKit sharedInstance] peripheralFind] registerPeripheralStopFindPhone:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            TSLog(@"设备停止查找手机");
            [weakSelf hideFindPhoneOverlay:NO];
        });
    }];
}

#pragma mark - Actions

/**
 * 主操作按钮点击（查找设备 / 结束查找）
 */
- (void)actionButtonTapped {
    if (self.findState == TSFindStateIdle || self.findState == TSFindStateFound) {
        [self beginFindPeripheral];
    } else {
        [self stopFindPeripheral];
    }
}

/**
 * 弹窗「找到了」按钮点击
 */
- (void)foundPhoneButtonTapped {
    [self notifyPhoneFound];
}

#pragma mark - Network

/**
 * 开始查找设备
 */
- (void)beginFindPeripheral {
    [[[TopStepComKit sharedInstance] peripheralFind] beginFindPeripheral:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isSuccess || error) {
                TSLog(@"开始查找失败: %@", error.localizedDescription);
                [self showToastWithMessage:error.localizedDescription ?: @"指令发送失败" isSuccess:NO];
                return;
            }
            TSLog(@"开始查找设备成功");
        });
    }];
    [self transitionToState:TSFindStateScanning];
}

/**
 * 停止查找设备
 */
- (void)stopFindPeripheral {
    [[[TopStepComKit sharedInstance] peripheralFind] stopFindPeripheral:^(BOOL isSuccess, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TSLog(@"停止查找: success=%d error=%@", isSuccess, error.localizedDescription);
        });
    }];
    [self transitionToState:TSFindStateIdle];
}

/**
 * 告知设备手机已被找到，停止震动和铃声
 */
- (void)notifyPhoneFound {
    [[[TopStepComKit sharedInstance] peripheralFind] notifyPeripheralPhoneHasBeenFound:^(BOOL isSuccess, NSError *error) {
        TSLog(@"通知设备手机已找到: success=%d error=%@", isSuccess, error.localizedDescription);
    }];
    [self hideFindPhoneOverlay:YES];
}

#pragma mark - State Machine

/**
 * 切换查找状态，同步更新 UI 和动画
 */
- (void)transitionToState:(TSFindState)state {
    self.findState = state;

    switch (state) {
        case TSFindStateIdle:
            [self stopRadarAnimation];
            [self configActionButton:@"查找设备" filled:YES];
            self.statusLabel.text      = @"点击按钮开始查找设备";
            self.statusLabel.textColor = TSColor_TextSecondary;
            self.radarCenterView.backgroundColor = TSColor_Primary;
            break;

        case TSFindStateScanning:
            [self startRadarAnimation];
            [self configActionButton:@"结束查找" filled:NO];
            self.statusLabel.text      = @"查找中，设备将响铃或震动…";
            self.statusLabel.textColor = TSColor_Primary;
            self.radarCenterView.backgroundColor = TSColor_Primary;
            break;

        case TSFindStateFound:
            [self stopRadarAnimation];
            [self configActionButton:@"查找设备" filled:YES];
            self.statusLabel.text      = @"设备已找到 ✓";
            self.statusLabel.textColor = TSColor_Success;
            // 中心圆变绿，2 秒后恢复
            self.radarCenterView.backgroundColor = TSColor_Success;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.findState == TSFindStateFound) {
                    self.radarCenterView.backgroundColor = TSColor_Primary;
                    self.statusLabel.text      = @"点击按钮开始查找设备";
                    self.statusLabel.textColor = TSColor_TextSecondary;
                    self.findState = TSFindStateIdle;
                }
            });
            break;
    }
}

/**
 * 收到设备已被找到的回调
 */
- (void)onPeripheralFound {
    [self transitionToState:TSFindStateFound];
    [self showToastWithMessage:@"设备已找到" isSuccess:YES];
}

#pragma mark - Radar Animation

/**
 * 启动雷达扩散圆环动画（循环）
 */
- (void)startRadarAnimation {
    for (NSInteger i = 0; i < (NSInteger)self.radarRings.count; i++) {
        UIView *ring               = self.radarRings[i];
        CGFloat centerX            = kRadarMaxRadius - kRadarCenterSize / 2.f;
        CGFloat centerY            = kRadarMaxRadius - kRadarCenterSize / 2.f;
        ring.frame                 = CGRectMake(centerX, centerY, kRadarCenterSize, kRadarCenterSize);
        ring.layer.cornerRadius    = kRadarCenterSize / 2.f;
        ring.alpha                 = 1.0f;
        ring.layer.borderColor     = TSColor_Primary.CGColor;
        ring.backgroundColor       = [TSColor_Primary colorWithAlphaComponent:0.08f];
        [self animateRing:ring delay:i * kRingDelay];
    }
}

/**
 * 对单个圆环执行「从中心扩散 + 透明度渐出」循环动画
 */
- (void)animateRing:(UIView *)ring delay:(NSTimeInterval)delay {
    CGFloat finalDiam  = kRadarMaxRadius * 2;
    CGFloat finalX     = 0;
    CGFloat finalY     = 0;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self runRingLoopAnimation:ring finalFrame:CGRectMake(finalX, finalY, finalDiam, finalDiam) delay:delay];
    });
}

/**
 * 单个圆环的循环扩散动画（递归调用实现循环）
 */
- (void)runRingLoopAnimation:(UIView *)ring finalFrame:(CGRect)finalFrame delay:(NSTimeInterval)delay {
    if (self.findState != TSFindStateScanning) return;

    CGFloat initDiam = kRadarCenterSize;
    CGFloat initX    = kRadarMaxRadius - initDiam / 2.f;
    CGFloat initY    = kRadarMaxRadius - initDiam / 2.f;
    ring.frame               = CGRectMake(initX, initY, initDiam, initDiam);
    ring.layer.cornerRadius  = initDiam / 2.f;
    ring.alpha               = 0.8f;

    [UIView animateWithDuration:kRingDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        ring.frame              = finalFrame;
        ring.layer.cornerRadius = CGRectGetWidth(finalFrame) / 2.f;
        ring.alpha              = 0.0f;
    } completion:^(BOOL finished) {
        if (finished && self.findState == TSFindStateScanning) {
            [self runRingLoopAnimation:ring finalFrame:finalFrame delay:delay];
        }
    }];
}

/**
 * 停止雷达动画，恢复圆环初始状态
 */
- (void)stopRadarAnimation {
    for (UIView *ring in self.radarRings) {
        [ring.layer removeAllAnimations];
        CGFloat initDiam     = kRadarCenterSize;
        CGFloat initX        = kRadarMaxRadius - initDiam / 2.f;
        CGFloat initY        = kRadarMaxRadius - initDiam / 2.f;
        ring.frame           = CGRectMake(initX, initY, initDiam, initDiam);
        ring.layer.cornerRadius = initDiam / 2.f;
        ring.alpha           = 0.0f;
    }
}

#pragma mark - Find Phone Overlay

/**
 * 显示「设备找手机」全屏遮罩，启动波纹动画和震动
 */
- (void)showFindPhoneOverlay {
    self.findPhoneOverlay.hidden = NO;
    self.findPhoneOverlay.alpha  = 0.0f;

    [UIView animateWithDuration:0.3 animations:^{
        self.findPhoneOverlay.alpha = 1.0f;
    }];

    [self startPhoneRippleAnimation];
    [self startPhoneVibration];
}

/**
 * 隐藏「设备找手机」遮罩，停止波纹动画和震动
 *
 * @param showToast 是否显示「已告知设备」提示（用户主动点击时为 YES，设备主动停止时为 NO）
 */
- (void)hideFindPhoneOverlay:(BOOL)showToast {
    [self stopPhoneVibration];
    [self stopPhoneRippleAnimation];

    [UIView animateWithDuration:0.25 animations:^{
        self.findPhoneOverlay.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.findPhoneOverlay.hidden = YES;
    }];

    if (showToast) {
        [self showToastWithMessage:@"已告知设备，手机已被找到" isSuccess:YES];
    }
}

#pragma mark - Phone Ripple Animation

/**
 * 启动弹窗内波纹动画（橙色循环扩散）
 */
- (void)startPhoneRippleAnimation {
    CGFloat containerDiam = CGRectGetWidth(self.phoneRippleContainer.bounds);

    for (NSInteger i = 0; i < kRadarRingCount; i++) {
        UIView *ring = [self.phoneRippleContainer viewWithTag:2000 + i];
        CGFloat initD = containerDiam * 0.4f;
        CGFloat initX = (containerDiam - initD) / 2.f;
        ring.frame           = CGRectMake(initX, initX, initD, initD);
        ring.layer.cornerRadius = initD / 2.f;
        ring.alpha           = 0.0f;
        ring.layer.borderColor = TSColor_Warning.CGColor;
        ring.backgroundColor   = [TSColor_Warning colorWithAlphaComponent:0.08f];
        [self runPhoneRippleLoop:ring containerDiam:containerDiam delay:i * kRingDelay];
    }
}

/**
 * 单个波纹圆环的循环动画
 */
- (void)runPhoneRippleLoop:(UIView *)ring containerDiam:(CGFloat)containerDiam delay:(NSTimeInterval)delay {
    if (self.findPhoneOverlay.hidden) return;

    CGFloat initD = containerDiam * 0.4f;
    CGFloat initX = (containerDiam - initD) / 2.f;
    ring.frame            = CGRectMake(initX, initX, initD, initD);
    ring.layer.cornerRadius = initD / 2.f;
    ring.alpha            = 0.8f;

    [UIView animateWithDuration:kRingDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        ring.frame              = CGRectMake(0, 0, containerDiam, containerDiam);
        ring.layer.cornerRadius = containerDiam / 2.f;
        ring.alpha              = 0.0f;
    } completion:^(BOOL finished) {
        if (finished && !self.findPhoneOverlay.hidden) {
            [self runPhoneRippleLoop:ring containerDiam:containerDiam delay:delay];
        }
    }];
}

/**
 * 停止弹窗波纹动画
 */
- (void)stopPhoneRippleAnimation {
    for (NSInteger i = 0; i < kRadarRingCount; i++) {
        UIView *ring = [self.phoneRippleContainer viewWithTag:2000 + i];
        [ring.layer removeAllAnimations];
        ring.alpha = 0.0f;
    }
}

#pragma mark - Vibration

/**
 * 启动循环震动（约每 1.5 秒震动一次）
 */
- (void)startPhoneVibration {
    self.isVibratingForPhone = YES;
    [self vibrateOnce];
}

/**
 * 单次震动，如果仍在找手机状态则递归循环
 */
- (void)vibrateOnce {
    if (!self.isVibratingForPhone) return;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self vibrateOnce];
    });
}

/**
 * 停止震动
 */
- (void)stopPhoneVibration {
    self.isVibratingForPhone = NO;
}

#pragma mark - Button Helper

/**
 * 配置主操作按钮样式（填充 = 查找设备；轮廓 = 结束查找）
 */
- (void)configActionButton:(NSString *)title filled:(BOOL)filled {
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    if (filled) {
        self.actionButton.backgroundColor        = TSColor_Primary;
        self.actionButton.layer.borderWidth       = 0;
        [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.actionButton.backgroundColor        = [UIColor clearColor];
        self.actionButton.layer.borderColor       = TSColor_Primary.CGColor;
        self.actionButton.layer.borderWidth       = 1.5f;
        [self.actionButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    }
}

#pragma mark - Toast

/**
 * 底部 Toast 提示（1.5 秒自动消失）
 */
- (void)showToastWithMessage:(NSString *)message isSuccess:(BOOL)isSuccess {
    UIView *toast        = [[UIView alloc] init];
    UIColor *bgColor     = isSuccess
        ? [TSColor_Success colorWithAlphaComponent:0.92f]
        : [[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1.f] colorWithAlphaComponent:0.88f];
    toast.backgroundColor    = bgColor;
    toast.layer.cornerRadius = 10.f;
    toast.alpha              = 0;

    UILabel *label      = [[UILabel alloc] init];
    label.text          = message;
    label.textColor     = [UIColor whiteColor];
    label.font          = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW   = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize  size   = [label sizeThatFits:CGSizeMake(maxW - 32.f, CGFLOAT_MAX)];
    CGFloat toastW = MIN(size.width + 32.f, maxW);
    CGFloat toastH = size.height + 20.f;

    toast.frame = CGRectMake(
        (CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
        CGRectGetHeight(self.view.bounds) * 0.72f,
        toastW, toastH
    );
    label.frame = CGRectMake(16.f, 10.f, toastW - 32.f, size.height);

    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:0.25 animations:^{
        toast.alpha = 1.0f;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL fin) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - Lazy Properties

- (UIView *)radarContainerView {
    if (!_radarContainerView) {
        _radarContainerView              = [[UIView alloc] init];
        _radarContainerView.clipsToBounds = YES;
        _radarContainerView.backgroundColor = [UIColor clearColor];
    }
    return _radarContainerView;
}

- (UIView *)radarCenterView {
    if (!_radarCenterView) {
        _radarCenterView               = [[UIView alloc] init];
        _radarCenterView.backgroundColor = TSColor_Primary;
        _radarCenterView.clipsToBounds   = YES;
    }
    return _radarCenterView;
}

- (UILabel *)radarIconLabel {
    if (!_radarIconLabel) {
        _radarIconLabel               = [[UILabel alloc] init];
        _radarIconLabel.text          = @"⌚";
        _radarIconLabel.font          = [UIFont systemFontOfSize:28.f];
        _radarIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _radarIconLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton setTitle:@"查找设备" forState:UIControlStateNormal];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _actionButton.titleLabel.font     = TSFont_H2;
        _actionButton.backgroundColor     = TSColor_Primary;
        _actionButton.layer.cornerRadius  = kActionBtnH / 2.f;
        [_actionButton addTarget:self action:@selector(actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel               = [[UILabel alloc] init];
        _statusLabel.text          = @"点击按钮开始查找设备";
        _statusLabel.font          = TSFont_Body;
        _statusLabel.textColor     = TSColor_TextSecondary;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (UIView *)findPhoneOverlay {
    if (!_findPhoneOverlay) {
        _findPhoneOverlay              = [[UIView alloc] init];
        _findPhoneOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        _findPhoneOverlay.hidden       = YES;
    }
    return _findPhoneOverlay;
}

- (UIView *)findPhoneCard {
    if (!_findPhoneCard) {
        _findPhoneCard                    = [[UIView alloc] init];
        _findPhoneCard.backgroundColor    = TSColor_Card;
        _findPhoneCard.layer.cornerRadius = TSRadius_LG;
        _findPhoneCard.layer.shadowColor  = [UIColor blackColor].CGColor;
        _findPhoneCard.layer.shadowOpacity = 0.15f;
        _findPhoneCard.layer.shadowOffset = CGSizeMake(0, 4);
        _findPhoneCard.layer.shadowRadius = 12.f;
    }
    return _findPhoneCard;
}

- (UIView *)phoneRippleContainer {
    if (!_phoneRippleContainer) {
        _phoneRippleContainer              = [[UIView alloc] init];
        _phoneRippleContainer.clipsToBounds = YES;
        _phoneRippleContainer.backgroundColor = [UIColor clearColor];
    }
    return _phoneRippleContainer;
}

- (UILabel *)phoneIconLabel {
    if (!_phoneIconLabel) {
        _phoneIconLabel               = [[UILabel alloc] init];
        _phoneIconLabel.text          = @"📱";
        _phoneIconLabel.font          = [UIFont systemFontOfSize:36.f];
        _phoneIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _phoneIconLabel;
}

- (UILabel *)findPhoneTitleLabel {
    if (!_findPhoneTitleLabel) {
        _findPhoneTitleLabel               = [[UILabel alloc] init];
        _findPhoneTitleLabel.text          = @"设备正在找手机";
        _findPhoneTitleLabel.font          = TSFont_H2;
        _findPhoneTitleLabel.textColor     = TSColor_TextPrimary;
        _findPhoneTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _findPhoneTitleLabel;
}

- (UILabel *)findPhoneSubtitleLabel {
    if (!_findPhoneSubtitleLabel) {
        _findPhoneSubtitleLabel               = [[UILabel alloc] init];
        _findPhoneSubtitleLabel.text          = @"请稍作移动，找到手机后\n点击下方按钮告知设备";
        _findPhoneSubtitleLabel.font          = TSFont_Body;
        _findPhoneSubtitleLabel.textColor     = TSColor_TextSecondary;
        _findPhoneSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        _findPhoneSubtitleLabel.numberOfLines = 0;
    }
    return _findPhoneSubtitleLabel;
}

- (UIButton *)foundPhoneButton {
    if (!_foundPhoneButton) {
        _foundPhoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_foundPhoneButton setTitle:@"找到了" forState:UIControlStateNormal];
        [_foundPhoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _foundPhoneButton.titleLabel.font    = TSFont_H2;
        _foundPhoneButton.backgroundColor    = TSColor_Success;
        _foundPhoneButton.layer.cornerRadius = 25.f;
        [_foundPhoneButton addTarget:self action:@selector(foundPhoneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _foundPhoneButton;
}

@end
