//
//  TSAIChatRoundCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatRoundCell.h"

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

#import "TSRootVC.h"

@interface TSAIChatRoundCell ()

// 轮次标签 "Round 0"
@property (nonatomic, strong) UILabel *roundTagLabel;
// Q / A 气泡
@property (nonatomic, strong) UIView  *questionBubble;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UIView  *answerBubble;
@property (nonatomic, strong) UILabel *answerLabel;
// 内部纵向编排：Q 气泡 / A 气泡 / Intent chips
@property (nonatomic, strong) UIStackView *contentStack;
// Intent chip 容器（由 appendIntent: 累加）
@property (nonatomic, strong) UIStackView *intentStack;

@end

@implementation TSAIChatRoundCell

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - 公开方法

- (void)setRoundIndex:(NSInteger)roundIndex {
    _roundIndex = roundIndex;
    self.roundTagLabel.text = [NSString stringWithFormat:@"ROUND %ld", (long)roundIndex];
}

- (void)setQuestionText:(NSString *)text isFinal:(BOOL)isFinal {
    NSString *display = text ?: @"";
    self.questionBubble.hidden = (display.length == 0);
    self.questionLabel.attributedText = [self attributedTextForBubble:display
                                                         streaming:!isFinal
                                                         tintColor:[UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f]];
}

- (void)setAnswerText:(NSString *)text isFinal:(BOOL)isFinal {
    NSString *display = text ?: @"";
    self.answerBubble.hidden = (display.length == 0);
    self.answerLabel.attributedText = [self attributedTextForBubble:display
                                                       streaming:!isFinal
                                                       tintColor:TSColor_Purple];
}

- (void)appendIntent:(TSAIChatIntent *)intent {
    if (!intent) return;
    UIView *chip = [self makeIntentChipForIntent:intent];
    [self.intentStack addArrangedSubview:chip];
}

#pragma mark - 私有方法

/// 装配子视图层级
- (void)setupSubviews {
    [self addSubview:self.roundTagLabel];
    [self addSubview:self.contentStack];

    [self.contentStack addArrangedSubview:self.questionBubble];
    [self.questionBubble addSubview:self.questionLabel];
    [self.contentStack addArrangedSubview:self.answerBubble];
    [self.answerBubble addSubview:self.answerLabel];
    [self.contentStack addArrangedSubview:self.intentStack];

    [self setupConstraints];
}

/// AutoLayout 约束（让 UIStackView 自适应高度，外部直接挂 UIStackView 即可滚动）
- (void)setupConstraints {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.roundTagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStack.translatesAutoresizingMaskIntoConstraints  = NO;
    self.questionBubble.translatesAutoresizingMaskIntoConstraints = NO;
    self.answerBubble.translatesAutoresizingMaskIntoConstraints   = NO;
    self.questionLabel.translatesAutoresizingMaskIntoConstraints  = NO;
    self.answerLabel.translatesAutoresizingMaskIntoConstraints    = NO;

    CGFloat hPad = TSSpacing_SM + 4.f;
    CGFloat vPad = TSSpacing_SM;

    [NSLayoutConstraint activateConstraints:@[
        [self.roundTagLabel.topAnchor      constraintEqualToAnchor:self.topAnchor],
        [self.roundTagLabel.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor],
        [self.roundTagLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor],

        [self.contentStack.topAnchor      constraintEqualToAnchor:self.roundTagLabel.bottomAnchor constant:6.f],
        [self.contentStack.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor],
        [self.contentStack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.contentStack.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor],

        [self.questionLabel.topAnchor      constraintEqualToAnchor:self.questionBubble.topAnchor      constant:vPad],
        [self.questionLabel.leadingAnchor  constraintEqualToAnchor:self.questionBubble.leadingAnchor  constant:hPad],
        [self.questionLabel.trailingAnchor constraintEqualToAnchor:self.questionBubble.trailingAnchor constant:-hPad],
        [self.questionLabel.bottomAnchor   constraintEqualToAnchor:self.questionBubble.bottomAnchor   constant:-vPad],

        [self.answerLabel.topAnchor      constraintEqualToAnchor:self.answerBubble.topAnchor      constant:vPad],
        [self.answerLabel.leadingAnchor  constraintEqualToAnchor:self.answerBubble.leadingAnchor  constant:hPad],
        [self.answerLabel.trailingAnchor constraintEqualToAnchor:self.answerBubble.trailingAnchor constant:-hPad],
        [self.answerLabel.bottomAnchor   constraintEqualToAnchor:self.answerBubble.bottomAnchor   constant:-vPad],
    ]];

    // 让 Q 气泡靠左，A 气泡左缩进 16 形成视觉层次
    self.questionBubble.preservesSuperviewLayoutMargins = NO;
    self.answerBubble.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0);
}

