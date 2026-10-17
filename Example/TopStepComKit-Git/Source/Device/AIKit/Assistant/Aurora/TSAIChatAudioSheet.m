//
//  TSAIChatAudioSheet.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatAudioSheet.h"

#import <AVFoundation/AVFoundation.h>

#import "TSAIChatTheme.h"
#import "TSAIEarbudsMicrophoneUI.h"

#pragma mark - 选项行

/// 一行选项：图标块 36 + 标题 / code + 副标 + 徽标 + 单选圈 22
@interface TSAIChatAudioOptionRow : UIControl
@property (nonatomic, strong) UIView *iconBlock;
@property (nonatomic, strong) CAGradientLayer *iconGradient;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UIView *radio;
@property (nonatomic, strong) CAGradientLayer *radioGradient;
@property (nonatomic, strong) UIImageView *checkView;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL available;
- (void)configureTitle:(NSString *)title code:(NSString *)code subtitle:(NSString *)subtitle symbol:(NSString *)symbol gradient:(NSArray *)colors;
- (void)setBadge:(nullable NSString *)text live:(BOOL)live;
@end

@implementation TSAIChatAudioOptionRow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.69];
        self.layer.cornerRadius = 18;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.88].CGColor;
        TSAIChatApplyCardShadow(self.layer);

        _iconBlock = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 36, 36)];
        _iconBlock.layer.cornerRadius = 12;
        _iconBlock.layer.cornerCurve = kCACornerCurveContinuous;
        _iconBlock.layer.masksToBounds = YES;
        _iconBlock.userInteractionEnabled = NO;
        _iconGradient = [CAGradientLayer layer];
        _iconGradient.startPoint = CGPointMake(0, 0);
        _iconGradient.endPoint = CGPointMake(1, 1);
        _iconGradient.frame = _iconBlock.bounds;
        [_iconBlock.layer addSublayer:_iconGradient];
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(9.5, 9.5, 17, 17)];
        _iconView.tintColor = [UIColor whiteColor];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconBlock addSubview:_iconView];
        [self addSubview:_iconBlock];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = TSAIChatFont(11.5, UIFontWeightRegular);
        _subtitleLabel.textColor = TSAIChatInk3Color();
        _subtitleLabel.userInteractionEnabled = NO;
        [self addSubview:_subtitleLabel];

        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.font = TSAIChatFont(10.5, UIFontWeightBold);
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.layer.cornerRadius = 10;
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.hidden = YES;
        [self addSubview:_badgeLabel];

        _radio = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        _radio.layer.cornerRadius = 11;
        _radio.layer.borderWidth = 2;
        _radio.layer.borderColor = [TSAIChatInkColor() colorWithAlphaComponent:0.19].CGColor;
        _radio.userInteractionEnabled = NO;
        _radioGradient = TSAIChatPrimaryGradientLayer();
        _radioGradient.frame = _radio.bounds;
        _radioGradient.cornerRadius = 11;
        _radioGradient.hidden = YES;
        [_radio.layer addSublayer:_radioGradient];
        _checkView = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"checkmark", 10, UIImageSymbolWeightHeavy)];
        _checkView.tintColor = [UIColor whiteColor];
        _checkView.contentMode = UIViewContentModeScaleAspectFit;
        _checkView.frame = CGRectMake(5, 5, 12, 12);
        _checkView.hidden = YES;
        [_radio addSubview:_checkView];
        [self addSubview:_radio];

        _available = YES;
        [self addTarget:self action:@selector(onDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.radio.center = CGPointMake(width - 12 - 11, 28);
    CGFloat right = CGRectGetMinX(self.radio.frame) - 10;
    if (!self.badgeLabel.hidden) {
        CGFloat badgeWidth = ceil([self.badgeLabel sizeThatFits:CGSizeMake(200, 20)].width) + 16;
        self.badgeLabel.frame = CGRectMake(right - badgeWidth, 18, badgeWidth, 20);
        right -= badgeWidth + 8;
    }
    CGFloat textX = 10 + 36 + 12;
    self.titleLabel.frame = CGRectMake(textX, 10, MAX(0, right - textX), 18);
    self.subtitleLabel.frame = CGRectMake(textX, 30, MAX(0, right - textX), 15);
}

- (void)configureTitle:(NSString *)title code:(NSString *)code subtitle:(NSString *)subtitle symbol:(NSString *)symbol gradient:(NSArray *)colors {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
        initWithString:title
            attributes:@{NSFontAttributeName: TSAIChatFont(14, UIFontWeightBold),
                         NSForegroundColorAttributeName: TSAIChatInkColor()}];
    [text appendAttributedString:[[NSAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"  %@", code]
            attributes:@{NSFontAttributeName: [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium],
                         NSForegroundColorAttributeName: TSAIChatInk2Color(),
                         NSBackgroundColorAttributeName: [TSAIChatInkColor() colorWithAlphaComponent:0.06]}]];
    self.titleLabel.attributedText = text;
    self.subtitleLabel.text = subtitle;
    self.iconView.image = TSAIChatSymbol(symbol, 14, UIImageSymbolWeightSemibold);
    self.iconGradient.colors = colors;
}

