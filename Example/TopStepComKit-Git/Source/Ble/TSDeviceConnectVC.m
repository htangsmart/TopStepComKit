//
//  TSDeviceConnectVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSDeviceConnectVC.h"
#import <QuartzCore/QuartzCore.h>
#import <TopStepComKit/TopStepComKit.h>

typedef NS_ENUM(NSInteger, TSConnectionState) {
    TSConnectionStateConnecting = 0,
    TSConnectionStateSuccess,
    TSConnectionStateFailure,
};

@interface TSDeviceConnectVC ()

/** 设备图标 */
@property (nonatomic, strong) UIImageView *deviceIconView;

/** 脉冲环容器 */
@property (nonatomic, strong) UIView *pulseContainer;

/** 内圈 */
@property (nonatomic, strong) UIView *innerCircle;

/** 中圈 */
@property (nonatomic, strong) UIView *middleCircle;

/** 外圈 */
@property (nonatomic, strong) UIView *outerCircle;

/** 设备名称标签 */
@property (nonatomic, strong) UILabel *deviceNameLabel;

/** 状态文字标签 */
@property (nonatomic, strong) UILabel *statusLabel;

/** 操作按钮 */
@property (nonatomic, strong) UIButton *actionButton;

/** 结果图标（成功/失败） */
@property (nonatomic, strong) UIImageView *resultIconView;

/** 当前连接状态 */
@property (nonatomic, assign) TSConnectionState connectionState;

/** 是否正在连接中 */
@property (nonatomic, assign) BOOL isConnecting;

@end

@implementation TSDeviceConnectVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self startConnectingAnimation];
    [self startBleConnection];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAnimation];
}

- (void)dealloc {
    [self stopAnimation];
}

#pragma mark - UI 设置

/** 设置界面 */
- (void)setupUI {
    self.title = @"连接设备";
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.pulseContainer];
    [self.pulseContainer addSubview:self.outerCircle];
    [self.pulseContainer addSubview:self.middleCircle];
    [self.pulseContainer addSubview:self.innerCircle];
    [self.pulseContainer addSubview:self.deviceIconView];

    [self.view addSubview:self.resultIconView];
    [self.view addSubview:self.deviceNameLabel];
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.actionButton];

    [self layoutViews];
    [self updateUIForState:TSConnectionStateConnecting];
}

/** 布局视图 */
- (void)layoutViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat centerY = 200;

    self.pulseContainer.frame = CGRectMake((screenWidth - 200) / 2, centerY - 100, 200, 200);

    CGFloat circleSize = 120;
    self.innerCircle.frame = CGRectMake((200 - circleSize) / 2, (200 - circleSize) / 2, circleSize, circleSize);
    self.innerCircle.layer.cornerRadius = circleSize / 2;

    self.middleCircle.frame = self.innerCircle.frame;
    self.middleCircle.layer.cornerRadius = circleSize / 2;

    self.outerCircle.frame = self.innerCircle.frame;
    self.outerCircle.layer.cornerRadius = circleSize / 2;

    CGFloat iconSize = 60;
    self.deviceIconView.frame = CGRectMake((200 - iconSize) / 2, (200 - iconSize) / 2, iconSize, iconSize);

    // resultIconView 位置应该和 pulseContainer 中心对齐
    CGFloat resultX = (screenWidth - iconSize) / 2;
    CGFloat resultY = centerY - 100 + (200 - iconSize) / 2;
    self.resultIconView.frame = CGRectMake(resultX, resultY, iconSize, iconSize);

    self.deviceNameLabel.frame = CGRectMake(20, centerY + 120, screenWidth - 40, 30);
    self.statusLabel.frame = CGRectMake(20, CGRectGetMaxY(self.deviceNameLabel.frame) + 10, screenWidth - 40, 25);

    self.actionButton.frame = CGRectMake((screenWidth - 200) / 2, CGRectGetMaxY(self.statusLabel.frame) + 60, 200, 44);
}

#pragma mark - 动画控制

/** 开始连接动画 */
- (void)startConnectingAnimation {
    [self stopAnimation];

    [self addPulseAnimationToLayer:self.innerCircle.layer delay:0 duration:2.0 scale:1.5];
    [self addPulseAnimationToLayer:self.middleCircle.layer delay:0.4 duration:2.0 scale:1.8];
    [self addPulseAnimationToLayer:self.outerCircle.layer delay:0.8 duration:2.0 scale:2.1];
}

