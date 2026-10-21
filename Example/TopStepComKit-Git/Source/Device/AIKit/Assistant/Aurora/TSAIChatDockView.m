//
//  TSAIChatDockView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatDockView.h"

#import "TSAIChatTheme.h"

static const CGFloat kTSAIChatDockCancelThreshold = 70;
static const NSInteger kTSAIChatDockWaveCount = 26;
/// 波形刷新间隔（秒）
static const NSTimeInterval kTSAIChatDockWaveInterval = 0.11;
/// 「准备中」呼吸波形的周期（秒）
static const NSTimeInterval kTSAIChatDockBreathPeriod = 1.6;

@interface TSAIChatDockView () <UITextFieldDelegate>

// 提示行
@property (nonatomic, strong) UILabel *hintLabel;
// 胶囊
@property (nonatomic, strong) UIView *capsule;
// 输入框
@property (nonatomic, strong, readwrite) UITextField *textField;
// 聚焦外环
@property (nonatomic, strong) UIView *focusRing;
// 发送键 36
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) CAGradientLayer *sendGradient;
/// 发送箭头：与麦克风键一样用独立 imageView 盖在渐变层之上（UIButton 自带 imageView 的 layer 会被后加的渐变 sublayer 压住）
@property (nonatomic, strong) UIImageView *sendIcon;
// 麦克风键 46
@property (nonatomic, strong) UIView *micButton;
@property (nonatomic, strong) CAGradientLayer *micGradient;
@property (nonatomic, strong) UIImageView *micIcon;
// 脉冲 / 录音外环
@property (nonatomic, strong) UIView *pulseRing;
// 按压手势
@property (nonatomic, strong) UILongPressGestureRecognizer *pressGesture;
// 按压起点
@property (nonatomic, assign) CGPoint pressOrigin;
// 当前是否处于取消区
@property (nonatomic, assign) BOOL cancelling;

// 录音条：红点 + 计时 + 波形
@property (nonatomic, strong) UIView *recordBar;
@property (nonatomic, strong) UIView *redDot;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) UIView *waveView;
@property (nonatomic, strong) NSArray<CAGradientLayer *> *waveBars;
@property (nonatomic, strong, nullable) NSTimer *waveTimer;
// 取消靶点 44 + 标签
@property (nonatomic, strong) UIView *cancelTarget;
@property (nonatomic, strong) CAGradientLayer *cancelTargetGradient;
@property (nonatomic, strong) UIImageView *cancelTargetIcon;
@property (nonatomic, strong) UILabel *cancelTargetLabel;
@property (nonatomic, assign) BOOL cancelTargetVisible;
// 录音态
@property (nonatomic, assign, readwrite) BOOL isRecording;
@property (nonatomic, copy, nullable) NSString *recordingHint;
// 录音条是否为「准备中」样式（麦克风还没出数据）
@property (nonatomic, assign, readwrite) BOOL isPreparing;
// 「准备中」呼吸波形的相位
@property (nonatomic, assign) CGFloat breathPhase;
// 按下触感（light）
@property (nonatomic, strong) UIImpactFeedbackGenerator *pressFeedback;
// 麦克风就绪触感（selection）
@property (nonatomic, strong) UISelectionFeedbackGenerator *readyFeedback;

@end

