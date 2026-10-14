//
//  TSAIChatFlowView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatFlowView.h"

#import "TSAIChatTheme.h"

/// 光球容器边长 / 光球与状态文案间距 / 状态文案与正文间距 / 正文最小占位
static const CGFloat kTSAIChatFlowOrbSide = 240;
static const CGFloat kTSAIChatFlowOrbGap = 22;
static const CGFloat kTSAIChatFlowStatusGap = 16;
static const CGFloat kTSAIChatFlowMinTextHeight = 70;
/// 文字放不下时光球收缩让位：240 → 144，间距 22 → 12
static const CGFloat kTSAIChatFlowCompactOrbScale = 0.6;
static const CGFloat kTSAIChatFlowCompactOrbGap = 12;
/// 文字滚动区：底部留白、上下渐隐高度
static const CGFloat kTSAIChatFlowTextBottomPadding = 16;
static const CGFloat kTSAIChatFlowTextTopFade = 18;
static const CGFloat kTSAIChatFlowTextBottomFade = 36;

@interface TSAIChatFlowView () <UIScrollViewDelegate>

// 240 容器
@property (nonatomic, strong) UIView *orbContainer;
// 光球 150
@property (nonatomic, strong) TSAIChatOrbView *orbView;
// 3 道涟漪
@property (nonatomic, strong) NSArray<UIView *> *ripples;
// 均衡器 5 根
@property (nonatomic, strong) UIView *equalizer;
@property (nonatomic, strong) NSArray<CALayer *> *equalizerBars;
// 状态文案
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
// 当前轮文字滚动区（长回答可滚动，上下边缘渐隐）
@property (nonatomic, strong) UIView *textViewport;
@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) CAGradientLayer *textFadeMask;
// 当前是否为收缩态（光球缩小让位给文字）
@property (nonatomic, assign) BOOL compactStage;
// 上次布局时文字是否可滚动（首次可滚动时闪一下滚动条）
@property (nonatomic, assign) BOOL textScrollable;
// 当前轮文字
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UILabel *answerLabel;
@property (nonatomic, strong) UIView *cursor;
@property (nonatomic, strong, nullable) NSTimer *cursorTimer;

@end

@implementation TSAIChatFlowView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _orbContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
        [self addSubview:_orbContainer];

        NSMutableArray *ripples = [NSMutableArray array];
        for (NSInteger index = 0; index < 3; index++) {
            UIView *ripple = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240)];
            ripple.center = CGPointMake(120, 120);
            ripple.layer.cornerRadius = 120;
            ripple.layer.borderWidth = 2;
            ripple.layer.borderColor = [TSAIChatSkyColor() colorWithAlphaComponent:0.40].CGColor;
            ripple.hidden = YES;
            ripple.userInteractionEnabled = NO;
            [_orbContainer addSubview:ripple];
            [ripples addObject:ripple];
        }
        _ripples = ripples;

        _orbView = [[TSAIChatOrbView alloc] initWithDiameter:150];
        _orbView.center = CGPointMake(120, 120);
        [_orbContainer addSubview:_orbView];

        _equalizer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7 * 5 + 6 * 4, 46)];
        _equalizer.center = CGPointMake(120, 120);
        _equalizer.hidden = YES;
        _equalizer.userInteractionEnabled = NO;
        NSMutableArray *bars = [NSMutableArray array];
        for (NSInteger index = 0; index < 5; index++) {
            CALayer *bar = [CALayer layer];
            bar.backgroundColor = [UIColor whiteColor].CGColor;
            bar.cornerRadius = 3.5;
            bar.bounds = CGRectMake(0, 0, 7, 46);
            bar.position = CGPointMake(3.5 + index * 13, 23);
            bar.shadowColor = [UIColor blackColor].CGColor;
            bar.shadowOpacity = 0.13;
            bar.shadowOffset = CGSizeMake(0, 2);
            bar.shadowRadius = 4;
            [_equalizer.layer addSublayer:bar];
            [bars addObject:bar];
        }
        _equalizerBars = bars;
        [_orbContainer addSubview:_equalizer];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOrbTapped)];
        [_orbContainer addGestureRecognizer:tap];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = TSAIChatFont(13, UIFontWeightRegular);
        _subtitleLabel.textColor = TSAIChatInk2Color();
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.numberOfLines = 2;
        [self addSubview:_subtitleLabel];

        _textViewport = [[UIView alloc] init];
        [self addSubview:_textViewport];
        _textFadeMask = [CAGradientLayer layer];
        _textFadeMask.startPoint = CGPointMake(0.5, 0);
        _textFadeMask.endPoint = CGPointMake(0.5, 1);
        _textViewport.layer.mask = _textFadeMask;

        _textScrollView = [[UIScrollView alloc] init];
        _textScrollView.delegate = self;
        _textScrollView.showsHorizontalScrollIndicator = NO;
        _textScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_textViewport addSubview:_textScrollView];

        _questionLabel = [[UILabel alloc] init];
        _questionLabel.numberOfLines = 0;
        _questionLabel.textAlignment = NSTextAlignmentCenter;
        [_textScrollView addSubview:_questionLabel];

        _answerLabel = [[UILabel alloc] init];
        _answerLabel.numberOfLines = 0;
        _answerLabel.textAlignment = NSTextAlignmentCenter;
        [_textScrollView addSubview:_answerLabel];

        _cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 16)];
        _cursor.backgroundColor = TSAIChatSkyColor();
        _cursor.layer.cornerRadius = 1;
        _cursor.hidden = YES;
        [_textScrollView addSubview:_cursor];

        _orbState = TSAIChatOrbStateIdle;
        [self applyTexts];
    }
    return self;
}

