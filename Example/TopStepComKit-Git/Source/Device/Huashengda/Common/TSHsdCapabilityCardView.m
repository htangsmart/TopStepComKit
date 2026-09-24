//
//  TSHsdCapabilityCardView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdCapabilityCardView.h"
#import "TSBaseVC.h"

static const CGFloat kCardPadding      = 18.f;
static const CGFloat kWatchIconWidth   = 50.f;
static const CGFloat kWatchIconHeight  = 60.f;
static const CGFloat kSegmentHeight    = 7.f;
static const CGFloat kSegmentGap       = 5.f;
static const CGFloat kDetailCellHeight    = 34.f;
static const CGFloat kDetailCellGap       = 6.f;

/// 卡片上的绿色（支持）与文字次色，深色卡不随系统深浅色变化
#define TSHsdCardGreen   [UIColor colorWithRed:60/255.f green:203/255.f blue:155/255.f alpha:1.f]
#define TSHsdCardInk2    [UIColor colorWithRed:169/255.f green:175/255.f blue:198/255.f alpha:1.f]
#define TSHsdCardLine    [UIColor colorWithWhite:1.f alpha:0.12f]

@implementation TSHsdCapabilityItem

+ (instancetype)itemWithName:(NSString *)name shortName:(NSString *)shortName supported:(BOOL)supported {
    TSHsdCapabilityItem *item = [[TSHsdCapabilityItem alloc] init];
    item.name = name;
    item.shortName = shortName;
    item.supported = supported;
    return item;
}

@end

/// 单个能力段：支持为绿实心，不支持为虚线空框
@interface TSHsdSegmentView : UIView
@property (nonatomic, assign) BOOL supported;
@property (nonatomic, strong) CAShapeLayer *dashLayer;
@end

@implementation TSHsdSegmentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = kSegmentHeight / 2.f;
        _dashLayer = [CAShapeLayer layer];
        _dashLayer.fillColor = UIColor.clearColor.CGColor;
        _dashLayer.strokeColor = [UIColor colorWithWhite:1.f alpha:0.3f].CGColor;
        _dashLayer.lineWidth = 1.5f;
        _dashLayer.lineDashPattern = @[@3, @3];
        [self.layer addSublayer:_dashLayer];
    }
    return self;
}

- (void)setSupported:(BOOL)supported {
    _supported = supported;
    self.backgroundColor = supported ? TSHsdCardGreen : UIColor.clearColor;
    self.dashLayer.hidden = supported;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dashLayer.frame = self.bounds;
    self.dashLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.75f, 0.75f)
                                                     cornerRadius:kSegmentHeight / 2.f].CGPath;
}

@end

@interface TSHsdCapabilityCardView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIView *watchIconView;
@property (nonatomic, strong) UILabel *watchKitLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) NSMutableArray<TSHsdSegmentView *> *segmentViews;
@property (nonatomic, strong) NSMutableArray<UILabel *> *segmentLabels;
@property (nonatomic, strong) NSMutableArray<UIView *> *detailCells;
/// 展开区容器（能力明细）：位置始终按展开后的最终位置摆好，展开 / 收起只动 alpha 与卡片高度，
/// 这样在外层的高度动画里文字不会从左上角"长出来"
@property (nonatomic, strong) UIView *detailContainer;

@end

@implementation TSHsdCapabilityCardView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _segmentViews = [NSMutableArray array];
        _segmentLabels = [NSMutableArray array];
        _detailCells = [NSMutableArray array];
        [self ts_setupUI];
    }
    return self;
}

#pragma mark - 私有方法

- (void)ts_setupUI {
    self.layer.cornerRadius = 26.f;
    self.layer.masksToBounds = YES;

    [self.layer insertSublayer:self.gradientLayer atIndex:0];
    [self addSubview:self.watchIconView];
    [self.watchIconView addSubview:self.watchKitLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.statusDot];
    [self addSubview:self.statusLabel];
    [self addSubview:self.separatorLine];
    [self addSubview:self.countLabel];
    [self addSubview:self.toggleButton];
    [self addSubview:self.detailContainer];
}

