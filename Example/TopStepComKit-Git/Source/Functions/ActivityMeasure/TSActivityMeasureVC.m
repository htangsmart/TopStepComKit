//
//  TSActivityMeasureVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/6.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSActivityMeasureVC.h"
#import <TopStepComKit/TopStepComKit.h>

// ─── Design System ─────────────────────────────────────────────────────────
#define TSColor_Background      [UIColor colorWithRed:242/255.f green:242/255.f blue:247/255.f alpha:1.f]
#define TSColor_Card            [UIColor whiteColor]
#define TSColor_Primary         [UIColor colorWithRed:74/255.f green:144/255.f blue:226/255.f alpha:1.f]
#define TSColor_TextPrimary     [UIColor colorWithRed:28/255.f  green:28/255.f  blue:30/255.f  alpha:1.f]
#define TSColor_TextSecondary   [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f]
#define TSColor_Success         [UIColor colorWithRed:52/255.f  green:199/255.f blue:89/255.f  alpha:1.f]
#define TSColor_Danger          [UIColor colorWithRed:255/255.f green:59/255.f  blue:48/255.f  alpha:1.f]
#define TSColor_HeartRate       [UIColor colorWithRed:255/255.f green:59/255.f  blue:48/255.f  alpha:1.f]
#define TSColor_BloodOxygen     [UIColor colorWithRed:0/255.f   green:122/255.f blue:255/255.f alpha:1.f]
#define TSColor_Stress          [UIColor colorWithRed:175/255.f green:82/255.f  blue:222/255.f alpha:1.f]

#define TSSpacing_MD    16.f
#define TSRadius_MD     12.f
#define TSFont_H1       [UIFont systemFontOfSize:20.f weight:UIFontWeightBold]
#define TSFont_H2       [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold]
#define TSFont_Body     [UIFont systemFontOfSize:15.f weight:UIFontWeightRegular]
#define TSFont_Caption  [UIFont systemFontOfSize:13.f weight:UIFontWeightRegular]
#define TSFont_Large    [UIFont systemFontOfSize:48.f weight:UIFontWeightBold]

// ─── Constants ─────────────────────────────────────────────────────────────
static const CGFloat kCircleSize = 200.f;
static const CGFloat kCountdownRingWidth = 12.f;
static const CGFloat kInnerCircleRadius = 80.f;

// ─── Measurement State ─────────────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSMeasureState) {
    TSMeasureStateIdle,         // 待测量
    TSMeasureStateMeasuring,    // 测量中
    TSMeasureStateCompleted     // 已完成
};

// ─── Local Measurement Type ───────────────────────────────────────────────
typedef NS_ENUM(NSInteger, TSLocalMeasureType) {
    TSLocalMeasureTypeHeartRate = 0,     // 心率
    TSLocalMeasureTypeBloodOxygen,       // 血氧
    TSLocalMeasureTypeStress             // 压力
};

@interface TSActivityMeasureVC ()

// 状态
@property (nonatomic, assign) TSMeasureState currentState;      // 当前状态
@property (nonatomic, assign) TSLocalMeasureType selectedType;  // 选中的测量类型
@property (nonatomic, assign) NSInteger currentValue;           // 当前测量值
@property (nonatomic, assign) NSInteger elapsedTime;            // 已测量时间
@property (nonatomic, strong) NSTimer *measureTimer;            // 测量计时器

// UI组件
@property (nonatomic, strong) UIScrollView *scrollView;         // 滚动容器
@property (nonatomic, strong) UIView *contentView;              // 内容容器
@property (nonatomic, strong) UIView *tabBar;                   // Tab切换栏
@property (nonatomic, strong) NSMutableArray<UIButton *> *tabButtons;  // Tab按钮数组
@property (nonatomic, strong) UIView *tabIndicator;             // Tab指示器

// 参数配置
@property (nonatomic, strong) UIView *paramCard;                // 参数卡片
@property (nonatomic, strong) UISlider *durationSlider;         // 时长滑块
@property (nonatomic, strong) UILabel *durationLabel;           // 时长标签
@property (nonatomic, strong) UISlider *intervalSlider;         // 间隔滑块
@property (nonatomic, strong) UILabel *intervalLabel;           // 间隔标签

// 测量区域
@property (nonatomic, strong) UIView *measureCard;              // 测量卡片
@property (nonatomic, strong) UIView *circleContainer;          // 圆形容器
@property (nonatomic, strong) CAShapeLayer *countdownRing;      // 外圈：倒计时环
@property (nonatomic, strong) CAShapeLayer *innerCircleLayer;   // 内圈：呼吸动画层
@property (nonatomic, strong) UILabel *valueLabel;              // 数值标签
@property (nonatomic, strong) UILabel *unitLabel;               // 单位标签
@property (nonatomic, strong) UILabel *statusLabel;             // 状态标签
@property (nonatomic, strong) UIImageView *checkmarkIcon;       // 完成图标

// 结果区域
@property (nonatomic, strong) UIView *resultCard;               // 结果卡片
@property (nonatomic, strong) UILabel *resultValueLabel;        // 结果数值
@property (nonatomic, strong) UILabel *resultStatusLabel;       // 结果状态
@property (nonatomic, strong) UILabel *resultTimeLabel;         // 测量时长

// 操作按钮
@property (nonatomic, strong) UIButton *actionButton;           // 操作按钮

@end

@implementation TSActivityMeasureVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主动测量";
    self.view.backgroundColor = TSColor_Background;
    
    [self initData];
    [self setupViews];
    [self layoutViews];
}

