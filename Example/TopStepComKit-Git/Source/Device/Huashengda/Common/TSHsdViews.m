//
//  TSHsdViews.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdViews.h"
#import "TSHsdDisplay.h"
#import "TSRootVC.h"
#import <objc/runtime.h>

#pragma mark - 工具函数

UIImage *_Nullable TSHsdSymbol(NSString *name, CGFloat pointSize, UIImageSymbolWeight weight) {
    if (!name.length) { return nil; }
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight];
    UIImage *image = [UIImage systemImageNamed:name withConfiguration:config];
    if (!image) { image = [UIImage systemImageNamed:@"questionmark.circle" withConfiguration:config]; }
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

NSAttributedString *TSHsdRich(NSString *text, UIFont *font, UIColor *color, UIColor *boldColor) {
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    UIFont *bold = [UIFont systemFontOfSize:font.pointSize weight:UIFontWeightSemibold];
    NSArray<NSString *> *parts = [text componentsSeparatedByString:@"<b>"];
    for (NSUInteger i = 0; i < parts.count; i++) {
        NSString *part = parts[i];
        if (i == 0) {
            [result appendAttributedString:[[NSAttributedString alloc] initWithString:part attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}]];
            continue;
        }
        NSRange close = [part rangeOfString:@"</b>"];
        NSString *boldText = close.location == NSNotFound ? part : [part substringToIndex:close.location];
        NSString *rest = close.location == NSNotFound ? @"" : [part substringFromIndex:close.location + close.length];
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:boldText attributes:@{NSFontAttributeName: bold, NSForegroundColorAttributeName: boldColor}]];
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:rest attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}]];
    }
    return result;
}

static UIColor *TSHsdLine(void) {
    return TSAdaptiveColor([[UIColor blackColor] colorWithAlphaComponent:0.06], [[UIColor whiteColor] colorWithAlphaComponent:0.08]);
}

static UIColor *TSHsdFill2(void) {
    return TSAdaptiveColor([UIColor colorWithRed:0xE1/255.f green:0xE4/255.f blue:0xEE/255.f alpha:1], [UIColor colorWithRed:0x2A/255.f green:0x2F/255.f blue:0x40/255.f alpha:1]);
}

static void TSHsdApplyCardShadow(UIView *view) {
    view.layer.shadowColor = [UIColor colorWithRed:0x14/255.f green:0x17/255.f blue:0x26/255.f alpha:1].CGColor;
    view.layer.shadowOpacity = 0.06f;
    view.layer.shadowRadius = 10.f;
    view.layer.shadowOffset = CGSizeMake(0, 4.f);
}

static CGFloat TSHsdTextHeight(NSString *text, UIFont *font, CGFloat width, CGFloat lineMultiple) {
    if (!text.length) { return 0; }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineMultiple;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: style}
                                     context:nil];
    return ceil(rect.size.height);
}

static UILabel *TSHsdMakeLabel(UIFont *font, UIColor *color) {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

#pragma mark - UIView (TSHsdBlockSpacing)

@implementation UIView (TSHsdBlockSpacing)

- (NSNumber *)hsd_spacingBefore { return objc_getAssociatedObject(self, @selector(hsd_spacingBefore)); }
- (void)setHsd_spacingBefore:(NSNumber *)value { objc_setAssociatedObject(self, @selector(hsd_spacingBefore), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
- (NSNumber *)hsd_spacingAfter { return objc_getAssociatedObject(self, @selector(hsd_spacingAfter)); }
- (void)setHsd_spacingAfter:(NSNumber *)value { objc_setAssociatedObject(self, @selector(hsd_spacingAfter), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

@end

#pragma mark - TSHsdStackView

@interface TSHsdStackView ()
@property (nonatomic, strong) NSMutableArray<UIView *> *blockList;
@end

@implementation TSHsdStackView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _blockList = [NSMutableArray array];
    _spacing = 12.f;
    _sideInset = 16.f;
    _topInset = 2.f;
    _bottomInset = 40.f;
    return self;
}

- (void)setBlocks:(NSArray<UIView *> *)blocks {
    [self removeAllBlocks];
    for (UIView *block in blocks) { [self addBlock:block]; }
}

- (void)addBlock:(UIView *)block {
    if (!block) { return; }
    [self.blockList addObject:block];
    [self addSubview:block];
    [self setNeedsLayout];
}

- (void)removeAllBlocks {
    for (UIView *block in self.blockList) { [block removeFromSuperview]; }
    [self.blockList removeAllObjects];
}

- (CGFloat)ts_gapBetween:(UIView *)a and:(UIView *)b {
    if (b.hsd_spacingBefore) { return b.hsd_spacingBefore.doubleValue; }
    if (a.hsd_spacingAfter) { return a.hsd_spacingAfter.doubleValue; }
    return self.spacing;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = size.width - self.sideInset * 2;
    CGFloat y = self.topInset;
    UIView *previous = nil;
    for (UIView *block in self.blockList) {
        if (block.hidden) { continue; }
        if (previous) { y += [self ts_gapBetween:previous and:block]; }
        y += [block sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
        previous = block;
    }
    return CGSizeMake(size.width, y + self.bottomInset);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width - self.sideInset * 2;
    CGFloat y = self.topInset;
    UIView *previous = nil;
    for (UIView *block in self.blockList) {
        if (block.hidden) { continue; }
        if (previous) { y += [self ts_gapBetween:previous and:block]; }
        CGFloat h = [block sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
        block.frame = CGRectMake(self.sideInset, y, width, h);
        y += h;
        previous = block;
    }
}

@end

#pragma mark - TSHsdChipsRow

@interface TSHsdChipsRow ()
@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;
@end

@implementation TSHsdChipsRow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _labels = [NSMutableArray array];
    _hue = [TSHsdDisplay hueParental];
    self.hsd_spacingAfter = @(6);
    return self;
}

- (void)setChips:(NSArray<NSString *> *)chips {
    _chips = [chips copy];
    for (UILabel *label in self.labels) { [label removeFromSuperview]; }
    [self.labels removeAllObjects];
    [chips enumerateObjectsUsingBlock:^(NSString *chip, NSUInteger idx, BOOL *stop) {
        UILabel *label = TSHsdMakeLabel([UIFont monospacedSystemFontOfSize:11.f weight:UIFontWeightSemibold], idx == 0 ? self.hue : [TSHsdDisplay textSecondary]);
        label.text = chip;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = idx == 0 ? [TSHsdDisplay tint12:self.hue] : [TSHsdDisplay fill];
        label.layer.cornerRadius = 7.f;
        label.clipsToBounds = YES;
        [self addSubview:label];
        [self.labels addObject:label];
    }];
    [self setNeedsLayout];
}

- (void)setHue:(UIColor *)hue {
    _hue = hue;
    self.chips = self.chips;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, self.labels.count ? 22.f : 0);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 4.f;
    for (UILabel *label in self.labels) {
        CGFloat w = ceil([label.text sizeWithAttributes:@{NSFontAttributeName: label.font}].width) + 16.f;
        label.frame = CGRectMake(x, 0, w, 22.f);
        x += w + 6.f;
    }
}

@end

#pragma mark - TSHsdSecView

@interface TSHsdSecView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong, readwrite) UIButton *actionButton;
@end

@implementation TSHsdSecView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _titleLabel = TSHsdMakeLabel([UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold], [TSHsdDisplay textSecondary]);
    [self addSubview:_titleLabel];
    _rightLabel = TSHsdMakeLabel([UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium], [TSHsdDisplay textTertiary]);
    _rightLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_rightLabel];
    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold];
    _actionButton.layer.cornerRadius = 14.f;
    _actionButton.layer.borderWidth = 1.f;
    _actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10.f, 0, 11.f);
    _actionButton.hidden = YES;
    [_actionButton addTarget:self action:@selector(ts_actionTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_actionButton];
    self.hsd_spacingAfter = @(8);
    return self;
}

- (void)setTitle:(NSString *)title { _title = [title copy]; self.titleLabel.text = title; }
- (void)setRightText:(nullable NSString *)rightText { _rightText = [rightText copy]; self.rightLabel.text = rightText; }
- (void)setActionTitle:(nullable NSString *)actionTitle { _actionTitle = [actionTitle copy]; [self ts_applyAction]; }
- (void)setActionSymbol:(nullable NSString *)actionSymbol { _actionSymbol = [actionSymbol copy]; [self ts_applyAction]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_applyAction]; }

- (void)ts_applyAction {
    self.actionButton.hidden = (self.actionTitle.length == 0);
    [self.actionButton setTitle:self.actionTitle forState:UIControlStateNormal];
    [self.actionButton setTitleColor:self.hue forState:UIControlStateNormal];
    [self.actionButton setImage:TSHsdSymbol(self.actionSymbol, 12.f, UIImageSymbolWeightBold) forState:UIControlStateNormal];
    self.actionButton.imageEdgeInsets = self.actionSymbol.length ? UIEdgeInsetsMake(0, -3.f, 0, 3.f) : UIEdgeInsetsZero;
    self.actionButton.tintColor = self.hue;
    self.actionButton.backgroundColor = [self.hue colorWithAlphaComponent:0.12f];
    self.actionButton.layer.borderColor = [self.hue colorWithAlphaComponent:0.22f].CGColor;
    [self setNeedsLayout];
}

- (void)ts_actionTapped { if (self.onAction) { self.onAction(); } }

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (self.actionTitle.length) { [self ts_applyAction]; }   // CGColor 不随深浅色自动切换
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, self.actionTitle.length ? 32.f : 26.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    if (self.actionTitle.length) {
        CGSize bs = [self.actionButton sizeThatFits:CGSizeZero];
        CGFloat bw = ceil(bs.width) + (self.actionSymbol.length ? 4.f : 0);
        self.actionButton.frame = CGRectMake(w - 4.f - bw, 2.f, bw, 28.f);
        CGFloat rightMax = CGRectGetMinX(self.actionButton.frame) - 8.f;
        self.rightLabel.frame = CGRectMake(w / 2.f, 6.f, rightMax - w / 2.f, 20.f);
        self.titleLabel.frame = CGRectMake(6.f, 6.f, w / 2.f, 20.f);
        return;
    }
    self.rightLabel.frame = CGRectMake(w / 2.f, 6.f, w / 2.f - 6.f, 20.f);
    self.titleLabel.frame = CGRectMake(6.f, 6.f, w / 2.f, 20.f);
}

