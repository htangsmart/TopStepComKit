//
//  TSAIQAComposerView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQAComposerView.h"

#import "TSAIQATheme.h"

static const CGFloat kTSAIQAComposerFieldMinHeight = 44.0;
static const CGFloat kTSAIQAComposerFieldMaxHeight = 110.0;
static const CGFloat kTSAIQAComposerButtonSize = 44.0;

@interface TSAIQAComposerView () <UITextViewDelegate>

// 提示行
@property (nonatomic, strong) UILabel *hintLabel;
// 输入框
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
// 发送 / 停止
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIView *stopSquare;
@property (nonatomic, strong) UILabel *sendGlyphLabel;
// 顶部分割线
@property (nonatomic, strong) UIView *topLine;
// 当前输入框高度
@property (nonatomic, assign) CGFloat fieldHeight;

@end

@implementation TSAIQAComposerView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIQAPageBackgroundColor() colorWithAlphaComponent:0.96];
        _fieldHeight = kTSAIQAComposerFieldMinHeight;
        _inputEnabled = YES;
        [self addSubview:self.topLine];
        [self addSubview:self.hintLabel];
        [self addSubview:self.textView];
        [self.textView addSubview:self.placeholderLabel];
        [self addSubview:self.actionButton];
        [self.actionButton addSubview:self.sendGlyphLabel];
        [self.actionButton addSubview:self.stopSquare];
        [self applyStreamingAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.topLine.frame = CGRectMake(0, 0, width, 1.0);
    CGFloat y = 8.0;
    BOOL hasHint = (self.hint.length > 0);
    self.hintLabel.frame = CGRectMake(12.0, y, width - 24.0, hasHint ? 14.0 : 0);
    y += hasHint ? 20.0 : 0;
    self.actionButton.frame = CGRectMake(width - 12.0 - kTSAIQAComposerButtonSize,
                                         y + self.fieldHeight - kTSAIQAComposerButtonSize,
                                         kTSAIQAComposerButtonSize, kTSAIQAComposerButtonSize);
    self.sendGlyphLabel.frame = self.actionButton.bounds;
    self.stopSquare.frame = CGRectMake(14.0, 14.0, 16.0, 16.0);
    self.textView.frame = CGRectMake(12.0, y, width - 24.0 - kTSAIQAComposerButtonSize - 8.0, self.fieldHeight);
    self.placeholderLabel.frame = CGRectMake(16.0, 0, CGRectGetWidth(self.textView.bounds) - 32.0, kTSAIQAComposerFieldMinHeight);
}

#pragma mark - 公开方法

/** 不含安全区的高度 */
- (CGFloat)contentHeight {
    CGFloat height = 8.0 + self.fieldHeight + 8.0;
    if (self.hint.length > 0) {
        height += 20.0;
    }
    return height;
}

