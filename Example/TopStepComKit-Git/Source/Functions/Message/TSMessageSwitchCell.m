//
//  TSMessageSwitchCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/17.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSMessageSwitchCell.h"
#import "TSBaseVC.h"
#import <TopStepComKit/TopStepComKit.h>

@interface TSMessageSwitchCell ()
@property (nonatomic, strong) UIView       *iconBg;
@property (nonatomic, strong) UIImageView  *iconView;
@property (nonatomic, strong) UILabel      *nameLabel;
@property (nonatomic, strong) UISwitch     *toggle;
@end

@implementation TSMessageSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;

        // 图标圆角背景
        _iconBg = [[UIView alloc] init];
        _iconBg.layer.cornerRadius = 8;
        _iconBg.clipsToBounds = YES;
        _iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_iconBg];

        // SF Symbol 图标
        _iconView = [[UIImageView alloc] init];
        _iconView.tintColor = UIColor.whiteColor;
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [_iconBg addSubview:_iconView];

        // 名称
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = TSFont_Body;
        _nameLabel.textColor = TSColor_TextPrimary;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_nameLabel];

        // Switch
        _toggle = [[UISwitch alloc] init];
        _toggle.onTintColor = TSColor_Primary;
        _toggle.translatesAutoresizingMaskIntoConstraints = NO;
        [_toggle addTarget:self action:@selector(onToggleChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_toggle];

        CGFloat iconSize = 32;
        CGFloat symbolPad = 6;

        [NSLayoutConstraint activateConstraints:@[
            // 图标背景：左边距 16，垂直居中，固定 32×32，上下各留 12pt（决定最小 Cell 高度）
            [_iconBg.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:TSSpacing_MD],
            [_iconBg.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_iconBg.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:TSSpacing_MD],
            [_iconBg.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-TSSpacing_MD],
            [_iconBg.widthAnchor constraintEqualToConstant:iconSize],
            [_iconBg.heightAnchor constraintEqualToConstant:iconSize],

            // 图标内部 symbol，内缩 6pt
            [_iconView.leadingAnchor constraintEqualToAnchor:_iconBg.leadingAnchor constant:symbolPad],
            [_iconView.trailingAnchor constraintEqualToAnchor:_iconBg.trailingAnchor constant:-symbolPad],
            [_iconView.topAnchor constraintEqualToAnchor:_iconBg.topAnchor constant:symbolPad],
            [_iconView.bottomAnchor constraintEqualToAnchor:_iconBg.bottomAnchor constant:-symbolPad],

            // Switch：右边距 16，垂直居中
            [_toggle.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-TSSpacing_MD],
            [_toggle.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

            // 名称：图标右边 12，Switch 左边 8，垂直居中，撑开高度
            [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconBg.trailingAnchor constant:TSSpacing_MD],
            [_nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_toggle.leadingAnchor constant:-TSSpacing_SM],
            [_nameLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_nameLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:TSSpacing_MD],
            [_nameLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-TSSpacing_MD],
        ]];
    }
    return self;
}

- (void)configureWithModel:(TSMessageModel *)model
                  iconName:(NSString *)iconName
                 iconColor:(UIColor *)iconColor
                      name:(NSString *)name {
    _iconBg.backgroundColor = iconColor;
    _iconView.image = [UIImage systemImageNamed:iconName];
    _nameLabel.text = name;
    _toggle.on = model.isEnable;
}

- (void)setEnabled:(BOOL)enabled {
    _toggle.enabled = enabled;
    _nameLabel.alpha = enabled ? 1.0 : 0.5;
}

- (void)onToggleChanged:(UISwitch *)sender {
    if (self.onSwitchChanged) {
        self.onSwitchChanged(sender.isOn);
    }
}

@end
