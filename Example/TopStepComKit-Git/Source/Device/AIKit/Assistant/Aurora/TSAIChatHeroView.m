//
//  TSAIChatHeroView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatHeroView.h"

#import "TSAIChatOrbView.h"
#import "TSAIChatTheme.h"

@interface TSAIChatHeroView ()

// 光球 150
@property (nonatomic, strong) TSAIChatOrbView *orbView;
// 标题「嗨，我在。」
@property (nonatomic, strong) UILabel *titleLabel;
// 副标
@property (nonatomic, strong) UILabel *subtitleLabel;
// 建议 chip
@property (nonatomic, strong) NSArray<UIControl *> *chips;
// chip 文案
@property (nonatomic, strong) NSArray<NSString *> *suggestions;

@end

@implementation TSAIChatHeroView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _orbView = [[TSAIChatOrbView alloc] initWithDiameter:150];
        [self addSubview:_orbView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"嗨，我在。";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.attributedText = [[NSAttributedString alloc]
            initWithString:@"嗨，我在。"
                attributes:@{NSFontAttributeName: TSAIChatFont(24, UIFontWeightHeavy),
                             NSForegroundColorAttributeName: TSAIChatInkColor(),
                             NSKernAttributeName: @(-0.4)}];
        [self addSubview:_titleLabel];

        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = 13.5 * 0.6 - 2;
        paragraph.alignment = NSTextAlignmentCenter;
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.attributedText = [[NSAttributedString alloc]
            initWithString:@"按住麦克风说一句，松开就有回答。想打字也行。"
                attributes:@{NSFontAttributeName: TSAIChatFont(13.5, UIFontWeightRegular),
                             NSForegroundColorAttributeName: TSAIChatInk2Color(),
                             NSParagraphStyleAttributeName: paragraph}];
        [self addSubview:_subtitleLabel];

        _suggestions = @[@"今天天气怎么样？", @"我今天适合跑步吗？", @"昨晚睡得怎么样？", @"明早七点半叫我起床"];
        NSArray<NSString *> *symbols = @[@"sun.max.fill", @"figure.run", @"moon.fill", @"alarm.fill"];
        NSArray<UIColor *> *tints = @[TSAIChatPeachColor(), TSAIChatMintColor(), TSAIChatVioletColor(), TSAIChatSkyColor()];
        NSMutableArray *chips = [NSMutableArray array];
        for (NSInteger index = 0; index < _suggestions.count; index++) {
            UIControl *chip = [self makeChipWithText:_suggestions[index] symbol:symbols[index] tint:tints[index]];
            chip.tag = index;
            [self addSubview:chip];
            [chips addObject:chip];
        }
        _chips = chips;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat contentWidth = width - 56;
    CGFloat y = 0;
    self.orbView.center = CGPointMake(width / 2, y + 75);
    self.orbView.bounds = CGRectMake(0, 0, 150, 150);
    y += 150 + 22;
    self.titleLabel.frame = CGRectMake(28, y, contentWidth, 30);
    y += 30 + 8;
    CGFloat subtitleWidth = MIN(260, contentWidth);
    CGFloat subtitleHeight = ceil([self.subtitleLabel sizeThatFits:CGSizeMake(subtitleWidth, CGFLOAT_MAX)].height);
    self.subtitleLabel.frame = CGRectMake((width - subtitleWidth) / 2, y, subtitleWidth, subtitleHeight);
    y += subtitleHeight + 22;
    [self layoutChipsFromY:y width:contentWidth originX:28];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat contentWidth = size.width - 56;
    CGFloat subtitleWidth = MIN(260, contentWidth);
    CGFloat subtitleHeight = ceil([self.subtitleLabel sizeThatFits:CGSizeMake(subtitleWidth, CGFLOAT_MAX)].height);
    CGFloat chipsHeight = [self chipsHeightForWidth:contentWidth];
    return CGSizeMake(size.width, 150 + 22 + 30 + 8 + subtitleHeight + 22 + chipsHeight + 20);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self.orbView restartAnimations];
    }
}

#pragma mark - 公开方法

- (void)playEntrance {
    for (NSInteger index = 0; index < self.chips.count; index++) {
        TSAIChatPopIn(self.chips[index], 0.5, 0.08 * index);
    }
}

- (void)restartAnimations {
    [self.orbView restartAnimations];
}

#pragma mark - 私有方法

