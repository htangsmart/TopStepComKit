//
//  TSAIChatRoundView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatRoundView.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIChatOrbView.h"
#import "TSAIChatTheme.h"

#pragma mark - 播放条

/// 5 根播放条：宽 3，间距 2.5，高 4 → 14 → 4，.8s，延迟 0/.12/.24/.36/.18
@interface TSAIChatPlayBarsView : UIView
@property (nonatomic, assign) BOOL white;
- (void)restart;
@end

@implementation TSAIChatPlayBarsView {
    NSArray<CAGradientLayer *> *_bars;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 3 * 5 + 2.5 * 4, 14)];
    if (self) {
        NSMutableArray *bars = [NSMutableArray array];
        for (NSInteger index = 0; index < 5; index++) {
            CAGradientLayer *bar = [CAGradientLayer layer];
            bar.startPoint = CGPointMake(0.5, 0);
            bar.endPoint = CGPointMake(0.5, 1);
            bar.cornerRadius = 1.5;
            bar.anchorPoint = CGPointMake(0.5, 0.5);
            bar.bounds = CGRectMake(0, 0, 3, 14);
            bar.position = CGPointMake(1.5 + index * 5.5, 7);
            [self.layer addSublayer:bar];
            [bars addObject:bar];
        }
        _bars = bars;
        self.white = NO;
    }
    return self;
}

- (void)setWhite:(BOOL)white {
    _white = white;
    for (CAGradientLayer *bar in _bars) {
        bar.colors = white
            ? @[(id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor]
            : @[(id)TSAIChatMintColor().CGColor, (id)TSAIChatSkyColor().CGColor];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) [self restart];
}

- (void)restart {
    NSTimeInterval delays[5] = {0, 0.12, 0.24, 0.36, 0.18};
    for (NSInteger index = 0; index < 5; index++) {
        CAGradientLayer *bar = _bars[index];
        [bar removeAnimationForKey:@"tsai.bar"];
        if (TSAIChatReduceMotion()) {
            bar.transform = CATransform3DMakeScale(1, 0.6, 1);
            continue;
        }
        CAKeyframeAnimation *bounce = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
        bounce.values = @[@(4.0 / 14), @1, @(4.0 / 14)];
        bounce.keyTimes = @[@0, @0.5, @1];
        bounce.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        bounce.duration = 0.8;
        bounce.beginTime = CACurrentMediaTime() + delays[index];
        bounce.repeatCount = HUGE_VALF;
        [bar addAnimation:bounce forKey:@"tsai.bar"];
    }
}

@end

#pragma mark - 三色点

/// 三色点：7pt 圆 violet / sky / mint，上下 5pt，1.1s，延迟 0/.15/.3
@interface TSAIChatThinkDotsView : UIView
- (void)restart;
@end

@implementation TSAIChatThinkDotsView {
    NSArray<CALayer *> *_dots;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 7 * 3 + 5 * 2, 17)];
    if (self) {
        NSArray<UIColor *> *colors = @[TSAIChatVioletColor(), TSAIChatSkyColor(), TSAIChatMintColor()];
        NSMutableArray *dots = [NSMutableArray array];
        for (NSInteger index = 0; index < 3; index++) {
            CALayer *dot = [CALayer layer];
            dot.bounds = CGRectMake(0, 0, 7, 7);
            dot.cornerRadius = 3.5;
            dot.backgroundColor = colors[index].CGColor;
            dot.position = CGPointMake(3.5 + index * 12, 11);
            [self.layer addSublayer:dot];
            [dots addObject:dot];
        }
        _dots = dots;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) [self restart];
}

- (void)restart {
    NSTimeInterval delays[3] = {0, 0.15, 0.3};
    for (NSInteger index = 0; index < 3; index++) {
        CALayer *dot = _dots[index];
        [dot removeAnimationForKey:@"tsai.think"];
        if (TSAIChatReduceMotion()) continue;
        CAKeyframeAnimation *hop = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
        hop.values = @[@0, @(-5), @0];
        hop.keyTimes = @[@0, @0.5, @1];
        hop.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        hop.duration = 1.1;
        hop.beginTime = CACurrentMediaTime() + delays[index];
        hop.repeatCount = HUGE_VALF;
        [dot addAnimation:hop forKey:@"tsai.think"];
    }
}

@end

#pragma mark - 轮视图