- (void)dealloc {
    [self stopMeasureTimer];
}

#pragma mark - Init Data

- (void)initData {
    _currentState = TSMeasureStateIdle;
    _selectedType = TSLocalMeasureTypeHeartRate;
    _currentValue = 0;
    _elapsedTime = 0;
    _tabButtons = [NSMutableArray array];
}

#pragma mark - Setup Views

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    
    // Tab切换栏
    [self setupTabBar];
    
    // 参数配置卡片
    [self setupParamCard];
    
    // 测量区域
    [self setupMeasureCard];
    
    // 结果区域
    [self setupResultCard];
    
    // 操作按钮
    [self.view addSubview:self.actionButton];
    
    // 初始状态
    [self updateUIForState:TSMeasureStateIdle];
}

- (void)setupTabBar {
    _tabBar = [[UIView alloc] init];
    _tabBar.backgroundColor = TSColor_Card;
    [_contentView addSubview:_tabBar];
    
    NSArray *titles = @[@"💓 心率", @"🫁 血氧", @"😰 压力"];
    CGFloat btnWidth = (self.view.bounds.size.width - TSSpacing_MD * 2) / 3;
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(i * btnWidth, 0, btnWidth, 44);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = TSFont_Body;
        btn.tag = i;
        [btn addTarget:self action:@selector(onTabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_tabBar addSubview:btn];
        [_tabButtons addObject:btn];
    }
    
    _tabIndicator = [[UIView alloc] init];
    _tabIndicator.backgroundColor = TSColor_HeartRate;
    _tabIndicator.frame = CGRectMake(0, 42, btnWidth, 2);
    [_tabBar addSubview:_tabIndicator];
    
    [self updateTabColors];
}

- (void)setupParamCard {
    _paramCard = [self createCardView];
    [_contentView addSubview:_paramCard];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"⚙️ 测量参数";
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.frame = CGRectMake(TSSpacing_MD, 12, 200, 24);
    [_paramCard addSubview:titleLabel];
    
    CGFloat yOffset = 48;
    CGFloat width = self.view.bounds.size.width - TSSpacing_MD * 2;
    
    // 最大时长
    UILabel *durationTitle = [self createLabel:@"最大时长"];
    durationTitle.frame = CGRectMake(TSSpacing_MD, yOffset, 80, 20);
    [_paramCard addSubview:durationTitle];
    
    _durationSlider = [[UISlider alloc] init];
    _durationSlider.frame = CGRectMake(TSSpacing_MD + 90, yOffset, width - 90 - TSSpacing_MD * 2 - 70, 20);
    _durationSlider.minimumValue = 10;
    _durationSlider.maximumValue = 300;
    _durationSlider.value = 60;
    _durationSlider.tintColor = TSColor_Primary;
    [_durationSlider addTarget:self action:@selector(onDurationChanged:) forControlEvents:UIControlEventValueChanged];
    [_paramCard addSubview:_durationSlider];
    
    _durationLabel = [[UILabel alloc] init];
    _durationLabel.frame = CGRectMake(width - 60, yOffset, 60, 20);
    _durationLabel.text = @"60秒";
    _durationLabel.font = TSFont_Body;
    _durationLabel.textColor = TSColor_Primary;
    _durationLabel.textAlignment = NSTextAlignmentRight;
    [_paramCard addSubview:_durationLabel];
    
    yOffset += 40;
    
    // 测量间隔
    UILabel *intervalTitle = [self createLabel:@"测量间隔"];
    intervalTitle.frame = CGRectMake(TSSpacing_MD, yOffset, 80, 20);
    [_paramCard addSubview:intervalTitle];
    
    _intervalSlider = [[UISlider alloc] init];
    _intervalSlider.frame = CGRectMake(TSSpacing_MD + 90, yOffset, width - 90 - TSSpacing_MD * 2 - 70, 20);
    _intervalSlider.minimumValue = 1;
    _intervalSlider.maximumValue = 10;
    _intervalSlider.value = 5;
    _intervalSlider.tintColor = TSColor_Primary;
    [_intervalSlider addTarget:self action:@selector(onIntervalChanged:) forControlEvents:UIControlEventValueChanged];
    [_paramCard addSubview:_intervalSlider];
    
    _intervalLabel = [[UILabel alloc] init];
    _intervalLabel.frame = CGRectMake(width - 60, yOffset, 60, 20);
    _intervalLabel.text = @"5秒";
    _intervalLabel.font = TSFont_Body;
    _intervalLabel.textColor = TSColor_Primary;
    _intervalLabel.textAlignment = NSTextAlignmentRight;
    [_paramCard addSubview:_intervalLabel];
}