@end

#pragma mark - TSHsdFootView

@interface TSHsdFootView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdFootView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:12.5f], [TSHsdDisplay textTertiary]);
    _label.numberOfLines = 0;
    [self addSubview:_label];
    self.hsd_spacingBefore = @(8);
    return self;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.25f;
    self.label.attributedText = [[NSAttributedString alloc] initWithString:text ?: @"" attributes:@{NSFontAttributeName: self.label.font, NSForegroundColorAttributeName: self.label.textColor, NSParagraphStyleAttributeName: style}];
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, TSHsdTextHeight(self.text, self.label.font, size.width - 12.f, 1.25f));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(6.f, 0, self.bounds.size.width - 12.f, self.bounds.size.height);
}

@end

#pragma mark - TSHsdBannerView

@interface TSHsdBannerView ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.layer.cornerRadius = 16.f;
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconView];
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:12.5f], [TSHsdDisplay textSecondary]);
    _label.numberOfLines = 0;
    [self addSubview:_label];
    [self ts_apply];
    return self;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.2f;
    self.label.attributedText = [[NSAttributedString alloc] initWithString:text ?: @"" attributes:@{NSFontAttributeName: self.label.font, NSForegroundColorAttributeName: self.label.textColor, NSParagraphStyleAttributeName: style}];
    [self setNeedsLayout];
}

- (void)setWarn:(BOOL)warn { _warn = warn; [self ts_apply]; }

- (void)ts_apply {
    UIColor *tint = self.warn ? [TSHsdDisplay statusWarn] : [TSHsdDisplay hueParental];
    self.backgroundColor = [tint colorWithAlphaComponent:self.warn ? 0.11f : 0.08f];
    self.iconView.tintColor = tint;
    self.iconView.image = TSHsdSymbol(self.warn ? @"exclamationmark.triangle" : @"info.circle", 15.f, UIImageSymbolWeightMedium);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat textW = size.width - 14.f * 2 - 17.f - 10.f;
    return CGSizeMake(size.width, TSHsdTextHeight(self.text, self.label.font, textW, 1.2f) + 24.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.iconView.frame = CGRectMake(14.f, 13.f, 17.f, 17.f);
    self.label.frame = CGRectMake(41.f, 12.f, w - 41.f - 14.f, self.bounds.size.height - 24.f);
}

@end

#pragma mark - TSHsdIconBlock

@interface TSHsdIconBlock ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation TSHsdIconBlock

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _side = 40.f;
    _tint = [TSHsdDisplay hueParental];
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];
    [self ts_apply];
    return self;
}

- (void)setSymbol:(nullable NSString *)symbol { _symbol = [symbol copy]; [self ts_apply]; }
- (void)setTint:(UIColor *)tint { _tint = tint; [self ts_apply]; }
- (void)setEmoStyle:(BOOL)emoStyle { _emoStyle = emoStyle; [self ts_apply]; }
- (void)setSide:(CGFloat)side { _side = side; [self ts_apply]; }

- (void)ts_apply {
    self.layer.cornerRadius = self.side >= 48.f ? 16.f : (self.side <= 30.f ? 10.f : 13.f);
    self.backgroundColor = self.emoStyle ? [TSHsdDisplay fill] : [TSHsdDisplay tint12:self.tint];
    self.imageView.tintColor = self.emoStyle ? [TSHsdDisplay ink] : self.tint;
    CGFloat pointSize = self.side >= 48.f ? 22.f : (self.side <= 30.f ? 14.f : 18.f);
    self.imageView.image = TSHsdSymbol(self.symbol, pointSize, UIImageSymbolWeightMedium);
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(self.side, self.side); }

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end

#pragma mark - TSHsdCardView

@interface TSHsdCardView ()
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) NSMutableArray<UIView *> *separators;
@end

@implementation TSHsdCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _separators = [NSMutableArray array];
    _container = [[UIView alloc] init];
    _container.layer.cornerRadius = 22.f;
    _container.clipsToBounds = YES;
    [self addSubview:_container];
    [self ts_applyStyle];
    return self;
}

- (void)setRows:(NSArray<UIView *> *)rows {
    for (UIView *row in _rows) { [row removeFromSuperview]; }
    for (UIView *separator in self.separators) { [separator removeFromSuperview]; }
    [self.separators removeAllObjects];
    _rows = [rows copy];
    for (UIView *row in rows) {
        if ([row isKindOfClass:[TSHsdRowView class]]) { ((TSHsdRowView *)row).compact = self.readOnlyStyle; }
        [self.container addSubview:row];
    }
    for (NSUInteger i = 1; i < rows.count; i++) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = self.readOnlyStyle ? TSHsdFill2() : TSHsdLine();
        [self.container addSubview:separator];
        [self.separators addObject:separator];
    }
    [self setNeedsLayout];
}

- (void)setReadOnlyStyle:(BOOL)readOnlyStyle {
    _readOnlyStyle = readOnlyStyle;
    [self ts_applyStyle];
    for (UIView *row in self.rows) {
        if ([row isKindOfClass:[TSHsdRowView class]]) { ((TSHsdRowView *)row).compact = readOnlyStyle; }
    }
    for (UIView *separator in self.separators) { separator.backgroundColor = readOnlyStyle ? TSHsdFill2() : TSHsdLine(); }
}

- (void)setGradient:(nullable CAGradientLayer *)gradient {
    [_gradient removeFromSuperlayer];
    _gradient = gradient;
    if (gradient) { [self.container.layer insertSublayer:gradient atIndex:0]; }
}

- (void)ts_applyStyle {
    self.container.backgroundColor = self.readOnlyStyle ? [TSHsdDisplay fill] : [TSHsdDisplay card];
    if (self.readOnlyStyle) {
        self.layer.shadowOpacity = 0;
    } else {
        TSHsdApplyCardShadow(self);
    }
}

- (BOOL)ts_rowHasLead:(UIView *)row {
    return [row isKindOfClass:[TSHsdRowView class]] && ((TSHsdRowView *)row).hasLead;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = self.readOnlyStyle ? 8.f : 0;
    for (UIView *row in self.rows) {
        if (row.hidden) { continue; }
        h += [row sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)].height;
    }
    return CGSizeMake(size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.container.frame = self.bounds;
    self.gradient.frame = self.container.bounds;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:22.f].CGPath;
    CGFloat w = self.bounds.size.width;
    CGFloat y = self.readOnlyStyle ? 4.f : 0;
    UIView *previous = nil;
    NSUInteger separatorIndex = 0;
    for (NSUInteger i = 0; i < self.rows.count; i++) {
        UIView *row = self.rows[i];
        if (i > 0 && separatorIndex < self.separators.count) {
            UIView *separator = self.separators[separatorIndex++];
            separator.hidden = row.hidden || !previous;
            CGFloat left = ([self ts_rowHasLead:row] && [self ts_rowHasLead:previous]) ? 69.f : 16.f;
            separator.frame = CGRectMake(left, y, w - left - 16.f, 1.f / [UIScreen mainScreen].scale);
        }
        if (row.hidden) { continue; }
        CGFloat h = [row sizeThatFits:CGSizeMake(w, CGFLOAT_MAX)].height;
        row.frame = CGRectMake(0, y, w, h);
        y += h;
        previous = row;
    }
}

@end

#pragma mark - TSHsdRowView

@interface TSHsdRowView ()
@property (nonatomic, strong) TSHsdIconBlock *iconBlock;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *chevron;
@property (nonatomic, strong) UIView *highlight;
@end

@implementation TSHsdRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];

    _highlight = [[UIView alloc] init];
    _highlight.backgroundColor = [TSHsdDisplay fill];
    _highlight.hidden = YES;
    [self addSubview:_highlight];

    _iconBlock = [[TSHsdIconBlock alloc] init];
    _iconBlock.hidden = YES;
    [self addSubview:_iconBlock];

    _titleLabel = TSHsdMakeLabel([UIFont systemFontOfSize:16.f weight:UIFontWeightMedium], [TSHsdDisplay ink]);
    _titleLabel.numberOfLines = 2;
    [self addSubview:_titleLabel];

    _subtitleLabel = TSHsdMakeLabel([UIFont systemFontOfSize:12.5f], [TSHsdDisplay textSecondary]);
    _subtitleLabel.numberOfLines = 2;
    [self addSubview:_subtitleLabel];

    _chevron = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"chevron.right", 13.f, UIImageSymbolWeightSemibold)];
    _chevron.tintColor = [TSHsdDisplay textTertiary];
    _chevron.contentMode = UIViewContentModeCenter;
    _chevron.hidden = YES;
    [self addSubview:_chevron];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_tapped)];
    [self addGestureRecognizer:tap];
    return self;
}

- (void)setSymbol:(nullable NSString *)symbol {
    _symbol = [symbol copy];
    self.iconBlock.symbol = symbol;
    self.iconBlock.hidden = (symbol.length == 0);
    [self setNeedsLayout];
}

- (void)setIconColor:(nullable UIColor *)iconColor { _iconColor = iconColor; self.iconBlock.tint = iconColor ?: self.hue; }
- (void)setHue:(UIColor *)hue { _hue = hue; if (!self.iconColor) { self.iconBlock.tint = hue; } }
- (void)setEmoStyle:(BOOL)emoStyle { _emoStyle = emoStyle; self.iconBlock.emoStyle = emoStyle; }
- (void)setTitle:(nullable NSString *)title { _title = [title copy]; self.titleLabel.text = title; [self setNeedsLayout]; }
- (void)setAttributedTitle:(nullable NSAttributedString *)attributedTitle { _attributedTitle = [attributedTitle copy]; self.titleLabel.attributedText = attributedTitle; [self setNeedsLayout]; }
- (void)setSubtitle:(nullable NSString *)subtitle { _subtitle = [subtitle copy]; self.subtitleLabel.text = subtitle; [self setNeedsLayout]; }