/**
 * 根据 items 重建能力段、短名与明细格
 */
- (void)ts_rebuildItemViews {
    for (UIView *view in self.segmentViews) { [view removeFromSuperview]; }
    for (UIView *view in self.segmentLabels) { [view removeFromSuperview]; }
    for (UIView *view in self.detailCells) { [view removeFromSuperview]; }
    [self.segmentViews removeAllObjects];
    [self.segmentLabels removeAllObjects];
    [self.detailCells removeAllObjects];

    NSInteger supportedCount = 0;
    for (TSHsdCapabilityItem *item in self.items) {
        if (item.supported) { supportedCount++; }

        TSHsdSegmentView *segment = [[TSHsdSegmentView alloc] init];
        segment.supported = item.supported;
        [self addSubview:segment];
        [self.segmentViews addObject:segment];

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:9.5f weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = item.supported ? TSHsdCardInk2 : [TSHsdCardInk2 colorWithAlphaComponent:0.45f];
        label.attributedText = [[NSAttributedString alloc] initWithString:item.shortName ?: @""
                                                               attributes:item.supported ? @{} : @{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)}];
        [self addSubview:label];
        [self.segmentLabels addObject:label];

        [self.detailCells addObject:[self ts_detailCellForItem:item]];
    }

    NSString *countText = [NSString stringWithFormat:@"%ld / %lu", (long)supportedCount, (unsigned long)self.items.count];
    NSMutableAttributedString *count = [[NSMutableAttributedString alloc] initWithString:countText
                                                                              attributes:@{NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize:15 weight:UIFontWeightBold],
                                                                                           NSForegroundColorAttributeName: UIColor.whiteColor}];
    [count appendAttributedString:[[NSAttributedString alloc] initWithString:[@" " stringByAppendingString:TSLocalizedString(@"hsd.cap.available")]
                                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.5f],
                                                                               NSForegroundColorAttributeName: TSHsdCardInk2}]];
    self.countLabel.attributedText = count;
}

/**
 * 展开态里的一格：名称 + 勾/横；不支持为虚线框
 */
- (UIView *)ts_detailCellForItem:(TSHsdCapabilityItem *)item {
    UIView *cell = [[UIView alloc] init];
    cell.layer.cornerRadius = 10.f;
    cell.backgroundColor = item.supported ? [UIColor colorWithWhite:1.f alpha:0.07f] : UIColor.clearColor;
    if (!item.supported) {
        CAShapeLayer *dash = [CAShapeLayer layer];
        dash.name = @"dash";
        dash.fillColor = UIColor.clearColor.CGColor;
        dash.strokeColor = [UIColor colorWithWhite:1.f alpha:0.2f].CGColor;
        dash.lineWidth = 1.5f;
        dash.lineDashPattern = @[@3, @3];
        [cell.layer addSublayer:dash];
    }

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.tag = 2;
    nameLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium];
    nameLabel.textColor = item.supported ? UIColor.whiteColor : TSHsdCardInk2;
    nameLabel.text = item.name;
    [cell addSubview:nameLabel];

    UIImageView *mark = [[UIImageView alloc] init];
    mark.tag = 3;
    mark.contentMode = UIViewContentModeScaleAspectFit;
    mark.tintColor = item.supported ? TSHsdCardGreen : TSHsdCardInk2;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:11 weight:UIImageSymbolWeightBold];
        mark.image = [UIImage systemImageNamed:item.supported ? @"checkmark" : @"minus" withConfiguration:config];
    }
    [cell addSubview:mark];
    cell.alpha = item.supported ? 1.f : 0.6f;
    [self.detailContainer addSubview:cell];
    return cell;
}

- (void)ts_toggle {
    self.expanded = !self.expanded;
    if (self.onToggle) { self.onToggle(self.expanded); }
}

#pragma mark - 布局