- (void)setupMeasureCard {
    _measureCard = [self createCardView];
    [_contentView addSubview:_measureCard];

    // 圆形容器
    _circleContainer = [[UIView alloc] init];
    _circleContainer.frame = CGRectMake((self.view.bounds.size.width - TSSpacing_MD * 2 - kCircleSize) / 2, 40, kCircleSize, kCircleSize);
    [_measureCard addSubview:_circleContainer];

    // 外圈：倒计时环
    UIBezierPath *countdownPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kCircleSize/2, kCircleSize/2)
                                                                  radius:(kCircleSize - kCountdownRingWidth) / 2
                                                              startAngle:-M_PI_2
                                                                endAngle:M_PI_2 * 3
                                                               clockwise:YES];

    _countdownRing = [CAShapeLayer layer];
    _countdownRing.path = countdownPath.CGPath;
    _countdownRing.fillColor = [UIColor clearColor].CGColor;
    _countdownRing.strokeColor = TSColor_Success.CGColor;
    _countdownRing.lineWidth = kCountdownRingWidth;
    _countdownRing.lineCap = kCALineCapRound;
    _countdownRing.strokeStart = 0.0;
    _countdownRing.strokeEnd = 1.0;
    [_circleContainer.layer addSublayer:_countdownRing];

    // 内圈：呼吸动画层
    _innerCircleLayer = [CAShapeLayer layer];
    _innerCircleLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kCircleSize/2, kCircleSize/2)
                                                            radius:kInnerCircleRadius
                                                        startAngle:0
                                                          endAngle:M_PI * 2
                                                         clockwise:YES].CGPath;
    _innerCircleLayer.fillColor = [TSColor_HeartRate colorWithAlphaComponent:0.15].CGColor;
    _innerCircleLayer.strokeColor = [UIColor clearColor].CGColor;
    [_circleContainer.layer addSublayer:_innerCircleLayer];

    // 数值标签
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.frame = CGRectMake(0, kCircleSize/2 - 30, kCircleSize, 50);
    _valueLabel.text = @"--";
    _valueLabel.font = TSFont_Large;
    _valueLabel.textColor = TSColor_TextPrimary;
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    [_circleContainer addSubview:_valueLabel];

    // 单位标签
    _unitLabel = [[UILabel alloc] init];
    _unitLabel.frame = CGRectMake(0, kCircleSize/2 + 20, kCircleSize, 20);
    _unitLabel.text = @"BPM";
    _unitLabel.font = TSFont_Body;
    _unitLabel.textColor = TSColor_TextSecondary;
    _unitLabel.textAlignment = NSTextAlignmentCenter;
    [_circleContainer addSubview:_unitLabel];

    // 完成图标（初始隐藏）
    _checkmarkIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
    _checkmarkIcon.tintColor = TSColor_Success;
    _checkmarkIcon.frame = CGRectMake(kCircleSize/2 - 30, 20, 60, 60);
    _checkmarkIcon.alpha = 0;
    [_circleContainer addSubview:_checkmarkIcon];

    // 状态标签
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(TSSpacing_MD, kCircleSize + 60, self.view.bounds.size.width - TSSpacing_MD * 4, 30);
    _statusLabel.text = @"准备开始测量";
    _statusLabel.font = TSFont_Body;
    _statusLabel.textColor = TSColor_TextSecondary;
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [_measureCard addSubview:_statusLabel];
}

- (void)setupResultCard {
    _resultCard = [self createCardView];
    _resultCard.hidden = YES;
    [_contentView addSubview:_resultCard];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"✅ 测量完成";
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_Success;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(TSSpacing_MD, 20, self.view.bounds.size.width - TSSpacing_MD * 4, 30);
    [_resultCard addSubview:titleLabel];
    
    _resultValueLabel = [[UILabel alloc] init];
    _resultValueLabel.frame = CGRectMake(TSSpacing_MD, 70, self.view.bounds.size.width - TSSpacing_MD * 4, 60);
    _resultValueLabel.text = @"💓 85 BPM";
    _resultValueLabel.font = [UIFont systemFontOfSize:36 weight:UIFontWeightBold];
    _resultValueLabel.textColor = TSColor_TextPrimary;
    _resultValueLabel.textAlignment = NSTextAlignmentCenter;
    [_resultCard addSubview:_resultValueLabel];
    
    _resultStatusLabel = [[UILabel alloc] init];
    _resultStatusLabel.frame = CGRectMake(TSSpacing_MD, 140, self.view.bounds.size.width - TSSpacing_MD * 4, 30);
    _resultStatusLabel.text = @"正常";
    _resultStatusLabel.font = TSFont_H1;
    _resultStatusLabel.textColor = TSColor_Success;
    _resultStatusLabel.textAlignment = NSTextAlignmentCenter;
    [_resultCard addSubview:_resultStatusLabel];
    
    _resultTimeLabel = [[UILabel alloc] init];
    _resultTimeLabel.frame = CGRectMake(TSSpacing_MD, 190, self.view.bounds.size.width - TSSpacing_MD * 4, 40);
    _resultTimeLabel.text = @"测量时长: 60秒\n完成时间: 14:30";
    _resultTimeLabel.font = TSFont_Caption;
    _resultTimeLabel.textColor = TSColor_TextSecondary;
    _resultTimeLabel.textAlignment = NSTextAlignmentCenter;
    _resultTimeLabel.numberOfLines = 2;
    [_resultCard addSubview:_resultTimeLabel];
}

#pragma mark - Layout

- (void)layoutViews {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    _scrollView.frame = CGRectMake(0, 0, width, height - 80);
    
    CGFloat yOffset = TSSpacing_MD;
    
    // Tab栏
    _tabBar.frame = CGRectMake(TSSpacing_MD, yOffset, width - TSSpacing_MD * 2, 44);
    yOffset += 44 + TSSpacing_MD;
    
    // 参数卡片
    _paramCard.frame = CGRectMake(TSSpacing_MD, yOffset, width - TSSpacing_MD * 2, 140);
    yOffset += 140 + TSSpacing_MD;
    
    // 测量卡片
    _measureCard.frame = CGRectMake(TSSpacing_MD, yOffset, width - TSSpacing_MD * 2, 340);
    yOffset += 340 + TSSpacing_MD;
    
    // 结果卡片
    _resultCard.frame = CGRectMake(TSSpacing_MD, yOffset, width - TSSpacing_MD * 2, 200);
    yOffset += 200 + TSSpacing_MD;
    
    _contentView.frame = CGRectMake(0, 0, width, yOffset);
    _scrollView.contentSize = CGSizeMake(width, yOffset);
    
    // 操作按钮
    _actionButton.frame = CGRectMake(TSSpacing_MD, height - 64, width - TSSpacing_MD * 2, 50);
}