/** 停止动画 */
- (void)stopAnimation {
    [self.innerCircle.layer removeAllAnimations];
    [self.middleCircle.layer removeAllAnimations];
    [self.outerCircle.layer removeAllAnimations];
}

/** 添加脉冲动画到图层 */
- (void)addPulseAnimationToLayer:(CALayer *)layer delay:(CFTimeInterval)delay duration:(CFTimeInterval)duration scale:(CGFloat)scale {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(scale);

    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(0.6);
    opacityAnimation.toValue = @(0.0);

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[scaleAnimation, opacityAnimation];
    group.duration = duration;
    group.repeatCount = HUGE_VALF;
    group.beginTime = CACurrentMediaTime() + delay;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [layer addAnimation:group forKey:@"pulse"];
}

#pragma mark - 状态更新

/** 更新界面状态 */
- (void)updateUIForState:(TSConnectionState)state {
    self.connectionState = state;

    switch (state) {
        case TSConnectionStateConnecting: {
            self.statusLabel.text = @"正在连接中...";
            self.statusLabel.textColor = [UIColor grayColor];
            [self.actionButton setTitle:@"取消连接" forState:UIControlStateNormal];
            self.actionButton.backgroundColor = [UIColor lightGrayColor];
            self.resultIconView.hidden = YES;
            self.deviceIconView.hidden = NO;
            self.pulseContainer.hidden = NO;
            break;
        }

        case TSConnectionStateSuccess: {
            [self stopAnimation];
            self.statusLabel.text = @"连接成功";
            self.statusLabel.textColor = [UIColor systemGreenColor];
            self.actionButton.hidden = YES;
            self.resultIconView.hidden = NO;
            self.deviceIconView.hidden = YES;
            self.pulseContainer.hidden = YES;
            self.resultIconView.image = [self createCheckmarkImage];

            // 播放成功动画
            [self playSuccessAnimation];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.onConnectSuccess) {
                    self.onConnectSuccess();
                }
                [self.navigationController popViewControllerAnimated:YES];
            });
            break;
        }

        case TSConnectionStateFailure: {
            [self stopAnimation];
            self.statusLabel.text = @"连接失败，请重试";
            self.statusLabel.textColor = [UIColor systemRedColor];
            [self.actionButton setTitle:@"重新连接" forState:UIControlStateNormal];
            self.actionButton.backgroundColor = [UIColor systemBlueColor];
            self.actionButton.hidden = NO;
            self.resultIconView.hidden = NO;
            self.deviceIconView.hidden = YES;
            self.pulseContainer.hidden = YES;
            self.resultIconView.image = [self createCrossImage];

            // 播放失败动画
            [self playFailureAnimation];
            break;
        }
    }
}

#pragma mark - 蓝牙连接

/** 开始蓝牙连接 */
- (void)startBleConnection {
    if (!self.peripheral) {
        NSLog(@"[TSDeviceConnectVC] 错误：peripheral 为空");
        NSError *error = [NSError errorWithDomain:@"TSDeviceConnectVC"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"设备对象为空"}];
        [self handleConnectionFailure:error];
        return;
    }

    self.isConnecting = YES;

    // 创建连接参数
    TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc] initWithUserId:@"demo_user_001"];// 使用默认用户ID，实际项目中应从用户系统获取

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] bleConnector] connectWithPeripheral:(TSPeripheral *)self.peripheral
                                                                    param:param
                                                               completion:^(TSBleConnectionState connectionState, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (connectionState == eTSBleStateConnected) {
                // 连接成功
                strongSelf.isConnecting = NO;
                [strongSelf handleConnectionSuccess];
            } else if (connectionState == eTSBleStateDisconnected && error) {
                // 连接失败
                strongSelf.isConnecting = NO;
                [strongSelf handleConnectionFailure:error];
            }
            // 其他中间状态（Connecting、Authenticating、PreparingData）不处理，继续等待
        });
    }];
}