@implementation TSAIChatDockView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        _inputLevel = -1;

        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = TSAIChatFont(11.5, UIFontWeightMedium);
        _hintLabel.textColor = TSAIChatInk3Color();
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_hintLabel];

        // 取消靶点（dock 内绝对定位，录音时浮出）
        _cancelTarget = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        TSAIChatApplyGlass(_cancelTarget, 22);
        TSAIChatApplyCardShadow(_cancelTarget.layer);
        _cancelTarget.userInteractionEnabled = NO;
        _cancelTarget.alpha = 0;
        _cancelTargetGradient = TSAIChatCancelGradientLayer();
        _cancelTargetGradient.frame = _cancelTarget.bounds;
        _cancelTargetGradient.cornerRadius = 22;
        _cancelTargetGradient.hidden = YES;
        [_cancelTarget.layer addSublayer:_cancelTargetGradient];
        _cancelTargetIcon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"xmark", 13, UIImageSymbolWeightBold)];
        _cancelTargetIcon.tintColor = TSAIChatInk3Color();
        _cancelTargetIcon.contentMode = UIViewContentModeScaleAspectFit;
        _cancelTargetIcon.frame = CGRectMake(14, 14, 16, 16);
        [_cancelTarget addSubview:_cancelTargetIcon];
        _cancelTargetLabel = [[UILabel alloc] init];
        _cancelTargetLabel.text = @"取消";
        _cancelTargetLabel.font = TSAIChatFont(10.5, UIFontWeightBold);
        _cancelTargetLabel.textColor = TSAIChatInk3Color();
        _cancelTargetLabel.textAlignment = NSTextAlignmentCenter;
        _cancelTargetLabel.frame = CGRectMake(-20, -20, 84, 14);
        [_cancelTarget addSubview:_cancelTargetLabel];
        [self addSubview:_cancelTarget];

        _capsule = [[UIView alloc] init];
        TSAIChatApplyGlass(_capsule, 30);
        TSAIChatApplyFloatShadow(_capsule.layer);
        [self addSubview:_capsule];

        _focusRing = [[UIView alloc] init];
        _focusRing.layer.cornerRadius = 34;
        _focusRing.layer.cornerCurve = kCACornerCurveContinuous;
        _focusRing.layer.borderWidth = 4;
        _focusRing.layer.borderColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.10].CGColor;
        _focusRing.userInteractionEnabled = NO;
        _focusRing.alpha = 0;
        [self insertSubview:_focusRing belowSubview:_capsule];

        _textField = [[UITextField alloc] init];
        _textField.font = TSAIChatFont(15, UIFontWeightRegular);
        _textField.textColor = TSAIChatInkColor();
        _textField.returnKeyType = UIReturnKeySend;
        _textField.delegate = self;
        _textField.enablesReturnKeyAutomatically = YES;
        [_textField addTarget:self action:@selector(onTextChanged) forControlEvents:UIControlEventEditingChanged];
        [_capsule addSubview:_textField];

        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(0, 0, 36, 36);
        _sendButton.layer.cornerRadius = 18;
        _sendButton.layer.masksToBounds = YES;
        _sendGradient = TSAIChatPrimaryGradientLayer();
        _sendGradient.frame = _sendButton.bounds;
        [_sendButton.layer addSublayer:_sendGradient];
        _sendIcon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"arrow.up", 14, UIImageSymbolWeightBold)];
        _sendIcon.tintColor = [UIColor whiteColor];
        _sendIcon.contentMode = UIViewContentModeScaleAspectFit;
        _sendIcon.userInteractionEnabled = NO;
        _sendIcon.frame = CGRectMake(10, 10, 16, 16);
        [_sendButton addSubview:_sendIcon];
        _sendButton.transform = CGAffineTransformMakeScale(0.01, 0.01);
        _sendButton.alpha = 0;
        [_sendButton addTarget:self action:@selector(onSendTapped) forControlEvents:UIControlEventTouchUpInside];
        [_capsule addSubview:_sendButton];

        // 录音条
        _recordBar = [[UIView alloc] init];
        _recordBar.hidden = YES;
        _recordBar.userInteractionEnabled = NO;
        _redDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _redDot.backgroundColor = TSAIChatRoseColor();
        _redDot.layer.cornerRadius = 4;
        [_recordBar addSubview:_redDot];
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:15 weight:UIFontWeightHeavy];
        _timerLabel.textColor = TSAIChatInkColor();
        _timerLabel.text = @"00:00";
        [_recordBar addSubview:_timerLabel];
        _waveView = [[UIView alloc] init];
        _waveView.clipsToBounds = YES;
        NSMutableArray *bars = [NSMutableArray array];
        for (NSInteger index = 0; index < kTSAIChatDockWaveCount; index++) {
            CAGradientLayer *bar = [CAGradientLayer layer];
            bar.startPoint = CGPointMake(0.5, 0);
            bar.endPoint = CGPointMake(0.5, 1);
            bar.cornerRadius = 1.5;
            bar.bounds = CGRectMake(0, 0, 3, 4);
            [_waveView.layer addSublayer:bar];
            [bars addObject:bar];
        }
        _waveBars = bars;
        [_recordBar addSubview:_waveView];
        [_capsule addSubview:_recordBar];

        _pulseRing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
        _pulseRing.layer.cornerRadius = 27;
        _pulseRing.layer.borderWidth = 2;
        _pulseRing.layer.borderColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.33].CGColor;
        _pulseRing.userInteractionEnabled = NO;
        _pulseRing.hidden = YES;
        [_capsule addSubview:_pulseRing];

        _micButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        _micButton.layer.cornerRadius = 23;
        _micButton.layer.shadowColor = TSAIChatVioletColor().CGColor;
        _micButton.layer.shadowOpacity = 0.27;
        _micButton.layer.shadowOffset = CGSizeMake(0, 8);
        _micButton.layer.shadowRadius = 9;
        _micGradient = TSAIChatPrimaryGradientLayer();
        _micGradient.frame = _micButton.bounds;
        _micGradient.cornerRadius = 23;
        [_micButton.layer addSublayer:_micGradient];
        _micIcon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"mic.fill", 18, UIImageSymbolWeightSemibold)];
        _micIcon.tintColor = [UIColor whiteColor];
        _micIcon.contentMode = UIViewContentModeScaleAspectFit;
        _micIcon.frame = CGRectMake(13, 13, 20, 20);
        [_micButton addSubview:_micIcon];
        [_capsule addSubview:_micButton];

        _pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
        _pressGesture.minimumPressDuration = 0;
        _pressGesture.allowableMovement = CGFLOAT_MAX;
        [_micButton addGestureRecognizer:_pressGesture];

        [self applyBusy];
        [self applyHint];
    }
    return self;
}