#pragma mark - Animations

- (void)startMeasureAnimations {
    // 1. 外圈展开动画
    CABasicAnimation *expand = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    expand.fromValue = @(0.0);
    expand.toValue = @(1.0);
    expand.duration = 0.5;
    expand.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_countdownRing addAnimation:expand forKey:@"expand"];

    // 2. 内圈淡入
    _innerCircleLayer.opacity = 0;
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = @(0.0);
    fadeIn.toValue = @(1.0);
    fadeIn.duration = 0.5;
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    [_innerCircleLayer addAnimation:fadeIn forKey:@"fadeIn"];
    _innerCircleLayer.opacity = 1.0;

    // 3. 延迟启动倒计时和呼吸动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startCountdownAnimation];
        [self startBreathingAnimationForType:self.selectedType];
    });
}

- (void)startCountdownAnimation {
    // 倒计时环逆时针消耗
    CABasicAnimation *countdown = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    countdown.fromValue = @(1.0);
    countdown.toValue = @(0.0);
    countdown.duration = _durationSlider.value;
    countdown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    countdown.fillMode = kCAFillModeForwards;
    countdown.removedOnCompletion = NO;
    [_countdownRing addAnimation:countdown forKey:@"countdown"];
}

- (void)startBreathingAnimationForType:(TSLocalMeasureType)type {
    // 移除旧动画
    [_innerCircleLayer removeAnimationForKey:@"breathing"];
    [_innerCircleLayer removeAnimationForKey:@"breathingOpacity"];

    switch (type) {
        case TSLocalMeasureTypeHeartRate:
            [self startHeartBeatAnimation];
            break;
        case TSLocalMeasureTypeBloodOxygen:
            [self startBloodOxygenAnimation];
            break;
        case TSLocalMeasureTypeStress:
            [self startStressAnimation];
            break;
    }
}

// 心率：波纹扩散动画
- (void)startHeartBeatAnimation {
    // 粉红色
    UIColor *pinkColor = [UIColor colorWithRed:255/255.f green:105/255.f blue:180/255.f alpha:1.f];

    CGPoint center = CGPointMake(kCircleSize/2, kCircleSize/2);
    CGFloat startRadius = kInnerCircleRadius;  // 从内圈半径开始
    CGFloat endRadius = kInnerCircleRadius * 1.5;  // 扩散到1.5倍

    // 创建3个波纹层
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *ripple = [CAShapeLayer layer];
        ripple.fillColor = [UIColor clearColor].CGColor;
        ripple.strokeColor = [pinkColor colorWithAlphaComponent:0.7].CGColor;
        ripple.lineWidth = 3.0;
        ripple.opacity = 0;  // 初始透明

        // 设置初始path（起始半径）
        UIBezierPath *startPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:startRadius
                                                              startAngle:0
                                                                endAngle:M_PI * 2
                                                               clockwise:YES];
        ripple.path = startPath.CGPath;
        [_circleContainer.layer insertSublayer:ripple below:_innerCircleLayer];

        // 创建结束path（结束半径）
        UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                radius:endRadius
                                                            startAngle:0
                                                              endAngle:M_PI * 2
                                                             clockwise:YES];

        // 动画组
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = 2.5;  // 放慢到2.5秒
        group.repeatCount = HUGE_VALF;
        group.beginTime = CACurrentMediaTime() + i * 0.8;  // 错开时间也增加
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        // 路径动画（半径从小到大）
        CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnim.fromValue = (__bridge id)startPath.CGPath;
        pathAnim.toValue = (__bridge id)endPath.CGPath;

        // 透明度动画（从0.8到0）
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = @(0.8);
        opacityAnim.toValue = @(0.0);

        group.animations = @[pathAnim, opacityAnim];
        [ripple addAnimation:group forKey:@"ripple"];
    }
}

