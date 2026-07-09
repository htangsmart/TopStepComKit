//
//  TSAITTSInputCard.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAITTSInputCard.h"

#import "TSRootVC.h"

/// 字符数预警阈值（剩余 ≤ 此值时计数器变橙）
static const NSInteger kTSAITTSInputWarnRemainder = 50;

@interface TSAITTSInputCard () <UITextViewDelegate>

@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UIButton   *sampleButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel    *placeholderLabel;
@property (nonatomic, strong) UILabel    *charCountLabel;

@end

@implementation TSAITTSInputCard

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TSColor_Card;
        self.layer.cornerRadius = TSRadius_MD;
        self.maxChars = 500;
        self.editable = YES;
        [self addSubview:self.titleLabel];
        [self addSubview:self.sampleButton];
        [self addSubview:self.textView];
        [self.textView addSubview:self.placeholderLabel];
        [self addSubview:self.charCountLabel];
        [self refreshAffordances];
    }
    return self;
}

#pragma mark - 公开方法

- (void)setText:(NSString *)text {
    self.textView.text = text ?: @"";
    [self refreshAffordances];
}

- (NSString *)text {
    return self.textView.text ?: @"";
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.textView.editable = editable;
    self.sampleButton.enabled = editable;
    self.sampleButton.alpha = editable ? 1.f : 0.4f;
}

- (void)setMaxChars:(NSInteger)maxChars {
    _maxChars = maxChars;
    self.placeholderLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_tts.source_placeholder"), (long)maxChars];
    [self refreshAffordances];
}

- (void)resignTextEditing {
    [self.textView resignFirstResponder];
}

- (NSString *)trimmedText {
    return [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat pad = TSSpacing_SM;
    CGFloat headerH = 22.f;
    CGFloat charLabelH = 18.f;

    self.titleLabel.frame = CGRectMake(pad, pad, width - 80.f - pad * 2, headerH);
    self.sampleButton.frame = CGRectMake(width - 80.f - pad, pad, 80.f, headerH);

    CGFloat textY = pad + headerH + TSSpacing_XS;
    CGFloat textH = height - textY - charLabelH - pad;
    self.textView.frame = CGRectMake(pad, textY, width - pad * 2, textH);
    self.placeholderLabel.frame = CGRectMake(TSSpacing_XS, TSSpacing_XS,
                                              CGRectGetWidth(self.textView.bounds) - TSSpacing_XS * 2,
                                              20.f);
    self.charCountLabel.frame = CGRectMake(pad,
                                            height - charLabelH - pad / 2.f,
                                            width - pad * 2,
                                            charLabelH);
}

#pragma mark - 私有方法

/// 刷新字符数 + 占位符显隐
- (void)refreshAffordances {
    NSInteger length = (NSInteger)self.textView.text.length;
    self.charCountLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_tts.chars_fmt"),
                                 (long)length, (long)self.maxChars];
    if (length > self.maxChars) {
        self.charCountLabel.textColor = TSColor_Danger;
    } else if (length > self.maxChars - kTSAITTSInputWarnRemainder) {
        self.charCountLabel.textColor = TSColor_Warning;
    } else {
        self.charCountLabel.textColor = TSColor_TextSecondary;
    }
    self.placeholderLabel.hidden = (length > 0);
}

#pragma mark - 事件

- (void)onSampleTapped {
    [self.delegate inputCardDidTapSample:self];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self refreshAffordances];
    [self.delegate inputCardDidChangeText:self];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TSFont_H2;
        _titleLabel.textColor = TSColor_TextPrimary;
        _titleLabel.text = TSLocalizedString(@"ai_tts.source");
    }
    return _titleLabel;
}

- (UIButton *)sampleButton {
    if (!_sampleButton) {
        _sampleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sampleButton setTitle:TSLocalizedString(@"ai_tts.sample") forState:UIControlStateNormal];
        _sampleButton.titleLabel.font = TSFont_Caption;
        [_sampleButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _sampleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_sampleButton addTarget:self action:@selector(onSampleTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sampleButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.font = TSFont_Body;
        _textView.textColor = TSColor_TextPrimary;
        _textView.backgroundColor = TSColor_Background;
        _textView.layer.cornerRadius = TSRadius_SM;
        _textView.textContainerInset = UIEdgeInsetsMake(TSSpacing_XS, TSSpacing_XS, TSSpacing_XS, TSSpacing_XS);
        _textView.alwaysBounceVertical = YES;
    }
    return _textView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.font = TSFont_Body;
        _placeholderLabel.textColor = TSColor_TextSecondary;
        _placeholderLabel.userInteractionEnabled = NO;
    }
    return _placeholderLabel;
}

- (UILabel *)charCountLabel {
    if (!_charCountLabel) {
        _charCountLabel = [[UILabel alloc] init];
        _charCountLabel.font = TSFont_Caption;
        _charCountLabel.textColor = TSColor_TextSecondary;
        _charCountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _charCountLabel;
}

@end
