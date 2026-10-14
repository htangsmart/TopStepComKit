//
//  TSAIQADeviceActionBar.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQADeviceActionBar.h"

#import "TSAIQATheme.h"

static const CGFloat kTSAIQAActionBarHeight = 118.0;
static const CGFloat kTSAIQAActionPrimarySize = 68.0;

@interface TSAIQADeviceActionBar ()

// 顶部分割线
@property (nonatomic, strong) UIView *topLine;
// 主按钮
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, strong) CAShapeLayer *playLayer;
@property (nonatomic, strong) UIView *stopSquare;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
// 两侧路由
@property (nonatomic, strong) UIButton *inputButton;
@property (nonatomic, strong) UIButton *outputButton;
// 说明
@property (nonatomic, strong) UILabel *captionLabel;

@end

@implementation TSAIQADeviceActionBar

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIQAPageBackgroundColor() colorWithAlphaComponent:0.96];
        _primaryEnabled = YES;
        _inputRouteTitle = @"自动";
        _outputRouteTitle = @"自动";
        [self addSubview:self.topLine];
        [self addSubview:self.inputButton];
        [self addSubview:self.outputButton];
        [self addSubview:self.primaryButton];
        [self.primaryButton.layer addSublayer:self.playLayer];
        [self.primaryButton addSubview:self.stopSquare];
        [self.primaryButton addSubview:self.spinner];
        [self addSubview:self.captionLabel];
        [self applyAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.topLine.frame = CGRectMake(0, 0, width, 1.0);
    CGFloat primaryX = (width - kTSAIQAActionPrimarySize) / 2.0;
    self.primaryButton.frame = CGRectMake(primaryX, 10.0, kTSAIQAActionPrimarySize, kTSAIQAActionPrimarySize);
    self.playLayer.frame = self.primaryButton.bounds;
    self.stopSquare.frame = CGRectMake(23.0, 23.0, 22.0, 22.0);
    self.spinner.center = CGPointMake(kTSAIQAActionPrimarySize / 2.0, kTSAIQAActionPrimarySize / 2.0);

    CGFloat sideWidth = primaryX - 20.0 - 10.0;
    self.inputButton.frame = CGRectMake(20.0, 14.0, sideWidth, 60.0);
    self.outputButton.frame = CGRectMake(primaryX + kTSAIQAActionPrimarySize + 10.0, 14.0, sideWidth, 60.0);
    [self layoutSideButton:self.inputButton];
    [self layoutSideButton:self.outputButton];

    self.captionLabel.frame = CGRectMake(16.0, 86.0, width - 32.0, 26.0);
}

#pragma mark - 公开方法

+ (CGFloat)contentHeight {
    return kTSAIQAActionBarHeight;
}

- (void)setArmed:(BOOL)armed {
    _armed = armed;
    [self applyAppearance];
}

- (void)setPrimaryEnabled:(BOOL)primaryEnabled {
    _primaryEnabled = primaryEnabled;
    [self applyAppearance];
}

- (void)setBusy:(BOOL)busy {
    _busy = busy;
    [self applyAppearance];
}

- (void)setInputRouteTitle:(NSString *)inputRouteTitle {
    _inputRouteTitle = [inputRouteTitle copy];
    ((UILabel *)[self.inputButton viewWithTag:12]).text = inputRouteTitle;
}

- (void)setOutputRouteTitle:(NSString *)outputRouteTitle {
    _outputRouteTitle = [outputRouteTitle copy];
    ((UILabel *)[self.outputButton viewWithTag:12]).text = outputRouteTitle;
}

- (void)setCaption:(NSString *)caption {
    _caption = [caption copy];
    self.captionLabel.text = caption;
}

#pragma mark - 私有方法

/** 刷新主按钮样式 */
- (void)applyAppearance {
    self.primaryButton.enabled = self.primaryEnabled && !self.busy;
    self.playLayer.hidden = self.armed || self.busy;
    self.stopSquare.hidden = !self.armed || self.busy;
    if (self.busy) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
    UIColor *background;
    if (!self.primaryEnabled) {
        background = [UIColor colorWithRed:0xC9 / 255.0 green:0xCD / 255.0 blue:0xDC / 255.0 alpha:1.0];
    } else if (self.armed) {
        background = TSAIQATextPrimaryColor();
    } else {
        background = TSAIQATintColor();
    }
    self.primaryButton.backgroundColor = background;
    self.primaryButton.layer.shadowColor = background.CGColor;
    self.primaryButton.layer.shadowOpacity = self.primaryEnabled ? 0.33 : 0;
}