- (void)setBadge:(NSString *)text live:(BOOL)live {
    self.badgeLabel.hidden = text.length == 0;
    self.badgeLabel.text = text;
    self.badgeLabel.textColor = live ? TSAIChatHexColor(0x1E8F76) : TSAIChatInk3Color();
    self.badgeLabel.backgroundColor = live ? [TSAIChatMintColor() colorWithAlphaComponent:0.14] : [TSAIChatInkColor() colorWithAlphaComponent:0.05];
    [self setNeedsLayout];
}

- (void)setOn:(BOOL)on {
    _on = on;
    self.layer.borderColor = on ? [TSAIChatVioletColor() colorWithAlphaComponent:0.40].CGColor : [UIColor colorWithWhite:1 alpha:0.88].CGColor;
    self.backgroundColor = on ? [UIColor colorWithWhite:1 alpha:0.90] : [UIColor colorWithWhite:1 alpha:0.69];
    self.radio.layer.borderColor = on ? [UIColor clearColor].CGColor : [TSAIChatInkColor() colorWithAlphaComponent:0.19].CGColor;
    self.radioGradient.hidden = !on;
    self.checkView.hidden = !on;
    if (on && !TSAIChatReduceMotion()) {
        self.checkView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.62 initialSpringVelocity:0.8 options:0 animations:^{
            self.checkView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)setAvailable:(BOOL)available {
    _available = available;
    self.alpha = available ? 1 : 0.5;
    self.enabled = available;
}

- (void)onDown { [UIView animateWithDuration:0.15 animations:^{ self.transform = CGAffineTransformMakeScale(0.98, 0.98); }]; }
- (void)onUp { [UIView animateWithDuration:0.2 animations:^{ self.transform = CGAffineTransformIdentity; }]; }

@end

#pragma mark - 面板

@interface TSAIChatAudioSheet ()

@property (nonatomic, weak) UIView *hostView;
@property (nonatomic, strong) UIControl *scrim;
@property (nonatomic, strong) UIView *grabber;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *headIcon;
@property (nonatomic, strong) UIScrollView *bodyScroll;
@property (nonatomic, strong) UILabel *inputTitle;
@property (nonatomic, strong) UILabel *inputHint;
@property (nonatomic, strong) UILabel *outputTitle;
@property (nonatomic, strong) UILabel *outputHint;
@property (nonatomic, strong) NSArray<TSAIChatAudioOptionRow *> *inputRows;
@property (nonatomic, strong) NSArray<TSAIChatAudioOptionRow *> *outputRows;
@property (nonatomic, strong) UIView *noteView;
@property (nonatomic, strong) UIImageView *noteIcon;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) CAGradientLayer *okGradient;
@property (nonatomic, assign) BOOL headsetConnected;
// 页面会话模式：对话（SingleRound）下「耳机仓」播放置灰
@property (nonatomic, assign) TSAIChatConversationMode conversationMode;
@property (nonatomic, copy, nullable) void (^onChange)(void);
/// 确认样式：遮罩不关闭，「完成」关闭后回调 onConfirm
@property (nonatomic, assign) BOOL confirmStyle;
@property (nonatomic, copy, nullable) void (^onConfirm)(void);

@end

@implementation TSAIChatAudioSheet

#pragma mark - 公开方法

+ (instancetype)showInView:(UIView *)hostView
          headsetConnected:(BOOL)headsetConnected
          conversationMode:(TSAIChatConversationMode)conversationMode
                  onChange:(void (^)(void))onChange {
    return [self showInView:hostView
           headsetConnected:headsetConnected
           conversationMode:conversationMode
               confirmStyle:NO
                   onChange:onChange
                  onConfirm:nil];
}

+ (instancetype)showConfirmInView:(UIView *)hostView
                 headsetConnected:(BOOL)headsetConnected
                 conversationMode:(TSAIChatConversationMode)conversationMode
                         onChange:(void (^)(void))onChange
                        onConfirm:(void (^)(void))onConfirm {
    return [self showInView:hostView
           headsetConnected:headsetConnected
           conversationMode:conversationMode
               confirmStyle:YES
                   onChange:onChange
                  onConfirm:onConfirm];
}

+ (instancetype)showInView:(UIView *)hostView
          headsetConnected:(BOOL)headsetConnected
          conversationMode:(TSAIChatConversationMode)conversationMode
              confirmStyle:(BOOL)confirmStyle
                  onChange:(void (^)(void))onChange
                 onConfirm:(void (^)(void))onConfirm {
    TSAIChatAudioSheet *sheet = [[TSAIChatAudioSheet alloc] initWithFrame:CGRectZero];
    sheet.hostView = hostView;
    sheet.headsetConnected = headsetConnected;
    sheet.conversationMode = conversationMode;
    sheet.confirmStyle = confirmStyle;
    sheet.onChange = onChange;
    sheet.onConfirm = onConfirm;
    [sheet buildOptionRows];
    sheet.subtitleLabel.text = conversationMode == TSAIChatConversationModeContinuous
        ? (confirmStyle ? @"AI 畅聊专用 · 选好后点「完成」开始畅聊" : @"AI 畅聊专用 · 下一次畅聊生效")
        : @"AI 对话专用 · 下一次提问生效";
    sheet.scrim = [[UIControl alloc] initWithFrame:hostView.bounds];
    sheet.scrim.backgroundColor = [TSAIChatInkColor() colorWithAlphaComponent:0.20];
    sheet.scrim.alpha = 0;
    sheet.scrim.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (!confirmStyle) {
        // 确认样式必须点「完成」才开始畅聊，遮罩只拦截触摸
        [sheet.scrim addTarget:sheet action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    [hostView addSubview:sheet.scrim];
    [hostView addSubview:sheet];
    // 系统蓝牙耳机连上 / 断开时刷新「耳机」播放项；SDK 耳机麦克风状态变化时刷新「耳机」拾音项
    [[NSNotificationCenter defaultCenter] addObserver:sheet
                                             selector:@selector(onAudioRouteChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:sheet
                                             selector:@selector(onAudioRouteChanged:)
                                                 name:TSAIEarbudsMicrophoneStatusDidChangeNotification
                                               object:nil];
    [sheet refresh];
    [sheet layoutInHost];
    sheet.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(sheet.bounds) * 1.1);
    void (^apply)(void) = ^{ sheet.transform = CGAffineTransformIdentity; sheet.scrim.alpha = 1; };
    if (TSAIChatReduceMotion()) {
        apply();
    } else {
        [UIView animateWithDuration:0.42 delay:0 usingSpringWithDamping:0.72 initialSpringVelocity:0.6
                            options:UIViewAnimationOptionAllowUserInteraction animations:apply completion:nil];
    }
    return sheet;
}

- (void)updateHeadsetConnected:(BOOL)headsetConnected {
    self.headsetConnected = headsetConnected;
    [self refresh];
}

/// 系统音频路由变化（蓝牙耳机连接 / 断开）
- (void)onAudioRouteChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refresh];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismiss {
    CGFloat height = CGRectGetHeight(self.bounds);
    [UIView animateWithDuration:TSAIChatReduceMotion() ? 0 : 0.3
                     animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, height * 1.1);
        self.scrim.alpha = 0;
    }
                     completion:^(BOOL finished) {
        [self.scrim removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.90];
        self.layer.cornerRadius = 34;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        self.layer.shadowColor = TSAIChatHexColor(0x3B2E8A).CGColor;
        self.layer.shadowOpacity = 0.12;
        self.layer.shadowOffset = CGSizeMake(0, -18);
        self.layer.shadowRadius = 25;

        _grabber = [[UIView alloc] init];
        _grabber.backgroundColor = [TSAIChatInkColor() colorWithAlphaComponent:0.13];
        _grabber.layer.cornerRadius = 2.5;
        [self addSubview:_grabber];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.attributedText = [[NSAttributedString alloc]
            initWithString:@"拾音与语音播放"
                attributes:@{NSFontAttributeName: TSAIChatFont(20, UIFontWeightHeavy),
                             NSForegroundColorAttributeName: TSAIChatInkColor(),
                             NSKernAttributeName: @(-0.3)}];
        [self addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.text = @"";
        _subtitleLabel.font = TSAIChatFont(12, UIFontWeightRegular);
        _subtitleLabel.textColor = TSAIChatInk3Color();
        [self addSubview:_subtitleLabel];

        _headIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _headIcon.backgroundColor = [TSAIChatInkColor() colorWithAlphaComponent:0.05];
        _headIcon.layer.cornerRadius = 11;
        _headIcon.layer.cornerCurve = kCACornerCurveContinuous;
        UIImageView *sliders = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"slider.horizontal.3", 13, UIImageSymbolWeightSemibold)];
        sliders.tintColor = TSAIChatInk2Color();
        sliders.contentMode = UIViewContentModeScaleAspectFit;
        sliders.frame = CGRectMake(8.5, 8.5, 15, 15);
        [_headIcon addSubview:sliders];
        [self addSubview:_headIcon];

        _bodyScroll = [[UIScrollView alloc] init];
        _bodyScroll.showsVerticalScrollIndicator = NO;
        _bodyScroll.alwaysBounceVertical = YES;
        // 必须裁剪：否则滚动后选项行会画到标题区 / 面板之外，盖住导航栏
        _bodyScroll.clipsToBounds = YES;
        [self addSubview:_bodyScroll];

        _inputTitle = [self makeSectionTitle:@"拾音"];
        _inputHint = [self makeSectionHint:@"仅语音输入 · 文字提问不拾音"];
        _outputTitle = [self makeSectionTitle:@"语音播放"];
        _outputHint = [self makeSectionHint:@"回答的 TTS 从哪里播"];
        [_bodyScroll addSubview:_inputTitle];
        [_bodyScroll addSubview:_inputHint];
        [_bodyScroll addSubview:_outputTitle];
        [_bodyScroll addSubview:_outputHint];

        // 选项行按线路（对话 / 畅聊）生成，见 buildOptionRows
        _inputRows = @[];
        _outputRows = @[];

        _noteView = [[UIView alloc] init];
        _noteView.backgroundColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.06];
        _noteView.layer.cornerRadius = 14;
        _noteView.layer.cornerCurve = kCACornerCurveContinuous;
        _noteIcon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"info.circle", 12, UIImageSymbolWeightSemibold)];
        _noteIcon.tintColor = TSAIChatVioletColor();
        _noteIcon.contentMode = UIViewContentModeScaleAspectFit;
        [_noteView addSubview:_noteIcon];
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.font = TSAIChatFont(11.5, UIFontWeightRegular);
        _noteLabel.textColor = TSAIChatInk2Color();
        _noteLabel.numberOfLines = 0;
        [_noteView addSubview:_noteLabel];
        [_bodyScroll addSubview:_noteView];

        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okButton setTitle:@"完成" forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _okButton.titleLabel.font = TSAIChatFont(15, UIFontWeightBold);
        _okButton.layer.cornerRadius = 25;
        _okButton.layer.shadowColor = TSAIChatVioletColor().CGColor;
        _okButton.layer.shadowOpacity = 0.25;
        _okButton.layer.shadowOffset = CGSizeMake(0, 10);
        _okButton.layer.shadowRadius = 12;
        _okGradient = TSAIChatPrimaryGradientLayer();
        _okGradient.cornerRadius = 25;
        [_okButton.layer insertSublayer:_okGradient atIndex:0];
        [_okButton addTarget:self action:@selector(onOkTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_okButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat bottomSafe = self.hostView.safeAreaInsets.bottom;
    self.grabber.frame = CGRectMake((width - 36) / 2, 10, 36, 5);
    self.titleLabel.frame = CGRectMake(20, 29, width - 92, 24);
    self.subtitleLabel.frame = CGRectMake(20, 29 + 24 + 3, width - 92, 15);
    self.headIcon.frame = CGRectMake(width - 20 - 32, 29, 32, 32);
    CGFloat footTop = CGRectGetHeight(self.bounds) - bottomSafe - 12 - 50 - 12;
    self.okButton.frame = CGRectMake(20, footTop + 12, width - 40, 50);
    self.okGradient.frame = self.okButton.bounds;
    CGFloat bodyTop = 29 + 24 + 3 + 15 + 6;
    self.bodyScroll.frame = CGRectMake(0, bodyTop, width, MAX(0, footTop - bodyTop));

    CGFloat contentWidth = width - 40;
    CGFloat y = 10;
    y = [self layoutSection:self.inputTitle hint:self.inputHint rows:self.inputRows atY:y width:contentWidth];
    y += 10;
    y = [self layoutSection:self.outputTitle hint:self.outputHint rows:self.outputRows atY:y width:contentWidth];
    y += 12;
    CGFloat noteTextWidth = contentWidth - 12 - 14 - 8 - 12;
    CGFloat noteHeight = ceil([self.noteLabel sizeThatFits:CGSizeMake(noteTextWidth, CGFLOAT_MAX)].height) + 20;
    self.noteView.frame = CGRectMake(20, y, contentWidth, noteHeight);
    self.noteIcon.frame = CGRectMake(12, 11, 14, 14);
    self.noteLabel.frame = CGRectMake(12 + 14 + 8, 10, noteTextWidth, noteHeight - 20);
    y += noteHeight + 16;
    self.bodyScroll.contentSize = CGSizeMake(width, y);
}

/// 一节：标题行 16 + 下边距 8，行高 56 间距 6
- (CGFloat)layoutSection:(UILabel *)title hint:(UILabel *)hint rows:(NSArray<TSAIChatAudioOptionRow *> *)rows atY:(CGFloat)y width:(CGFloat)width {
    CGFloat hintWidth = ceil([hint sizeThatFits:CGSizeMake(width, 16)].width);
    title.frame = CGRectMake(24, y, width - hintWidth - 16, 16);
    hint.frame = CGRectMake(20 + width - 4 - hintWidth, y, hintWidth, 16);
    y += 16 + 8;
    for (TSAIChatAudioOptionRow *row in rows) {
        row.frame = CGRectMake(20, y, width, 56);
        y += 56 + 6;
    }
    return y - 6;
}

#pragma mark - 私有方法

- (void)layoutInHost {
    CGFloat hostHeight = CGRectGetHeight(self.hostView.bounds);
    CGFloat width = CGRectGetWidth(self.hostView.bounds);
    CGFloat bottomSafe = self.hostView.safeAreaInsets.bottom;
    // 行数随线路变化（对话没有「耳机仓」两行）
    CGFloat rowsHeight = (CGFloat)(self.inputRows.count + self.outputRows.count) * 62 - 12 + 2 * (16 + 8) + 10 + 10 + 12;
    CGFloat noteHeight = 50;
    CGFloat wanted = 29 + 24 + 3 + 15 + 6 + 10 + rowsHeight + noteHeight + 16 + 12 + 50 + 12 + bottomSafe;
    CGFloat height = MIN(wanted, floor(hostHeight * 0.78));
    self.frame = CGRectMake(0, hostHeight - height, width, height);
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UILabel *)makeSectionTitle:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = TSAIChatFont(12, UIFontWeightBold);
    label.textColor = TSAIChatInk2Color();
    return label;
}