- (void)dealloc {
    [_cursorTimer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat contentWidth = width - 48;

    CGFloat subtitleHeight = ceil([self.subtitleLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height);
    CGFloat statusHeight = MAX(56, 28 + 6 + subtitleHeight);
    CGFloat questionHeight = ceil([self.questionLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height);
    CGFloat answerHeight = ceil([self.answerLabel sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)].height);
    CGFloat textHeight = questionHeight + (answerHeight > 0 ? 8 + answerHeight : 0);

    // 常规布局（240 光球）放不下当前轮文字 → 光球收缩让位；新一轮文字变短后自动恢复
    CGFloat regularHeight = kTSAIChatFlowOrbSide + kTSAIChatFlowOrbGap + statusHeight + kTSAIChatFlowStatusGap
                          + MAX(kTSAIChatFlowMinTextHeight, textHeight);
    BOOL compact = textHeight > 0 && regularHeight > height;
    CGFloat orbScale = compact ? kTSAIChatFlowCompactOrbScale : 1;
    CGFloat orbSide = kTSAIChatFlowOrbSide * orbScale;
    CGFloat orbGap = compact ? kTSAIChatFlowCompactOrbGap : kTSAIChatFlowOrbGap;
    CGFloat headerHeight = orbSide + orbGap + statusHeight + kTSAIChatFlowStatusGap;

    // 收缩后仍放不下 → 文字区占满剩余高度并可滚动
    CGFloat availableHeight = MAX(0, height - headerHeight);
    BOOL scrollable = textHeight > availableHeight;
    CGFloat viewportHeight = scrollable ? availableHeight : textHeight;
    CGFloat totalHeight = headerHeight + (compact ? viewportHeight : MAX(kTSAIChatFlowMinTextHeight, textHeight));
    CGFloat y = MAX(0, (height - totalHeight) / 2);

    BOOL animateStage = compact != self.compactStage && self.window != nil && !TSAIChatReduceMotion();
    self.compactStage = compact;
    void (^applyStage)(void) = ^{
        self.orbContainer.transform = CGAffineTransformMakeScale(orbScale, orbScale);
        self.orbContainer.center = CGPointMake(width / 2, y + orbSide / 2);
        CGFloat statusY = y + orbSide + orbGap;
        self.titleLabel.frame = CGRectMake(24, statusY, contentWidth, 28);
        self.subtitleLabel.frame = CGRectMake(24, statusY + 28 + 6, contentWidth, subtitleHeight);
        self.textViewport.frame = CGRectMake(0, statusY + statusHeight + kTSAIChatFlowStatusGap, width, viewportHeight);
        self.textScrollView.frame = self.textViewport.bounds;
    };
    if (animateStage) {
        [UIView animateWithDuration:0.45
                              delay:0
             usingSpringWithDamping:0.86
              initialSpringVelocity:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:applyStage
                         completion:nil];
    } else {
        applyStage();
    }

    // 滚动区内：问题 → 回答 → 光标
    self.questionLabel.frame = CGRectMake(24, 0, contentWidth, questionHeight);
    CGFloat answerY = questionHeight + (answerHeight > 0 ? 8 : 0);
    self.answerLabel.frame = CGRectMake(24, answerY, contentWidth, answerHeight);
    CGRect lastLine = [self lastLineRectOfLabel:self.answerLabel];
    self.cursor.frame = CGRectMake(CGRectGetMinX(self.answerLabel.frame) + CGRectGetMaxX(lastLine) + 3,
                                   CGRectGetMinY(self.answerLabel.frame) + CGRectGetMaxY(lastLine) - 18, 2, 16);

    UIScrollView *scrollView = self.textScrollView;
    scrollView.contentSize = CGSizeMake(width, textHeight + (scrollable ? kTSAIChatFlowTextBottomPadding : 0));
    scrollView.scrollEnabled = scrollable;
    // 内容变短（新一轮开始）时把越界的偏移拉回，停在顶部
    if (!scrollView.isDragging && !scrollView.isDecelerating) {
        CGFloat maxOffset = MAX(0, scrollView.contentSize.height - viewportHeight);
        if (scrollView.contentOffset.y > maxOffset) scrollView.contentOffset = CGPointMake(0, maxOffset);
    }
    if (scrollable && !self.textScrollable) [scrollView flashScrollIndicators];
    self.textScrollable = scrollable;
    [self updateTextFade];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self restartAnimations];
    } else {
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
    }
}

