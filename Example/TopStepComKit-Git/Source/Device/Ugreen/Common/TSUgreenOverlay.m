//
//  TSUgreenOverlay.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSUgreenOverlay.h"

#import "TSRootVC.h"
#import "TSHsdDisplay.h"
#import "TSHsdViews.h"
#import "TSUgreenDisplay.h"

/** 0xRRGGBB → UIColor */
static UIColor *TSUgOvRGB(NSInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.f green:((hex >> 8) & 0xFF) / 255.f blue:(hex & 0xFF) / 255.f alpha:1.f];
}

/** 遮罩色（原型 #0a0c14） */
static UIColor *TSUgOvMask(CGFloat alpha) {
    return [TSUgOvRGB(0x0A0C14) colorWithAlphaComponent:alpha];
}

/** 带行高的文字高度 */
static CGFloat TSUgOvTextHeight(NSString *text, UIFont *font, CGFloat width, CGFloat lineMultiple) {
    if (!text.length) { return 0; }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineMultiple;
    style.alignment = NSTextAlignmentCenter;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: style} context:nil];
    return ceil(rect.size.height);
}

/** 带行高的居中富文本 */
static NSAttributedString *TSUgOvText(NSString *text, UIFont *font, UIColor *color, CGFloat lineMultiple) {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineMultiple;
    style.alignment = NSTextAlignmentCenter;
    return [[NSAttributedString alloc] initWithString:text ?: @"" attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: style}];
}

#pragma mark - TSUgreenAlertAction

@interface TSUgreenAlertAction ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, assign, readwrite) TSUgreenAlertActionStyle style;
@property (nonatomic, copy, readwrite, nullable) void (^handler)(void);
@end

@implementation TSUgreenAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(TSUgreenAlertActionStyle)style handler:(nullable void (^)(void))handler {
    TSUgreenAlertAction *action = [[self alloc] init];
    action.title = title;
    action.style = style;
    action.handler = handler;
    return action;
}

@end

#pragma mark - TSUgreenAlertController

static const CGFloat kTSUgAlertWidth = 292.f;

@interface TSUgreenAlertController ()
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) UIColor *tint;
@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) NSString *code;
@property (nonatomic, copy) NSArray<TSUgreenAlertAction *> *actions;
// 遮罩与卡片
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *card;
@property (nonatomic, strong) TSHsdIconBlock *iconBlock;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) NSArray<UIButton *> *buttons;
@property (nonatomic, assign) BOOL appeared;
@property (nonatomic, assign) BOOL closing;
@end

@implementation TSUgreenAlertController

#pragma mark - 生命周期

