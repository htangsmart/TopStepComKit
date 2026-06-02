//
//  TSAIInterpreterLanguageBarView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterLanguageBarView.h"

/// 单个胶囊容器（堆叠 LABEL / value / autoTag）
@interface TSAIInterpreterLanguagePillView : UIControl
/// 顶部小号大写 LABEL（"SOURCE" / "TARGET"）
@property (nonatomic, strong) UILabel *labelTitle;
/// 中部大号语言名
@property (nonatomic, strong) UILabel *valueLabel;
/// 尾部橙色 auto 小标（仅源胶囊使用）
@property (nonatomic, strong) UILabel *autoTagLabel;
@end

@implementation TSAIInterpreterLanguagePillView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemGray6Color];
        self.layer.cornerRadius = 10.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        [self addSubview:self.labelTitle];
        [self addSubview:self.valueLabel];
        [self addSubview:self.autoTagLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat labelH = 14.0;
    CGFloat valueH = 22.0;
    CGFloat blockH = labelH + 3.0 + valueH;
    CGFloat topY = (height - blockH) / 2.0;
    self.labelTitle.frame = CGRectMake(0, topY, width, labelH);

    BOOL hasAutoTag = !self.autoTagLabel.hidden && self.autoTagLabel.text.length > 0;
    if (hasAutoTag) {
        CGSize tagSize = [self.autoTagLabel sizeThatFits:CGSizeMake(width, valueH)];
        CGFloat tagW = ceil(tagSize.width) + 12.0;
        CGFloat tagH = 18.0;
        CGFloat valueW = [self.valueLabel sizeThatFits:CGSizeMake(width, valueH)].width;
        CGFloat totalW = MIN(width, valueW + 4.0 + tagW);
        CGFloat startX = (width - totalW) / 2.0;
        CGFloat valueY = topY + labelH + 3.0;
        self.valueLabel.frame = CGRectMake(startX, valueY, totalW - tagW - 4.0, valueH);
        self.autoTagLabel.frame = CGRectMake(CGRectGetMaxX(self.valueLabel.frame) + 4.0,
                                              valueY + (valueH - tagH) / 2.0,
                                              tagW, tagH);
        self.autoTagLabel.layer.cornerRadius = tagH / 2.0;
    } else {
        self.valueLabel.frame = CGRectMake(0, topY + labelH + 3.0, width, valueH);
    }
}

- (void)setLabelTitleText:(NSString *)title {
    self.labelTitle.text = title;
}

- (void)setValueText:(NSString *)text autoTag:(NSString *)autoTag {
    self.valueLabel.text = text;
    if (autoTag.length > 0) {
        self.autoTagLabel.text = autoTag;
        self.autoTagLabel.hidden = NO;
    } else {
        self.autoTagLabel.text = nil;
        self.autoTagLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.alpha = enabled ? 1.0 : 0.5;
}

#pragma mark - 属性（懒加载）

- (UILabel *)labelTitle {
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc] init];
        _labelTitle.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
        _labelTitle.textColor = [UIColor secondaryLabelColor];
        _labelTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _labelTitle;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        _valueLabel.textColor = [UIColor labelColor];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _valueLabel;
}

- (UILabel *)autoTagLabel {
    if (!_autoTagLabel) {
        _autoTagLabel = [[UILabel alloc] init];
        _autoTagLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightMedium];
        _autoTagLabel.textColor = [UIColor systemOrangeColor];
        _autoTagLabel.backgroundColor = [[UIColor systemOrangeColor] colorWithAlphaComponent:0.12];
        _autoTagLabel.textAlignment = NSTextAlignmentCenter;
        _autoTagLabel.clipsToBounds = YES;
        _autoTagLabel.hidden = YES;
    }
    return _autoTagLabel;
}

@end

#pragma mark -

@interface TSAIInterpreterLanguageBarView ()
/// 源语言胶囊
@property (nonatomic, strong) TSAIInterpreterLanguagePillView *sourcePill;
/// 目标语言胶囊
@property (nonatomic, strong) TSAIInterpreterLanguagePillView *targetPill;
/// 中间互换按钮（蓝色圆形）
@property (nonatomic, strong) UIButton *swapButton;
@end

@implementation TSAIInterpreterLanguageBarView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        self.layer.cornerRadius = 14.0;
        [self addSubview:self.sourcePill];
        [self addSubview:self.swapButton];
        [self addSubview:self.targetPill];

        [self.sourcePill setLabelTitleText:NSLocalizedString(@"ai_interpreter.label_source", nil)];
        [self.targetPill setLabelTitleText:NSLocalizedString(@"ai_interpreter.label_target", nil)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat innerPad = 12.0;
    CGFloat width = CGRectGetWidth(self.bounds) - innerPad * 2;
    CGFloat height = CGRectGetHeight(self.bounds) - innerPad * 2;
    CGFloat swapSize = 38.0;
    CGFloat gap = 10.0;
    CGFloat pillW = (width - swapSize - gap * 2) / 2.0;
    self.sourcePill.frame = CGRectMake(innerPad, innerPad, pillW, height);
    self.swapButton.frame = CGRectMake(innerPad + pillW + gap,
                                         innerPad + (height - swapSize) / 2.0,
                                         swapSize, swapSize);
    self.swapButton.layer.cornerRadius = swapSize / 2.0;
    self.targetPill.frame = CGRectMake(innerPad + pillW + gap * 2 + swapSize,
                                         innerPad, pillW, height);
}

#pragma mark - 公开方法

- (void)setSourceValueText:(NSString *)valueText autoTag:(NSString *)autoTag {
    [self.sourcePill setValueText:valueText autoTag:autoTag];
}

- (void)setTargetValueText:(NSString *)valueText {
    [self.targetPill setValueText:valueText autoTag:nil];
}

- (void)setPillsEnabled:(BOOL)pillsEnabled swapEnabled:(BOOL)swapEnabled {
    self.sourcePill.enabled = pillsEnabled;
    self.targetPill.enabled = pillsEnabled;
    self.swapButton.enabled = swapEnabled;
    self.swapButton.alpha = swapEnabled ? 1.0 : 0.35;
}

#pragma mark - 私有方法

- (void)onSourcePillTouch {
    if (self.onSourceTap) self.onSourceTap();
}

- (void)onTargetPillTouch {
    if (self.onTargetTap) self.onTargetTap();
}

- (void)onSwapButtonTap {
    if (self.onSwapTap) self.onSwapTap();
}

#pragma mark - 属性（懒加载）

- (TSAIInterpreterLanguagePillView *)sourcePill {
    if (!_sourcePill) {
        _sourcePill = [[TSAIInterpreterLanguagePillView alloc] init];
        [_sourcePill addTarget:self action:@selector(onSourcePillTouch)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _sourcePill;
}

- (TSAIInterpreterLanguagePillView *)targetPill {
    if (!_targetPill) {
        _targetPill = [[TSAIInterpreterLanguagePillView alloc] init];
        [_targetPill addTarget:self action:@selector(onTargetPillTouch)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _targetPill;
}

- (UIButton *)swapButton {
    if (!_swapButton) {
        _swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _swapButton.backgroundColor = [UIColor systemBlueColor];
        _swapButton.tintColor = [UIColor whiteColor];
        if (@available(iOS 13.0, *)) {
            UIImage *icon = [UIImage systemImageNamed:@"arrow.left.arrow.right"];
            [_swapButton setImage:icon forState:UIControlStateNormal];
        } else {
            [_swapButton setTitle:@"⇄" forState:UIControlStateNormal];
            [_swapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [_swapButton addTarget:self action:@selector(onSwapButtonTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _swapButton;
}

@end