- (void)setExtraView:(nullable UIView *)extraView {
    [_extraView removeFromSuperview];
    _extraView = extraView;
    if (extraView) { [self addSubview:extraView]; }
    [self setNeedsLayout];
}

- (void)setRightView:(nullable UIView *)rightView {
    [_rightView removeFromSuperview];
    _rightView = rightView;
    if (rightView) { [self addSubview:rightView]; }
    [self setNeedsLayout];
}

- (void)setShowsChevron:(BOOL)showsChevron { _showsChevron = showsChevron; self.chevron.hidden = !showsChevron; [self setNeedsLayout]; }
- (void)setOff:(BOOL)off { _off = off; self.alpha = off ? 0.45f : 1.f; self.userInteractionEnabled = !off; }
- (void)setDim:(BOOL)dim { _dim = dim; CGFloat a = dim ? 0.5f : 1.f; self.iconBlock.alpha = a; self.titleLabel.alpha = a; self.subtitleLabel.alpha = a; self.extraView.alpha = a; }
- (void)setCompact:(BOOL)compact {
    _compact = compact;
    self.titleLabel.font = compact ? [UIFont systemFontOfSize:14.5f weight:UIFontWeightRegular] : [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
    self.titleLabel.textColor = compact ? [TSHsdDisplay textSecondary] : [TSHsdDisplay ink];
    [self setNeedsLayout];
}

- (BOOL)hasLead { return self.symbol.length > 0; }

- (void)ts_tapped {
    if (!self.onTap) { return; }
    self.highlight.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.highlight.hidden = YES; });
    self.onTap();
}

- (CGFloat)ts_rightWidth {
    CGFloat w = 0;
    if (self.rightView) { w += [self.rightView sizeThatFits:CGSizeMake(200.f, 60.f)].width; }
    if (self.showsChevron) { w += 16.f + (self.rightView ? 8.f : 0); }
    return w;
}

- (CGFloat)ts_textWidthFor:(CGFloat)width {
    CGFloat left = 16.f + (self.hasLead ? 40.f + 13.f : 0);
    CGFloat right = [self ts_rightWidth];
    return width - left - 16.f - (right > 0 ? right + 13.f : 0);
}

- (CGFloat)ts_textBlockHeightFor:(CGFloat)width {
    CGFloat textW = [self ts_textWidthFor:width];
    CGFloat h = 0;
    if (self.titleLabel.text.length || self.titleLabel.attributedText.length) {
        h += MIN([self.titleLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height, 44.f);
    }
    if (self.subtitle.length) { h += 3.f + MIN([self.subtitleLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height, 36.f); }
    if (self.extraView) { h += 7.f + [self.extraView sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height; }
    return h;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat pad = self.compact ? 9.f : 12.f;
    CGFloat minH = self.compact ? 46.f : 60.f;
    CGFloat content = [self ts_textBlockHeightFor:size.width];
    if (self.hasLead) { content = MAX(content, 40.f); }
    if (self.rightView) { content = MAX(content, [self.rightView sizeThatFits:CGSizeMake(200.f, 60.f)].height); }
    return CGSizeMake(size.width, MAX(minH, content + pad * 2));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    self.highlight.frame = self.bounds;
    CGFloat x = 16.f;
    if (self.hasLead) {
        self.iconBlock.frame = CGRectMake(x, self.topAligned ? 12.f : (h - 40.f) / 2.f, 40.f, 40.f);
        x += 53.f;
    }
    // 右侧：箭头贴边，控件在其左
    CGFloat rightEdge = w - 16.f;
    if (self.showsChevron) {
        self.chevron.frame = CGRectMake(rightEdge - 16.f + 5.f, (h - 16.f) / 2.f, 16.f, 16.f);
        rightEdge -= 16.f - 5.f + 8.f;
    }
    if (self.rightView) {
        CGSize rs = [self.rightView sizeThatFits:CGSizeMake(200.f, 60.f)];
        self.rightView.frame = CGRectMake(rightEdge - rs.width, self.topAligned ? 12.f : (h - rs.height) / 2.f, rs.width, rs.height);
    }
    CGFloat textW = [self ts_textWidthFor:w];
    CGFloat block = [self ts_textBlockHeightFor:w];
    CGFloat y = self.topAligned ? 12.f : (h - block) / 2.f;
    CGFloat titleH = MIN([self.titleLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height, 44.f);
    self.titleLabel.frame = CGRectMake(x, y, textW, titleH);
    y += titleH;
    if (self.subtitle.length) {
        CGFloat subH = MIN([self.subtitleLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height, 36.f);
        self.subtitleLabel.frame = CGRectMake(x, y + 3.f, textW, subH);
        y += 3.f + subH;
    } else {
        self.subtitleLabel.frame = CGRectZero;
    }
    if (self.extraView) {
        CGFloat extraH = [self.extraView sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height;
        self.extraView.frame = CGRectMake(x, y + 7.f, textW, extraH);
    }
}

@end

#pragma mark - TSHsdTimeBox

@implementation TSHsdTimeBox

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    self.titleLabel.font = [TSHsdDisplay roundedFontOfSize:16.f weight:UIFontWeightSemibold];
    self.layer.cornerRadius = 11.f;
    [self addTarget:self action:@selector(ts_tapped) forControlEvents:UIControlEventTouchUpInside];
    [self ts_apply];
    return self;
}

- (void)setMinute:(NSInteger)minute { _minute = minute; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }

- (void)ts_apply {
    [self setTitle:[TSHsdDisplay timeStringForMinute:self.minute] forState:UIControlStateNormal];
    [self setTitleColor:self.hue forState:UIControlStateNormal];
    self.backgroundColor = [self.hue colorWithAlphaComponent:0.11f];
}

- (void)ts_tapped { if (self.onTap) { self.onTap(); } }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(72.f, 34.f); }

@end

#pragma mark - TSHsdValueBox

@implementation TSHsdValueBox

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    self.layer.cornerRadius = 11.f;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
    [self addTarget:self action:@selector(ts_tapped) forControlEvents:UIControlEventTouchUpInside];
    [self ts_apply];
    return self;
}

- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }
- (void)setValueText:(NSAttributedString *)valueText { _valueText = [valueText copy]; [self ts_apply]; }

- (void)ts_apply {
    self.backgroundColor = [self.hue colorWithAlphaComponent:0.11f];
    if (!self.valueText) { [self setAttributedTitle:nil forState:UIControlStateNormal]; return; }
    [self setAttributedTitle:self.valueText forState:UIControlStateNormal];
}

- (void)ts_tapped { if (self.onTap) { self.onTap(); } }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat textW = ceil([self.valueText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 34.f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width);
    return CGSizeMake(MAX(56.f, textW + 24.f), 34.f);
}

@end

#pragma mark - TSHsdValueLabel

@implementation TSHsdValueLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.font = [UIFont systemFontOfSize:15.f];
    self.textColor = [TSHsdDisplay textSecondary];
    self.textAlignment = NSTextAlignmentRight;
    return self;
}

- (void)setMono:(BOOL)mono { _mono = mono; if (mono) { self.font = [TSHsdDisplay monoFontOfSize:14.f]; } }
- (void)setRounded:(BOOL)rounded { _rounded = rounded; if (rounded) { self.font = [TSHsdDisplay roundedFontOfSize:15.f weight:UIFontWeightSemibold]; } }

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [super sizeThatFits:size];
    return CGSizeMake(MIN(ceil(s.width), 180.f), MAX(ceil(s.height), 20.f));
}

@end

#pragma mark - TSHsdStateLabel

@interface TSHsdStateLabel ()
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdStateLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _dot = [[UIView alloc] init];
    _dot.layer.cornerRadius = 3.f;
    [self addSubview:_dot];
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:11.5f weight:UIFontWeightSemibold], [TSHsdDisplay textSecondary]);
    [self addSubview:_label];
    return self;
}

- (void)setText:(NSString *)text color:(UIColor *)color {
    self.label.text = text;
    self.label.textColor = color;
    self.dot.backgroundColor = color;
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat w = ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName: self.label.font}].width);
    return CGSizeMake(w + 11.f, 16.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dot.frame = CGRectMake(0, (self.bounds.size.height - 6.f) / 2.f, 6.f, 6.f);
    self.label.frame = CGRectMake(11.f, 0, self.bounds.size.width - 11.f, self.bounds.size.height);
}

@end

#pragma mark - TSHsdPill

@interface TSHsdPill ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdPill

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    self.layer.cornerRadius = 11.f;
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconView];
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:11.5f weight:UIFontWeightSemibold], [TSHsdDisplay textSecondary]);
    [self addSubview:_label];
    [self ts_apply];
    return self;
}

- (void)setText:(NSString *)text { _text = [text copy]; self.label.text = text; [self setNeedsLayout]; }
- (void)setSymbol:(nullable NSString *)symbol { _symbol = [symbol copy]; [self ts_apply]; }
- (void)setStyle:(TSHsdPillStyle)style { _style = style; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }

- (void)ts_apply {
    UIColor *fg = nil, *bg = nil;
    switch (self.style) {
        case TSHsdPillStyleHue: fg = self.hue; bg = [self.hue colorWithAlphaComponent:0.12f]; break;
        case TSHsdPillStyleCoin: {
            UIColor *amber = [TSHsdDisplay hueTask];
            fg = TSAdaptiveColor([UIColor colorWithRed:0xA6/255.f green:0x6E/255.f blue:0x0F/255.f alpha:1], [UIColor colorWithRed:0xF5/255.f green:0xC0/255.f blue:0x62/255.f alpha:1]);
            bg = [amber colorWithAlphaComponent:0.16f];
            break;
        }
        case TSHsdPillStylePlain:
        default: fg = [TSHsdDisplay textSecondary]; bg = [TSHsdDisplay fill]; break;
    }
    self.backgroundColor = bg;
    self.label.textColor = fg;
    self.iconView.tintColor = fg;
    self.iconView.image = TSHsdSymbol(self.symbol, 10.f, UIImageSymbolWeightBold);
    self.iconView.hidden = (self.symbol.length == 0);
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat w = ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName: self.label.font}].width) + 18.f;
    if (self.symbol.length) { w += 16.f; }
    return CGSizeMake(w, 22.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 9.f;
    if (self.symbol.length) { self.iconView.frame = CGRectMake(x, 5.f, 12.f, 12.f); x += 16.f; }
    self.label.frame = CGRectMake(x, 0, self.bounds.size.width - x - 9.f, self.bounds.size.height);
}