/** 创建两侧路由按钮：图标位、说明、值 */
- (UIButton *)makeSideButtonWithCaption:(NSString *)caption glyph:(NSString *)glyph kind:(TSAIQARouteKind)kind {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = kind;

    UILabel *glyphLabel = [[UILabel alloc] init];
    glyphLabel.tag = 10;
    glyphLabel.text = glyph;
    glyphLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
    glyphLabel.textColor = TSAIQATextSecondaryColor();
    glyphLabel.textAlignment = NSTextAlignmentCenter;
    glyphLabel.backgroundColor = [UIColor whiteColor];
    glyphLabel.layer.cornerRadius = 9.0;
    glyphLabel.layer.borderWidth = 1.0;
    glyphLabel.layer.borderColor = TSAIQALineColor().CGColor;
    glyphLabel.layer.masksToBounds = YES;
    [button addSubview:glyphLabel];

    UILabel *captionLabel = [[UILabel alloc] init];
    captionLabel.tag = 11;
    captionLabel.text = caption;
    captionLabel.font = [UIFont systemFontOfSize:10.0];
    captionLabel.textColor = TSAIQATextTertiaryColor();
    captionLabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:captionLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.tag = 12;
    valueLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightBold];
    valueLabel.textColor = TSAIQATextPrimaryColor();
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [button addSubview:valueLabel];

    [button addTarget:self action:@selector(onSideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/** 布局两侧按钮内部标签 */
- (void)layoutSideButton:(UIButton *)button {
    CGFloat width = CGRectGetWidth(button.bounds);
    [button viewWithTag:10].frame = CGRectMake((width - 30.0) / 2.0, 0, 30.0, 30.0);
    [button viewWithTag:11].frame = CGRectMake(0, 33.0, width, 12.0);
    [button viewWithTag:12].frame = CGRectMake(0, 46.0, width, 14.0);
}

#pragma mark - 事件

/** 点击主按钮 */
- (void)onPrimaryTapped {
    [self.delegate deviceActionBarDidTapPrimary:self];
}

/** 点击两侧路由按钮 */
- (void)onSideButtonTapped:(UIButton *)sender {
    [self.delegate deviceActionBar:self didTapRoute:(TSAIQARouteKind)sender.tag];
}

#pragma mark - 属性（懒加载）

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = TSAIQALineColor();
    }
    return _topLine;
}

- (UIButton *)primaryButton {
    if (!_primaryButton) {
        _primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _primaryButton.layer.cornerRadius = kTSAIQAActionPrimarySize / 2.0;
        _primaryButton.layer.shadowRadius = 13.0;
        _primaryButton.layer.shadowOffset = CGSizeMake(0, 10.0);
        [_primaryButton addTarget:self action:@selector(onPrimaryTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _primaryButton;
}

- (CAShapeLayer *)playLayer {
    if (!_playLayer) {
        _playLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(27.0, 20.0)];
        [path addLineToPoint:CGPointMake(49.0, 34.0)];
        [path addLineToPoint:CGPointMake(27.0, 48.0)];
        [path closePath];
        _playLayer.path = path.CGPath;
        _playLayer.fillColor = [UIColor whiteColor].CGColor;
        _playLayer.lineJoin = kCALineJoinRound;
    }
    return _playLayer;
}

- (UIView *)stopSquare {
    if (!_stopSquare) {
        _stopSquare = [[UIView alloc] init];
        _stopSquare.backgroundColor = [UIColor whiteColor];
        _stopSquare.layer.cornerRadius = 5.0;
        _stopSquare.userInteractionEnabled = NO;
        _stopSquare.hidden = YES;
    }
    return _stopSquare;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.hidesWhenStopped = YES;
    }
    return _spinner;
}

- (UIButton *)inputButton {
    if (!_inputButton) {
        _inputButton = [self makeSideButtonWithCaption:@"拾音" glyph:@"◉" kind:TSAIQARouteKindInput];
    }
    return _inputButton;
}

- (UIButton *)outputButton {
    if (!_outputButton) {
        _outputButton = [self makeSideButtonWithCaption:@"播放" glyph:@"◐" kind:TSAIQARouteKindOutput];
    }
    return _outputButton;
}

- (UILabel *)captionLabel {
    if (!_captionLabel) {
        _captionLabel = [[UILabel alloc] init];
        _captionLabel.font = [UIFont systemFontOfSize:10.5];
        _captionLabel.textColor = TSAIQATextTertiaryColor();
        _captionLabel.textAlignment = NSTextAlignmentCenter;
        _captionLabel.numberOfLines = 2;
    }
    return _captionLabel;
}

@end