- (void)dealloc {
    [_waveTimer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.hintLabel.frame = CGRectMake(16, 10, width - 32, 16);
    self.capsule.frame = CGRectMake(16, 10 + 16 + 6, width - 32, 60);
    self.focusRing.frame = CGRectInset(self.capsule.frame, -4, -4);
    CGFloat capsuleWidth = CGRectGetWidth(self.capsule.bounds);
    self.micButton.center = CGPointMake(capsuleWidth - 8 - 23, 30);
    self.pulseRing.center = self.micButton.center;
    self.sendButton.center = CGPointMake(capsuleWidth - 8 - 46 - 8 - 18, 30);
    CGFloat textRight = self.sendButton.alpha > 0 ? CGRectGetMinX(self.sendButton.frame) - 8 : CGRectGetMinX(self.micButton.frame) - 8;
    self.textField.frame = CGRectMake(18, 8, textRight - 18, 44);

    // 录音条：左 18 起，到麦克风左侧 10
    self.recordBar.frame = CGRectMake(18, 0, CGRectGetMinX(self.micButton.frame) - 10 - 18, 60);
    CGFloat barWidth = CGRectGetWidth(self.recordBar.bounds);
    self.redDot.center = CGPointMake(4, 30);
    self.timerLabel.frame = CGRectMake(18, 20, 42, 20);
    CGFloat waveX = 18 + 42 + 10;
    self.waveView.frame = CGRectMake(waveX, 14, MAX(0, barWidth - waveX), 32);
    CGFloat waveWidth = kTSAIChatDockWaveCount * 3 + (kTSAIChatDockWaveCount - 1) * 2.5;
    CGFloat startX = (CGRectGetWidth(self.waveView.bounds) - waveWidth) / 2;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSInteger index = 0; index < kTSAIChatDockWaveCount; index++) {
        self.waveBars[index].position = CGPointMake(startX + 1.5 + index * 5.5, 16);
    }
    [CATransaction commit];

    // 取消靶点：与麦克风同 x，中心在麦克风中心上方 84
    CGPoint micCenterInDock = [self.capsule convertPoint:self.micButton.center toView:self];
    self.cancelTarget.center = CGPointMake(micCenterInDock.x, micCenterInDock.y - 84);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) [self restartAnimations];
}