@end

#pragma mark - TSHsdStepperView

@interface TSHsdStepperView ()
@property (nonatomic, strong) UIButton *minusButton;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation TSHsdStepperView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _step = 1; _minValue = 0; _maxValue = 999;
    self.backgroundColor = [TSHsdDisplay fill];
    self.layer.cornerRadius = 12.f;
    _minusButton = [self ts_buttonWithSymbol:@"minus" action:@selector(ts_minus)];
    _plusButton = [self ts_buttonWithSymbol:@"plus" action:@selector(ts_plus)];
    _valueLabel = TSHsdMakeLabel([TSHsdDisplay roundedFontOfSize:16.f weight:UIFontWeightSemibold], [TSHsdDisplay ink]);
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_valueLabel];
    [self ts_apply];
    return self;
}

- (UIButton *)ts_buttonWithSymbol:(NSString *)symbol action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:TSHsdSymbol(symbol, 13.f, UIImageSymbolWeightBold) forState:UIControlStateNormal];
    button.tintColor = [TSHsdDisplay ink];
    button.layer.cornerRadius = 9.f;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)setValue:(NSInteger)value { _value = value; [self ts_apply]; }
- (void)ts_apply { self.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)self.value]; }

- (void)ts_minus { [self ts_changeBy:-self.step]; }
- (void)ts_plus { [self ts_changeBy:self.step]; }
- (void)ts_changeBy:(NSInteger)delta {
    NSInteger next = MAX(self.minValue, MIN(self.maxValue, self.value + delta));
    if (next == self.value) { return; }
    self.value = next;
    if (self.onChange) { self.onChange(next); }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat textW = MAX(30.f, ceil([self.valueLabel.text sizeWithAttributes:@{NSFontAttributeName: self.valueLabel.font}].width) + 8.f);
    return CGSizeMake(3.f + 30.f + 4.f + textW + 4.f + 30.f + 3.f, 36.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.minusButton.frame = CGRectMake(3.f, 3.f, 30.f, 30.f);
    self.plusButton.frame = CGRectMake(w - 33.f, 3.f, 30.f, 30.f);
    self.valueLabel.frame = CGRectMake(37.f, 0, w - 74.f, 36.f);
}

@end

#pragma mark - TSHsdNumBox

@interface TSHsdNumBox () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *prefixLabel;
@property (nonatomic, strong) UITextField *field;
@property (nonatomic, strong) UILabel *unitLabel;
@end

@implementation TSHsdNumBox

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _minValue = 0; _maxValue = 999;
    self.backgroundColor = [TSHsdDisplay fill];
    self.layer.cornerRadius = 11.f;
    _prefixLabel = TSHsdMakeLabel([UIFont systemFontOfSize:12.f], [TSHsdDisplay textSecondary]);
    [self addSubview:_prefixLabel];
    _field = [[UITextField alloc] init];
    _field.font = [TSHsdDisplay roundedFontOfSize:16.f weight:UIFontWeightSemibold];
    _field.textColor = [TSHsdDisplay ink];
    _field.textAlignment = NSTextAlignmentRight;
    _field.keyboardType = UIKeyboardTypeNumberPad;
    _field.delegate = self;
    [_field addTarget:self action:@selector(ts_editingChanged) forControlEvents:UIControlEventEditingChanged];
    [_field addTarget:self action:@selector(ts_editingEnded) forControlEvents:UIControlEventEditingDidEnd];
    [self addSubview:_field];
    _unitLabel = TSHsdMakeLabel([UIFont systemFontOfSize:12.f], [TSHsdDisplay textSecondary]);
    [self addSubview:_unitLabel];
    return self;
}

- (void)setValue:(NSInteger)value { _value = value; self.field.text = [NSString stringWithFormat:@"%ld", (long)value]; }
- (void)setUnit:(nullable NSString *)unit { _unit = [unit copy]; self.unitLabel.text = unit; [self setNeedsLayout]; }
- (void)setPrefix:(nullable NSString *)prefix { _prefix = [prefix copy]; self.prefixLabel.text = prefix; [self setNeedsLayout]; }

- (void)ts_editingChanged {
    NSInteger v = self.field.text.integerValue;
    _value = v;
    if (self.onChange) { self.onChange(v); }
}

- (void)ts_editingEnded {
    NSInteger v = MAX(self.minValue, MIN(self.maxValue, self.field.text.integerValue));
    self.value = v;
    if (self.onChange) { self.onChange(v); }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { [textField resignFirstResponder]; return YES; }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat w = 11.f + 44.f + 11.f;
    if (self.prefix.length) { w += ceil([self.prefix sizeWithAttributes:@{NSFontAttributeName: self.prefixLabel.font}].width) + 4.f; }
    if (self.unit.length) { w += ceil([self.unit sizeWithAttributes:@{NSFontAttributeName: self.unitLabel.font}].width) + 4.f; }
    return CGSizeMake(w, 34.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 11.f, h = self.bounds.size.height;
    if (self.prefix.length) {
        CGFloat pw = ceil([self.prefix sizeWithAttributes:@{NSFontAttributeName: self.prefixLabel.font}].width);
        self.prefixLabel.frame = CGRectMake(x, 0, pw, h);
        x += pw + 4.f;
    }
    self.field.frame = CGRectMake(x, 0, 44.f, h);
    x += 44.f + 4.f;
    self.unitLabel.frame = CGRectMake(x, 0, self.bounds.size.width - x - 11.f, h);
}

@end

#pragma mark - TSHsdSegView

@implementation TSHsdSegItem
+ (instancetype)itemWithTitle:(NSString *)title symbol:(nullable NSString *)symbol {
    TSHsdSegItem *item = [[TSHsdSegItem alloc] init];
    item.title = title;
    item.symbol = symbol;
    return item;
}
@end

@interface TSHsdSegView ()
@property (nonatomic, strong) UIView *track;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@end

@implementation TSHsdSegView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _buttons = [NSMutableArray array];
    _track = [[UIView alloc] init];
    _track.backgroundColor = TSHsdFill2();
    _track.layer.cornerRadius = 13.f;
    [self addSubview:_track];
    return self;
}

- (void)setItems:(NSArray<TSHsdSegItem *> *)items {
    _items = [items copy];
    for (UIButton *button in self.buttons) { [button removeFromSuperview]; }
    [self.buttons removeAllObjects];
    [items enumerateObjectsUsingBlock:^(TSHsdSegItem *item, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = idx;
        button.titleLabel.font = [UIFont systemFontOfSize:self.small ? 12.5f : 13.5f weight:UIFontWeightSemibold];
        [button setTitle:item.title forState:UIControlStateNormal];
        if (item.symbol.length) {
            [button setImage:TSHsdSymbol(item.symbol, 12.f, UIImageSymbolWeightSemibold) forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -3.f, 0, 3.f);
        }
        button.layer.cornerRadius = self.small ? 8.f : 10.f;
        [button addTarget:self action:@selector(ts_tapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.track addSubview:button];
        [self.buttons addObject:button];
    }];
    [self ts_apply];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex { _selectedIndex = selectedIndex; [self ts_apply]; }
- (void)setSmall:(BOOL)small { _small = small; self.track.layer.cornerRadius = small ? 10.f : 13.f; self.track.backgroundColor = small ? [TSHsdDisplay fill] : TSHsdFill2(); self.items = self.items; }
- (void)setInsetInCard:(BOOL)insetInCard { _insetInCard = insetInCard; [self setNeedsLayout]; }

- (void)ts_apply {
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        BOOL on = (NSInteger)idx == self.selectedIndex;
        TSHsdSegItem *item = self.items[idx];
        UIColor *color = on ? (item.onColor ?: [TSHsdDisplay ink]) : [TSHsdDisplay textSecondary];
        [button setTitleColor:color forState:UIControlStateNormal];
        button.tintColor = color;
        button.backgroundColor = on ? [TSHsdDisplay card] : [UIColor clearColor];
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOpacity = on ? 0.12f : 0;
        button.layer.shadowRadius = 2.f;
        button.layer.shadowOffset = CGSizeMake(0, 1.f);
    }];
}

- (void)ts_tapped:(UIButton *)sender {
    if (sender.tag == self.selectedIndex) { return; }
    self.selectedIndex = sender.tag;
    if (self.onChange) { self.onChange(sender.tag); }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = self.small ? 30.f : 40.f;
    if (self.insetInCard) { h += 24.f; }
    return CGSizeMake(self.small ? MIN(size.width, 120.f) : size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat inset = self.insetInCard ? 16.f : 0, top = self.insetInCard ? 12.f : 0;
    CGFloat h = self.small ? 30.f : 40.f;
    self.track.frame = CGRectMake(inset, top, self.bounds.size.width - inset * 2, h);
    CGFloat pad = self.small ? 2.f : 3.f;
    CGFloat bw = (self.track.bounds.size.width - pad * 2) / MAX(1, (CGFloat)self.buttons.count);
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(pad + idx * bw, pad, bw, h - pad * 2);
    }];
}

@end

#pragma mark - TSHsdFieldView

@interface TSHsdFieldView ()
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *labelView;
@property (nonatomic, strong) UILabel *counter;
@property (nonatomic, strong) UIView *meter;
@property (nonatomic, strong) UIView *meterFill;
@end

