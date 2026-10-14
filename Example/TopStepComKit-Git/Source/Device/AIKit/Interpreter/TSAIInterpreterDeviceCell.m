//
//  TSAIInterpreterDeviceCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterDeviceCell.h"

#import "TSAIInterpreterTheme.h"

@interface TSAIInterpreterDeviceCell ()

/// 图标块
@property (nonatomic, strong) UIView *iconTile;
/// 图标
@property (nonatomic, strong) UIImageView *iconView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TSAIInterpreterDeviceCell

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _available = YES;
        self.backgroundColor = [TSAIInterpreterTheme panel];
        self.layer.cornerRadius = 16.0;
        self.layer.borderWidth = 2.0;
        self.clipsToBounds = YES;
        [self addSubview:self.iconTile];
        [self.iconTile addSubview:self.iconView];
        [self addSubview:self.titleLabel];
        [self applyStyle];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    // 原型：padding 12 6，图标 36，间距 8，标题 12px；整体垂直居中。
    CGFloat titleH = ceil(self.titleLabel.font.lineHeight * 1.2);
    CGFloat contentH = 36.0 + 8.0 + titleH;
    CGFloat y = MAX(12.0, (height - contentH) / 2.0);
    self.iconTile.frame = CGRectMake((width - 36.0) / 2.0, y, 36.0, 36.0);
    self.iconView.frame = self.iconTile.bounds;
    self.titleLabel.frame = CGRectMake(6.0, CGRectGetMaxY(self.iconTile.frame) + 8.0, width - 12.0, titleH);
}

#pragma mark - 公开方法

- (void)setSymbol:(NSString *)symbolName title:(NSString *)title {
    UIImageSymbolConfiguration *cfg =
        [UIImageSymbolConfiguration configurationWithPointSize:18.0 weight:UIImageSymbolWeightMedium];
    self.iconView.image = [[UIImage systemImageNamed:symbolName withConfiguration:cfg]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

#pragma mark - 状态

- (void)setKind:(TSAIInterpreterDeviceCellKind)kind {
    _kind = kind;
    [self applyStyle];
}

- (void)setAvailable:(BOOL)available {
    _available = available;
    [self applyStyle];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self applyStyle];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = (self.available ? 1.0 : 0.5) * (highlighted ? 0.7 : 1.0);
}

/// 按 kind / selected / available 套用原型配色
- (void)applyStyle {
    BOOL input = self.kind == TSAIInterpreterDeviceCellKindInput;
    UIColor *accent = input ? [TSAIInterpreterTheme jade] : [TSAIInterpreterTheme cobalt];
    UIColor *accent50 = input ? [TSAIInterpreterTheme jade50] : [TSAIInterpreterTheme cobalt50];
    self.alpha = self.available ? 1.0 : 0.5;
    if (!self.available) {
        self.layer.borderColor = [TSAIInterpreterTheme paper].CGColor;
        self.iconTile.backgroundColor = [TSAIInterpreterTheme dimBackground];
        self.iconView.tintColor = [TSAIInterpreterTheme dim];
        return;
    }
    if (self.selected) {
        self.layer.borderColor = accent.CGColor;
        self.iconTile.backgroundColor = accent;
        self.iconView.tintColor = [UIColor whiteColor];
    } else {
        self.layer.borderColor = [TSAIInterpreterTheme paper].CGColor;
        self.iconTile.backgroundColor = accent50;
        self.iconView.tintColor = accent;
    }
}

#pragma mark - 属性（懒加载）

- (UIView *)iconTile {
    if (!_iconTile) {
        _iconTile = [[UIView alloc] init];
        _iconTile.layer.cornerRadius = 12.0;
        _iconTile.userInteractionEnabled = NO;
    }
    return _iconTile;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [TSAIInterpreterTheme fontOfSize:12.0 cssWeight:600];
        _titleLabel.textColor = [TSAIInterpreterTheme ink];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.8;
    }
    return _titleLabel;
}

@end