+ (instancetype)alertWithSymbol:(NSString *)symbol tint:(UIColor *)tint title:(NSString *)title message:(nullable NSString *)message
                           code:(nullable NSString *)code actions:(NSArray<TSUgreenAlertAction *> *)actions {
    TSUgreenAlertController *alert = [[self alloc] init];
    alert.symbol = symbol;
    alert.tint = tint;
    alert.alertTitle = title;
    alert.message = message;
    alert.code = code;
    alert.actions = actions;
    alert.modalPresentationStyle = UIModalPresentationOverFullScreen;
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return alert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.maskView = [[UIView alloc] init];
    self.maskView.backgroundColor = TSUgOvMask(0.4f);
    self.maskView.alpha = 0;
    [self.view addSubview:self.maskView];

    self.card = [[UIView alloc] init];
    self.card.backgroundColor = [TSHsdDisplay card];
    self.card.layer.cornerRadius = 26.f;
    self.card.layer.shadowColor = TSUgOvRGB(0x141726).CGColor;
    self.card.layer.shadowOpacity = 0.25f;
    self.card.layer.shadowRadius = 20.f;
    self.card.layer.shadowOffset = CGSizeMake(0, 18.f);
    self.card.alpha = 0;
    [self.view addSubview:self.card];

    self.iconBlock = [[TSHsdIconBlock alloc] init];
    self.iconBlock.side = 48.f;
    self.iconBlock.tint = self.tint;
    self.iconBlock.symbol = self.symbol;
    [self.card addSubview:self.iconBlock];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.attributedText = TSUgOvText(self.alertTitle, [UIFont systemFontOfSize:17.f weight:UIFontWeightBold], [TSHsdDisplay ink], 1.1f);
    [self.card addSubview:self.titleLabel];

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.attributedText = TSUgOvText(self.message, [UIFont systemFontOfSize:13.5f], [TSHsdDisplay textSecondary], 1.3f);
    [self.card addSubview:self.messageLabel];

    self.codeLabel = [[UILabel alloc] init];
    self.codeLabel.numberOfLines = 0;
    self.codeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.codeLabel.attributedText = TSUgOvText(self.code, [TSHsdDisplay monoFontOfSize:10.5f], [TSHsdDisplay textTertiary], 1.1f);
    [self.card addSubview:self.codeLabel];

    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    [self.actions enumerateObjectsUsingBlock:^(TSUgreenAlertAction *action, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = (NSInteger)idx;
        button.titleLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold];
        button.layer.cornerRadius = 22.f;
        [button setTitle:action.title forState:UIControlStateNormal];
        switch (action.style) {
            case TSUgreenAlertActionStyleStrong:
                button.backgroundColor = [TSHsdDisplay ink];
                [button setTitleColor:[TSHsdDisplay card] forState:UIControlStateNormal];
                break;
            case TSUgreenAlertActionStyleDestructive:
                button.backgroundColor = [TSHsdDisplay statusBad];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                break;
            case TSUgreenAlertActionStyleNormal:
            default:
                button.backgroundColor = [TSHsdDisplay fill];
                [button setTitleColor:[TSHsdDisplay ink] forState:UIControlStateNormal];
                break;
        }
        [button addTarget:self action:@selector(ts_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.card addSubview:button];
        [buttons addObject:button];
    }];
    self.buttons = buttons;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.appeared) { return; }
    self.appeared = YES;
    // 原型 pop：从 0.92 弹到 1
    self.card.transform = CGAffineTransformMakeScale(0.92f, 0.92f);
    [UIView animateWithDuration:0.22 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.6 options:0 animations:^{
        self.maskView.alpha = 1;
        self.card.alpha = 1;
        self.card.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.maskView.frame = bounds;
    CGFloat cardW = MIN(kTSUgAlertWidth, bounds.size.width - 48.f), innerW = cardW - 36.f;
    CGFloat y = 22.f;
    CGAffineTransform saved = self.card.transform;
    self.card.transform = CGAffineTransformIdentity;
    self.iconBlock.frame = CGRectMake((cardW - 48.f) / 2.f, y, 48.f, 48.f);
    y += 48.f + 12.f;
    CGFloat titleH = ceil([self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(innerW, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
    self.titleLabel.frame = CGRectMake(18.f, y, innerW, titleH);
    y += titleH;
    if (self.message.length) {
        CGFloat h = TSUgOvTextHeight(self.message, [UIFont systemFontOfSize:13.5f], innerW, 1.3f);
        self.messageLabel.frame = CGRectMake(18.f, y + 6.f, innerW, h);
        y += 6.f + h;
    }
    if (self.code.length) {
        CGFloat h = ceil([self.codeLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)].height);
        self.codeLabel.frame = CGRectMake(18.f, y + 8.f, innerW, h);
        y += 8.f + h;
    }
    y += 18.f;
    NSUInteger count = MAX(self.buttons.count, 1);
    CGFloat buttonW = (innerW - 8.f * (count - 1)) / count;
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(18.f + idx * (buttonW + 8.f), y, buttonW, 44.f);
    }];
    y += 44.f + 16.f;
    self.card.bounds = CGRectMake(0, 0, cardW, y);
    self.card.center = CGPointMake(bounds.size.width / 2.f, bounds.size.height / 2.f);
    self.card.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.card.bounds, 12.f, 12.f) cornerRadius:26.f].CGPath;
    self.card.transform = saved;
}