@implementation TSHsdFieldView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _maxBytes = 32;
    _hue = [TSHsdDisplay hueParental];
    _labelView = TSHsdMakeLabel([UIFont systemFontOfSize:12.f weight:UIFontWeightMedium], [TSHsdDisplay textTertiary]);
    [self addSubview:_labelView];
    _counter = TSHsdMakeLabel([TSHsdDisplay monoFontOfSize:11.f], [TSHsdDisplay textTertiary]);
    _counter.textAlignment = NSTextAlignmentRight;
    [self addSubview:_counter];
    _textField = [[UITextField alloc] init];
    _textField.font = [UIFont systemFontOfSize:16.f];
    _textField.textColor = [TSHsdDisplay ink];
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_textField addTarget:self action:@selector(ts_changed) forControlEvents:UIControlEventEditingChanged];
    [_textField addTarget:self action:@selector(ts_done) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:_textField];
    _meter = [[UIView alloc] init];
    _meter.backgroundColor = [TSHsdDisplay fill];
    _meter.layer.cornerRadius = 1.5f;
    _meter.clipsToBounds = YES;
    [self addSubview:_meter];
    _meterFill = [[UIView alloc] init];
    _meterFill.layer.cornerRadius = 1.5f;
    [_meter addSubview:_meterFill];
    [self ts_apply];
    return self;
}

- (void)setLabel:(NSString *)label { _label = [label copy]; self.labelView.text = label; }
- (void)setPlaceholder:(nullable NSString *)placeholder { _placeholder = [placeholder copy]; self.textField.placeholder = placeholder; }
- (void)setText:(nullable NSString *)text { self.textField.text = text; [self ts_apply]; }
- (nullable NSString *)text { return self.textField.text; }
- (void)setMaxBytes:(NSUInteger)maxBytes { _maxBytes = maxBytes; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }
- (BOOL)overLimit { return [TSHsdDisplay utf8Length:self.textField.text] > self.maxBytes; }

- (void)ts_apply {
    NSUInteger n = [TSHsdDisplay utf8Length:self.textField.text];
    self.counter.text = [NSString stringWithFormat:TSLocalizedString(@"hsd.bytes_format"), (unsigned long)n, (unsigned long)self.maxBytes];
    BOOL over = self.overLimit;
    self.counter.textColor = over ? [TSHsdDisplay statusBad] : [TSHsdDisplay textTertiary];
    self.counter.font = over ? [UIFont monospacedSystemFontOfSize:11.f weight:UIFontWeightBold] : [TSHsdDisplay monoFontOfSize:11.f];
    self.meterFill.backgroundColor = over ? [TSHsdDisplay statusBad] : self.hue;
    [self setNeedsLayout];
}

- (void)ts_changed { [self ts_apply]; if (self.onChange) { self.onChange(self.textField.text ?: @""); } }
- (void)ts_done { [self.textField resignFirstResponder]; }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 13.f + 16.f + 6.f + 24.f + 9.f + 3.f + 12.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width - 32.f;
    self.counter.frame = CGRectMake(16.f + w - 110.f, 13.f, 110.f, 16.f);
    self.labelView.frame = CGRectMake(16.f, 13.f, w - 114.f, 16.f);
    self.textField.frame = CGRectMake(16.f, 35.f, w, 24.f);
    self.meter.frame = CGRectMake(16.f, 68.f, w, 3.f);
    CGFloat ratio = self.maxBytes ? MIN(1.f, (CGFloat)[TSHsdDisplay utf8Length:self.textField.text] / (CGFloat)self.maxBytes) : 0;
    self.meterFill.frame = CGRectMake(0, 0, w * ratio, 3.f);
}

@end

#pragma mark - TSHsdDuoTimeView

@interface TSHsdDuoTimeView ()
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIView *midLine;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *nextTag;
@property (nonatomic, strong) TSHsdTimeBox *startBox;
@property (nonatomic, strong) TSHsdTimeBox *endBox;
@end

@implementation TSHsdDuoTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _startTitle = TSLocalizedString(@"hsd.time.start");
    _endTitle = TSLocalizedString(@"hsd.time.end");
    _topLine = [[UIView alloc] init]; _topLine.backgroundColor = TSHsdLine(); [self addSubview:_topLine];
    _midLine = [[UIView alloc] init]; _midLine.backgroundColor = TSHsdLine(); [self addSubview:_midLine];
    _startLabel = TSHsdMakeLabel([UIFont systemFontOfSize:13.f], [TSHsdDisplay textSecondary]); [self addSubview:_startLabel];
    _endLabel = TSHsdMakeLabel([UIFont systemFontOfSize:13.f], [TSHsdDisplay textSecondary]); [self addSubview:_endLabel];
    _nextTag = TSHsdMakeLabel([UIFont systemFontOfSize:10.f weight:UIFontWeightBold], [TSHsdDisplay statusWarn]);
    _nextTag.text = TSLocalizedString(@"hsd.time.next_day");
    [self addSubview:_nextTag];
    __weak typeof(self) weakSelf = self;
    _startBox = [[TSHsdTimeBox alloc] init]; _startBox.onTap = ^{ if (weakSelf.onTapStart) { weakSelf.onTapStart(); } }; [self addSubview:_startBox];
    _endBox = [[TSHsdTimeBox alloc] init]; _endBox.onTap = ^{ if (weakSelf.onTapEnd) { weakSelf.onTapEnd(); } }; [self addSubview:_endBox];
    [self ts_apply];
    return self;
}

- (void)setStartMinute:(NSInteger)startMinute { _startMinute = startMinute; [self ts_apply]; }
- (void)setEndMinute:(NSInteger)endMinute { _endMinute = endMinute; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }
- (void)setStartTitle:(NSString *)startTitle { _startTitle = [startTitle copy]; [self ts_apply]; }
- (void)setEndTitle:(NSString *)endTitle { _endTitle = [endTitle copy]; [self ts_apply]; }

- (void)ts_apply {
    self.startBox.hue = self.hue; self.endBox.hue = self.hue;
    self.startBox.minute = self.startMinute; self.endBox.minute = self.endMinute;
    self.startLabel.text = self.startTitle; self.endLabel.text = self.endTitle;
    self.nextTag.hidden = !(self.endMinute <= self.startMinute);
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 58.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height, half = floor(w / 2.f);
    CGFloat px = 1.f / [UIScreen mainScreen].scale;
    self.topLine.frame = CGRectMake(0, 0, w, px);
    self.midLine.frame = CGRectMake(half, 0, px, h);
    self.startLabel.frame = CGRectMake(16.f, 0, half - 16.f - 80.f, h);
    self.startBox.frame = CGRectMake(half - 16.f - 72.f, (h - 34.f) / 2.f, 72.f, 34.f);
    self.endLabel.frame = CGRectMake(half + 16.f, 0, 40.f, h);
    self.nextTag.frame = CGRectMake(half + 16.f + 32.f, 0, 40.f, h);
    self.endBox.frame = CGRectMake(w - 16.f - 72.f, (h - 34.f) / 2.f, 72.f, 34.f);
}

@end

#pragma mark - TSHsdCTAButton

@implementation TSHsdCTAButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    [self addTarget:self action:@selector(ts_tapped) forControlEvents:UIControlEventTouchUpInside];
    [self ts_apply];
    return self;
}

- (void)setTitle:(NSString *)title symbol:(nullable NSString *)symbol {
    _symbol = [symbol copy];
    [self setTitle:title forState:UIControlStateNormal];
    [self setImage:TSHsdSymbol(symbol, self.small ? 12.f : 14.f, UIImageSymbolWeightSemibold) forState:UIControlStateNormal];
    self.imageEdgeInsets = symbol.length ? UIEdgeInsetsMake(0, -4.f, 0, 4.f) : UIEdgeInsetsZero;
    [self ts_apply];
}

- (void)setSoft:(BOOL)soft { _soft = soft; [self ts_apply]; }
- (void)setRaised:(BOOL)raised { _raised = raised; [self ts_apply]; }
- (void)setSmall:(BOOL)small { _small = small; [self ts_apply]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; self.alpha = enabled ? 1.f : 0.28f; }

- (void)ts_apply {
    self.titleLabel.font = [UIFont systemFontOfSize:self.small ? 13.5f : 15.f weight:UIFontWeightSemibold];
    self.layer.cornerRadius = self.small ? 18.f : 23.f;
    BOOL light = self.soft || self.raised;
    self.backgroundColor = self.raised ? [TSHsdDisplay card] : (self.soft ? [TSHsdDisplay fill] : [TSHsdDisplay ink]);
    UIColor *fg = light ? [TSHsdDisplay ink] : [TSHsdDisplay card];
    [self setTitleColor:fg forState:UIControlStateNormal];
    self.tintColor = fg;
    self.contentEdgeInsets = UIEdgeInsetsMake(0, self.small ? 15.f : 20.f, 0, self.small ? 15.f : 20.f);
}

- (void)ts_tapped { if (self.onTap) { self.onTap(); } }

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize s = [super sizeThatFits:size];
    return CGSizeMake(ceil(s.width) + (self.symbol.length ? 4.f : 0), self.small ? 36.f : 46.f);
}

@end

#pragma mark - TSHsdGhostAddButton

@interface TSHsdGhostAddButton ()
@property (nonatomic, strong) CAShapeLayer *border;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdGhostAddButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _symbol = @"plus";
    _border = [CAShapeLayer layer];
    _border.fillColor = [UIColor clearColor].CGColor;
    _border.lineWidth = 1.5f;
    _border.lineDashPattern = @[@5, @4];
    [self.layer addSublayer:_border];
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeCenter;
    _iconView.tintColor = [TSHsdDisplay textSecondary];
    [self addSubview:_iconView];
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:14.5f weight:UIFontWeightSemibold], [TSHsdDisplay textSecondary]);
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_label];
    [self addTarget:self action:@selector(ts_tapped) forControlEvents:UIControlEventTouchUpInside];
    [self ts_apply];
    return self;
}

- (void)setTitle:(NSString *)title { _title = [title copy]; [self ts_apply]; }
- (void)setSmall:(nullable NSString *)small { _small = [small copy]; [self ts_apply]; }
- (void)setSymbol:(nullable NSString *)symbol { _symbol = [symbol copy]; [self ts_apply]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; self.alpha = enabled ? 1.f : 0.5f; }

