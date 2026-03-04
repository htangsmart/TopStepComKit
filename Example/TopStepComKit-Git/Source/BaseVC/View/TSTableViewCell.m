//
//  TSTableViewCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/2.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTableViewCell.h"
#import "TSBaseVC.h"  // Design System 常量

static const CGFloat kIconSize        = 36.f;
static const CGFloat kIconCorner      = 8.f;
static const CGFloat kIconPadding     = 8.f;
static const CGFloat kIconLeading     = 16.f;
static const CGFloat kTitleFontSize   = 15.f;
static const CGFloat kSubtitleFontSize = 12.f;

@interface TSTableViewCell ()
@property (nonatomic, strong) UIView      *iconContainer;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *subtitleLabel;
@end

@implementation TSTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self ts_setupViews];
    }
    return self;
}

- (void)ts_setupViews {
    self.backgroundColor = TSColor_Card;
    self.selectionStyle  = UITableViewCellSelectionStyleDefault;
    self.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;

    // 图标背景圆角容器
    self.iconContainer = [[UIView alloc] init];
    self.iconContainer.layer.cornerRadius = kIconCorner;
    self.iconContainer.clipsToBounds      = YES;
    self.iconContainer.backgroundColor    = TSColor_Primary;
    [self.contentView addSubview:self.iconContainer];

    // SF Symbol 图标
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.tintColor     = [UIColor whiteColor];
    self.iconImageView.contentMode   = UIViewContentModeScaleAspectFit;
    [self.iconContainer addSubview:self.iconImageView];

    // 主标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font      = [UIFont systemFontOfSize:kTitleFontSize weight:UIFontWeightMedium];
    self.titleLabel.textColor = TSColor_TextPrimary;
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];

    // 副标题
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.font      = [UIFont systemFontOfSize:kSubtitleFontSize];
    self.subtitleLabel.textColor = TSColor_TextSecondary;
    self.subtitleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.subtitleLabel];
}

#pragma mark - Public

- (void)reloadCellWithModel:(TSValueModel *)cellModel {
    self.titleLabel.text = cellModel.valueName;

    BOOL hasSubtitle = (cellModel.subtitle.length > 0);
    self.subtitleLabel.text   = cellModel.subtitle;
    self.subtitleLabel.hidden = !hasSubtitle;

    BOOL hasIcon = (cellModel.iconName.length > 0);
    self.iconContainer.hidden = !hasIcon;

    if (hasIcon) {
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:kIconSize - kIconPadding * 2 weight:UIImageSymbolWeightMedium];
            UIImage *img = [UIImage systemImageNamed:cellModel.iconName withConfiguration:config];
            self.iconImageView.image = img ?: [UIImage systemImageNamed:@"square.grid.2x2.fill" withConfiguration:config];
        }
        self.iconContainer.backgroundColor = cellModel.iconColor ?: TSColor_Primary;
    }

    [self setNeedsLayout];
}

- (void)reloadCellWithName:(NSString *)name {
    self.titleLabel.text      = name;
    self.subtitleLabel.text   = nil;
    self.subtitleLabel.hidden = YES;
    self.iconContainer.hidden = YES;
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat contentH = CGRectGetHeight(self.contentView.bounds);
    CGFloat iconY    = (contentH - kIconSize) / 2.f;

    CGFloat textLeading;
    if (!self.iconContainer.hidden) {
        self.iconContainer.frame  = CGRectMake(kIconLeading, iconY, kIconSize, kIconSize);
        CGFloat imgPad            = kIconPadding;
        self.iconImageView.frame  = CGRectMake(imgPad, imgPad, kIconSize - imgPad * 2, kIconSize - imgPad * 2);
        textLeading               = CGRectGetMaxX(self.iconContainer.frame) + 12.f;
    } else {
        textLeading = kIconLeading;
    }

    CGFloat textWidth = CGRectGetWidth(self.contentView.bounds) - textLeading - 8.f;

    if (!self.subtitleLabel.hidden && self.subtitleLabel.text.length > 0) {
        // 双行布局
        CGFloat titleH    = 20.f;
        CGFloat subtitleH = 16.f;
        CGFloat blockH    = titleH + 3.f + subtitleH;
        CGFloat startY    = (contentH - blockH) / 2.f;
        self.titleLabel.frame    = CGRectMake(textLeading, startY, textWidth, titleH);
        self.subtitleLabel.frame = CGRectMake(textLeading, startY + titleH + 3.f, textWidth, subtitleH);
    } else {
        // 单行居中
        CGFloat titleH = 22.f;
        self.titleLabel.frame  = CGRectMake(textLeading, (contentH - titleH) / 2.f, textWidth, titleH);
        self.subtitleLabel.frame = CGRectZero;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