static const CGFloat kTSAIChatBubbleMaxWidthRatio = 0.84;
static const CGFloat kTSAIChatBubblePaddingV = 11;
static const CGFloat kTSAIChatBubblePaddingH = 14;
static const CGFloat kTSAIChatBubbleGap = 8;

/// 四角独立圆角的气泡路径（TL / TR / BR / BL）
static UIBezierPath *TSAIChatBubblePath(CGRect rect, CGFloat tl, CGFloat tr, CGFloat br, CGFloat bl) {
    CGFloat w = CGRectGetWidth(rect), h = CGRectGetHeight(rect);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(tl, 0)];
    [path addLineToPoint:CGPointMake(w - tr, 0)];
    [path addArcWithCenter:CGPointMake(w - tr, tr) radius:tr startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(w, h - br)];
    [path addArcWithCenter:CGPointMake(w - br, h - br) radius:br startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bl, h)];
    [path addArcWithCenter:CGPointMake(bl, h - bl) radius:bl startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, tl)];
    [path addArcWithCenter:CGPointMake(tl, tl) radius:tl startAngle:M_PI endAngle:M_PI * 1.5 clockwise:YES];
    [path closePath];
    return path;
}

@interface TSAIChatRoundView ()

@property (nonatomic, strong, readwrite) TSAIChatRoundModel *model;

// 用户气泡
@property (nonatomic, strong) UIView *meBubble;
@property (nonatomic, strong) CAGradientLayer *meGradient;
@property (nonatomic, strong) UIImageView *meMetaIcon;
@property (nonatomic, strong) UILabel *meMetaLabel;
@property (nonatomic, strong) UILabel *meTextLabel;
@property (nonatomic, strong) TSAIChatPlayBarsView *meBars;
@property (nonatomic, strong) UIView *meCursor;

// AI 气泡
@property (nonatomic, strong) UIView *aiBubble;
@property (nonatomic, strong) CAShapeLayer *aiGlassLayer;
@property (nonatomic, strong) TSAIChatOrbView *aiMetaOrb;
@property (nonatomic, strong) TSAIChatPlayBarsView *aiMetaBars;
@property (nonatomic, strong) UIImageView *aiMetaIcon;
@property (nonatomic, strong) UILabel *aiMetaLabel;
@property (nonatomic, strong) TSAIChatThinkDotsView *aiDots;
@property (nonatomic, strong) UILabel *aiTextLabel;
@property (nonatomic, strong) UIView *aiCursor;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) NSMutableArray<UIView *> *intentTags;

// 入场标记
@property (nonatomic, assign) BOOL meEntered;
@property (nonatomic, assign) BOOL aiEntered;
// 光标闪烁定时器
@property (nonatomic, strong, nullable) NSTimer *cursorTimer;

@end

@implementation TSAIChatRoundView

#pragma mark - 生命周期

- (instancetype)initWithModel:(TSAIChatRoundModel *)model {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _model = model;
        _intentTags = [NSMutableArray array];
        [self buildMeBubble];
        [self buildAIBubble];
        self.meBubble.alpha = 0;
        self.aiBubble.alpha = 0;
        [self refresh];
    }
    return self;
}

- (void)dealloc {
    [_cursorTimer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutWithWidth:CGRectGetWidth(self.bounds) apply:YES];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self updateCursorTimer];
    } else {
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
    }
}

#pragma mark - 公开方法