#pragma mark - 公开方法

- (void)presentFrom:(UIViewController *)presenter {
    [presenter presentViewController:self animated:NO completion:nil];
}

#pragma mark - 私有方法

- (void)ts_buttonTapped:(UIButton *)sender {
    if (self.closing) { return; }
    self.closing = YES;
    TSUgreenAlertAction *action = self.actions[(NSUInteger)sender.tag];
    [UIView animateWithDuration:0.18 animations:^{
        self.maskView.alpha = 0;
        self.card.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (action.handler) { action.handler(); }
        }];
    }];
}

@end

#pragma mark - TSUgreenHUD

@interface TSUgreenHUD ()
@property (nonatomic, strong) UIVisualEffectView *box;
@property (nonatomic, strong) UIView *boxTint;
@property (nonatomic, strong) CAShapeLayer *ring;
@property (nonatomic, strong) CAShapeLayer *arc;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation TSUgreenHUD

+ (instancetype)showInView:(UIView *)view text:(NSString *)text detail:(nullable NSString *)detail hue:(UIColor *)hue {
    TSUgreenHUD *hud = [[TSUgreenHUD alloc] initWithFrame:view.bounds];
    hud.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    hud.arc.strokeColor = [hue resolvedColorWithTraitCollection:view.traitCollection].CGColor;
    [hud updateText:text detail:detail];
    hud.alpha = 0;
    [view addSubview:hud];
    [UIView animateWithDuration:0.18 animations:^{ hud.alpha = 1; }];
    return hud;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.backgroundColor = TSUgOvMask(0.2f);
    _box = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
    _box.layer.cornerRadius = 24.f;
    _box.clipsToBounds = YES;
    [self addSubview:_box];
    _boxTint = [[UIView alloc] init];
    _boxTint.backgroundColor = [[TSHsdDisplay card] colorWithAlphaComponent:0.7f];
    [_box.contentView addSubview:_boxTint];

    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1.5f, 1.5f, 27.f, 27.f)];
    _ring = [CAShapeLayer layer];
    _ring.path = path.CGPath;
    _ring.fillColor = [UIColor clearColor].CGColor;
    _ring.lineWidth = 3.f;
    [_box.contentView.layer addSublayer:_ring];
    _arc = [CAShapeLayer layer];
    _arc.path = path.CGPath;
    _arc.fillColor = [UIColor clearColor].CGColor;
    _arc.lineWidth = 3.f;
    _arc.lineCap = kCALineCapRound;
    _arc.strokeEnd = 0.28f;
    [_box.contentView.layer addSublayer:_arc];
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    spin.toValue = @(M_PI * 2);
    spin.duration = 0.8;
    spin.repeatCount = HUGE_VALF;
    [_arc addAnimation:spin forKey:@"spin"];

    _textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold];
    _textLabel.textColor = [TSHsdDisplay textSecondary];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [_box.contentView addSubview:_textLabel];
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [TSHsdDisplay monoFontOfSize:10.5f];
    _detailLabel.textColor = [TSHsdDisplay textTertiary];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    [_box.contentView addSubview:_detailLabel];
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitUpdatesFrequently;
    return self;
}

- (void)updateText:(NSString *)text detail:(nullable NSString *)detail {
    self.textLabel.text = text;
    self.detailLabel.text = detail;
    self.detailLabel.hidden = (detail.length == 0);
    self.accessibilityLabel = text;
    [self setNeedsLayout];
}