/// chip：内边距 9/14，圆角 18，白 α.69，描边白 α.88，字 13/600，18 彩色图标块
- (UIControl *)makeChipWithText:(NSString *)text symbol:(NSString *)symbol tint:(UIColor *)tint {
    UIControl *chip = [[UIControl alloc] init];
    chip.backgroundColor = [UIColor colorWithWhite:1 alpha:0.69];
    chip.layer.cornerRadius = 18;
    chip.layer.cornerCurve = kCACornerCurveContinuous;
    chip.layer.borderWidth = 1;
    chip.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.88].CGColor;
    TSAIChatApplyCardShadow(chip.layer);

    UIView *iconBlock = [[UIView alloc] initWithFrame:CGRectMake(14, 9, 18, 18)];
    iconBlock.backgroundColor = tint;
    iconBlock.layer.cornerRadius = 6;
    iconBlock.layer.cornerCurve = kCACornerCurveContinuous;
    iconBlock.userInteractionEnabled = NO;
    iconBlock.tag = 1;
    UIImageView *icon = [[UIImageView alloc] initWithImage:TSAIChatSymbol(symbol, 9, UIImageSymbolWeightBold)];
    icon.tintColor = [UIColor whiteColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.frame = CGRectMake(3.5, 3.5, 11, 11);
    [iconBlock addSubview:icon];
    [chip addSubview:iconBlock];

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = TSAIChatFont(13, UIFontWeightSemibold);
    label.textColor = TSAIChatInkColor();
    label.tag = 2;
    label.userInteractionEnabled = NO;
    CGSize textSize = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, 18)];
    label.frame = CGRectMake(14 + 18 + 6, 9, ceil(textSize.width), 18);
    [chip addSubview:label];

    chip.bounds = CGRectMake(0, 0, 14 + 18 + 6 + ceil(textSize.width) + 14, 36);
    [chip addTarget:self action:@selector(onChipTapped:) forControlEvents:UIControlEventTouchUpInside];
    [chip addTarget:self action:@selector(onChipDown:) forControlEvents:UIControlEventTouchDown];
    [chip addTarget:self action:@selector(onChipUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    return chip;
}

/// 横向换行居中，间距 8
- (void)layoutChipsFromY:(CGFloat)startY width:(CGFloat)width originX:(CGFloat)originX {
    NSMutableArray<NSMutableArray<UIControl *> *> *rows = [NSMutableArray array];
    NSMutableArray<UIControl *> *row = [NSMutableArray array];
    CGFloat rowWidth = 0;
    for (UIControl *chip in self.chips) {
        CGFloat chipWidth = CGRectGetWidth(chip.bounds);
        if (row.count > 0 && rowWidth + 8 + chipWidth > width) {
            [rows addObject:row];
            row = [NSMutableArray array];
            rowWidth = 0;
        }
        rowWidth += (row.count > 0 ? 8 : 0) + chipWidth;
        [row addObject:chip];
    }
    if (row.count > 0) [rows addObject:row];

    CGFloat y = startY;
    for (NSMutableArray<UIControl *> *line in rows) {
        CGFloat lineWidth = -8;
        for (UIControl *chip in line) lineWidth += CGRectGetWidth(chip.bounds) + 8;
        CGFloat x = originX + (width - lineWidth) / 2;
        for (UIControl *chip in line) {
            CGFloat chipWidth = CGRectGetWidth(chip.bounds);
            chip.center = CGPointMake(x + chipWidth / 2, y + 18);
            x += chipWidth + 8;
        }
        y += 36 + 8;
    }
}

/// chip 区总高
- (CGFloat)chipsHeightForWidth:(CGFloat)width {
    NSInteger rows = 1;
    CGFloat rowWidth = 0;
    NSInteger count = 0;
    for (UIControl *chip in self.chips) {
        CGFloat chipWidth = CGRectGetWidth(chip.bounds);
        if (count > 0 && rowWidth + 8 + chipWidth > width) {
            rows++;
            rowWidth = 0;
            count = 0;
        }
        rowWidth += (count > 0 ? 8 : 0) + chipWidth;
        count++;
    }
    return rows * 36 + (rows - 1) * 8;
}

#pragma mark - 事件

- (void)onChipTapped:(UIControl *)chip {
    if (self.onSuggestionTap && chip.tag < self.suggestions.count) {
        self.onSuggestionTap(self.suggestions[chip.tag]);
    }
}

- (void)onChipDown:(UIControl *)chip {
    [UIView animateWithDuration:0.15 animations:^{
        chip.transform = CGAffineTransformMakeScale(0.96, 0.96);
    }];
}

- (void)onChipUp:(UIControl *)chip {
    [UIView animateWithDuration:0.2 animations:^{
        chip.transform = CGAffineTransformIdentity;
    }];
}

@end