// 血氧：呼吸光晕动画
- (void)startBloodOxygenAnimation {
    // 蓝色
    UIColor *blueColor = [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];

    CGPoint center = CGPointMake(kCircleSize/2, kCircleSize/2);

    // 创建2个呼吸光晕层
    for (int i = 0; i < 2; i++) {
        CAShapeLayer *glow = [CAShapeLayer layer];
        glow.fillColor = [UIColor clearColor].CGColor;
        glow.strokeColor = [blueColor colorWithAlphaComponent:0.6].CGColor;
        glow.lineWidth = 3.0;
        glow.opacity = 0;  // 初始透明
        [_circleContainer.layer insertSublayer:glow below:_innerCircleLayer];

        // 呼吸动画：半径从小到大再回到小（同心圆）
        CGFloat minRadius = kInnerCircleRadius * 0.95;  // 收缩到95%
        CGFloat maxRadius = kInnerCircleRadius * 1.08;  // 扩张到108%

        // 创建起始path（小）
        UIBezierPath *startPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:minRadius
                                                              startAngle:0
                                                                endAngle:M_PI * 2
                                                               clockwise:YES];
        glow.path = startPath.CGPath;

        // 创建结束path（大）
        UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                radius:maxRadius
                                                            startAngle:0
                                                              endAngle:M_PI * 2
                                                             clockwise:YES];

        // 呼吸动画组
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = 1.5;  // 加快到1.5秒
        group.repeatCount = HUGE_VALF;
        group.beginTime = CACurrentMediaTime() + i * 0.75;  // 错开0.75秒
        group.autoreverses = YES;  // 自动反向（呼气-吸气）
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        // 路径动画（半径变化）
        CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnim.fromValue = (__bridge id)startPath.CGPath;
        pathAnim.toValue = (__bridge id)endPath.CGPath;

        // 透明度动画
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = @(0.3);
        opacityAnim.toValue = @(0.8);

        group.animations = @[pathAnim, opacityAnim];
        [glow addAnimation:group forKey:@"breathing"];
    }

    // 内圈本身也添加轻微的呼吸效果（同心圆）
    CGFloat innerMinRadius = kInnerCircleRadius * 0.98;
    CGFloat innerMaxRadius = kInnerCircleRadius * 1.02;

    UIBezierPath *innerStartPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                   radius:innerMinRadius
                                                               startAngle:0
                                                                 endAngle:M_PI * 2
                                                                clockwise:YES];
    UIBezierPath *innerEndPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                 radius:innerMaxRadius
                                                             startAngle:0
                                                               endAngle:M_PI * 2
                                                              clockwise:YES];

    CABasicAnimation *innerPathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    innerPathAnim.fromValue = (__bridge id)innerStartPath.CGPath;
    innerPathAnim.toValue = (__bridge id)innerEndPath.CGPath;
    innerPathAnim.duration = 1.5;  // 同步加快到1.5秒
    innerPathAnim.autoreverses = YES;
    innerPathAnim.repeatCount = HUGE_VALF;
    innerPathAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_innerCircleLayer addAnimation:innerPathAnim forKey:@"breathing"];
}

// 压力：脉动波纹动画
- (void)startStressAnimation {
    // 紫色
    UIColor *purpleColor = [UIColor colorWithRed:175/255.f green:82/255.f blue:222/255.f alpha:1.f];

    CGPoint center = CGPointMake(kCircleSize/2, kCircleSize/2);
    CGFloat startRadius = kInnerCircleRadius;  // 从内圈半径开始
    CGFloat endRadius = kInnerCircleRadius * 1.4;  // 扩散到1.4倍

    // 创建3个脉动波纹层
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *pulse = [CAShapeLayer layer];
        pulse.fillColor = [UIColor clearColor].CGColor;
        pulse.strokeColor = [purpleColor colorWithAlphaComponent:0.7].CGColor;
        pulse.lineWidth = 3.0;
        pulse.opacity = 0;  // 初始透明

        // 设置初始path（起始半径）
        UIBezierPath *startPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                  radius:startRadius
                                                              startAngle:0
                                                                endAngle:M_PI * 2
                                                               clockwise:YES];
        pulse.path = startPath.CGPath;
        [_circleContainer.layer insertSublayer:pulse below:_innerCircleLayer];

        // 创建结束path（结束半径）
        UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                radius:endRadius
                                                            startAngle:0
                                                              endAngle:M_PI * 2
                                                             clockwise:YES];

        // 动画组
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = 2.0;  // 脉动周期2秒
        group.repeatCount = HUGE_VALF;
        group.beginTime = CACurrentMediaTime() + i * 0.66;  // 错开时间
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        // 路径动画（半径从小到大）
        CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnim.fromValue = (__bridge id)startPath.CGPath;
        pathAnim.toValue = (__bridge id)endPath.CGPath;

        // 透明度动画（从0.8到0）
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = @(0.8);
        opacityAnim.toValue = @(0.0);

        group.animations = @[pathAnim, opacityAnim];
        [pulse addAnimation:group forKey:@"pulse"];
    }

    // 内圈添加轻微的脉动效果（同心圆）
    CGFloat innerMinRadius = kInnerCircleRadius * 0.97;
    CGFloat innerMaxRadius = kInnerCircleRadius * 1.03;

    UIBezierPath *innerStartPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                   radius:innerMinRadius
                                                               startAngle:0
                                                                 endAngle:M_PI * 2
                                                                clockwise:YES];
    UIBezierPath *innerEndPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                 radius:innerMaxRadius
                                                             startAngle:0
                                                               endAngle:M_PI * 2
                                                              clockwise:YES];

    CABasicAnimation *innerPathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    innerPathAnim.fromValue = (__bridge id)innerStartPath.CGPath;
    innerPathAnim.toValue = (__bridge id)innerEndPath.CGPath;
    innerPathAnim.duration = 1.0;
    innerPathAnim.autoreverses = YES;
    innerPathAnim.repeatCount = HUGE_VALF;
    innerPathAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_innerCircleLayer addAnimation:innerPathAnim forKey:@"breathing"];
}

- (void)stopMeasureAnimations {
    [_countdownRing removeAllAnimations];
    [_innerCircleLayer removeAllAnimations];

    // 移除波纹层
    NSArray *sublayers = [_circleContainer.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]] && layer != _countdownRing && layer != _innerCircleLayer) {
            [layer removeFromSuperlayer];
        }
    }

    _countdownRing.strokeEnd = 1.0;
}

- (void)updateValueWithAnimation:(NSInteger)newValue {
    // 1. 数字翻转动画
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_valueLabel.layer addAnimation:transition forKey:@"valueChange"];

    // 2. 缩放弹跳
    CAKeyframeAnimation *bounce = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounce.values = @[@1.0, @1.2, @1.0];
    bounce.keyTimes = @[@0.0, @0.5, @1.0];
    bounce.duration = 0.4;
    [_valueLabel.layer addAnimation:bounce forKey:@"bounce"];

    // 3. 更新数值
    _valueLabel.text = [NSString stringWithFormat:@"%ld", (long)newValue];

    // 4. 震动反馈
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [feedback impactOccurred];
    }
}