- (void)refresh {
    TSAIChatRoundModel *model = self.model;
    BOOL isText = model.source == TSAIChatRoundSourceText;
    BOOL recognizing = model.state == TSAIChatRoundStateRecognizing || model.state == TSAIChatRoundStateRecording;

    // 用户气泡
    NSString *meMeta = isText ? @"文字" : TSAIChatClockString(model.inputDuration);
    if (recognizing && !isText) meMeta = [meMeta stringByAppendingString:@" · 识别中"];
    self.meMetaLabel.text = meMeta;
    self.meMetaIcon.image = TSAIChatSymbol(isText ? @"keyboard" : @"mic.fill", 10, UIImageSymbolWeightSemibold);
    BOOL hasQuestion = model.question.length > 0;
    self.meBars.hidden = !(recognizing && !hasQuestion && !isText);
    self.meTextLabel.hidden = !hasQuestion;
    self.meTextLabel.attributedText = [self bodyTextWithString:model.question ?: @"" color:[UIColor whiteColor]];
    self.meCursor.hidden = !(recognizing && hasQuestion && !model.questionFinal);
    self.meBubble.hidden = NO;

    // AI 气泡
    BOOL showAI = model.state != TSAIChatRoundStateRecording && model.state != TSAIChatRoundStateRecognizing;
    if (model.state == TSAIChatRoundStateError) showAI = YES;
    self.aiBubble.hidden = !showAI;
    BOOL hasAnswer = model.answer.length > 0;
    self.aiMetaOrb.hidden = YES;
    self.aiMetaBars.hidden = YES;
    self.aiMetaIcon.hidden = YES;
    self.aiDots.hidden = YES;
    self.aiCursor.hidden = YES;
    self.retryButton.hidden = YES;
    self.aiTextLabel.hidden = NO;
    self.aiMetaLabel.textColor = TSAIChatInk3Color();
    self.aiGlassLayer.strokeColor = TSAIChatGlassLineColor().CGColor;
    self.aiGlassLayer.lineWidth = 1;
    self.aiTextLabel.attributedText = [self bodyTextWithString:model.answer ?: @"" color:TSAIChatInkColor()];
    switch (model.state) {
        case TSAIChatRoundStateAnswering:
            self.aiMetaOrb.hidden = NO;
            if (!hasAnswer && model.statusText.length > 0) {
                // App 侧正在处理意图（如获取位置）：用进度文案代替「想一想」
                self.aiMetaLabel.text = model.statusText;
            } else {
                self.aiMetaLabel.text = hasAnswer ? (model.answerFinal ? @"准备播放" : @"回答中") : @"想一想";
            }
            self.aiDots.hidden = hasAnswer;
            self.aiTextLabel.hidden = !hasAnswer;
            self.aiCursor.hidden = !hasAnswer || model.answerFinal;
            break;
        case TSAIChatRoundStateSpeaking:
            self.aiMetaBars.hidden = NO;
            self.aiMetaLabel.text = @"播放中 · 点击停止";
            self.aiGlassLayer.strokeColor = [TSAIChatMintColor() colorWithAlphaComponent:0.33].CGColor;
            self.aiGlassLayer.lineWidth = 2;
            break;
        case TSAIChatRoundStateDone:
            self.aiMetaIcon.hidden = NO;
            self.aiMetaIcon.image = TSAIChatSymbol(@"checkmark.circle.fill", 11, UIImageSymbolWeightBold);
            self.aiMetaIcon.tintColor = TSAIChatMintColor();
            self.aiMetaLabel.text = @"已回答";
            break;
        case TSAIChatRoundStateError: {
            // 执行不了的指令意图（如播放音乐）：中性提示，不给「重试」（重试仍会命中同一指令）
            BOOL unsupported = model.intentStatus == TSAIChatRoundIntentStatusUnsupported;
            UIColor *tintColor = unsupported ? TSAIChatAmberColor() : TSAIChatRoseColor();
            self.aiMetaIcon.hidden = NO;
            self.aiMetaIcon.image = TSAIChatSymbol(unsupported ? @"bolt.slash.fill" : @"exclamationmark.triangle.fill",
                                                   11, UIImageSymbolWeightBold);
            self.aiMetaIcon.tintColor = tintColor;
            self.aiMetaLabel.textColor = unsupported ? TSAIChatInk2Color() : TSAIChatRoseColor();
            self.aiMetaLabel.text = model.errorText.length > 0 ? model.errorText : @"出错了";
            self.aiGlassLayer.strokeColor = [tintColor colorWithAlphaComponent:0.33].CGColor;
            self.aiTextLabel.attributedText = [self bodyTextWithString:model.errorBodyText.length > 0
                                                                            ? model.errorBodyText
                                                                            : @"没听清这句话，再按住说一遍试试。"
                                                                 color:TSAIChatInkColor()];
            self.retryButton.hidden = unsupported;
            break;
        }
        default:
            break;
    }
    [self rebuildIntentTags];
    [self updateCursorTimer];
    [self setNeedsLayout];
    [self.superview setNeedsLayout];
}

- (void)playEntranceIfNeeded {
    if (!self.meEntered && !self.meBubble.hidden) {
        self.meEntered = YES;
        TSAIChatPopIn(self.meBubble, 0.45, 0);
    }
    if (!self.aiEntered && !self.aiBubble.hidden) {
        self.aiEntered = YES;
        TSAIChatPopIn(self.aiBubble, 0.45, 0);
    }
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [self layoutWithWidth:width apply:NO];
}

