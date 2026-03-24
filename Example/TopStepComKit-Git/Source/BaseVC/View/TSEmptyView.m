//
//  TSEmptyView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSEmptyView.h"
#import "TSRootVC.h"

@interface TSEmptyView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *subtitleLabel;

@end

@implementation TSEmptyView

#pragma mark - 工厂方法

+ (instancetype)viewWithIcon:(NSString *)iconName
                       title:(NSString *)title
                    subtitle:(nullable NSString *)subtitle {
    TSEmptyView *view = [[self alloc] init];
    [view configureWithIcon:iconName title:title subtitle:subtitle];
    return view;
}

#pragma mark - 私有方法

- (void)configureWithIcon:(NSString *)iconName
                    title:(NSString *)title
                 subtitle:(nullable NSString *)subtitle {
    self.backgroundColor = [UIColor clearColor];

    // 图标
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:48
                                                                                             weight:UIImageSymbolWeightLight];
        self.iconImageView.image = [UIImage systemImageNamed:iconName withConfiguration:config];
    } else {
        self.iconImageView.image = [UIImage imageNamed:iconName];
    }

    // 文本
    self.titleLabel.text    = title;
    self.subtitleLabel.text = subtitle;
    self.subtitleLabel.hidden = (subtitle.length == 0);

    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width  = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat iconSize     = 64.f;
    CGFloat iconTop      = height * 0.35f;
    CGFloat titleTop     = iconTop + iconSize + TSSpacing_MD;
    CGFloat labelWidth   = width * 0.7f;
    CGFloat labelX       = (width - labelWidth) * 0.5f;

    self.iconImageView.frame = CGRectMake((width - iconSize) * 0.5f, iconTop, iconSize, iconSize);

    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    self.titleLabel.frame = CGRectMake(labelX, titleTop, labelWidth, titleSize.height);

    if (!self.subtitleLabel.hidden) {
        CGFloat subtitleTop = CGRectGetMaxY(self.titleLabel.frame) + TSSpacing_SM;
        CGSize  subtitleSize = [self.subtitleLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.subtitleLabel.frame = CGRectMake(labelX, subtitleTop, labelWidth, subtitleSize.height);
    }
}

#pragma mark - 属性懒加载

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.tintColor   = TSColor_TextSecondary;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font          = TSFont_H2;
        _titleLabel.textColor     = TSColor_TextPrimary;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font          = TSFont_Body;
        _subtitleLabel.textColor     = TSColor_TextSecondary;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.numberOfLines = 0;
    }
    return _subtitleLabel;
}

@end