- (CGFloat)ts_contentHeightForWidth:(CGFloat)width {
    CGFloat height = kCardPadding + kWatchIconHeight + 16.f + 1.f + 14.f + 18.f + 10.f + kSegmentHeight + 5.f + 12.f;
    if (self.expanded) {
        NSUInteger rows = (self.items.count + 1) / 2;
        height += 14.f + rows * kDetailCellHeight + (rows > 0 ? (rows - 1) * kDetailCellGap : 0);
    }
    return height + kCardPadding;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, [self ts_contentHeightForWidth:size.width]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat contentWidth = width - kCardPadding * 2;
    self.gradientLayer.frame = self.bounds;

    CGFloat y = kCardPadding;
    self.watchIconView.frame = CGRectMake(kCardPadding, y, kWatchIconWidth, kWatchIconHeight);
    self.watchKitLabel.frame = self.watchIconView.bounds;
    CGFloat textX = CGRectGetMaxX(self.watchIconView.frame) + 14.f;
    self.nameLabel.frame = CGRectMake(textX, y + 10.f, width - textX - kCardPadding, 24.f);
    self.statusDot.frame = CGRectMake(textX, y + 42.f, 7.f, 7.f);
    self.statusLabel.frame = CGRectMake(textX + 13.f, y + 35.f, width - textX - 13.f - kCardPadding, 20.f);
    y += kWatchIconHeight + 16.f;

    self.separatorLine.frame = CGRectMake(kCardPadding, y, contentWidth, 1.f);
    y += 1.f + 14.f;

    self.countLabel.frame = CGRectMake(kCardPadding, y, contentWidth - 90.f, 18.f);
    self.toggleButton.frame = CGRectMake(width - kCardPadding - 90.f, y - 8.f, 90.f, 34.f);
    y += 18.f + 10.f;

    NSUInteger count = self.segmentViews.count;
    if (count > 0) {
        CGFloat segmentWidth = (contentWidth - kSegmentGap * (count - 1)) / count;
        for (NSUInteger i = 0; i < count; i++) {
            CGFloat x = kCardPadding + i * (segmentWidth + kSegmentGap);
            self.segmentViews[i].frame = CGRectMake(x, y, segmentWidth, kSegmentHeight);
            self.segmentLabels[i].frame = CGRectMake(x - 2.f, y + kSegmentHeight + 5.f, segmentWidth + 4.f, 12.f);
        }
    }
    y += kSegmentHeight + 5.f + 12.f;

    // 展开区：始终按最终位置布局（相对容器），只用 alpha 表示展开 / 收起
    y += 14.f;
    CGFloat cellWidth = (contentWidth - kDetailCellGap) / 2.f;
    CGFloat dy = 0;
    for (NSUInteger i = 0; i < self.detailCells.count; i++) {
        UIView *cell = self.detailCells[i];
        CGFloat x = kCardPadding + (i % 2) * (cellWidth + kDetailCellGap);
        CGFloat cy = dy + (i / 2) * (kDetailCellHeight + kDetailCellGap);
        cell.frame = CGRectMake(x, cy, cellWidth, kDetailCellHeight);
        [cell viewWithTag:2].frame = CGRectMake(12.f, 0, cellWidth - 12.f - 30.f, kDetailCellHeight);
        [cell viewWithTag:3].frame = CGRectMake(cellWidth - 24.f, (kDetailCellHeight - 14.f) / 2.f, 14.f, 14.f);
        for (CALayer *layer in cell.layer.sublayers) {
            if ([layer.name isEqualToString:@"dash"]) {
                layer.frame = cell.bounds;
                ((CAShapeLayer *)layer).path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(cell.bounds, 0.75f, 0.75f) cornerRadius:10.f].CGPath;
            }
        }
    }
    NSUInteger rows = (self.detailCells.count + 1) / 2;
    dy += rows * kDetailCellHeight + (rows > 0 ? (rows - 1) * kDetailCellGap : 0);
    self.detailContainer.frame = CGRectMake(0, y, width, dy);
    self.detailContainer.alpha = self.expanded ? 1.f : 0.f;
    self.detailContainer.userInteractionEnabled = self.expanded;
}