/// 生成带光标的气泡富文本
- (NSAttributedString *)attributedTextForBubble:(NSString *)body
                                      streaming:(BOOL)streaming
                                      tintColor:(UIColor *)tintColor {
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    [result appendAttributedString:[[NSAttributedString alloc] initWithString:body
                                                                   attributes:@{
        NSFontAttributeName: TSFont_Body,
        NSForegroundColorAttributeName: TSColor_TextPrimary,
    }]];
    if (streaming) {
        [result appendAttributedString:[[NSAttributedString alloc] initWithString:@" ▍"
                                                                       attributes:@{
            NSFontAttributeName: TSFont_Body,
            NSForegroundColorAttributeName: tintColor,
        }]];
    }
    return result;
}

/// 生成单个 Intent chip
- (UIView *)makeIntentChipForIntent:(TSAIChatIntent *)intent {
    UIView *chip = [[UIView alloc] init];
    chip.backgroundColor = [TSColor_Warning colorWithAlphaComponent:0.15f];
    chip.layer.cornerRadius = 10.f;
    chip.layer.borderWidth = 0.5f;
    chip.layer.borderColor = [TSColor_Warning colorWithAlphaComponent:0.5f].CGColor;
    chip.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *label = [[UILabel alloc] init];
    label.font = TSFont_Caption;
    label.textColor = TSColor_Warning;
    label.numberOfLines = 0;
    label.text = [self chipTextForIntent:intent];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [chip addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor      constraintEqualToAnchor:chip.topAnchor      constant:6.f],
        [label.leadingAnchor  constraintEqualToAnchor:chip.leadingAnchor  constant:10.f],
        [label.trailingAnchor constraintEqualToAnchor:chip.trailingAnchor constant:-10.f],
        [label.bottomAnchor   constraintEqualToAnchor:chip.bottomAnchor   constant:-6.f],
    ]];

    [chip setContentHuggingPriority:UILayoutPriorityDefaultHigh + 1
                            forAxis:UILayoutConstraintAxisHorizontal];

    return chip;
}

/// chip 文本：Type · query → value
- (NSString *)chipTextForIntent:(TSAIChatIntent *)intent {
    NSString *typeName = [self readableNameForIntentType:intent.type fallback:intent.intentId];
    NSString *query = intent.query.length > 0 ? intent.query : @"-";
    NSString *value = intent.value.length > 0 ? intent.value : @"-";
    return [NSString stringWithFormat:@"🔊 %@ · %@ → %@", typeName, query, value];
}

/// 把 TSAIChatIntentType 转成可读名（Unknown 时回退 intentId）
- (NSString *)readableNameForIntentType:(TSAIChatIntentType)type fallback:(NSString *)fallback {
    if (type == TSAIChatIntentTypeUnknown) {
        return fallback.length > 0 ? fallback : @"Unknown";
    }
    return [NSString stringWithFormat:@"Intent#%ld", (long)type];
}

#pragma mark - 属性（懒加载）

- (UILabel *)roundTagLabel {
    if (!_roundTagLabel) {
        _roundTagLabel = [[UILabel alloc] init];
        _roundTagLabel.font = [UIFont systemFontOfSize:10.f weight:UIFontWeightSemibold];
        _roundTagLabel.textColor = TSColor_TextSecondary;
        _roundTagLabel.text = @"ROUND 0";
    }
    return _roundTagLabel;
}

- (UIStackView *)contentStack {
    if (!_contentStack) {
        _contentStack = [[UIStackView alloc] init];
        _contentStack.axis = UILayoutConstraintAxisVertical;
        _contentStack.alignment = UIStackViewAlignmentFill;
        _contentStack.spacing = 6.f;
    }
    return _contentStack;
}

- (UIView *)questionBubble {
    if (!_questionBubble) {
        _questionBubble = [[UIView alloc] init];
        _questionBubble.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.10f];
        _questionBubble.layer.cornerRadius = 14.f;
        _questionBubble.hidden = YES;
    }
    return _questionBubble;
}

- (UILabel *)questionLabel {
    if (!_questionLabel) {
        _questionLabel = [[UILabel alloc] init];
        _questionLabel.font = TSFont_Body;
        _questionLabel.numberOfLines = 0;
        _questionLabel.textColor = TSColor_TextPrimary;
    }
    return _questionLabel;
}

- (UIView *)answerBubble {
    if (!_answerBubble) {
        _answerBubble = [[UIView alloc] init];
        _answerBubble.backgroundColor = TSColor_Card;
        _answerBubble.layer.cornerRadius = 14.f;
        _answerBubble.layer.borderWidth = 0.5f;
        _answerBubble.layer.borderColor = TSColor_Separator.CGColor;
        _answerBubble.hidden = YES;
    }
    return _answerBubble;
}

- (UILabel *)answerLabel {
    if (!_answerLabel) {
        _answerLabel = [[UILabel alloc] init];
        _answerLabel.font = TSFont_Body;
        _answerLabel.numberOfLines = 0;
        _answerLabel.textColor = TSColor_TextPrimary;
    }
    return _answerLabel;
}

- (UIStackView *)intentStack {
    if (!_intentStack) {
        _intentStack = [[UIStackView alloc] init];
        _intentStack.axis = UILayoutConstraintAxisVertical;
        _intentStack.alignment = UIStackViewAlignmentLeading;
        _intentStack.spacing = 4.f;
    }
    return _intentStack;
}

@end