/** 收起键盘 */
- (void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

- (void)setStreaming:(BOOL)streaming {
    _streaming = streaming;
    [self applyStreamingAppearance];
}

- (void)setInputEnabled:(BOOL)inputEnabled {
    _inputEnabled = inputEnabled;
    [self applyStreamingAppearance];
}

- (void)setHint:(NSString *)hint {
    _hint = [hint copy];
    self.hintLabel.text = hint;
    [self setNeedsLayout];
    [self.delegate composerViewDidChangeHeight:self];
}

- (void)setText:(NSString *)text {
    self.textView.text = text ?: @"";
    [self textViewDidChange:self.textView];
}

- (NSString *)text {
    return self.textView.text ?: @"";
}

#pragma mark - 私有方法

/** 按流式状态与可用性刷新输入框与按钮 */
- (void)applyStreamingAppearance {
    BOOL editable = self.inputEnabled && !self.streaming;
    self.textView.editable = editable;
    self.textView.backgroundColor = editable ? [UIColor whiteColor]
                                             : [UIColor colorWithRed:0xF0 / 255.0 green:0xF1 / 255.0 blue:0xF6 / 255.0 alpha:1.0];
    self.sendGlyphLabel.hidden = self.streaming;
    self.stopSquare.hidden = !self.streaming;
    if (self.streaming) {
        self.actionButton.enabled = YES;
        self.actionButton.backgroundColor = TSAIQATextPrimaryColor();
    } else {
        BOOL hasText = ([self trimmedText].length > 0);
        self.actionButton.enabled = self.inputEnabled && hasText;
        self.actionButton.backgroundColor = self.actionButton.enabled
            ? TSAIQATintColor()
            : [UIColor colorWithRed:0xC9 / 255.0 green:0xCD / 255.0 blue:0xDC / 255.0 alpha:1.0];
    }
    self.actionButton.layer.shadowOpacity = self.actionButton.enabled ? 0.25 : 0;
}

/** 去除首尾空白的文本 */
- (NSString *)trimmedText {
    return [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ?: @"";
}

/** 根据内容更新输入框高度 */
- (void)updateFieldHeight {
    CGFloat width = CGRectGetWidth(self.textView.bounds);
    if (width <= 0) {
        return;
    }
    CGSize fitting = [self.textView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGFloat height = MAX(kTSAIQAComposerFieldMinHeight, MIN(kTSAIQAComposerFieldMaxHeight, ceil(fitting.height)));
    if (fabs(height - self.fieldHeight) < 0.5) {
        return;
    }
    self.fieldHeight = height;
    self.textView.scrollEnabled = (fitting.height > kTSAIQAComposerFieldMaxHeight);
    [self setNeedsLayout];
    [self.delegate composerViewDidChangeHeight:self];
}

#pragma mark - 事件

/** 点击发送或停止 */
- (void)onActionTapped {
    if (self.streaming) {
        [self.delegate composerViewDidTapStop:self];
        return;
    }
    NSString *text = [self trimmedText];
    if (text.length == 0) {
        return;
    }
    [self.delegate composerView:self didSubmitText:text];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = (textView.text.length > 0);
    [self applyStreamingAppearance];
    [self updateFieldHeight];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 回车发送，Shift 换行在 iOS 上不可区分，因此回车一律发送
    if ([text isEqualToString:@"\n"]) {
        [self onActionTapped];
        return NO;
    }
    return YES;
}

#pragma mark - 属性（懒加载）

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = TSAIQALineColor();
    }
    return _topLine;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = [UIFont systemFontOfSize:10.5];
        _hintLabel.textColor = TSAIQATextTertiaryColor();
        _hintLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hintLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textColor = TSAIQATextPrimaryColor();
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.cornerRadius = 22.0;
        _textView.layer.borderWidth = 1.0;
        _textView.layer.borderColor = TSAIQALineColor().CGColor;
        _textView.textContainerInset = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0);
        _textView.scrollEnabled = NO;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES;
    }
    return _textView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.text = @"输入问题…";
        _placeholderLabel.font = [UIFont systemFontOfSize:14.0];
        _placeholderLabel.textColor = TSAIQATextTertiaryColor();
    }
    return _placeholderLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.layer.cornerRadius = kTSAIQAComposerButtonSize / 2.0;
        _actionButton.layer.shadowColor = TSAIQATintColor().CGColor;
        _actionButton.layer.shadowRadius = 9.0;
        _actionButton.layer.shadowOffset = CGSizeMake(0, 6.0);
        [_actionButton addTarget:self action:@selector(onActionTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UILabel *)sendGlyphLabel {
    if (!_sendGlyphLabel) {
        _sendGlyphLabel = [[UILabel alloc] init];
        _sendGlyphLabel.text = @"↑";
        _sendGlyphLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
        _sendGlyphLabel.textColor = [UIColor whiteColor];
        _sendGlyphLabel.textAlignment = NSTextAlignmentCenter;
        _sendGlyphLabel.userInteractionEnabled = NO;
    }
    return _sendGlyphLabel;
}

- (UIView *)stopSquare {
    if (!_stopSquare) {
        _stopSquare = [[UIView alloc] init];
        _stopSquare.backgroundColor = [UIColor whiteColor];
        _stopSquare.layer.cornerRadius = 4.0;
        _stopSquare.userInteractionEnabled = NO;
        _stopSquare.hidden = YES;
    }
    return _stopSquare;
}

@end