/** 处理连接成功 */
- (void)handleConnectionSuccess {
    [self updateUIForState:TSConnectionStateSuccess];

    // 保存 MAC 和 userId 到 UserDefaults，供自动重连使用
    if (self.peripheral && self.peripheral.systemInfo.mac) {
        [[NSUserDefaults standardUserDefaults] setObject:self.peripheral.systemInfo.mac forKey:@"kCurrentMac"];
        [[NSUserDefaults standardUserDefaults] setObject:@"demo_user_001" forKey:@"kUserId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // 触发成功回调
    if (self.onConnectSuccess) {
        self.onConnectSuccess();
    }
}

/** 处理连接失败 */
- (void)handleConnectionFailure:(NSError *)error {
    [self updateUIForState:TSConnectionStateFailure];

    if (self.onConnectFailure) {
        self.onConnectFailure(error);
    }
}

/** 取消连接 */
- (void)cancelConnection {
    if (self.isConnecting) {
        [[[TopStepComKit sharedInstance] bleConnector] disconnectCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
            
        }];
        self.isConnecting = NO;
    }
}

#pragma mark - 公开方法

/** 模拟连接成功（供外部调用） */
- (void)simulateConnectSuccess {
    [self updateUIForState:TSConnectionStateSuccess];
}

/** 模拟连接失败（供外部调用） */
- (void)simulateConnectFailure {
    [self updateUIForState:TSConnectionStateFailure];
}

#pragma mark - 事件处理

/** 按钮点击 */
- (void)onActionButtonTapped {
    if (self.connectionState == TSConnectionStateConnecting) {
        [self cancelConnection];
        if (self.onCancel) {
            self.onCancel();
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.connectionState == TSConnectionStateFailure) {
        [self updateUIForState:TSConnectionStateConnecting];
        [self startConnectingAnimation];
        [self startBleConnection];
    }
}

#pragma mark - 辅助方法

/** 播放成功动画 */
- (void)playSuccessAnimation {
    // 1. 绿色圆圈背景从小到大弹出（0.3s，带回弹效果）
    UIView *greenCircle = [[UIView alloc] initWithFrame:self.resultIconView.frame];
    greenCircle.backgroundColor = [UIColor systemGreenColor];
    greenCircle.layer.cornerRadius = 30;
    greenCircle.alpha = 0;
    [self.view insertSubview:greenCircle belowSubview:self.resultIconView];

    // 初始缩放为 0.5
    greenCircle.transform = CGAffineTransformMakeScale(0.5, 0.5);

    // 圆圈弹出动画
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        greenCircle.alpha = 1.0;
        greenCircle.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        // 2. 对勾图标渐显（0.3s，延迟0.2s）
        self.resultIconView.alpha = 0;
        [UIView animateWithDuration:0.3
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            self.resultIconView.alpha = 1.0;
        } completion:^(BOOL finished) {
            // 3. 文字淡入
            self.statusLabel.alpha = 0;
            [UIView animateWithDuration:0.3
                                  delay:0.1
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                self.statusLabel.alpha = 1.0;
            } completion:nil];
        }];
    }];
}

/** 播放失败动画 */
- (void)playFailureAnimation {
    // 1. 红色圆圈背景从小到大弹出（0.3s，带回弹效果）
    UIView *redCircle = [[UIView alloc] initWithFrame:self.resultIconView.frame];
    redCircle.backgroundColor = [UIColor systemRedColor];
    redCircle.layer.cornerRadius = 30;
    redCircle.alpha = 0;
    [self.view insertSubview:redCircle belowSubview:self.resultIconView];

    // 初始缩放为 0.5
    redCircle.transform = CGAffineTransformMakeScale(0.5, 0.5);

    // 圆圈弹出动画
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        redCircle.alpha = 1.0;
        redCircle.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        // 2. 叉号图标渐显（0.3s，延迟0.2s）
        self.resultIconView.alpha = 0;
        [UIView animateWithDuration:0.3
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            self.resultIconView.alpha = 1.0;
        } completion:^(BOOL finished) {
            // 3. 抖动动画（0.2s，延迟0.4s）
            [self shakeView:redCircle];
            [self shakeView:self.resultIconView];

            // 4. 文字淡入
            self.statusLabel.alpha = 0;
            [UIView animateWithDuration:0.3
                                  delay:0.6
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                self.statusLabel.alpha = 1.0;
            } completion:nil];
        }];
    }];
}