- (void)showCompletionAnimation {
    // 1. 停止所有动画
    [self stopMeasureAnimations];

    // 2. 外圈淡出
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = @(1.0);
    fadeOut.toValue = @(0.0);
    fadeOut.duration = 0.3;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    [_countdownRing addAnimation:fadeOut forKey:@"fadeOut"];

    // 3. 显示成功图标
    _checkmarkIcon.alpha = 0;
    _checkmarkIcon.transform = CGAffineTransformMakeScale(0.5, 0.5);

    [UIView animateWithDuration:0.6
                          delay:0.2
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.8
                        options:0
                     animations:^{
        self.checkmarkIcon.alpha = 1.0;
        self.checkmarkIcon.transform = CGAffineTransformIdentity;
    } completion:nil];

    // 4. 震动反馈
    if (@available(iOS 10.0, *)) {
        UINotificationFeedbackGenerator *feedback = [[UINotificationFeedbackGenerator alloc] init];
        [feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
}

#pragma mark - Actions

- (void)onTabTapped:(UIButton *)sender {
    if (_currentState == TSMeasureStateMeasuring) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" 
                                                                       message:@"当前正在测量，切换将停止测量，是否继续？" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self stopMeasure];
            [self switchToType:sender.tag];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self switchToType:sender.tag];
}

- (void)switchToType:(TSLocalMeasureType)type {
    _selectedType = type;

    // 更新Tab指示器
    CGFloat btnWidth = (self.view.bounds.size.width - TSSpacing_MD * 2) / 3;
    [UIView animateWithDuration:0.3 animations:^{
        self.tabIndicator.frame = CGRectMake(type * btnWidth, 42, btnWidth, 2);
    }];

    [self updateTabColors];
    [self updateUIForState:_currentState];
}

- (void)updateTabColors {
    UIColor *selectedColor = [self currentTypeColor];
    _tabIndicator.backgroundColor = selectedColor;
    _innerCircleLayer.fillColor = [selectedColor colorWithAlphaComponent:0.15].CGColor;

    for (NSInteger i = 0; i < _tabButtons.count; i++) {
        UIButton *btn = _tabButtons[i];
        [btn setTitleColor:(i == _selectedType ? selectedColor : TSColor_TextSecondary) forState:UIControlStateNormal];
        // 测量中时禁用其他Tab
        if (_currentState == TSMeasureStateMeasuring && i != _selectedType) {
            btn.enabled = NO;
            btn.alpha = 0.4;
        } else {
            btn.enabled = YES;
            btn.alpha = 1.0;
        }
    }
}

- (void)onDurationChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    _durationLabel.text = [NSString stringWithFormat:@"%ld秒", (long)value];
}

- (void)onIntervalChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    _intervalLabel.text = [NSString stringWithFormat:@"%ld秒", (long)value];
}

- (void)onActionButtonTapped {
    switch (_currentState) {
        case TSMeasureStateIdle:
            [self startMeasure];
            break;
        case TSMeasureStateMeasuring:
            [self stopMeasure];
            break;
        case TSMeasureStateCompleted:
            [self resetMeasure];
            break;
    }
}

#pragma mark - Measure Logic

- (void)startMeasure {
    TSActivityMeasureParam *param = [[TSActivityMeasureParam alloc] init];
    param.measureType = [self currentMeasureType];
    param.maxMeasureDuration = (UInt8)_durationSlider.value;
    param.interval = (UInt8)_intervalSlider.value;

    __weak typeof(self) weakSelf = self;

    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate: {
            [[[TopStepComKit sharedInstance] heartRate] startMeasureWithParam:param
                                                                 startHandler:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleMeasureStart:success error:error];
            } dataHandler:^(TSHRValueItem * _Nullable data, NSError * _Nullable error) {
                [weakSelf handleHeartRateData:data error:error];
            } endHandler:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleMeasureEnd:success error:error];
            }];
            break;
        }
        case TSLocalMeasureTypeBloodOxygen: {
            [[[TopStepComKit sharedInstance] bloodOxygen] startMeasureWithParam:param
                                                                   startHandler:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleMeasureStart:success error:error];
            } dataHandler:^(TSBOValueItem * _Nullable data, NSError * _Nullable error) {
                [weakSelf handleBloodOxygenData:data error:error];
            } endHandler:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleMeasureEnd:success error:error];
            }];
            break;
        }
        case TSLocalMeasureTypeStress: {
            [[[TopStepComKit sharedInstance] stress] startMeasureWithParam:param
                                                              startHandler:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleMeasureStart:success error:error];
            } dataHandler:^(TSStressValueItem * _Nullable data, NSError * _Nullable error) {
                [weakSelf handleStressData:data error:error];
            } endHandler:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleMeasureEnd:success error:error];
            }];
            break;
        }
    }
}

- (void)stopMeasure {
    __weak typeof(self) weakSelf = self;

    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate: {
            [[[TopStepComKit sharedInstance] heartRate] stopMeasureCompletion:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleStopMeasure:success error:error];
            }];
            break;
        }
        case TSLocalMeasureTypeBloodOxygen: {
            [[[TopStepComKit sharedInstance] bloodOxygen] stopMeasureCompletion:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleStopMeasure:success error:error];
            }];
            break;
        }
        case TSLocalMeasureTypeStress: {
            [[[TopStepComKit sharedInstance] stress] stopMeasureCompletion:^(BOOL success, NSError * _Nullable error) {
                [weakSelf handleStopMeasure:success error:error];
            }];
            break;
        }
    }

    [self stopMeasureTimer];
    [self stopMeasureAnimations];
}

