//
//  TSDialCell.m
//  TopStepComKit_Example
//

#import "TSDialCell.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorAppearance.h"

@interface TSDialCell ()
// 卡片浅色底与真实成品图。
@property (nonatomic, strong) UIView *tileView;
@property (nonatomic, strong) UIImageView *previewImageView;
// 无预览图时显示图标和提示。
@property (nonatomic, strong) UIImageView *placeholderIcon;
@property (nonatomic, strong) UILabel *placeholderLabel;
// 标题、来源与状态。
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *checkBadge;
@property (nonatomic, strong) UILabel *lockedLabel;
// 管理模式删除按钮。
@property (nonatomic, strong) UIButton *removeButton;
@end

@implementation TSDialCell

#pragma mark - 生命周期

// 三列卡片结构与 HTML 的 mtile、标题和副标题一致。
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.tileView];
        [self.tileView addSubview:self.previewImageView];
        [self.previewImageView addSubview:self.placeholderIcon];
        [self.previewImageView addSubview:self.placeholderLabel];
        [self.tileView addSubview:self.checkBadge];
        [self.tileView addSubview:self.lockedLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.subtitleLabel];
        [self.contentView addSubview:self.removeButton];
    }
    return self;
}

// 重用时清除回调和旧图片，避免删除到上一条数据。
- (void)prepareForReuse {
    [super prepareForReuse];
    self.onRemove = nil;
    self.previewImageView.image = nil;
    self.current = NO;
    self.managing = NO;
    self.removable = NO;
}

// 固定原型卡片高度，缩略图按设备真实比例等比缩放。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.tileView.frame = CGRectMake(0, 0, width, 112);
    BOOL round = self.screen.shape == eTSPeriphShapeCircle;
    CGFloat ratio = self.screen.screenSize.width > 0 ?
        self.screen.screenSize.height / self.screen.screenSize.width : 1.25;
    CGFloat faceHeight = round ? MIN(84, width - 16) : 89;
    CGFloat faceWidth = round ? faceHeight : MIN(width - 16, faceHeight / MAX(0.5, ratio));
    self.previewImageView.frame = CGRectMake((width - faceWidth) / 2, (112 - faceHeight) / 2, faceWidth, faceHeight);
    self.previewImageView.layer.cornerRadius = round ? faceWidth / 2 : 20;
    self.placeholderIcon.frame = CGRectMake((faceWidth - 24) / 2, faceHeight / 2 - 20, 24, 24);
    self.placeholderLabel.frame = CGRectMake(0, faceHeight / 2 + 7, faceWidth, 12);
    self.nameLabel.frame = CGRectMake(0, 120, width, 15);
    self.subtitleLabel.frame = CGRectMake(0, 139, width, 12);
    self.checkBadge.frame = CGRectMake(width - 23, 89, 18, 18);
    self.removeButton.frame = CGRectMake(width - 22, -5, 27, 27);
    self.lockedLabel.frame = CGRectMake(0, 86, width, 18);
    self.checkBadge.hidden = !self.current;
    self.removeButton.hidden = !self.managing || !self.removable;
    self.lockedLabel.hidden = !self.managing || self.removable;
    self.tileView.backgroundColor = [TSDialEditorAppearance color:self.current ? 0xFFF5EE : 0xF4F5EF];
    self.tileView.layer.borderColor = [TSDialEditorAppearance color:self.current ? 0xED9F7B : 0xF4F5EF].CGColor;
}

#pragma mark - 公开方法

// 成品图片不额外绘制时间；无图时明确展示缺省状态。
- (void)configureWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
    self.nameLabel.text = title;
    self.subtitleLabel.text = subtitle;
    self.previewImageView.image = image;
    self.previewImageView.backgroundColor = [TSDialEditorAppearance color:0xE9ECE2];
    self.placeholderIcon.hidden = image != nil;
    self.placeholderLabel.hidden = image != nil;
    self.accessibilityLabel = [NSString stringWithFormat:@"%@，%@", title, subtitle];
    self.removeButton.accessibilityLabel = [@"删除" stringByAppendingString:title];
    [self setNeedsLayout];
}

#pragma mark - 私有方法

// 删除必须由宿主确认后执行。
- (void)requestRemoval {
    if (self.managing && self.removable && self.onRemove) {
        self.onRemove();
    }
}

#pragma mark - 属性懒加载

// 原型浅色圆角卡片。
- (UIView *)tileView {
    if (!_tileView) {
        _tileView = [[UIView alloc] init];
        _tileView.layer.cornerRadius = 14;
        _tileView.layer.borderWidth = 1.5;
    }
    return _tileView;
}

// 圆表或方表屏幕裁切。
- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
    }
    return _previewImageView;
}

// 缺省手表线性图标。
- (UIImageView *)placeholderIcon {
    if (!_placeholderIcon) {
        _placeholderIcon = [[UIImageView alloc] initWithImage:[TSDialEditorAppearance icon:@"watch"]];
        _placeholderIcon.tintColor = [TSDialEditorAppearance color:0x8E9984];
    }
    return _placeholderIcon;
}

// 缺省提示。
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [TSDialEditorAppearance label:@"暂无预览" size:8 color:0x8E9984];
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _placeholderLabel;
}

// 卡片名称。
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [TSDialEditorAppearance label:@"" size:12 color:0x252823];
        _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    }
    return _nameLabel;
}

// 来源和草稿提示。
- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [TSDialEditorAppearance label:@"" size:10 color:0x959B8C];
    }
    return _subtitleLabel;
}

// 当前使用橙色勾选角标。
- (UILabel *)checkBadge {
    if (!_checkBadge) {
        _checkBadge = [TSDialEditorAppearance label:@"✓" size:12 color:0xFFFFFF];
        _checkBadge.textAlignment = NSTextAlignmentCenter;
        _checkBadge.backgroundColor = [TSDialEditorAppearance color:0xF16D43];
        _checkBadge.layer.cornerRadius = 9;
        _checkBadge.clipsToBounds = YES;
    }
    return _checkBadge;
}

// 内置表盘不可删除提示。
- (UILabel *)lockedLabel {
    if (!_lockedLabel) {
        _lockedLabel = [TSDialEditorAppearance label:@"内置 · 不可删除" size:9 color:0x909987];
        _lockedLabel.textAlignment = NSTextAlignmentCenter;
        _lockedLabel.backgroundColor = [[TSDialEditorAppearance color:0xF8F9F2] colorWithAlphaComponent:0.9];
    }
    return _lockedLabel;
}

// 删除按钮有独立命中区，不依赖长按。
- (UIButton *)removeButton {
    if (!_removeButton) {
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeButton setTitle:@"−" forState:UIControlStateNormal];
        _removeButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _removeButton.backgroundColor = [TSDialEditorAppearance color:0xDC7459];
        _removeButton.layer.cornerRadius = 13.5;
        _removeButton.layer.borderWidth = 3;
        _removeButton.layer.borderColor = UIColor.whiteColor.CGColor;
        [_removeButton addTarget:self action:@selector(requestRemoval) forControlEvents:UIControlEventTouchUpInside];
    }
    return _removeButton;
}

@end
