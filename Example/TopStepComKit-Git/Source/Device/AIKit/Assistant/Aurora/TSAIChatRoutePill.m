//
//  TSAIChatRoutePill.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatRoutePill.h"

#import "TSAIChatTheme.h"

@interface TSAIChatRoutePill ()

// 拾音图标
@property (nonatomic, strong) UIImageView *iconView;
// 文案：<b>耳机</b>拾音 · <b>耳机</b>播放
@property (nonatomic, strong) UILabel *textLabel;
// chevron
@property (nonatomic, strong) UIImageView *chevron;
// 锁图标 + 文案
@property (nonatomic, strong) UIImageView *lockIcon;
@property (nonatomic, strong) UILabel *lockLabel;

@end

@implementation TSAIChatRoutePill

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 13;
        self.layer.borderWidth = 1;

        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.tintColor = TSAIChatInk2Color();
        _iconView.userInteractionEnabled = NO;
        [self addSubview:_iconView];

        _textLabel = [[UILabel alloc] init];
        _textLabel.userInteractionEnabled = NO;
        [self addSubview:_textLabel];

        _chevron = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"chevron.right", 9, UIImageSymbolWeightBold)];
        _chevron.contentMode = UIViewContentModeScaleAspectFit;
        _chevron.tintColor = TSAIChatInk3Color();
        _chevron.userInteractionEnabled = NO;
        [self addSubview:_chevron];

        _lockIcon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(@"lock.fill", 10, UIImageSymbolWeightBold)];
        _lockIcon.contentMode = UIViewContentModeScaleAspectFit;
        _lockIcon.tintColor = TSAIChatVioletColor();
        _lockIcon.userInteractionEnabled = NO;
        [self addSubview:_lockIcon];

        _lockLabel = [[UILabel alloc] init];
        _lockLabel.font = TSAIChatFont(11.5, UIFontWeightRegular);
        _lockLabel.textColor = TSAIChatVioletColor();
        _lockLabel.text = @"会话中固定";
        _lockLabel.userInteractionEnabled = NO;
        [self addSubview:_lockLabel];

        _inputTitle = @"耳机";
        _inputSymbol = @"headphones";
        _outputTitle = @"耳机";
        [self addTarget:self action:@selector(onDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self refreshAnimated:NO];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 12;
    CGFloat height = CGRectGetHeight(self.bounds);
    self.iconView.frame = CGRectMake(x, (height - 13) / 2, 13, 13);
    x += 13 + 5;
    CGFloat textWidth = ceil([self.textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)].width);
    self.textLabel.frame = CGRectMake(x, 0, textWidth, height);
    x += textWidth;
    if (self.locked) {
        x += 6;
        self.lockIcon.frame = CGRectMake(x, (height - 13) / 2, 13, 13);
        x += 13 + 3;
        CGFloat lockWidth = ceil([self.lockLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, height)].width);
        self.lockLabel.frame = CGRectMake(x, 0, lockWidth, height);
    } else {
        x += 3;
        self.chevron.frame = CGRectMake(x, (height - 11) / 2, 11, 11);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = 12 + 13 + 5 + ceil([self.textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 26)].width);
    if (self.locked) {
        width += 6 + 13 + 3 + ceil([self.lockLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 26)].width);
    } else {
        width += 3 + 11;
    }
    return CGSizeMake(width + 12, [[self class] preferredHeight]);
}

#pragma mark - 公开方法

+ (CGFloat)preferredHeight {
    return 26;
}

- (void)setInputTitle:(NSString *)inputTitle { _inputTitle = [inputTitle copy]; [self refreshAnimated:NO]; }
- (void)setInputSymbol:(NSString *)inputSymbol { _inputSymbol = [inputSymbol copy]; [self refreshAnimated:NO]; }
- (void)setOutputTitle:(NSString *)outputTitle { _outputTitle = [outputTitle copy]; [self refreshAnimated:NO]; }
- (void)setVoiceOff:(BOOL)voiceOff { _voiceOff = voiceOff; [self refreshAnimated:NO]; }

- (void)setLocked:(BOOL)locked {
    if (_locked == locked) return;
    _locked = locked;
    [self refreshAnimated:YES];
}

#pragma mark - 私有方法

/// 刷新文案与锁定态（.3s 过渡）
- (void)refreshAnimated:(BOOL)animated {
    NSDictionary *bold = @{NSFontAttributeName: TSAIChatFont(11.5, UIFontWeightSemibold), NSForegroundColorAttributeName: TSAIChatInkColor()};
    NSDictionary *plain = @{NSFontAttributeName: TSAIChatFont(11.5, UIFontWeightRegular), NSForegroundColorAttributeName: TSAIChatInk2Color()};
    NSDictionary *sep = @{NSFontAttributeName: TSAIChatFont(11.5, UIFontWeightRegular), NSForegroundColorAttributeName: TSAIChatInk3Color()};
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.inputTitle ?: @"" attributes:bold];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"拾音" attributes:plain]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" · " attributes:sep]];
    if (self.voiceOff) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"不播放" attributes:bold]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"语音" attributes:plain]];
    } else {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:self.outputTitle ?: @"" attributes:bold]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"播放" attributes:plain]];
    }
    self.textLabel.attributedText = text;
    self.iconView.image = TSAIChatSymbol(self.inputSymbol ?: @"headphones", 11, UIImageSymbolWeightSemibold);
    self.lockIcon.hidden = !self.locked;
    self.lockLabel.hidden = !self.locked;
    self.chevron.hidden = self.locked;

    void (^apply)(void) = ^{
        if (self.locked) {
            self.backgroundColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.08];
            self.layer.borderColor = [TSAIChatVioletColor() colorWithAlphaComponent:0.19].CGColor;
        } else {
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.50];
            self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75].CGColor;
        }
    };
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:apply];
    [self.superview setNeedsLayout];
    [self setNeedsLayout];
}

#pragma mark - 事件

- (void)onDown {
    if (self.locked) return;
    [UIView animateWithDuration:0.15 animations:^{ self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75]; }];
}

- (void)onUp {
    if (self.locked) return;
    [UIView animateWithDuration:0.2 animations:^{ self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.50]; }];
}

@end