- (void)handleStopMeasure:(BOOL)success error:(NSError *)error {
    if (success) {
        [self showToast:@"测量已取消"];
    } else {
        [self showToast:[NSString stringWithFormat:@"停止失败: %@", error.localizedDescription ?: @"未知错误"]];
    }
    [self updateUIForState:TSMeasureStateIdle];
}

- (void)resetMeasure {
    _currentValue = 0;
    _elapsedTime = 0;
    _checkmarkIcon.alpha = 0;
    [self updateUIForState:TSMeasureStateIdle];
}

#pragma mark - Measure Handlers

- (void)handleMeasureStart:(BOOL)success error:(NSError *)error {
    NSLog(@"[TSActivityMeasure] 测量启动回调 - success:%d, error:%@, type:%ld", success, error, (long)_selectedType);

    if (success) {
        _currentState = TSMeasureStateMeasuring;
        _elapsedTime = 0;
        _currentValue = 0;
        [self updateUIForState:TSMeasureStateMeasuring];
        [self startMeasureAnimations];
        [self startMeasureTimer];

        NSLog(@"[TSActivityMeasure] 测量已启动，动画已开始");
    } else {
        NSLog(@"[TSActivityMeasure] 测量启动失败: %@", error.localizedDescription);
        [self showToast:[NSString stringWithFormat:@"测量启动失败: %@", error.localizedDescription ?: @"未知错误"]];
    }
}

- (void)handleHeartRateData:(TSHRValueItem *)data error:(NSError *)error {
    NSLog(@"[TSActivityMeasure] 心率数据回调 - value:%d, error:%@", data.hrValue, error);

    if (data && !error) {
        NSInteger newValue = data.hrValue;
        // 只有当数值有效且发生变化时才更新
        if (newValue > 0 && newValue != _currentValue) {
            [self updateValueWithAnimation:newValue];
            _currentValue = newValue;
        }
    }
}

- (void)handleBloodOxygenData:(TSBOValueItem *)data error:(NSError *)error {
    NSLog(@"[TSActivityMeasure] 血氧数据回调 - value:%d, error:%@", data.oxyValue, error);

    if (data && !error) {
        NSInteger newValue = data.oxyValue;
        // 只有当数值有效且发生变化时才更新
        if (newValue > 0 && newValue != _currentValue) {
            [self updateValueWithAnimation:newValue];
            _currentValue = newValue;
        }
    }
}

- (void)handleStressData:(TSStressValueItem *)data error:(NSError *)error {
    NSLog(@"[TSActivityMeasure] 压力数据回调 - value:%d, error:%@", data.stressValue, error);

    if (data && !error) {
        NSInteger newValue = data.stressValue;
        // 只有当数值有效且发生变化时才更新
        if (newValue >= 0 && newValue != _currentValue) {
            [self updateValueWithAnimation:newValue];
            _currentValue = newValue;
        }
    }
}

- (void)handleMeasureEnd:(BOOL)success error:(NSError *)error {
    NSLog(@"[TSActivityMeasure] 测量结束回调 - success:%d, error:%@, elapsedTime:%ld", success, error, (long)_elapsedTime);

    [self stopMeasureTimer];
    [self stopMeasureAnimations];

    if (success) {
        _currentState = TSMeasureStateCompleted;
        [self showCompletionAnimation];
        [self updateUIForState:TSMeasureStateCompleted];
        [self showToast:@"✅ 测量完成"];
    } else {
        [self showToast:[NSString stringWithFormat:@"❌ 测量失败: %@", error.localizedDescription ?: @"未知错误"]];
        [self updateUIForState:TSMeasureStateIdle];
    }
}

#pragma mark - Timer

