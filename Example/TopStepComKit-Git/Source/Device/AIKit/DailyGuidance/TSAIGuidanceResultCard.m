//
//  TSAIGuidanceResultCard.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIGuidanceResultCard.h"
#import "TSBaseVC.h"

// 卡片内边距与关键尺寸
static const CGFloat kCardPaddingH   = 16.f;
static const CGFloat kCardPaddingTop = 14.f;
static const CGFloat kCardPaddingBot = 12.f;
static const CGFloat kIconSize       = 28.f;
static const CGFloat kCheckSize      = 18.f;
static const CGFloat kRowGap         = 10.f;

@interface TSAIGuidanceResultCard ()

// 头部图标背景（青色圆角方块）
@property (nonatomic, strong) UIView    *iconContainer;
// 头部图标
@property (nonatomic, strong) UIImageView *iconView;
// 头部标题
@property (nonatomic, strong) UILabel   *titleLabel;
// 主引导文案
@property (nonatomic, strong) UILabel   *mainTextLabel;
// 行动清单上方分隔线
@property (nonatomic, strong) UIView    *separator;
// 免责声明
@property (nonatomic, strong) UILabel   *disclaimerLabel;
// 动态生成的行动项行（✓圆圈 + 文案）
@property (nonatomic, strong) NSMutableArray<UIView *>  *checkViews;
@property (nonatomic, strong) NSMutableArray<UILabel *> *actionLabels;

@end

@implementation TSAIGuidanceResultCard

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _checkViews   = [NSMutableArray array];
        _actionLabels = [NSMutableArray array];
        [self ts_setupViews];
    }
    return self;
}

#pragma mark - 私有方法

// 初始化固定子视图
- (void)ts_setupViews {
    self.backgroundColor = TSColor_Card;
    self.layer.cornerRadius = TSRadius_MD;
    self.clipsToBounds = YES;

    self.iconContainer = [[UIView alloc] init];
    self.iconContainer.backgroundColor = TSColor_Teal;
    self.iconContainer.layer.cornerRadius = 8.f;
    [self addSubview:self.iconContainer];

    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.tintColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightSemibold];
        self.iconView.image = [UIImage systemImageNamed:@"sparkles" withConfiguration:cfg];
    }
    [self.iconContainer addSubview:self.iconView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    self.titleLabel.textColor = TSColor_TextPrimary;
    [self addSubview:self.titleLabel];

    self.mainTextLabel = [[UILabel alloc] init];
    self.mainTextLabel.font = [UIFont systemFontOfSize:15.f];
    self.mainTextLabel.textColor = TSColor_TextPrimary;
    self.mainTextLabel.numberOfLines = 0;
    [self addSubview:self.mainTextLabel];

    self.separator = [[UIView alloc] init];
    self.separator.backgroundColor = TSColor_Separator;
    [self addSubview:self.separator];

    self.disclaimerLabel = [[UILabel alloc] init];
    self.disclaimerLabel.font = [UIFont systemFontOfSize:12.f];
    self.disclaimerLabel.textColor = TSColor_TextSecondary;
    self.disclaimerLabel.numberOfLines = 0;
    [self addSubview:self.disclaimerLabel];
}

// 创建单个 ✓ 圆圈视图
- (UIView *)ts_createCheckView {
    UIView *circle = [[UIView alloc] init];
    circle.backgroundColor = [TSColor_Success colorWithAlphaComponent:0.14f];
    circle.layer.cornerRadius = kCheckSize / 2.f;
    UIImageView *tick = [[UIImageView alloc] init];
    tick.contentMode = UIViewContentModeScaleAspectFit;
    tick.tintColor = TSColor_Success;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:10 weight:UIImageSymbolWeightBold];
        tick.image = [UIImage systemImageNamed:@"checkmark" withConfiguration:cfg];
    }
    tick.frame = CGRectMake(0, 0, kCheckSize, kCheckSize);
    tick.tag = 1;
    [circle addSubview:tick];
    return circle;
}

#pragma mark - 公开方法