- (void)ts_apply {
    self.iconView.image = TSHsdSymbol(self.symbol, 14.f, UIImageSymbolWeightSemibold);
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.title ?: @"" attributes:@{NSFontAttributeName: self.label.font, NSForegroundColorAttributeName: [TSHsdDisplay textSecondary]}];
    if (self.small.length) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[@" " stringByAppendingString:self.small] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.5f], NSForegroundColorAttributeName: [TSHsdDisplay textTertiary]}]];
    }
    self.label.attributedText = text;
    [self setNeedsLayout];
}

- (void)ts_tapped { if (self.onTap) { self.onTap(); } }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 50.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    self.border.frame = self.bounds;
    self.border.strokeColor = TSHsdFill2().CGColor;
    self.border.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.75f, 0.75f) cornerRadius:20.f].CGPath;
    CGFloat textW = ceil([self.label.attributedText size].width);
    CGFloat total = 16.f + 8.f + textW;
    CGFloat x = (self.bounds.size.width - total) / 2.f;
    self.iconView.frame = CGRectMake(x, (self.bounds.size.height - 16.f) / 2.f, 16.f, 16.f);
    self.label.frame = CGRectMake(x + 24.f, 0, textW + 4.f, self.bounds.size.height);
}

@end

#pragma mark - TSHsdDangerLink

@interface TSHsdDangerLink ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdDangerLink

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _iconView = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"trash", 14.f, UIImageSymbolWeightMedium)];
    _iconView.tintColor = [TSHsdDisplay statusBad];
    _iconView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconView];
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold], [TSHsdDisplay statusBad]);
    [self addSubview:_label];
    [self addTarget:self action:@selector(ts_tapped) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)setTitle:(NSString *)title { _title = [title copy]; self.label.text = title; [self setNeedsLayout]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; self.alpha = enabled ? 1.f : 0.4f; }
- (void)ts_tapped { if (self.onTap) { self.onTap(); } }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 50.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textW = ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName: self.label.font}].width);
    CGFloat x = (self.bounds.size.width - (17.f + 7.f + textW)) / 2.f;
    self.iconView.frame = CGRectMake(x, (self.bounds.size.height - 17.f) / 2.f, 17.f, 17.f);
    self.label.frame = CGRectMake(x + 24.f, 0, textW + 2.f, self.bounds.size.height);
}

@end

#pragma mark - TSHsdEmptyView

@interface TSHsdEmptyView ()
@property (nonatomic, strong) UIView *p1;
@property (nonatomic, strong) UIView *p2;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *d1;
@property (nonatomic, strong) UIView *d2;
@property (nonatomic, strong) UIView *d3;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *textLabel_;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) TSHsdCTAButton *actionButton;
@end

@implementation TSHsdEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _p1 = [[UIView alloc] init]; _p1.layer.cornerRadius = 26.f; _p1.transform = CGAffineTransformMakeRotation(-8 * M_PI / 180); [self addSubview:_p1];
    _p2 = [[UIView alloc] init]; _p2.layer.cornerRadius = 22.f; _p2.backgroundColor = [TSHsdDisplay card]; TSHsdApplyCardShadow(_p2); _p2.layer.shadowOpacity = 0.12f; [self addSubview:_p2];
    _iconView = [[UIImageView alloc] init]; _iconView.contentMode = UIViewContentModeCenter; [_p2 addSubview:_iconView];
    _d1 = [[UIView alloc] init]; _d1.layer.cornerRadius = 5.f; [self addSubview:_d1];
    _d2 = [[UIView alloc] init]; _d2.layer.cornerRadius = 3.f; _d2.backgroundColor = [[TSHsdDisplay hueTask] colorWithAlphaComponent:0.6f]; [self addSubview:_d2];
    _d3 = [[UIView alloc] init]; _d3.layer.cornerRadius = 7.f; _d3.layer.borderWidth = 2.f; [self addSubview:_d3];
    _titleLabel = TSHsdMakeLabel([UIFont systemFontOfSize:17.f weight:UIFontWeightBold], [TSHsdDisplay ink]); _titleLabel.textAlignment = NSTextAlignmentCenter; [self addSubview:_titleLabel];
    _textLabel_ = TSHsdMakeLabel([UIFont systemFontOfSize:13.5f], [TSHsdDisplay textSecondary]); _textLabel_.textAlignment = NSTextAlignmentCenter; _textLabel_.numberOfLines = 0; [self addSubview:_textLabel_];
    _codeLabel = TSHsdMakeLabel([TSHsdDisplay monoFontOfSize:11.f], [TSHsdDisplay textTertiary]); _codeLabel.textAlignment = NSTextAlignmentCenter; _codeLabel.numberOfLines = 0; [self addSubview:_codeLabel];
    _actionButton = [[TSHsdCTAButton alloc] init]; _actionButton.small = YES; _actionButton.hidden = YES; [self addSubview:_actionButton];
    __weak typeof(self) weakSelf = self;
    _actionButton.onTap = ^{ if (weakSelf.onAction) { weakSelf.onAction(); } };
    [self ts_apply];
    return self;
}

- (void)setSymbol:(NSString *)symbol { _symbol = [symbol copy]; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }
- (void)setTitle:(NSString *)title { _title = [title copy]; self.titleLabel.text = title; [self setNeedsLayout]; }
- (void)setText:(nullable NSString *)text { _text = [text copy]; self.textLabel_.text = text; [self setNeedsLayout]; }
- (void)setCode:(nullable NSString *)code { _code = [code copy]; self.codeLabel.text = code; [self setNeedsLayout]; }
- (void)setActionTitle:(nullable NSString *)actionTitle { _actionTitle = [actionTitle copy]; [self ts_apply]; }
- (void)setActionSymbol:(nullable NSString *)actionSymbol { _actionSymbol = [actionSymbol copy]; [self ts_apply]; }

- (void)ts_apply {
    self.p1.backgroundColor = [self.hue colorWithAlphaComponent:0.10f];
    self.iconView.image = TSHsdSymbol(self.symbol, 28.f, UIImageSymbolWeightMedium);
    self.iconView.tintColor = self.hue;
    self.d1.backgroundColor = [self.hue colorWithAlphaComponent:0.35f];
    self.d3.layer.borderColor = [self.hue colorWithAlphaComponent:0.3f].CGColor;
    self.actionButton.hidden = (self.actionTitle.length == 0);
    if (self.actionTitle.length) { [self.actionButton setTitle:self.actionTitle symbol:self.actionSymbol]; }
    [self setNeedsLayout];
}

- (CGFloat)ts_textWidth:(CGFloat)width { return MIN(270.f, width - 52.f); }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat tw = [self ts_textWidth:size.width];
    CGFloat h = 34.f + 92.f + 6.f + 8.f + 22.f;
    if (self.text.length) { h += 6.f + TSHsdTextHeight(self.text, self.textLabel_.font, tw, 1.2f); }
    if (self.code.length) { h += 8.f + TSHsdTextHeight(self.code, self.codeLabel.font, tw, 1.f); }
    if (self.actionTitle.length) { h += 18.f + 36.f; }
    return CGSizeMake(size.width, h + 30.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    CGFloat artX = (w - 112.f) / 2.f, artY = 34.f;
    self.p1.bounds = CGRectMake(0, 0, 72.f, 72.f); self.p1.center = CGPointMake(artX + 56.f, artY + 46.f);
    self.p2.frame = CGRectMake(artX + 24.f, artY + 12.f, 64.f, 64.f);
    self.iconView.frame = self.p2.bounds;
    self.d1.frame = CGRectMake(artX + 96.f, artY + 8.f, 10.f, 10.f);
    self.d2.frame = CGRectMake(artX + 6.f, artY + 30.f, 6.f, 6.f);
    self.d3.frame = CGRectMake(artX + 88.f, artY + 74.f, 14.f, 14.f);
    CGFloat tw = [self ts_textWidth:w], tx = (w - tw) / 2.f;
    CGFloat y = artY + 92.f + 14.f;
    self.titleLabel.frame = CGRectMake(tx, y, tw, 22.f); y += 22.f;
    if (self.text.length) { CGFloat th = TSHsdTextHeight(self.text, self.textLabel_.font, tw, 1.2f); self.textLabel_.frame = CGRectMake(tx, y + 6.f, tw, th); y += 6.f + th; }
    if (self.code.length) { CGFloat ch = TSHsdTextHeight(self.code, self.codeLabel.font, tw, 1.f); self.codeLabel.frame = CGRectMake(tx, y + 8.f, tw, ch); y += 8.f + ch; }
    if (self.actionTitle.length) { CGSize bs = [self.actionButton sizeThatFits:CGSizeZero]; self.actionButton.frame = CGRectMake((w - bs.width) / 2.f, y + 18.f, bs.width, 36.f); }
}

@end

#pragma mark - TSHsdLoadingView

@interface TSHsdLoadingView ()
@property (nonatomic, strong) CAShapeLayer *ring;
@property (nonatomic, strong) CAShapeLayer *arc;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSHsdLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _ring = [CAShapeLayer layer]; _ring.fillColor = [UIColor clearColor].CGColor; _ring.lineWidth = 3.f; [self.layer addSublayer:_ring];
    _arc = [CAShapeLayer layer]; _arc.fillColor = [UIColor clearColor].CGColor; _arc.lineWidth = 3.f; _arc.lineCap = kCALineCapRound; _arc.strokeEnd = 0.28f; [self.layer addSublayer:_arc];
    _label = TSHsdMakeLabel([UIFont systemFontOfSize:13.f], [TSHsdDisplay textSecondary]); _label.textAlignment = NSTextAlignmentCenter; [self addSubview:_label];
    return self;
}