#pragma mark - 私有方法 - 构建

/// 用户气泡：圆角 20 / 右下 6，gradPrimary，阴影 (0,8) blur20 violet α.19
- (void)buildMeBubble {
    self.meBubble = [[UIView alloc] init];
    self.meBubble.layer.shadowColor = TSAIChatVioletColor().CGColor;
    self.meBubble.layer.shadowOpacity = 0.19;
    self.meBubble.layer.shadowOffset = CGSizeMake(0, 8);
    self.meBubble.layer.shadowRadius = 10;
    self.meGradient = TSAIChatPrimaryGradientLayer();
    self.meGradient.mask = [CAShapeLayer layer];
    [self.meBubble.layer addSublayer:self.meGradient];
    [self addSubview:self.meBubble];

    self.meMetaIcon = [[UIImageView alloc] init];
    self.meMetaIcon.tintColor = [UIColor colorWithWhite:1 alpha:0.85];
    self.meMetaIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.meBubble addSubview:self.meMetaIcon];

    self.meMetaLabel = [[UILabel alloc] init];
    self.meMetaLabel.font = TSAIChatFont(11, UIFontWeightMedium);
    self.meMetaLabel.textColor = [UIColor colorWithWhite:1 alpha:0.85];
    [self.meBubble addSubview:self.meMetaLabel];

    self.meTextLabel = [[UILabel alloc] init];
    self.meTextLabel.numberOfLines = 0;
    [self.meBubble addSubview:self.meTextLabel];

    self.meBars = [[TSAIChatPlayBarsView alloc] init];
    self.meBars.white = YES;
    [self.meBubble addSubview:self.meBars];

    self.meCursor = [self makeCursorWithColor:[UIColor whiteColor]];
    [self.meBubble addSubview:self.meCursor];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPress.minimumPressDuration = 0.45;
    [self.meBubble addGestureRecognizer:longPress];
}

/// AI 气泡：圆角 20 / 左下 6，glass，描边 glassLine，shadow
- (void)buildAIBubble {
    self.aiBubble = [[UIView alloc] init];
    self.aiBubble.backgroundColor = [UIColor clearColor];
    TSAIChatApplyCardShadow(self.aiBubble.layer);
    self.aiGlassLayer = [CAShapeLayer layer];
    self.aiGlassLayer.fillColor = TSAIChatGlassColor().CGColor;
    self.aiGlassLayer.strokeColor = TSAIChatGlassLineColor().CGColor;
    self.aiGlassLayer.lineWidth = 1;
    [self.aiBubble.layer addSublayer:self.aiGlassLayer];
    [self addSubview:self.aiBubble];

    self.aiMetaOrb = [[TSAIChatOrbView alloc] initWithDiameter:16];
    [self.aiBubble addSubview:self.aiMetaOrb];

    self.aiMetaBars = [[TSAIChatPlayBarsView alloc] init];
    [self.aiBubble addSubview:self.aiMetaBars];

    self.aiMetaIcon = [[UIImageView alloc] init];
    self.aiMetaIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.aiBubble addSubview:self.aiMetaIcon];

    self.aiMetaLabel = [[UILabel alloc] init];
    self.aiMetaLabel.font = TSAIChatFont(11, UIFontWeightMedium);
    self.aiMetaLabel.textColor = TSAIChatInk3Color();
    [self.aiBubble addSubview:self.aiMetaLabel];

    self.aiDots = [[TSAIChatThinkDotsView alloc] init];
    [self.aiBubble addSubview:self.aiDots];

    self.aiTextLabel = [[UILabel alloc] init];
    self.aiTextLabel.numberOfLines = 0;
    [self.aiBubble addSubview:self.aiTextLabel];

    self.aiCursor = [self makeCursorWithColor:TSAIChatVioletColor()];
    [self.aiBubble addSubview:self.aiCursor];

    self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retryButton setTitle:@"重试" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:TSAIChatVioletColor() forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = TSAIChatFont(13, UIFontWeightBold);
    [self.retryButton setImage:TSAIChatSymbol(@"arrow.clockwise", 12, UIImageSymbolWeightBold) forState:UIControlStateNormal];
    self.retryButton.tintColor = TSAIChatVioletColor();
    self.retryButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
    self.retryButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
    [self.retryButton addTarget:self action:@selector(onRetryTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.aiBubble addSubview:self.retryButton];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAITapped)];
    [self.aiBubble addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPress.minimumPressDuration = 0.45;
    [self.aiBubble addGestureRecognizer:longPress];
}