#pragma mark - 公开方法

+ (CGFloat)contentHeight {
    return 10 + 16 + 6 + 60 + 10;
}

- (void)setBusy:(BOOL)busy {
    _busy = busy;
    [self applyBusy];
}

- (void)setHintText:(NSString *)hintText {
    _hintText = [hintText copy];
    [self applyHint];
}

- (void)setPulseEnabled:(BOOL)pulseEnabled {
    _pulseEnabled = pulseEnabled;
    [self restartAnimations];
}

- (void)setRecordingElapsed:(NSTimeInterval)recordingElapsed {
    _recordingElapsed = recordingElapsed;
    self.timerLabel.text = TSAIChatClockString(recordingElapsed);
}

- (void)setRecordingCancelling:(BOOL)recordingCancelling {
    if (_recordingCancelling == recordingCancelling) return;
    _recordingCancelling = recordingCancelling;
    [self applyRecordingTint];
    [self applyHint];
}

- (void)enterPreparingWithCancelTarget:(BOOL)showCancelTarget hint:(NSString *)hint {
    if (self.isRecording) {
        return;
    }
    [self.pressFeedback impactOccurred];
    [self.readyFeedback prepare];
    self.isPreparing = YES;
    self.breathPhase = 0;
    [self morphIntoRecordingWithCancelTarget:showCancelTarget hint:hint];
    [self playPressAnimation];
}

- (void)enterListeningWithHint:(NSString *)hint {
    if (!self.isRecording || !self.isPreparing) {
        return;
    }
    self.isPreparing = NO;
    self.recordingHint = hint;
    self.recordingElapsed = 0;
    [self.readyFeedback selectionChanged];
    [self applyRecordingTint];
    [self applyHint];
    [self startWave];
}

- (void)exitRecording {
    if (!self.isRecording) return;
    self.isRecording = NO;
    self.isPreparing = NO;
    self.recordingHint = nil;
    [self stopWave];
    self.recordBar.hidden = YES;
    self.textField.hidden = NO;
    self.sendButton.hidden = NO;
    [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.2 animations:^{
        self.cancelTarget.alpha = 0;
        self.cancelTarget.transform = CGAffineTransformMakeScale(0.7, 0.7);
        self.micButton.transform = CGAffineTransformIdentity;
    }];
    _recordingCancelling = NO;
    [self applyRecordingTint];
    [self applyBusy];
    [self applyHint];
    [self restartAnimations];
}

- (void)restartAnimations {
    [self.pulseRing.layer removeAnimationForKey:@"tsai.pulse"];
    BOOL recording = self.isRecording;
    BOOL show = recording || (self.pulseEnabled && !self.busy);
    show = show && !TSAIChatReduceMotion();
    self.pulseRing.hidden = !show;
    if (!show) return;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0.9;
    scale.toValue = @1.5;
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @0.8;
    fade.toValue = @0;
    group.animations = @[scale, fade];
    group.duration = recording ? 1.4 : 2.2;
    group.repeatCount = HUGE_VALF;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.pulseRing.layer addAnimation:group forKey:@"tsai.pulse"];
}

#pragma mark - 私有方法

