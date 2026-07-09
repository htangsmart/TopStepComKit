//
//  TSAIKitRootSectionHeaderView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/20.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootSectionHeaderView.h"

@interface TSAIKitRootSectionHeaderView ()

@property (nonatomic, strong) UIView *tintBar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *protocolLabel;
@property (nonatomic, strong) UILabel *countBadge;

@end

@implementation TSAIKitRootSectionHeaderView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutHeader];
}

#pragma mark - 公开方法

- (void)applyTitle:(NSString *)title
       protocolName:(NSString *)protocolName
              count:(NSInteger)count
          tintColor:(UIColor *)tintColor {
    self.titleLabel.text = title;
    self.protocolLabel.text = protocolName;
    NSString *unit = (count <= 1) ? @"capability" : @"capabilities";
    self.countBadge.text = [NSString stringWithFormat:@"%@ %@", @(count), unit];
    self.tintBar.backgroundColor = tintColor;
    self.countBadge.textColor = tintColor;
    self.countBadge.backgroundColor = [tintColor colorWithAlphaComponent:0.10];
    [self setNeedsLayout];
}

+ (CGFloat)heightForWidth:(CGFloat)width {
    return 8.0 + 16.0 + 4.0 + 14.0 + 12.0;
}

#pragma mark - 私有方法

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tintBar];
    [self addSubview:self.titleLabel];
    [self addSubview:self.protocolLabel];
    [self addSubview:self.countBadge];
}

- (void)layoutHeader {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat side = 20.0;
    CGFloat top = 8.0;

    CGFloat barWidth = 4.0;
    CGFloat barHeight = 14.0;
    self.tintBar.frame = CGRectMake(side, top + 1.0, barWidth, barHeight);
    self.tintBar.layer.cornerRadius = 2.0;

    CGFloat textX = CGRectGetMaxX(self.tintBar.frame) + 8.0;

    [self.countBadge sizeToFit];
    CGFloat badgeW = CGRectGetWidth(self.countBadge.bounds) + 14.0;
    CGFloat badgeH = 22.0;
    self.countBadge.frame = CGRectMake(width - badgeW - side, top, badgeW, badgeH);
    self.countBadge.layer.cornerRadius = 8.0;

    CGFloat textW = CGRectGetMinX(self.countBadge.frame) - 8.0 - textX;
    self.titleLabel.frame = CGRectMake(textX, top - 1.0, textW, 18.0);
    self.protocolLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + 2.0,
                                          width - textX - side, 14.0);
}

#pragma mark - 属性（懒加载）

- (UIView *)tintBar {
    if (!_tintBar) _tintBar = [[UIView alloc] init];
    return _tintBar;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor colorWithRed:0x0E/255.0 green:0x13/255.0 blue:0x30/255.0 alpha:1.0];
    }
    return _titleLabel;
}

- (UILabel *)protocolLabel {
    if (!_protocolLabel) {
        _protocolLabel = [[UILabel alloc] init];
        _protocolLabel.font = [UIFont fontWithName:@"Menlo" size:11.0];
        if (!_protocolLabel.font) {
            _protocolLabel.font = [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightRegular];
        }
        _protocolLabel.textColor = [UIColor colorWithRed:0x8A/255.0 green:0x90/255.0 blue:0xAB/255.0 alpha:1.0];
    }
    return _protocolLabel;
}

- (UILabel *)countBadge {
    if (!_countBadge) {
        _countBadge = [[UILabel alloc] init];
        _countBadge.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightSemibold];
        _countBadge.textAlignment = NSTextAlignmentCenter;
        _countBadge.clipsToBounds = YES;
    }
    return _countBadge;
}

@end
