//
//  TSOfflineMapCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSOfflineMapCell.h"

#import "TSRootVC.h"

@interface TSOfflineMapCell ()

// 地图缩略图标
@property (nonatomic, strong) UIImageView *thumbView;
// 名称
@property (nonatomic, strong) UILabel *nameLabel;
// 大小
@property (nonatomic, strong) UILabel *sizeLabel;
// 圆形勾选框
@property (nonatomic, strong) UIView *checkbox;
// 勾选对号
@property (nonatomic, strong) UIImageView *checkMark;

@end

@implementation TSOfflineMapCell

#pragma mark - 生命周期

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = TSColor_Card;
        [self ts_buildUI];
    }
    return self;
}

#pragma mark - 公开方法

/// 配置内容
- (void)configureWithName:(NSString *)name sizeText:(NSString *)sizeText checked:(BOOL)checked {
    self.nameLabel.text = name;
    self.sizeLabel.text = sizeText;
    if (checked) {
        self.checkbox.backgroundColor = TSColor_Primary;
        self.checkbox.layer.borderColor = TSColor_Primary.CGColor;
        self.checkMark.hidden = NO;
    } else {
        self.checkbox.backgroundColor = [UIColor clearColor];
        self.checkbox.layer.borderColor = TSColor_Separator.CGColor;
        self.checkMark.hidden = YES;
    }
}

#pragma mark - 私有方法

/// 构建 UI
- (void)ts_buildUI {
    self.thumbView = [[UIImageView alloc] init];
    self.thumbView.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.12f];
    self.thumbView.layer.cornerRadius = 10.f;
    self.thumbView.layer.masksToBounds = YES;
    self.thumbView.contentMode = UIViewContentModeCenter;
    self.thumbView.tintColor = TSColor_Primary;
    if (@available(iOS 13.0, *)) {
        self.thumbView.image = [UIImage systemImageNamed:@"map.fill"];
    }
    [self.contentView addSubview:self.thumbView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:16.f];
    self.nameLabel.textColor = TSColor_TextPrimary;
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.nameLabel];

    self.sizeLabel = [[UILabel alloc] init];
    self.sizeLabel.font = [UIFont systemFontOfSize:12.5f];
    self.sizeLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:self.sizeLabel];

    self.checkbox = [[UIView alloc] init];
    self.checkbox.layer.cornerRadius = 11.f;
    self.checkbox.layer.borderWidth = 1.5f;
    self.checkbox.layer.borderColor = TSColor_Separator.CGColor;
    [self.contentView addSubview:self.checkbox];

    self.checkMark = [[UIImageView alloc] init];
    self.checkMark.tintColor = [UIColor whiteColor];
    self.checkMark.contentMode = UIViewContentModeScaleAspectFit;
    self.checkMark.hidden = YES;
    if (@available(iOS 13.0, *)) {
        self.checkMark.image = [UIImage systemImageNamed:@"checkmark"];
    }
    [self.checkbox addSubview:self.checkMark];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat pad = 16.f;
    CGFloat thumbSize = 44.f;
    CGFloat h = self.contentView.bounds.size.height;
    CGFloat w = self.contentView.bounds.size.width;

    self.thumbView.frame = CGRectMake(pad, (h - thumbSize) / 2.f, thumbSize, thumbSize);

    CGFloat checkSize = 22.f;
    self.checkbox.frame = CGRectMake(w - pad - checkSize, (h - checkSize) / 2.f, checkSize, checkSize);
    self.checkMark.frame = CGRectMake(4.f, 4.f, checkSize - 8.f, checkSize - 8.f);

    CGFloat textX = CGRectGetMaxX(self.thumbView.frame) + 12.f;
    CGFloat textW = CGRectGetMinX(self.checkbox.frame) - 10.f - textX;
    self.nameLabel.frame = CGRectMake(textX, h / 2.f - 20.f, textW, 20.f);
    self.sizeLabel.frame = CGRectMake(textX, h / 2.f + 2.f, textW, 16.f);
}

@end