/// 胶囊原位变形为录音条：输入框 / 发送键淡出，录音条与取消靶点弹入
- (void)morphIntoRecordingWithCancelTarget:(BOOL)showCancelTarget hint:(NSString *)hint {
    self.isRecording = YES;
    self.recordingHint = hint;
    self.recordingCancelling = NO;
    self.recordingElapsed = 0;
    self.cancelTargetVisible = showCancelTarget;
    [self.textField resignFirstResponder];

    self.textField.hidden = YES;
    self.sendButton.hidden = YES;
    self.recordBar.hidden = NO;
    self.micButton.userInteractionEnabled = YES;
    TSAIChatPopIn(self.recordBar, 0.3, 0);
    [self applyRecordingTint];
    [self applyHint];
    [self startWave];
    [self restartAnimations];

    if (showCancelTarget) {
        self.cancelTarget.alpha = 0;
        self.cancelTarget.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.7, 0.7), CGAffineTransformMakeTranslation(0, 14));
        [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.3 delay:0 usingSpringWithDamping:0.62 initialSpringVelocity:0.8
                            options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.cancelTarget.alpha = 1;
            self.cancelTarget.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

/// 按下动画：麦克风先压下，再弹到 1.1 倍
- (void)playPressAnimation {
    if (TSAIChatReduceMotion()) {
        self.micButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
        return;
    }
    self.micButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.8
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.micButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:nil];
}

/// busy：输入区 α.5 不可交互、占位「等待回答…」、麦克风置灰无阴影；录音中不动麦克风
- (void)applyBusy {
    BOOL busy = self.busy;
    self.textField.enabled = !busy;
    self.textField.alpha = busy ? 0.5 : 1;
    self.textField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:busy ? @"等待回答…" : @"输入问题…"
            attributes:@{NSForegroundColorAttributeName: TSAIChatInk3Color(),
                         NSFontAttributeName: TSAIChatFont(15, UIFontWeightRegular)}];
    self.sendButton.enabled = !busy;
    if (self.isRecording) {
        [self applyHint];
        return;
    }
    self.micButton.userInteractionEnabled = !busy;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    if (busy) {
        self.micGradient.colors = @[(id)TSAIChatHexColor(0xCFCDE0).CGColor, (id)TSAIChatHexColor(0xCFCDE0).CGColor];
        self.micButton.layer.shadowOpacity = 0;
    } else {
        self.micGradient.colors = @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
        self.micButton.layer.shadowOpacity = 0.27;
    }
    [CATransaction commit];
    [self restartAnimations];
    [self applyHint];
}

/// 提示行：录音态紫 / 取消态玫红加粗 / busy 紫 / 其它弱色
- (void)applyHint {
    if (self.isRecording) {
        BOOL cancelling = self.recordingCancelling;
        self.hintLabel.text = cancelling ? @"松开取消" : (self.recordingHint ?: @"正在听你说 · 松开发送，上滑取消");
        self.hintLabel.textColor = cancelling ? TSAIChatRoseColor() : TSAIChatVioletColor();
        self.hintLabel.font = TSAIChatFont(11.5, cancelling ? UIFontWeightBold : UIFontWeightMedium);
        return;
    }
    self.hintLabel.text = self.hintText ?: @"";
    self.hintLabel.textColor = self.busy ? TSAIChatVioletColor() : TSAIChatInk3Color();
    self.hintLabel.font = TSAIChatFont(11.5, UIFontWeightMedium);
}