- (void)setText:(nullable NSString *)text { _text = [text copy]; self.label.text = text; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self setNeedsLayout]; }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 70.f + 30.f + 12.f + 18.f + 70.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cx = self.bounds.size.width / 2.f;
    CGRect ringRect = CGRectMake(cx - 15.f, 70.f, 30.f, 30.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1.5f, 1.5f, 27.f, 27.f)];
    self.ring.frame = ringRect;
    self.ring.path = path.CGPath; self.ring.strokeColor = TSHsdFill2().CGColor;
    self.arc.frame = ringRect;
    self.arc.path = path.CGPath; self.arc.strokeColor = self.hue.CGColor;
    self.label.frame = CGRectMake(0, 112.f, self.bounds.size.width, 18.f);
    if (![self.arc animationForKey:@"spin"]) {
        CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        spin.toValue = @(M_PI * 2); spin.duration = 0.8; spin.repeatCount = HUGE_VALF;
        [self.arc addAnimation:spin forKey:@"spin"];
    }
}

@end

#pragma mark - TSHsdWatchPreview

@interface TSHsdWatchPreview ()
@property (nonatomic, strong) UIView *body;
@property (nonatomic, strong) CAGradientLayer *bodyGradient;
@property (nonatomic, strong) UIView *crown;
@property (nonatomic, strong) UIView *screen;
@property (nonatomic, strong) UILabel *topLeftLabel;
@property (nonatomic, strong) UILabel *topRightLabel;
@property (nonatomic, strong) UIImageView *bigIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UILabel *coinLabel;
@property (nonatomic, strong) NSMutableArray<UILabel *> *lineLabels;
@property (nonatomic, strong) CAGradientLayer *glow;
@end

@implementation TSHsdWatchPreview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _lineLabels = [NSMutableArray array];
    _glow = [CAGradientLayer layer]; _glow.type = kCAGradientLayerRadial; _glow.startPoint = CGPointMake(0.5, 0.6); _glow.endPoint = CGPointMake(1, 1); [self.layer addSublayer:_glow];
    _body = [[UIView alloc] init]; _body.layer.cornerRadius = 40.f; _body.clipsToBounds = YES;
    _body.layer.borderWidth = 1.f; _body.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18f].CGColor;
    _bodyGradient = [CAGradientLayer layer];
    _bodyGradient.colors = @[(id)[UIColor colorWithRed:0x3a/255.f green:0x3d/255.f blue:0x47/255.f alpha:1].CGColor, (id)[UIColor colorWithRed:0x0c/255.f green:0x0d/255.f blue:0x11/255.f alpha:1].CGColor, (id)[UIColor colorWithRed:0x1b/255.f green:0x1d/255.f blue:0x24/255.f alpha:1].CGColor];
    _bodyGradient.locations = @[@0, @0.4, @1]; _bodyGradient.startPoint = CGPointMake(0, 0); _bodyGradient.endPoint = CGPointMake(1, 1);
    [_body.layer addSublayer:_bodyGradient];
    [self addSubview:_body];
    _crown = [[UIView alloc] init]; _crown.backgroundColor = [UIColor colorWithRed:0x44/255.f green:0x47/255.f blue:0x50/255.f alpha:1]; _crown.layer.cornerRadius = 2.f; [self addSubview:_crown];
    _screen = [[UIView alloc] init]; _screen.backgroundColor = [UIColor blackColor]; _screen.layer.cornerRadius = 33.f; _screen.clipsToBounds = YES; [_body addSubview:_screen];
    UIFont *topFont = [TSHsdDisplay roundedFontOfSize:10.5f weight:UIFontWeightBold];
    _topLeftLabel = TSHsdMakeLabel(topFont, [[UIColor whiteColor] colorWithAlphaComponent:0.7f]); [_screen addSubview:_topLeftLabel];
    _topRightLabel = TSHsdMakeLabel(topFont, [[UIColor whiteColor] colorWithAlphaComponent:0.7f]); _topRightLabel.textAlignment = NSTextAlignmentRight; [_screen addSubview:_topRightLabel];
    _bigIcon = [[UIImageView alloc] init]; _bigIcon.contentMode = UIViewContentModeCenter; _bigIcon.tintColor = [UIColor whiteColor]; [_screen addSubview:_bigIcon];
    _nameLabel = TSHsdMakeLabel([UIFont systemFontOfSize:13.f weight:UIFontWeightBold], [UIColor whiteColor]); _nameLabel.textAlignment = NSTextAlignmentCenter; _nameLabel.numberOfLines = 2; [_screen addSubview:_nameLabel];
    _metaLabel = TSHsdMakeLabel([TSHsdDisplay roundedFontOfSize:10.5f weight:UIFontWeightRegular], [[UIColor whiteColor] colorWithAlphaComponent:0.65f]); _metaLabel.textAlignment = NSTextAlignmentCenter; [_screen addSubview:_metaLabel];
    _coinLabel = TSHsdMakeLabel([TSHsdDisplay roundedFontOfSize:10.5f weight:UIFontWeightBold], [UIColor colorWithRed:0xf5/255.f green:0xb7/255.f blue:0x40/255.f alpha:1]);
    _coinLabel.textAlignment = NSTextAlignmentCenter; _coinLabel.backgroundColor = [[UIColor colorWithRed:0xf5/255.f green:0xb7/255.f blue:0x40/255.f alpha:1] colorWithAlphaComponent:0.15f];
    _coinLabel.layer.cornerRadius = 9.f; _coinLabel.clipsToBounds = YES; [_screen addSubview:_coinLabel];
    return self;
}

- (void)setHue:(UIColor *)hue { _hue = hue; [self setNeedsLayout]; }
- (void)setTopLeft:(nullable NSString *)topLeft { _topLeft = [topLeft copy]; self.topLeftLabel.text = topLeft; }
- (void)setTopRight:(nullable NSString *)topRight { _topRight = [topRight copy]; self.topRightLabel.text = topRight; }
- (void)setTopRightHighlighted:(BOOL)v { _topRightHighlighted = v; self.topRightLabel.textColor = v ? [UIColor colorWithRed:1 green:0x6b/255.f blue:0x57/255.f alpha:1] : [[UIColor whiteColor] colorWithAlphaComponent:0.7f]; }
- (void)setBigSymbol:(nullable NSString *)bigSymbol { _bigSymbol = [bigSymbol copy]; self.bigIcon.image = TSHsdSymbol(bigSymbol, 30.f, UIImageSymbolWeightMedium); [self setNeedsLayout]; }
- (void)setName:(nullable NSString *)name { _name = [name copy]; self.nameLabel.text = name; [self setNeedsLayout]; }
- (void)setMeta:(nullable NSString *)meta { _meta = [meta copy]; self.metaLabel.text = meta; [self setNeedsLayout]; }
- (void)setCoinText:(nullable NSString *)coinText { _coinText = [coinText copy]; self.coinLabel.text = coinText; self.coinLabel.hidden = (coinText.length == 0); [self setNeedsLayout]; }
- (void)setLinesPlaceholder:(nullable NSString *)placeholder { _linesPlaceholder = [placeholder copy]; [self setNeedsLayout]; }

- (void)setLines:(nullable NSArray<NSString *> *)lines {
    _lines = [lines copy];
    for (UILabel *label in self.lineLabels) { [label removeFromSuperview]; }
    [self.lineLabels removeAllObjects];
    NSArray<NSString *> *shown = lines.count ? lines : (self.linesPlaceholder.length ? @[self.linesPlaceholder] : @[]);
    for (NSString *line in shown) {
        UILabel *label = TSHsdMakeLabel([UIFont systemFontOfSize:11.f], lines.count ? [UIColor whiteColor] : [[UIColor whiteColor] colorWithAlphaComponent:0.35f]);
        label.text = line;
        label.numberOfLines = 2;
        label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:lines.count ? 0.11f : 0.06f];
        label.layer.cornerRadius = 10.f;
        label.clipsToBounds = YES;
        [self.screen addSubview:label];
        [self.lineLabels addObject:label];
    }
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 18.f + 176.f + 16.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.glow.frame = self.bounds;
    self.glow.colors = @[(id)[self.hue colorWithAlphaComponent:0.14f].CGColor, (id)[UIColor clearColor].CGColor];
    self.body.frame = CGRectMake((w - 148.f) / 2.f, 18.f, 148.f, 176.f);
    self.bodyGradient.frame = self.body.bounds;
    self.crown.frame = CGRectMake(CGRectGetMaxX(self.body.frame) - 1.f, 18.f + 52.f, 5.f, 26.f);
    self.screen.frame = CGRectInset(self.body.bounds, 7.f, 7.f);
    CGFloat sw = self.screen.bounds.size.width, sh = self.screen.bounds.size.height;
    self.topLeftLabel.frame = CGRectMake(12.f, 13.f, sw / 2.f - 12.f, 13.f);
    self.topRightLabel.frame = CGRectMake(sw / 2.f, 13.f, sw / 2.f - 12.f, 13.f);
    if (self.lineLabels.count) {
        CGFloat y = 34.f;
        for (UILabel *label in self.lineLabels) {
            CGFloat h = MIN(36.f, ceil([label sizeThatFits:CGSizeMake(sw - 24.f - 16.f, CGFLOAT_MAX)].height) + 12.f);
            label.frame = CGRectMake(12.f, y, sw - 24.f, h);
            y += h + 5.f;
        }
        // 内容左右各留 8 的 padding：用 UILabel 的 inset 近似（通过缩进）
        return;
    }
    self.bigIcon.frame = CGRectMake(0, 32.f, sw, 40.f);
    CGFloat nameH = MIN(32.f, ceil([self.nameLabel sizeThatFits:CGSizeMake(sw - 24.f, CGFLOAT_MAX)].height));
    self.nameLabel.frame = CGRectMake(12.f, 76.f, sw - 24.f, nameH);
    self.metaLabel.frame = CGRectMake(12.f, 76.f + nameH + 3.f, sw - 24.f, 13.f);
    CGFloat cw = ceil([self.coinLabel.text sizeWithAttributes:@{NSFontAttributeName: self.coinLabel.font}].width) + 16.f;
    self.coinLabel.frame = CGRectMake((sw - cw) / 2.f, sh - 13.f - 18.f, cw, 18.f);
}

@end

#pragma mark - TSHsdWeekDots

@interface TSHsdWeekDots ()
@property (nonatomic, strong) NSArray<UILabel *> *dots;
@end