#pragma mark - 公开方法

- (void)setOrbState:(TSAIChatOrbState)orbState {
    _orbState = orbState;
    [self.orbView setState:orbState animated:YES];
    [self restartAnimations];
}

- (void)setStatusTitle:(NSString *)statusTitle {
    _statusTitle = [statusTitle copy];
    [self applyTexts];
}

- (void)setStatusSubtitle:(NSString *)statusSubtitle {
    _statusSubtitle = [statusSubtitle copy];
    [self applyTexts];
}

- (void)setQuestionText:(NSString *)questionText {
    _questionText = [questionText copy];
    [self applyTexts];
}

- (void)setAnswerText:(NSString *)answerText {
    _answerText = [answerText copy];
    [self applyTexts];
}

- (void)setAnswerCursorVisible:(BOOL)answerCursorVisible {
    _answerCursorVisible = answerCursorVisible;
    [self applyTexts];
}

- (void)restartAnimations {
    [self.orbView restartAnimations];
    BOOL listening = self.orbState == TSAIChatOrbStateListening;
    BOOL speaking = self.orbState == TSAIChatOrbStateSpeaking;
    NSTimeInterval rippleDelays[3] = {0, 0.85, 1.7};
    for (NSInteger index = 0; index < 3; index++) {
        UIView *ripple = self.ripples[index];
        [ripple.layer removeAnimationForKey:@"tsai.ripple"];
        ripple.hidden = !listening || TSAIChatReduceMotion();
        if (ripple.hidden) continue;
        CAAnimationGroup *group = [CAAnimationGroup animation];
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @0.55;
        scale.toValue = @1.05;
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fade.fromValue = @0.8;
        fade.toValue = @0;
        group.animations = @[scale, fade];
        group.duration = 2.6;
        group.beginTime = CACurrentMediaTime() + rippleDelays[index];
        group.repeatCount = HUGE_VALF;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [ripple.layer addAnimation:group forKey:@"tsai.ripple"];
    }
    self.equalizer.hidden = !speaking;
    NSTimeInterval eqDelays[5] = {0, 0.12, 0.24, 0.1, 0.3};
    for (NSInteger index = 0; index < 5; index++) {
        CALayer *bar = self.equalizerBars[index];
        [bar removeAnimationForKey:@"tsai.eq"];
        if (!speaking) continue;
        if (TSAIChatReduceMotion()) { bar.transform = CATransform3DMakeScale(1, 0.5, 1); continue; }
        CAKeyframeAnimation *bounce = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
        bounce.values = @[@(12.0 / 46), @1, @(12.0 / 46)];
        bounce.keyTimes = @[@0, @0.5, @1];
        bounce.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        bounce.duration = 0.75;
        bounce.beginTime = CACurrentMediaTime() + eqDelays[index];
        bounce.repeatCount = HUGE_VALF;
        [bar addAnimation:bounce forKey:@"tsai.eq"];
    }
    [self updateCursorTimer];
}