/// 光标 2×15
- (UIView *)makeCursorWithColor:(UIColor *)color {
    UIView *cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 15)];
    cursor.backgroundColor = color;
    cursor.layer.cornerRadius = 1;
    return cursor;
}

/// 正文：15pt，行高 1.5
- (NSAttributedString *)bodyTextWithString:(NSString *)string color:(UIColor *)color {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 4.5;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:@{NSFontAttributeName: TSAIChatFont(15, UIFontWeightRegular),
                                                        NSForegroundColorAttributeName: color,
                                                        NSParagraphStyleAttributeName: paragraph}];
}

/// intent 标签：字 11.5/600，内边距 4/10，全圆角，闪电 11
- (void)rebuildIntentTags {
    for (UIView *tag in self.intentTags) [tag removeFromSuperview];
    [self.intentTags removeAllObjects];
    if (self.model.state != TSAIChatRoundStateDone && self.model.state != TSAIChatRoundStateError) return;
    for (TSAIChatIntent *intent in self.model.intents) {
        NSString *name = intent.intentId.length > 0 ? intent.intentId : (intent.query ?: @"intent");
        // 「已执行」只看 App 是否真的处理了该意图，不再按 value 是否非空判断
        BOOL executed = self.model.intentStatus == TSAIChatRoundIntentStatusExecuted;
        NSString *suffix = nil;
        switch (self.model.intentStatus) {
            case TSAIChatRoundIntentStatusExecuted: suffix = @"已执行"; break;
            case TSAIChatRoundIntentStatusFailed:   suffix = @"未完成"; break;
            case TSAIChatRoundIntentStatusPending:  suffix = @"处理中"; break;
            case TSAIChatRoundIntentStatusUnsupported: suffix = @"暂不支持"; break;
            default: break;
        }
        NSString *text = suffix ? [NSString stringWithFormat:@"%@ · %@", name, suffix] : name;

        UIView *tag = [[UIView alloc] init];
        tag.layer.cornerRadius = 12;
        tag.layer.masksToBounds = YES;
        CAGradientLayer *gradient = executed ? TSAIChatMintTagGradientLayer() : TSAIChatAmberTagGradientLayer();
        [tag.layer addSublayer:gradient];
        UIColor *textColor = executed ? [UIColor whiteColor] : TSAIChatHexColor(0x5A3A00);

        UIImageView *icon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"bolt.fill", 9, UIImageSymbolWeightBold)];
        icon.tintColor = textColor;
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.frame = CGRectMake(10, 6.5, 11, 11);
        [tag addSubview:icon];

        UILabel *label = [[UILabel alloc] init];
        label.text = text;
        label.font = TSAIChatFont(11.5, UIFontWeightSemibold);
        label.textColor = textColor;
        CGSize size = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, 16)];
        label.frame = CGRectMake(10 + 11 + 4, 4, ceil(size.width), 16);
        [tag addSubview:label];

        tag.bounds = CGRectMake(0, 0, 10 + 11 + 4 + ceil(size.width) + 10, 24);
        gradient.frame = tag.bounds;
        [self.aiBubble addSubview:tag];
        [self.intentTags addObject:tag];
    }
}

#pragma mark - 私有方法 - 布局

