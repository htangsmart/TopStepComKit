//
//  TSDialCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/8/25.
//

#import "TSDialCell.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSRootVC.h"

static const CGFloat kDialCellCornerRadius = 10.f;
static const CGFloat kDialCellBorderWidth = 3.f;

// 返回自定义表盘预览图的本地路径
static NSString *TSCustomDialPreviewPath(NSString *dialId) {
    if (dialId.length == 0) {
        return nil;
    }
    NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask,
                                                                     YES) firstObject]
        stringByAppendingPathComponent:@"dialPreviews"];
    return [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", dialId]];
}

@interface TSDialCell ()

// 表盘预览图
@property (nonatomic, strong) UIImageView *previewImageView;
// 无预览图时显示的表盘名称
@property (nonatomic, strong) UILabel *placeholderLabel;
// 当前表盘勾选角标
@property (nonatomic, strong) UILabel *checkBadge;

@end

@implementation TSDialCell

#pragma mark - 生命周期

// 初始化表盘单元格
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    self.contentView.layer.cornerRadius = kDialCellCornerRadius;
    self.contentView.clipsToBounds = YES;
    self.layer.cornerRadius = kDialCellCornerRadius;

    [self.contentView addSubview:self.previewImageView];
    [self.contentView addSubview:self.placeholderLabel];
    [self addSubview:self.checkBadge];
    return self;
}

// 更新子视图布局
- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewImageView.frame = self.contentView.bounds;
    self.placeholderLabel.frame = CGRectInset(self.contentView.bounds, 6, 6);
    self.checkBadge.frame = CGRectMake(CGRectGetWidth(self.bounds) - 20,
                                       CGRectGetHeight(self.bounds) - 20,
                                       18,
                                       18);
}

#pragma mark - 公开方法

// 使用表盘模型刷新单元格
- (void)configureWithDial:(TSDialModel *)dial isCurrent:(BOOL)isCurrent {
    UIImage *previewImage = nil;
    if (dial.dialType == eTSDialTypeCustomer) {
        NSString *previewPath = TSCustomDialPreviewPath(dial.dialId);
        if (previewPath) {
            previewImage = [UIImage imageWithContentsOfFile:previewPath];
        }
    }

    if (previewImage) {
        self.previewImageView.image = previewImage;
        self.previewImageView.hidden = NO;
        self.placeholderLabel.hidden = YES;
        self.contentView.backgroundColor = UIColor.blackColor;
    } else {
        self.previewImageView.hidden = YES;
        self.placeholderLabel.hidden = NO;
        self.placeholderLabel.text = dial.dialName.length ? dial.dialName : TSLocalizedString(@"dial.default_name");
        self.contentView.backgroundColor = [self colorForDialType:dial.dialType];
    }

    self.layer.borderWidth = isCurrent ? kDialCellBorderWidth : 0;
    self.layer.borderColor = isCurrent ? TSColor_Primary.CGColor : UIColor.clearColor.CGColor;
    self.checkBadge.hidden = !isCurrent;
}

#pragma mark - 私有方法

// 返回表盘类型对应的占位颜色
- (UIColor *)colorForDialType:(TSDialType)type {
    switch (type) {
        case eTSDialTypeBuiltIn:
            return TSColor_Indigo;
        case eTSDialTypeCloud:
            return TSColor_Primary;
        case eTSDialTypeCustomer:
            return TSColor_Teal;
        default:
            return TSColor_Gray;
    }
}

#pragma mark - 属性懒加载

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
    }
    return _previewImageView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        _placeholderLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9f];
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.numberOfLines = 3;
    }
    return _placeholderLabel;
}

- (UILabel *)checkBadge {
    if (!_checkBadge) {
        _checkBadge = [[UILabel alloc] init];
        _checkBadge.text = @"✓";
        _checkBadge.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        _checkBadge.textColor = UIColor.whiteColor;
        _checkBadge.textAlignment = NSTextAlignmentCenter;
        _checkBadge.backgroundColor = TSColor_Primary;
        _checkBadge.layer.cornerRadius = 9;
        _checkBadge.clipsToBounds = YES;
        _checkBadge.hidden = YES;
    }
    return _checkBadge;
}

@end