/// 录音态着色：紫 / 取消态玫红（胶囊描边、波形、计时、麦克风、靶点）；准备中计时淡显、红点不闪
- (void)applyRecordingTint {
    BOOL recording = self.isRecording;
    BOOL cancelling = recording && self.recordingCancelling;
    BOOL preparing = recording && self.isPreparing;
    UIColor *tint = cancelling ? TSAIChatRoseColor() : TSAIChatVioletColor();
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2];
    if (recording) {
        self.capsule.layer.borderColor = [tint colorWithAlphaComponent:cancelling ? 0.50 : 0.40].CGColor;
        self.focusRing.layer.borderColor = [tint colorWithAlphaComponent:0.10].CGColor;
        self.focusRing.alpha = 1;
        self.micGradient.colors = cancelling
            ? @[(id)TSAIChatRoseColor().CGColor, (id)TSAIChatHexColor(0xFF9A7B).CGColor]
            : @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
        self.micButton.layer.shadowColor = tint.CGColor;
        self.micButton.layer.shadowOpacity = 0.33;
        self.micButton.layer.shadowRadius = 12;
        self.micButton.layer.shadowOffset = CGSizeMake(0, 10);
        self.pulseRing.layer.borderColor = [tint colorWithAlphaComponent:cancelling ? 0.40 : 0.33].CGColor;
    } else {
        self.capsule.layer.borderColor = TSAIChatGlassLineColor().CGColor;
        self.focusRing.layer.borderColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.10].CGColor;
        self.focusRing.alpha = 0;
        self.micButton.layer.shadowColor = TSAIChatVioletColor().CGColor;
        self.micButton.layer.shadowOpacity = 0.27;
        self.micButton.layer.shadowRadius = 9;
        self.micButton.layer.shadowOffset = CGSizeMake(0, 8);
        self.pulseRing.layer.borderColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.33].CGColor;
    }
    self.timerLabel.textColor = cancelling ? TSAIChatRoseColor() : TSAIChatInkColor();
    self.timerLabel.alpha = preparing ? 0.45 : 1;
    for (CAGradientLayer *bar in self.waveBars) {
        bar.colors = cancelling
            ? @[(id)TSAIChatRoseColor().CGColor, (id)TSAIChatRoseColor().CGColor]
            : @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
    }
    [CATransaction commit];

    // 红点：准备中（还没录到声音）与取消态不闪烁
    [self.redDot.layer removeAnimationForKey:@"tsai.blink"];
    self.redDot.alpha = (cancelling || preparing) ? 0.4 : 1;
    if (recording && !cancelling && !preparing && !TSAIChatReduceMotion()) {
        CAKeyframeAnimation *blink = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        blink.values = @[@1, @1, @0.25, @0.25, @1];
        blink.keyTimes = @[@0, @0.49, @0.5, @0.99, @1];
        blink.duration = 1;
        blink.repeatCount = HUGE_VALF;
        [self.redDot.layer addAnimation:blink forKey:@"tsai.blink"];
    }

    // 靶点
    self.cancelTargetGradient.hidden = !cancelling;
    self.cancelTarget.backgroundColor = cancelling ? [UIColor clearColor] : TSAIChatGlassColor();
    self.cancelTarget.layer.borderColor = cancelling ? [UIColor clearColor].CGColor : TSAIChatGlassLineColor().CGColor;
    self.cancelTargetIcon.tintColor = cancelling ? [UIColor whiteColor] : TSAIChatInk3Color();
    self.cancelTargetLabel.textColor = cancelling ? TSAIChatRoseColor() : TSAIChatInk3Color();
    self.cancelTarget.layer.shadowColor = cancelling ? TSAIChatRoseColor().CGColor : TSAIChatHexColor(0x3B2E8A).CGColor;
    self.cancelTarget.layer.shadowOpacity = cancelling ? 0.33 : 0.08;
    if (recording && self.cancelTargetVisible) {
        [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.25 delay:0 usingSpringWithDamping:0.62 initialSpringVelocity:0.8
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.cancelTarget.transform = cancelling ? CGAffineTransformMakeScale(1.18, 1.18) : CGAffineTransformIdentity;
        } completion:nil];
    }
}

/// 波形：每 110ms 刷新，高 4–28，两端衰减 1 − 0.6·|i−13|/13
- (void)startWave {
    [self.waveTimer invalidate];
    self.waveTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAIChatDockWaveInterval
                                                      target:self
                                                    selector:@selector(onWaveTick)
                                                    userInfo:nil
                                                     repeats:YES];
    [self onWaveTick];
}