- (UILabel *)makeSectionHint:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = TSAIChatFont(12, UIFontWeightMedium);
    label.textColor = TSAIChatInk3Color();
    label.textAlignment = NSTextAlignmentRight;
    return label;
}

- (NSArray *)gradientForInputOption:(TSAIChatAudioInputOption)option {
    switch (option) {
        case TSAIChatAudioInputOptionDevice: return @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
        case TSAIChatAudioInputOptionSCO:    return @[(id)TSAIChatSkyColor().CGColor, (id)TSAIChatMintColor().CGColor];
        case TSAIChatAudioInputOptionPhone:  return @[(id)TSAIChatPeachColor().CGColor, (id)TSAIChatRoseColor().CGColor];
        default:                             return @[(id)TSAIChatInk2Color().CGColor, (id)TSAIChatInkColor().CGColor];
    }
}

- (NSArray *)gradientForOutputOption:(TSAIChatAudioOutputOption)option {
    switch (option) {
        case TSAIChatAudioOutputOptionA2DP:   return @[(id)TSAIChatSkyColor().CGColor, (id)TSAIChatMintColor().CGColor];
        case TSAIChatAudioOutputOptionPhone:  return @[(id)TSAIChatPeachColor().CGColor, (id)TSAIChatRoseColor().CGColor];
        case TSAIChatAudioOutputOptionSystem: return @[(id)TSAIChatInk2Color().CGColor, (id)TSAIChatInkColor().CGColor];
        case TSAIChatAudioOutputOptionNone:   return @[(id)TSAIChatHexColor(0xB9B7C9).CGColor, (id)TSAIChatHexColor(0x8E8BA6).CGColor];
        default:                              return @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
    }
}