- (void)startMeasureTimer {
    [self stopMeasureTimer];
    _measureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(onMeasureTimerTick)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopMeasureTimer {
    if (_measureTimer) {
        [_measureTimer invalidate];
        _measureTimer = nil;
    }
}

- (void)onMeasureTimerTick {
    _elapsedTime++;

    NSInteger maxDuration = (NSInteger)_durationSlider.value;
    NSInteger remaining = maxDuration - _elapsedTime;

    _statusLabel.text = [NSString stringWithFormat:@"⏱ 剩余 %ld 秒", (long)remaining];

    // 根据剩余时间改变倒计时环颜色
    [self updateCountdownRingColor:remaining];
}

- (void)updateCountdownRingColor:(NSInteger)remaining {
    UIColor *color;

    if (remaining > 20) {
        color = TSColor_Success;  // 绿色
    } else if (remaining > 10) {
        color = [UIColor colorWithRed:255/255.f green:204/255.f blue:0/255.f alpha:1.f];  // 黄色
    } else {
        color = TSColor_Danger;  // 红色
        // 最后10秒添加闪烁动画
        if (![_countdownRing animationForKey:@"blink"]) {
            CABasicAnimation *blink = [CABasicAnimation animationWithKeyPath:@"opacity"];
            blink.fromValue = @(1.0);
            blink.toValue = @(0.3);
            blink.duration = 0.5;
            blink.autoreverses = YES;
            blink.repeatCount = HUGE_VALF;
            [_countdownRing addAnimation:blink forKey:@"blink"];
        }
    }

    _countdownRing.strokeColor = color.CGColor;
}

#pragma mark - UI Update

- (void)updateUIForState:(TSMeasureState)state {
    _currentState = state;

    switch (state) {
        case TSMeasureStateIdle:
            _paramCard.hidden = NO;
            _measureCard.hidden = YES;
            _resultCard.hidden = YES;
            [_actionButton setTitle:[NSString stringWithFormat:@"🚀 开始测量%@", [self currentTypeName]] forState:UIControlStateNormal];
            _actionButton.backgroundColor = TSColor_Primary;
            _valueLabel.text = @"--";
            _statusLabel.text = @"准备开始测量";
            _checkmarkIcon.alpha = 0;
            _countdownRing.opacity = 1.0;
            _countdownRing.strokeEnd = 1.0;
            _countdownRing.strokeColor = TSColor_Success.CGColor;
            [_countdownRing removeAllAnimations];
            break;

        case TSMeasureStateMeasuring: {
            // 参数区动画收起
            [UIView animateWithDuration:0.3 animations:^{
                self.paramCard.alpha = 0;
                self.paramCard.transform = CGAffineTransformMakeScale(0.95, 0.95);
            } completion:^(BOOL finished) {
                self.paramCard.hidden = YES;
                self.paramCard.alpha = 1.0;
                self.paramCard.transform = CGAffineTransformIdentity;
            }];

            _measureCard.hidden = NO;
            _resultCard.hidden = YES;
            [_actionButton setTitle:@"⏹ 停止测量" forState:UIControlStateNormal];
            _actionButton.backgroundColor = TSColor_Danger;
            _statusLabel.text = [NSString stringWithFormat:@"正在测量%@...", [self currentTypeName]];
            _checkmarkIcon.alpha = 0;
            break;
        }
        case TSMeasureStateCompleted: {
            _paramCard.hidden = YES;
            _measureCard.hidden = YES;
            _resultCard.hidden = NO;
            [_actionButton setTitle:@"↻ 重新测量" forState:UIControlStateNormal];
            _actionButton.backgroundColor = TSColor_Primary;
            [self updateResultCard];
            break;
        }
    }

    _unitLabel.text = [self currentTypeUnit];
    [self updateTabColors];
}

- (void)updateResultCard {
    _resultValueLabel.text = [NSString stringWithFormat:@"%@ %ld %@", 
                              [self currentTypeIcon], 
                              (long)_currentValue, 
                              [self currentTypeUnit]];
    _resultStatusLabel.text = [self evaluateStatus:_currentValue];
    _resultTimeLabel.text = [NSString stringWithFormat:@"测量时长: %lds\n完成时间: %@", 
                             (long)_elapsedTime, 
                             [self currentTimeString]];
}

#pragma mark - Helper Methods

- (UIView *)createCardView {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_MD;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.1;
    card.layer.shadowRadius = 4;
    return card;
}

- (UILabel *)createLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = TSFont_Body;
    label.textColor = TSColor_TextSecondary;
    return label;
}

- (TSActiveMeasureType)currentMeasureType {
    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate:
            return TSMeasureTypeHeartRate;
        case TSLocalMeasureTypeBloodOxygen:
            return TSMeasureTypeBloodOxygen;
        case TSLocalMeasureTypeStress:
            return TSMeasureTypeStress;
    }
}

- (NSString *)currentTypeName {
    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate:
            return @"心率";
        case TSLocalMeasureTypeBloodOxygen:
            return @"血氧";
        case TSLocalMeasureTypeStress:
            return @"压力";
    }
}

- (NSString *)currentTypeIcon {
    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate:
            return @"💓";
        case TSLocalMeasureTypeBloodOxygen:
            return @"🫁";
        case TSLocalMeasureTypeStress:
            return @"😰";
    }
}

- (NSString *)currentTypeUnit {
    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate:
            return @"BPM";
        case TSLocalMeasureTypeBloodOxygen:
            return @"%";
        case TSLocalMeasureTypeStress:
            return @"分";
    }
}

- (UIColor *)currentTypeColor {
    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate:
            return TSColor_HeartRate;
        case TSLocalMeasureTypeBloodOxygen:
            return TSColor_BloodOxygen;
        case TSLocalMeasureTypeStress:
            return TSColor_Stress;
    }
}

- (NSString *)evaluateStatus:(NSInteger)value {
    switch (_selectedType) {
        case TSLocalMeasureTypeHeartRate:
            if (value < 60) return @"偏低";
            if (value <= 100) return @"正常";
            return @"偏高";

        case TSLocalMeasureTypeBloodOxygen:
            if (value >= 95) return @"正常";
            return @"偏低";

        case TSLocalMeasureTypeStress:
            if (value < 30) return @"放松";
            if (value < 60) return @"正常";
            if (value < 80) return @"紧张";
            return @"高压";
    }
}

- (NSString *)currentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:[NSDate date]];
}

- (void)showToast:(NSString *)message {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    toast.layer.cornerRadius = 8;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize size = [label sizeThatFits:CGSizeMake(maxW - 32.f, CGFLOAT_MAX)];
    CGFloat toastW = MIN(size.width + 32.f, maxW);
    CGFloat toastH = size.height + 20.f;

    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
                             CGRectGetHeight(self.view.bounds) * 0.72f,
                             toastW, toastH);
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

#pragma mark - Lazy Loading

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _actionButton.backgroundColor = TSColor_Primary;
        _actionButton.layer.cornerRadius = 12.f;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_actionButton setTitle:@"🚀 开始测量心率" forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(onActionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

@end