#pragma mark - Setter

- (void)setDeviceName:(NSString *)deviceName {
    _deviceName = [deviceName copy];
    self.nameLabel.text = deviceName;
}

- (void)setStatusText:(NSString *)statusText {
    _statusText = [statusText copy];
    self.statusLabel.text = statusText;
}

- (void)setConnected:(BOOL)connected {
    _connected = connected;
    self.statusDot.backgroundColor = connected ? TSHsdCardGreen : [UIColor colorWithRed:1.f green:107/255.f blue:87/255.f alpha:1.f];
}

- (void)setItems:(NSArray<TSHsdCapabilityItem *> *)items {
    _items = [items copy];
    [self ts_rebuildItemViews];
    [self setNeedsLayout];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    UIImage *chevron = nil;
    if (@available(iOS 13.0, *)) {
        chevron = [UIImage systemImageNamed:expanded ? @"chevron.down" : @"chevron.right"
                          withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:11 weight:UIImageSymbolWeightSemibold]];
    }
    [self.toggleButton setImage:chevron forState:UIControlStateNormal];
    [self setNeedsLayout];
}

#pragma mark - 懒加载

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(id)[UIColor colorWithRed:35/255.f green:40/255.f blue:70/255.f alpha:1.f].CGColor,
                                  (id)[UIColor colorWithRed:20/255.f green:23/255.f blue:38/255.f alpha:1.f].CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 1);
    }
    return _gradientLayer;
}

- (UIView *)watchIconView {
    if (!_watchIconView) {
        _watchIconView = [[UIView alloc] init];
        _watchIconView.backgroundColor = [UIColor colorWithRed:5/255.f green:6/255.f blue:10/255.f alpha:1.f];
        _watchIconView.layer.cornerRadius = 16.f;
        _watchIconView.layer.borderWidth = 2.f;
        _watchIconView.layer.borderColor = [UIColor colorWithWhite:1.f alpha:0.24f].CGColor;
    }
    return _watchIconView;
}

- (UILabel *)watchKitLabel {
    if (!_watchKitLabel) {
        _watchKitLabel = [[UILabel alloc] init];
        _watchKitLabel.text = @"NPK";
        _watchKitLabel.textColor = UIColor.whiteColor;
        _watchKitLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        _watchKitLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _watchKitLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightBold];
    }
    return _nameLabel;
}

- (UIView *)statusDot {
    if (!_statusDot) {
        _statusDot = [[UIView alloc] init];
        _statusDot.layer.cornerRadius = 3.5f;
        _statusDot.backgroundColor = TSHsdCardGreen;
    }
    return _statusDot;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = TSHsdCardInk2;
        _statusLabel.font = [UIFont systemFontOfSize:12.5f];
    }
    return _statusLabel;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = TSHsdCardLine;
    }
    return _separatorLine;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
    }
    return _countLabel;
}

- (UIButton *)toggleButton {
    if (!_toggleButton) {
        _toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _toggleButton.tintColor = TSHsdCardInk2;
        _toggleButton.titleLabel.font = [UIFont systemFontOfSize:12.5f];
        [_toggleButton setTitle:TSLocalizedString(@"hsd.cap.details") forState:UIControlStateNormal];
        [_toggleButton setTitleColor:TSHsdCardInk2 forState:UIControlStateNormal];
        _toggleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _toggleButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        _toggleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4.f, 0, -4.f);
        [_toggleButton addTarget:self action:@selector(ts_toggle) forControlEvents:UIControlEventTouchUpInside];
        self.expanded = NO;
    }
    return _toggleButton;
}

- (UIView *)detailContainer {
    if (!_detailContainer) {
        _detailContainer = [[UIView alloc] init];
        _detailContainer.alpha = 0;
        _detailContainer.userInteractionEnabled = NO;
    }
    return _detailContainer;
}

@end