- (void)stopWave {
    [self.waveTimer invalidate];
    self.waveTimer = nil;
}

/// 发送键：有文字 scale 1，否则 scale 0，.3s spring
- (void)updateSendButtonAnimated:(BOOL)animated {
    BOOL hasText = [self trimmedText].length > 0;
    void (^apply)(void) = ^{
        self.sendButton.transform = hasText ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.01, 0.01);
        self.sendButton.alpha = hasText ? 1 : 0;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    };
    if (animated && !TSAIChatReduceMotion()) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.62 initialSpringVelocity:0.8
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:apply completion:nil];
    } else {
        apply();
    }
}

/// 去除首尾空白的输入
- (NSString *)trimmedText {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";
}

/// 提交文本
- (void)submitText {
    NSString *text = [self trimmedText];
    if (text.length == 0 || self.busy) return;
    self.textField.text = @"";
    [self updateSendButtonAnimated:YES];
    if (self.onSend) self.onSend(text);
}

#pragma mark - 事件

- (void)onWaveTick {
    CGFloat level = self.inputLevel;
    CGFloat half = kTSAIChatDockWaveCount / 2.0;
    // 准备中：还没有声音，所有波形条一起低幅缓慢起伏（呼吸）
    CGFloat breath = 0;
    if (self.isPreparing) {
        self.breathPhase += 2 * M_PI * kTSAIChatDockWaveInterval / kTSAIChatDockBreathPeriod;
        breath = 0.06 + 0.10 * (0.5 + 0.5 * sin(self.breathPhase));
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.12];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    for (NSInteger index = 0; index < kTSAIChatDockWaveCount; index++) {
        CGFloat weight = 1 - 0.6 * fabs(index - half) / half;
        CGFloat base = 0;
        if (self.isPreparing) {
            base = breath;
        } else {
            CGFloat random = arc4random_uniform(1000) / 1000.0;
            base = level >= 0 ? MIN(1, level * 1.4) * (0.55 + random * 0.45) : random;
        }
        self.waveBars[index].bounds = CGRectMake(0, 0, 3, 4 + 24 * base * weight);
    }
    [CATransaction commit];
}

- (void)onTextChanged {
    [self updateSendButtonAnimated:YES];
}

- (void)onSendTapped {
    [self submitText];
}

- (void)onPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.pressOrigin = point;
            self.cancelling = NO;
            [self.textField resignFirstResponder];
            if (self.onPressBegan) self.onPressBegan();
            break;
        }
        case UIGestureRecognizerStateChanged: {
            BOOL cancelling = (self.pressOrigin.y - point.y) > kTSAIChatDockCancelThreshold;
            if (cancelling != self.cancelling) {
                self.cancelling = cancelling;
                if (self.onPressMoved) self.onPressMoved(cancelling);
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            BOOL cancelled = self.cancelling || gesture.state != UIGestureRecognizerStateEnded;
            self.cancelling = NO;
            if (self.onPressEnded) self.onPressEnded(cancelled);
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        self.capsule.layer.borderColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.38].CGColor;
        self.focusRing.alpha = 1;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.isRecording) return;
    [UIView animateWithDuration:0.2 animations:^{
        self.capsule.layer.borderColor = TSAIChatGlassLineColor().CGColor;
        self.focusRing.alpha = 0;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submitText];
    return NO;
}

#pragma mark - 属性（懒加载）

- (UIImpactFeedbackGenerator *)pressFeedback {
    if (!_pressFeedback) {
        _pressFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return _pressFeedback;
}

- (UISelectionFeedbackGenerator *)readyFeedback {
    if (!_readyFeedback) {
        _readyFeedback = [[UISelectionFeedbackGenerator alloc] init];
    }
    return _readyFeedback;
}

@end