@implementation TSHsdWeekDots

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueHabit];
    NSArray<NSString *> *keys = @[@"weekday.mon.short", @"weekday.tue.short", @"weekday.wed.short", @"weekday.thu.short", @"weekday.fri.short", @"weekday.sat.short", @"weekday.sun.short"];
    NSMutableArray<UILabel *> *dots = [NSMutableArray array];
    for (NSString *key in keys) {
        UILabel *dot = TSHsdMakeLabel([UIFont systemFontOfSize:8.f weight:UIFontWeightBold], [TSHsdDisplay textTertiary]);
        dot.text = TSLocalizedString(key);
        dot.textAlignment = NSTextAlignmentCenter;
        dot.layer.cornerRadius = 5.f;
        dot.clipsToBounds = YES;
        [self addSubview:dot];
        [dots addObject:dot];
    }
    _dots = [dots copy];
    [self ts_apply];
    return self;
}

- (void)setMask:(TSAlarmRepeat)mask { _mask = mask; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }

- (void)ts_apply {
    for (NSInteger i = 0; i < 7; i++) {
        BOOL on = (self.mask & (1 << i)) != 0;
        self.dots[i].backgroundColor = on ? self.hue : [TSHsdDisplay fill];
        self.dots[i].textColor = on ? [UIColor whiteColor] : [TSHsdDisplay textTertiary];
    }
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(14.f * 7 + 3.f * 6, 14.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    for (NSInteger i = 0; i < 7; i++) { self.dots[i].frame = CGRectMake(i * 17.f, 0, 14.f, 14.f); }
}

@end

#pragma mark - TSHsdProgressBar

@interface TSHsdProgressBar ()
@property (nonatomic, strong) UIView *fillView;
@end

@implementation TSHsdProgressBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    self.backgroundColor = [TSHsdDisplay fill];
    self.layer.cornerRadius = 2.5f;
    self.clipsToBounds = YES;
    _fillView = [[UIView alloc] init];
    _fillView.layer.cornerRadius = 2.5f;
    [self addSubview:_fillView];
    return self;
}

- (void)setProgress:(CGFloat)progress { _progress = MAX(0, MIN(1, progress)); [self setNeedsLayout]; }
- (void)setHue:(UIColor *)hue { _hue = hue; self.fillView.backgroundColor = hue; }
- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 5.f); }
- (void)layoutSubviews { [super layoutSubviews]; self.fillView.backgroundColor = self.hue; self.fillView.frame = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height); }

@end

#pragma mark - TSHsdRingView

@interface TSHsdRingView ()
@property (nonatomic, strong) CAShapeLayer *bg;
@property (nonatomic, strong) CAShapeLayer *fg;
@property (nonatomic, strong) UIImageView *iconView;
@end

@implementation TSHsdRingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueHabit];
    _bg = [CAShapeLayer layer]; _bg.fillColor = [UIColor clearColor].CGColor; _bg.lineWidth = 5.f; [self.layer addSublayer:_bg];
    _fg = [CAShapeLayer layer]; _fg.fillColor = [UIColor clearColor].CGColor; _fg.lineWidth = 5.f; _fg.lineCap = kCALineCapRound; [self.layer addSublayer:_fg];
    _iconView = [[UIImageView alloc] init]; _iconView.contentMode = UIViewContentModeCenter; [self addSubview:_iconView];
    return self;
}

- (void)setProgress:(CGFloat)progress { _progress = MAX(0, MIN(1, progress)); [self setNeedsLayout]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self setNeedsLayout]; }
- (void)setSymbol:(nullable NSString *)symbol { _symbol = [symbol copy]; self.iconView.image = TSHsdSymbol(symbol, 20.f, UIImageSymbolWeightMedium); }
- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(58.f, 58.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat r = 25.f;
    CGPoint c = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:c radius:r startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    self.bg.path = path.CGPath; self.bg.strokeColor = [TSHsdDisplay fill].CGColor;
    self.fg.path = path.CGPath; self.fg.strokeColor = self.hue.CGColor; self.fg.strokeEnd = self.progress;
    self.iconView.frame = self.bounds; self.iconView.tintColor = self.hue;
}

@end

#pragma mark - TSHsdHScrollPicker

@interface TSHsdHScrollPicker ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIControl *> *tiles;
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, copy, nullable) NSArray<NSString *> *smalls;
@property (nonatomic, copy, nullable) NSArray<UIColor *> *dotColors;
@property (nonatomic, copy, nullable) NSArray<NSString *> *symbols;
@end

@implementation TSHsdHScrollPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _tiles = [NSMutableArray array];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.clipsToBounds = NO;
    [self addSubview:_scrollView];
    return self;
}

- (void)setItemsWithTitles:(NSArray<NSString *> *)titles smalls:(nullable NSArray<NSString *> *)smalls dotColors:(nullable NSArray<UIColor *> *)dotColors symbols:(nullable NSArray<NSString *> *)symbols {
    self.titles = titles; self.smalls = smalls; self.dotColors = dotColors; self.symbols = symbols;
    for (UIControl *tile in self.tiles) { [tile removeFromSuperview]; }
    [self.tiles removeAllObjects];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIControl *tile = [[UIControl alloc] init];
        tile.tag = idx;
        tile.layer.cornerRadius = self.tileStyle ? 18.f : 16.f;
        TSHsdApplyCardShadow(tile);
        UILabel *main = TSHsdMakeLabel(self.tileStyle ? [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium] : [UIFont systemFontOfSize:15.f weight:UIFontWeightBold], [TSHsdDisplay ink]);
        main.text = title; main.tag = 1001; main.textAlignment = self.tileStyle ? NSTextAlignmentCenter : NSTextAlignmentLeft;
        [tile addSubview:main];
        if (self.tileStyle) {
            UIImageView *icon = [[UIImageView alloc] initWithImage:TSHsdSymbol(symbols.count > idx ? symbols[idx] : @"gamecontroller.fill", 20.f, UIImageSymbolWeightMedium)];
            icon.contentMode = UIViewContentModeCenter; icon.tag = 1002; [tile addSubview:icon];
        } else {
            UILabel *small = TSHsdMakeLabel([UIFont systemFontOfSize:10.5f weight:UIFontWeightSemibold], [TSHsdDisplay textTertiary]);
            small.text = smalls.count > idx ? smalls[idx] : @""; small.tag = 1003; [tile addSubview:small];
            UIView *dot = [[UIView alloc] init]; dot.layer.cornerRadius = 2.5f; dot.tag = 1004; [tile addSubview:dot];
        }
        [tile addTarget:self action:@selector(ts_tapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:tile];
        [self.tiles addObject:tile];
    }];
    [self ts_apply];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self ts_apply];
    // 选中项滚到可见范围（游戏条有 25 项）
    if (selectedIndex >= 0 && selectedIndex < (NSInteger)self.tiles.count) {
        [self layoutIfNeeded];
        [self.scrollView scrollRectToVisible:CGRectInset(self.tiles[selectedIndex].frame, -16.f, 0) animated:NO];
    }
}
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }

- (void)ts_apply {
    [self.tiles enumerateObjectsUsingBlock:^(UIControl *tile, NSUInteger idx, BOOL *stop) {
        BOOL on = (NSInteger)idx == self.selectedIndex;
        UILabel *main = [tile viewWithTag:1001];
        if (self.tileStyle) {
            tile.backgroundColor = [TSHsdDisplay card];
            tile.layer.borderWidth = on ? 2.f : 0;
            tile.layer.borderColor = self.hue.CGColor;
            main.textColor = on ? self.hue : [TSHsdDisplay textSecondary];
            main.font = [UIFont systemFontOfSize:11.5f weight:on ? UIFontWeightBold : UIFontWeightMedium];
            ((UIImageView *)[tile viewWithTag:1002]).tintColor = on ? self.hue : [TSHsdDisplay ink];
        } else {
            tile.backgroundColor = on ? self.hue : [TSHsdDisplay card];
            main.textColor = on ? [UIColor whiteColor] : [TSHsdDisplay ink];
            UILabel *small = [tile viewWithTag:1003];
            small.textColor = on ? [[UIColor whiteColor] colorWithAlphaComponent:0.78f] : [TSHsdDisplay textTertiary];
            UIView *dot = [tile viewWithTag:1004];
            dot.backgroundColor = on ? [UIColor whiteColor] : (self.dotColors.count > idx ? self.dotColors[idx] : [TSHsdDisplay statusWarn]);
        }
    }];
}

- (void)ts_tapped:(UIControl *)sender {
    self.selectedIndex = sender.tag;
    if (self.onChange) { self.onChange(sender.tag); }
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, (self.tileStyle ? 66.f : 58.f) + 6.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    // 与原型一样：滚动区域延伸到屏幕两侧（margin 0 -16）
    self.scrollView.frame = CGRectMake(-16.f, 2.f, self.bounds.size.width + 32.f, self.bounds.size.height - 2.f);
    CGFloat x = 16.f;
    CGFloat tileW = self.tileStyle ? 76.f : 0, tileH = self.tileStyle ? 66.f : 58.f;
    for (UIControl *tile in self.tiles) {
        UILabel *main = [tile viewWithTag:1001];
        if (!self.tileStyle) {
            tileW = MAX(74.f, ceil([main.text sizeWithAttributes:@{NSFontAttributeName: main.font}].width) + 24.f);
        }
        tile.frame = CGRectMake(x, 0, tileW, tileH);
        if (self.tileStyle) {
            [tile viewWithTag:1002].frame = CGRectMake(0, 10.f, tileW, 26.f);
            main.frame = CGRectMake(4.f, 40.f, tileW - 8.f, 16.f);
        } else {
            main.frame = CGRectMake(12.f, 10.f, tileW - 24.f, 20.f);
            [tile viewWithTag:1004].frame = CGRectMake(12.f, 38.f, 5.f, 5.f);
            [tile viewWithTag:1003].frame = CGRectMake(21.f, 32.f, tileW - 33.f, 16.f);
        }
        x += tileW + 8.f;
    }
    self.scrollView.contentSize = CGSizeMake(x + 8.f, tileH);
}

@end