- (void)dismiss {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textW = ceil([self.textLabel.text sizeWithAttributes:@{NSFontAttributeName: self.textLabel.font}].width);
    CGFloat detailW = self.detailLabel.hidden ? 0 : ceil([self.detailLabel.text sizeWithAttributes:@{NSFontAttributeName: self.detailLabel.font}].width);
    CGFloat boxW = MIN(self.bounds.size.width - 48.f, MAX(150.f, MAX(textW, detailW) + 44.f));
    CGFloat boxH = 20.f + 30.f + 12.f + 16.f + (self.detailLabel.hidden ? 0 : 6.f + 13.f) + 17.f;
    self.box.frame = CGRectMake((self.bounds.size.width - boxW) / 2.f, (self.bounds.size.height - boxH) / 2.f, boxW, boxH);
    self.boxTint.frame = self.box.bounds;
    CGRect ringFrame = CGRectMake((boxW - 30.f) / 2.f, 20.f, 30.f, 30.f);
    self.ring.frame = ringFrame;
    self.ring.strokeColor = [[TSHsdDisplay fill] resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    self.arc.frame = ringFrame;
    self.textLabel.frame = CGRectMake(8.f, 20.f + 30.f + 12.f, boxW - 16.f, 16.f);
    self.detailLabel.frame = CGRectMake(8.f, CGRectGetMaxY(self.textLabel.frame) + 6.f, boxW - 16.f, 13.f);
}

@end

#pragma mark - TSUgreenToast

static const NSInteger kTSUgToastTag = 0x75677473;   // 'ugts'

@implementation TSUgreenToast

+ (void)showText:(NSString *)text bad:(BOOL)bad inView:(UIView *)view {
    if (!text.length || !view) { return; }
    [[view viewWithTag:kTSUgToastTag] removeFromSuperview];

    UIView *toast = [[UIView alloc] init];
    toast.tag = kTSUgToastTag;
    toast.backgroundColor = [TSUgreenDisplay heroColor];
    toast.layer.shadowColor = [UIColor blackColor].CGColor;
    toast.layer.shadowOpacity = 0.4f;
    toast.layer.shadowRadius = 15.f;
    toast.layer.shadowOffset = CGSizeMake(0, 12.f);
    toast.userInteractionEnabled = NO;

    UIView *mark = [[UIView alloc] init];
    mark.backgroundColor = bad ? TSUgOvRGB(0xFF6B57) : TSUgOvRGB(0x3CCB9B);
    mark.layer.cornerRadius = 10.f;
    UIImageView *icon = [[UIImageView alloc] initWithImage:TSHsdSymbol(bad ? @"xmark" : @"checkmark", 9.f, UIImageSymbolWeightHeavy)];
    icon.tintColor = bad ? TSUgOvRGB(0x3A0A03) : TSUgOvRGB(0x06281C);
    icon.contentMode = UIViewContentModeCenter;
    [mark addSubview:icon];
    [toast addSubview:mark];

    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [toast addSubview:label];

    CGFloat maxW = view.bounds.size.width * 0.88f;
    CGFloat textW = MIN(ceil([text sizeWithAttributes:@{NSFontAttributeName: label.font}].width), maxW - 11.f - 20.f - 8.f - 16.f);
    CGFloat toastW = 11.f + 20.f + 8.f + textW + 16.f, toastH = 38.f;
    toast.frame = CGRectMake((view.bounds.size.width - toastW) / 2.f, view.safeAreaInsets.top + 6.f, toastW, toastH);
    toast.layer.cornerRadius = toastH / 2.f;
    mark.frame = CGRectMake(11.f, (toastH - 20.f) / 2.f, 20.f, 20.f);
    icon.frame = mark.bounds;
    label.frame = CGRectMake(11.f + 20.f + 8.f, 0, textW, toastH);
    [view addSubview:toast];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, text);

    // 原型 drop：从上方 16 落下
    toast.alpha = 0;
    toast.transform = CGAffineTransformMakeTranslation(0, -16.f);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.6 options:0 animations:^{
        toast.alpha = 1;
        toast.transform = CGAffineTransformIdentity;
    } completion:nil];
    __weak UIView *weakToast = toast;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *strongToast = weakToast;
        if (!strongToast) { return; }
        [UIView animateWithDuration:0.2 animations:^{
            strongToast.alpha = 0;
        } completion:^(BOOL finished) {
            [strongToast removeFromSuperview];
        }];
    });
}

@end