/// 布局并返回总高；apply = NO 时只计算
- (CGFloat)layoutWithWidth:(CGFloat)width apply:(BOOL)apply {
    CGFloat maxBubbleWidth = floor(width * kTSAIChatBubbleMaxWidthRatio);
    CGFloat textMaxWidth = maxBubbleWidth - kTSAIChatBubblePaddingH * 2;
    CGFloat y = 0;

    // 用户气泡
    CGFloat metaWidth = 12 + 6 + ceil([self.meMetaLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 14)].width);
    CGFloat contentWidth = metaWidth;
    CGFloat contentHeight = 0;
    CGSize meTextSize = CGSizeZero;
    if (!self.meTextLabel.hidden) {
        meTextSize = [self.meTextLabel sizeThatFits:CGSizeMake(textMaxWidth - (self.meCursor.hidden ? 0 : 6), CGFLOAT_MAX)];
        meTextSize.width = ceil(meTextSize.width);
        meTextSize.height = ceil(meTextSize.height);
        contentWidth = MAX(contentWidth, meTextSize.width + (self.meCursor.hidden ? 0 : 6));
        contentHeight = meTextSize.height;
    } else if (!self.meBars.hidden) {
        contentWidth = MAX(contentWidth, CGRectGetWidth(self.meBars.bounds));
        contentHeight = 18;
    }
    CGFloat meWidth = MIN(maxBubbleWidth, contentWidth + kTSAIChatBubblePaddingH * 2);
    CGFloat meHeight = kTSAIChatBubblePaddingV + 14 + 5 + contentHeight + kTSAIChatBubblePaddingV;
    if (apply) {
        self.meBubble.frame = CGRectMake(width - meWidth, y, meWidth, meHeight);
        self.meGradient.frame = self.meBubble.bounds;
        UIBezierPath *mePath = TSAIChatBubblePath(self.meBubble.bounds, 20, 20, 6, 20);
        ((CAShapeLayer *)self.meGradient.mask).frame = self.meBubble.bounds;
        ((CAShapeLayer *)self.meGradient.mask).path = mePath.CGPath;
        self.meBubble.layer.shadowPath = mePath.CGPath;
        self.meMetaIcon.frame = CGRectMake(kTSAIChatBubblePaddingH, kTSAIChatBubblePaddingV + 1, 12, 12);
        self.meMetaLabel.frame = CGRectMake(kTSAIChatBubblePaddingH + 18, kTSAIChatBubblePaddingV, meWidth - kTSAIChatBubblePaddingH * 2 - 18, 14);
        CGFloat bodyY = kTSAIChatBubblePaddingV + 14 + 5;
        self.meTextLabel.frame = CGRectMake(kTSAIChatBubblePaddingH, bodyY, meTextSize.width, meTextSize.height);
        self.meBars.center = CGPointMake(kTSAIChatBubblePaddingH + CGRectGetWidth(self.meBars.bounds) / 2, bodyY + 9);
        self.meCursor.frame = CGRectMake(kTSAIChatBubblePaddingH + meTextSize.width + 3, bodyY + meTextSize.height - 17, 2, 15);
    }
    y += meHeight;

    // AI 气泡
    if (!self.aiBubble.hidden) {
        y += kTSAIChatBubbleGap;
        CGFloat aiMetaLead = 16 + 6;
        if (!self.aiMetaBars.hidden) aiMetaLead = CGRectGetWidth(self.aiMetaBars.bounds) + 6;
        if (!self.aiMetaIcon.hidden) aiMetaLead = 12 + 6;
        CGSize aiMetaSize = [self.aiMetaLabel sizeThatFits:CGSizeMake(textMaxWidth - aiMetaLead, CGFLOAT_MAX)];
        aiMetaSize.width = ceil(aiMetaSize.width);
        aiMetaSize.height = MAX(16, ceil(aiMetaSize.height));
        CGFloat aiContentWidth = aiMetaLead + aiMetaSize.width;
        CGFloat aiBodyHeight = 0;
        CGSize aiTextSize = CGSizeZero;
        if (!self.aiDots.hidden) {
            aiContentWidth = MAX(aiContentWidth, CGRectGetWidth(self.aiDots.bounds));
            aiBodyHeight = 17;
        } else if (!self.aiTextLabel.hidden) {
            aiTextSize = [self.aiTextLabel sizeThatFits:CGSizeMake(textMaxWidth - (self.aiCursor.hidden ? 0 : 6), CGFLOAT_MAX)];
            aiTextSize.width = ceil(aiTextSize.width);
            aiTextSize.height = ceil(aiTextSize.height);
            aiContentWidth = MAX(aiContentWidth, aiTextSize.width + (self.aiCursor.hidden ? 0 : 6));
            aiBodyHeight = aiTextSize.height;
        }
        CGFloat tagsHeight = 0;
        if (self.intentTags.count > 0) {
            tagsHeight = 8;
            CGFloat lineWidth = 0;
            NSInteger lines = 1;
            for (UIView *tag in self.intentTags) {
                CGFloat tagWidth = CGRectGetWidth(tag.bounds);
                if (lineWidth > 0 && lineWidth + 6 + tagWidth > textMaxWidth) { lines++; lineWidth = 0; }
                lineWidth += (lineWidth > 0 ? 6 : 0) + tagWidth;
                aiContentWidth = MAX(aiContentWidth, MIN(textMaxWidth, lineWidth));
            }
            tagsHeight += lines * 24 + (lines - 1) * 6;
        }
        CGFloat retryHeight = self.retryButton.hidden ? 0 : 8 + 20;
        if (!self.retryButton.hidden) aiContentWidth = MAX(aiContentWidth, 60);
        CGFloat aiWidth = MIN(maxBubbleWidth, aiContentWidth + kTSAIChatBubblePaddingH * 2);
        CGFloat aiHeight = kTSAIChatBubblePaddingV + aiMetaSize.height + 6 + aiBodyHeight + tagsHeight + retryHeight + kTSAIChatBubblePaddingV;
        if (apply) {
            self.aiBubble.frame = CGRectMake(0, y, aiWidth, aiHeight);
            UIBezierPath *aiPath = TSAIChatBubblePath(self.aiBubble.bounds, 20, 20, 20, 6);
            self.aiGlassLayer.frame = self.aiBubble.bounds;
            self.aiGlassLayer.path = aiPath.CGPath;
            self.aiBubble.layer.shadowPath = aiPath.CGPath;
            CGFloat metaY = kTSAIChatBubblePaddingV;
            self.aiMetaOrb.center = CGPointMake(kTSAIChatBubblePaddingH + 8, metaY + 8);
            self.aiMetaBars.center = CGPointMake(kTSAIChatBubblePaddingH + CGRectGetWidth(self.aiMetaBars.bounds) / 2, metaY + 8);
            self.aiMetaIcon.frame = CGRectMake(kTSAIChatBubblePaddingH, metaY + 2, 12, 12);
            self.aiMetaLabel.frame = CGRectMake(kTSAIChatBubblePaddingH + aiMetaLead, metaY, aiWidth - kTSAIChatBubblePaddingH * 2 - aiMetaLead, aiMetaSize.height);
            CGFloat bodyY = metaY + aiMetaSize.height + 6;
            self.aiDots.frame = CGRectMake(kTSAIChatBubblePaddingH, bodyY, CGRectGetWidth(self.aiDots.bounds), 17);
            self.aiTextLabel.frame = CGRectMake(kTSAIChatBubblePaddingH, bodyY, aiTextSize.width, aiTextSize.height);
            self.aiCursor.frame = CGRectMake(kTSAIChatBubblePaddingH + aiTextSize.width + 3, bodyY + aiTextSize.height - 17, 2, 15);
            CGFloat tagY = bodyY + aiBodyHeight + 8;
            CGFloat tagX = kTSAIChatBubblePaddingH;
            for (UIView *tag in self.intentTags) {
                CGFloat tagWidth = CGRectGetWidth(tag.bounds);
                if (tagX > kTSAIChatBubblePaddingH && tagX + tagWidth > aiWidth - kTSAIChatBubblePaddingH) {
                    tagX = kTSAIChatBubblePaddingH;
                    tagY += 24 + 6;
                }
                tag.frame = CGRectMake(tagX, tagY, tagWidth, 24);
                tagX += tagWidth + 6;
            }
            self.retryButton.frame = CGRectMake(kTSAIChatBubblePaddingH, bodyY + aiBodyHeight + 8, 70, 20);
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        y += aiHeight;
    }
    return y;
}

/// 光标闪烁：1s 步进
- (void)updateCursorTimer {
    BOOL needsCursor = (!self.meCursor.hidden && !self.meBubble.hidden) || (!self.aiCursor.hidden && !self.aiBubble.hidden);
    if (needsCursor && self.window) {
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
        self.meCursor.alpha = 1;
        self.aiCursor.alpha = 1;
    }
}

#pragma mark - 事件

- (void)onCursorTick {
    CGFloat alpha = self.meCursor.alpha > 0.5 ? 0 : 1;
    self.meCursor.alpha = alpha;
    self.aiCursor.alpha = alpha;
}

- (void)onAITapped {
    if (self.model.state == TSAIChatRoundStateSpeaking) {
        [self.delegate roundViewDidTapSpeakingBubble:self];
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    if (self.model.state != TSAIChatRoundStateDone) return;
    BOOL isUser = gesture.view == self.meBubble;
    [self.delegate roundView:self didLongPressBubble:gesture.view isUserBubble:isUser];
}

- (void)onRetryTapped {
    [self.delegate roundViewDidTapRetry:self];
}

@end