- (void)configureWithMainText:(NSString *)mainText
                  actionItems:(NSArray<NSString *> *)actionItems
                   disclaimer:(NSString *)disclaimer {
    self.mainTextLabel.text = mainText.length > 0 ? mainText : TSLocalizedString(@"ai_guidance.empty");

    // 清理旧行动项
    for (UIView *view in self.checkViews)   { [view removeFromSuperview]; }
    for (UILabel *label in self.actionLabels) { [label removeFromSuperview]; }
    [self.checkViews removeAllObjects];
    [self.actionLabels removeAllObjects];

    for (NSString *item in actionItems) {
        UIView *check = [self ts_createCheckView];
        [self addSubview:check];
        [self.checkViews addObject:check];

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14.f];
        label.textColor = TSColor_TextPrimary;
        label.numberOfLines = 0;
        label.text = item;
        [self addSubview:label];
        [self.actionLabels addObject:label];
    }

    self.separator.hidden = (self.actionLabels.count == 0);
    self.disclaimerLabel.text = disclaimer.length > 0 ? disclaimer : TSLocalizedString(@"ai_guidance.disclaimer");
    [self setNeedsLayout];
}

- (CGFloat)heightForWidth:(CGFloat)width {
    return [self ts_layoutForWidth:width apply:NO];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    [self ts_layoutForWidth:CGRectGetWidth(self.bounds) apply:YES];
}

// 统一测量/布局：apply=YES 时设置 frame，返回内容总高度
- (CGFloat)ts_layoutForWidth:(CGFloat)width apply:(BOOL)apply {
    CGFloat contentW = width - kCardPaddingH * 2;
    CGFloat y = kCardPaddingTop;

    // 头部：图标 + 标题
    if (apply) {
        self.iconContainer.frame = CGRectMake(kCardPaddingH, y, kIconSize, kIconSize);
        self.iconView.frame = self.iconContainer.bounds;
        CGFloat titleX = kCardPaddingH + kIconSize + 8.f;
        self.titleLabel.frame = CGRectMake(titleX, y, width - titleX - kCardPaddingH, kIconSize);
    }
    y += kIconSize + kRowGap;

    // 主文案
    CGFloat mainH = [self ts_textHeight:self.mainTextLabel width:contentW];
    if (apply) {
        self.mainTextLabel.frame = CGRectMake(kCardPaddingH, y, contentW, mainH);
    }
    y += mainH;

    // 行动清单
    if (self.actionLabels.count > 0) {
        y += 12.f;
        if (apply) {
            self.separator.frame = CGRectMake(kCardPaddingH, y, contentW, 0.5f);
        }
        y += 12.f;

        CGFloat textX = kCardPaddingH + kCheckSize + 8.f;
        CGFloat textW = width - textX - kCardPaddingH;
        for (NSInteger idx = 0; idx < (NSInteger)self.actionLabels.count; idx++) {
            UILabel *label = self.actionLabels[idx];
            CGFloat rowTextH = [self ts_textHeight:label width:textW];
            CGFloat rowH = MAX(rowTextH, kCheckSize);
            if (apply) {
                UIView *check = self.checkViews[idx];
                check.frame = CGRectMake(kCardPaddingH, y + (rowH - kCheckSize) / 2.f, kCheckSize, kCheckSize);
                label.frame = CGRectMake(textX, y + (rowH - rowTextH) / 2.f, textW, rowTextH);
            }
            y += rowH + (idx == (NSInteger)self.actionLabels.count - 1 ? 0 : kRowGap);
        }
    }

    // 免责声明
    y += 10.f;
    CGFloat disclaimerH = [self ts_textHeight:self.disclaimerLabel width:contentW];
    if (apply) {
        self.disclaimerLabel.frame = CGRectMake(kCardPaddingH, y, contentW, disclaimerH);
    }
    y += disclaimerH + kCardPaddingBot;

    return y;
}

// 计算 label 文本在指定宽度下的高度
- (CGFloat)ts_textHeight:(UILabel *)label width:(CGFloat)width {
    if (label.text.length == 0) return 0.f;
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: label.font}
                                           context:nil].size;
    return ceil(size.height);
}

#pragma mark - 属性 setter

- (void)setCardTitle:(NSString *)cardTitle {
    _cardTitle = [cardTitle copy];
    self.titleLabel.text = cardTitle;
}

@end