#pragma mark - 私有方法

/// 文案与当前轮文字
- (void)applyTexts {
    self.titleLabel.attributedText = [[NSAttributedString alloc]
        initWithString:self.statusTitle ?: @""
            attributes:@{NSFontAttributeName: TSAIChatFont(22, UIFontWeightHeavy),
                         NSForegroundColorAttributeName: TSAIChatInkColor(),
                         NSKernAttributeName: @(-0.3)}];
    self.subtitleLabel.text = self.statusSubtitle ?: @"";

    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 15.5 * 0.55 - 3;
    paragraph.alignment = NSTextAlignmentCenter;
    self.questionLabel.attributedText = [[NSAttributedString alloc]
        initWithString:self.questionText ?: @""
            attributes:@{NSFontAttributeName: TSAIChatFont(15.5, UIFontWeightBold),
                         NSForegroundColorAttributeName: TSAIChatInkColor(),
                         NSParagraphStyleAttributeName: paragraph}];
    self.answerLabel.attributedText = [[NSAttributedString alloc]
        initWithString:self.answerText ?: @""
            attributes:@{NSFontAttributeName: TSAIChatFont(15.5, UIFontWeightRegular),
                         NSForegroundColorAttributeName: TSAIChatInk2Color(),
                         NSParagraphStyleAttributeName: paragraph}];
    self.cursor.hidden = !(self.answerCursorVisible && self.answerText.length > 0);
    [self updateCursorTimer];
    [self setNeedsLayout];
}

/// 文字滚动区上下渐隐：上方有被卷走的内容才淡出顶部，下方还有内容才淡出底部
- (void)updateTextFade {
    CGFloat height = CGRectGetHeight(self.textViewport.bounds);
    UIScrollView *scrollView = self.textScrollView;
    CGFloat offset = scrollView.contentOffset.y;
    BOOL fadeTop = height > 0 && offset > 0.5;
    BOOL fadeBottom = height > 0 && offset + height < scrollView.contentSize.height - 0.5;
    CGFloat topStop = height > 0 ? MIN(0.3, kTSAIChatFlowTextTopFade / height) : 0;
    CGFloat bottomStop = height > 0 ? MIN(0.3, kTSAIChatFlowTextBottomFade / height) : 0;
    id opaque = (__bridge id)[UIColor blackColor].CGColor;
    id clear = (__bridge id)[UIColor clearColor].CGColor;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.textFadeMask.frame = self.textViewport.bounds;
    self.textFadeMask.colors = @[fadeTop ? clear : opaque, opaque, opaque, fadeBottom ? clear : opaque];
    self.textFadeMask.locations = @[@0, @(topStop), @(1 - bottomStop), @1];
    [CATransaction commit];
}

/// 居中多行文本最后一行的矩形（label 坐标系）
- (CGRect)lastLineRectOfLabel:(UILabel *)label {
    if (label.attributedText.length == 0) return CGRectZero;
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:label.attributedText];
    NSLayoutManager *manager = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGRectGetWidth(label.bounds), CGFLOAT_MAX)];
    container.lineFragmentPadding = 0;
    [manager addTextContainer:container];
    [storage addLayoutManager:manager];
    NSRange glyphRange = [manager glyphRangeForTextContainer:container];
    if (glyphRange.length == 0) return CGRectZero;
    NSUInteger lastGlyph = NSMaxRange(glyphRange) - 1;
    CGRect lineRect = [manager lineFragmentUsedRectForGlyphAtIndex:lastGlyph effectiveRange:NULL];
    CGFloat offset = (CGRectGetWidth(label.bounds) - CGRectGetWidth(lineRect)) / 2;
    return CGRectOffset(lineRect, offset, 0);
}

/// 光标闪烁
- (void)updateCursorTimer {
    if (!self.cursor.hidden && self.window) {
        if (!self.cursorTimer) {
            self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                target:self
                                                              selector:@selector(onCursorTick)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    } else {
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursor.alpha = 1;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateTextFade];
}

#pragma mark - 事件

- (void)onCursorTick {
    self.cursor.alpha = self.cursor.alpha > 0.5 ? 0 : 1;
}

- (void)onOrbTapped {
    if (self.onOrbTap) self.onOrbTap();
}

@end