/** 抖动动画 */
- (void)shakeView:(UIView *)view {
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.values = @[@0, @-10, @10, @-5, @5, @0];
    shake.keyTimes = @[@0, @0.2, @0.4, @0.6, @0.8, @1.0];
    shake.duration = 0.4;
    shake.beginTime = CACurrentMediaTime() + 0.4;
    [view.layer addAnimation:shake forKey:@"shake"];
}

/** 创建对勾图标 */
- (UIImage *)createCheckmarkImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(60, 60), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 4);
    CGContextSetLineCap(context, kCGLineCapRound);

    CGContextMoveToPoint(context, 15, 30);
    CGContextAddLineToPoint(context, 25, 40);
    CGContextAddLineToPoint(context, 45, 20);
    CGContextStrokePath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

/** 创建叉号图标 */
- (UIImage *)createCrossImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(60, 60), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 4);
    CGContextSetLineCap(context, kCGLineCapRound);

    CGContextMoveToPoint(context, 20, 20);
    CGContextAddLineToPoint(context, 40, 40);
    CGContextMoveToPoint(context, 40, 20);
    CGContextAddLineToPoint(context, 20, 40);
    CGContextStrokePath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - 懒加载

- (UIView *)pulseContainer {
    if (!_pulseContainer) {
        _pulseContainer = [[UIView alloc] init];
        _pulseContainer.backgroundColor = [UIColor clearColor];
    }
    return _pulseContainer;
}

- (UIView *)innerCircle {
    if (!_innerCircle) {
        _innerCircle = [[UIView alloc] init];
        _innerCircle.backgroundColor = [UIColor clearColor];
        _innerCircle.layer.borderWidth = 2;
        _innerCircle.layer.borderColor = [UIColor systemBlueColor].CGColor;
    }
    return _innerCircle;
}

- (UIView *)middleCircle {
    if (!_middleCircle) {
        _middleCircle = [[UIView alloc] init];
        _middleCircle.backgroundColor = [UIColor clearColor];
        _middleCircle.layer.borderWidth = 2;
        _middleCircle.layer.borderColor = [UIColor systemBlueColor].CGColor;
    }
    return _middleCircle;
}

- (UIView *)outerCircle {
    if (!_outerCircle) {
        _outerCircle = [[UIView alloc] init];
        _outerCircle.backgroundColor = [UIColor clearColor];
        _outerCircle.layer.borderWidth = 2;
        _outerCircle.layer.borderColor = [UIColor systemBlueColor].CGColor;
    }
    return _outerCircle;
}

- (UIImageView *)deviceIconView {
    if (!_deviceIconView) {
        _deviceIconView = [[UIImageView alloc] init];
        _deviceIconView.contentMode = UIViewContentModeScaleAspectFit;

        UIImage *icon = nil;
        if (@available(iOS 13.0, *)) {
            icon = [UIImage systemImageNamed:@"applewatch"];
            if (!icon) {
                icon = [UIImage systemImageNamed:@"antenna.radiowaves.left.and.right"];
            }
        }

        if (!icon) {
            icon = [self createPlaceholderDeviceIcon];
        }

        _deviceIconView.image = icon;
        _deviceIconView.tintColor = [UIColor systemBlueColor];
    }
    return _deviceIconView;
}

- (UIImageView *)resultIconView {
    if (!_resultIconView) {
        _resultIconView = [[UIImageView alloc] init];
        _resultIconView.contentMode = UIViewContentModeCenter;
        _resultIconView.hidden = YES;
    }
    return _resultIconView;
}

- (UILabel *)deviceNameLabel {
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textAlignment = NSTextAlignmentCenter;
        _deviceNameLabel.font = [UIFont boldSystemFontOfSize:20];
        _deviceNameLabel.textColor = [UIColor blackColor];
        _deviceNameLabel.text = self.deviceName ?: @"未知设备";
    }
    return _deviceNameLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont systemFontOfSize:16];
        _statusLabel.textColor = [UIColor grayColor];
    }
    return _statusLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.layer.cornerRadius = 22;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(onActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

/** 创建占位设备图标 */
- (UIImage *)createPlaceholderDeviceIcon {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(60, 60), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [[UIColor systemBlueColor] setFill];
    CGContextFillEllipseInRect(context, CGRectMake(10, 10, 40, 40));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