/// 本面板编辑的线路偏好
- (TSAIChatAudioPreference *)preference {
    return [TSAIChatAudioPreference preferenceForConversationMode:self.conversationMode];
}

/// 按线路生成选项行：AI 对话没有「耳机仓」拾音 / 播放
- (void)buildOptionRows {
    for (UIView *row in self.inputRows) [row removeFromSuperview];
    for (UIView *row in self.outputRows) [row removeFromSuperview];
    TSAIChatAudioPreference *preference = [self preference];
    NSMutableArray *inputRows = [NSMutableArray array];
    for (NSNumber *optionNumber in [preference orderedInputOptions]) {
        TSAIChatAudioInputOption option = (TSAIChatAudioInputOption)optionNumber.integerValue;
        TSAIChatAudioOptionRow *row = [[TSAIChatAudioOptionRow alloc] init];
        row.tag = option;
        [row configureTitle:[TSAIChatAudioPreference titleForInputOption:option]
                       code:[TSAIChatAudioPreference codeForInputOption:option]
                   subtitle:[self subtitleForInputOption:option]
                     symbol:[TSAIChatAudioPreference symbolForInputOption:option]
                   gradient:[self gradientForInputOption:option]];
        [row addTarget:self action:@selector(onInputRowTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyScroll addSubview:row];
        [inputRows addObject:row];
    }
    self.inputRows = inputRows;

    NSMutableArray *outputRows = [NSMutableArray array];
    for (NSNumber *optionNumber in [preference orderedOutputOptions]) {
        TSAIChatAudioOutputOption option = (TSAIChatAudioOutputOption)optionNumber.integerValue;
        TSAIChatAudioOptionRow *row = [[TSAIChatAudioOptionRow alloc] init];
        row.tag = option;
        [row configureTitle:[TSAIChatAudioPreference titleForOutputOption:option]
                       code:[TSAIChatAudioPreference codeForOutputOption:option]
                   subtitle:[TSAIChatAudioPreference subtitleForOutputOption:option]
                     symbol:[TSAIChatAudioPreference symbolForOutputOption:option]
                   gradient:[self gradientForOutputOption:option]];
        [row addTarget:self action:@selector(onOutputRowTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyScroll addSubview:row];
        [outputRows addObject:row];
    }
    self.outputRows = outputRows;
    self.inputHint.text = [preference offersCaseOptions] ? @"畅聊全程按这里拾音" : @"仅按住说话 · 文字提问不拾音";
    [self setNeedsLayout];
}

/// 「自动」的副标随线路变化：对话线路没有耳机仓
- (NSString *)subtitleForInputOption:(TSAIChatAudioInputOption)option {
    if (option == TSAIChatAudioInputOptionAuto && ![self preference].offersCaseOptions) {
        return @"蓝牙耳机优先，没连就用手机";
    }
    return [TSAIChatAudioPreference subtitleForInputOption:option];
}

/// 按偏好、两条链路（耳机仓 BLE / 系统蓝牙耳机）状态与会话模式刷新选中 / 可用 / 徽标
- (void)refresh {
    TSAIChatAudioPreference *preference = [self preference];
    BOOL headset = self.headsetConnected;   // 耳机仓 BLE 已连接
    BOOL bluetoothHeadset = [TSAIChatAudioPreference isSystemBluetoothAudioConnected];
    // 「耳机」拾音由 SDK 判断（earbudsMicrophoneStatusForFeature:AIChat）
    TSAIEarbudsMicrophoneStatus *earbudsStatus = [TSAIChatAudioPreference earbudsMicrophoneStatus];
    BOOL earbudsMicrophone = [TSAIEarbudsMicrophoneUI isSelectableStatus:earbudsStatus];
    TSAIChatAudioInputOption effectiveInput = [preference effectiveInputWithHeadset:headset];
    for (TSAIChatAudioOptionRow *row in self.inputRows) {
        TSAIChatAudioInputOption option = (TSAIChatAudioInputOption)row.tag;
        BOOL needsCase = [TSAIChatAudioPreference inputOptionRequiresCase:option];
        BOOL needsBluetooth = [TSAIChatAudioPreference inputOptionRequiresBluetoothHeadset:option];
        BOOL available = (!needsCase || headset) && (!needsBluetooth || earbudsMicrophone);
        BOOL on = preference.input == option;
        row.available = available;
        row.on = on;
        if (!available) {
            [row setBadge:needsCase ? @"耳机仓未连接" : ([TSAIEarbudsMicrophoneUI titleSuffixForStatus:earbudsStatus] ?: @"耳机不可用") live:NO];
        } else if (option == TSAIChatAudioInputOptionAuto) {
            [row setBadge:on ? [NSString stringWithFormat:@"使用中 · %@", [TSAIChatAudioPreference titleForInputOption:effectiveInput]] : @"推荐" live:on];
        } else if (on || (preference.input != TSAIChatAudioInputOptionAuto && effectiveInput == option)) {
            [row setBadge:@"使用中" live:YES];
        } else {
            [row setBadge:nil live:NO];
        }
    }
    TSAIChatAudioOutputOption effectiveOutput = [preference effectiveOutputWithHeadset:headset];
    for (TSAIChatAudioOptionRow *row in self.outputRows) {
        TSAIChatAudioOutputOption option = (TSAIChatAudioOutputOption)row.tag;
        BOOL needsCase = [TSAIChatAudioPreference outputOptionRequiresCase:option];
        BOOL needsBluetooth = [TSAIChatAudioPreference outputOptionRequiresBluetoothHeadset:option];
        BOOL available = (!needsCase || headset) && (!needsBluetooth || bluetoothHeadset);
        row.available = available;
        row.on = preference.output == option;
        if (!available) {
            [row setBadge:needsCase ? @"耳机仓未连接" : @"未配对蓝牙" live:NO];
        } else if (effectiveOutput == option) {
            [row setBadge:@"使用中" live:YES];
        } else {
            [row setBadge:nil live:NO];
        }
    }
    NSMutableString *note = [NSMutableString string];
    if (preference.offersCaseOptions) {
        [note appendString:@"AI 畅聊会打开耳机仓的 AI 对话；拾音不选「耳机仓」时，耳机仓上传的声音不会被使用。"
                           @"「耳机仓」走 BLE 数据链路（Opus/PCM），「耳机」走 iOS 系统蓝牙音频（需在系统蓝牙中配对，与 BLE 连接无关）。"
                           @"耳机仓唤醒固定用耳机仓拾音。"];
        if (!headset) [note appendString:@" 耳机仓未连接，相关选项已置灰并回落到手机。"];
    } else {
        [note appendString:@"AI 对话只在手机端完成，文字提问和按住说话都不会拉起耳机仓。"
                           @"「耳机」走 iOS 系统蓝牙音频，需在系统蓝牙中配对。文字提问不拾音。"];
    }
    if (!earbudsMicrophone) {
        NSString *reason = [TSAIEarbudsMicrophoneUI unavailableReasonForStatus:earbudsStatus];
        [note appendFormat:@" 「耳机」拾音不可用，回落手机%@。", reason.length > 0 ? [NSString stringWithFormat:@"（%@）", reason] : @""];
    }
    if (!bluetoothHeadset) [note appendString:@" 未检测到系统蓝牙耳机，「耳机」播放已置灰（回落跟随系统）。"];
    self.noteLabel.text = note;
    [self setNeedsLayout];
}

#pragma mark - 事件

- (void)onInputRowTapped:(TSAIChatAudioOptionRow *)row {
    [self preference].input = (TSAIChatAudioInputOption)row.tag;
    [self refresh];
    if (self.onChange) self.onChange();
}

- (void)onOutputRowTapped:(TSAIChatAudioOptionRow *)row {
    [self preference].output = (TSAIChatAudioOutputOption)row.tag;
    [self refresh];
    if (self.onChange) self.onChange();
}

/// 「完成」：收起；确认样式下收起后回调 onConfirm（只回调一次）
- (void)onOkTapped {
    void (^onConfirm)(void) = self.confirmStyle ? self.onConfirm : nil;
    self.onConfirm = nil;
    [self dismiss];
    if (onConfirm) onConfirm();
}

@end
