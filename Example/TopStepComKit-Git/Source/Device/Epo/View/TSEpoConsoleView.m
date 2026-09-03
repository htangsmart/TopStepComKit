//
//  TSEpoConsoleView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSEpoConsoleView.h"
#import "TSBaseVC.h"

static const CGFloat kTitleH   = 42.f;
static const CGFloat kConsoleH = 150.f;
static const CGFloat kPad      = 16.f;

@interface TSEpoConsoleView ()

@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UIButton   *clearButton;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation TSEpoConsoleView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCardStyle];
        [self addSubview:self.titleLabel];
        [self addSubview:self.clearButton];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat innerW = w - kPad * 2;
    self.titleLabel.frame  = CGRectMake(kPad, 14.f, innerW - 60.f, 18.f);
    self.clearButton.frame = CGRectMake(w - kPad - 60.f, 10.f, 60.f, 26.f);
    self.textView.frame    = CGRectMake(kPad, kTitleH, innerW, kConsoleH);
}

#pragma mark - 公开方法

+ (CGFloat)cardHeight {
    return kTitleH + kConsoleH + 14.f;
}

/**
 * 追加一条带时间戳、按类型着色的日志
 */
- (void)appendLog:(NSString *)message type:(TSEpoLogType)type {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
    });

    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [formatter stringFromDate:[NSDate date]], message];
    NSDictionary *attrs = @{NSForegroundColorAttributeName: [self colorForType:type],
                            NSFontAttributeName: [self monoFont]};

    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributed appendAttributedString:[[NSAttributedString alloc] initWithString:line attributes:attrs]];
    self.textView.attributedText = attributed;

    NSUInteger length = self.textView.text.length;
    if (length > 0) {
        [self.textView scrollRangeToVisible:NSMakeRange(length - 1, 1)];
    }
}

#pragma mark - 私有方法

- (void)setupCardStyle {
    self.backgroundColor = TSColor_Card;
    self.layer.cornerRadius = 12.f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.05f;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 6.f;
}

- (void)onClearTapped {
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:@""];
    [self appendLog:TSLocalizedString(@"epo.console.cleared") type:TSEpoLogTypeInfo];
}

- (UIColor *)colorForType:(TSEpoLogType)type {
    switch (type) {
        case TSEpoLogTypeSuccess: return [UIColor colorWithRed:0.37f green:0.82f blue:0.54f alpha:1.f];
        case TSEpoLogTypeError:   return [UIColor colorWithRed:1.f green:0.42f blue:0.38f alpha:1.f];
        case TSEpoLogTypeWarning: return [UIColor colorWithRed:1.f green:0.76f blue:0.30f alpha:1.f];
        case TSEpoLogTypeInfo:
        default:                  return [UIColor colorWithRed:0.50f green:0.69f blue:1.f alpha:1.f];
    }
}

- (UIFont *)monoFont {
    return [UIFont fontWithName:@"Menlo" size:11.f] ?: [UIFont systemFontOfSize:11.f];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = TSLocalizedString(@"epo.console_title");
        _titleLabel.font = TSFont_Body;
        _titleLabel.textColor = TSColor_TextSecondary;
    }
    return _titleLabel;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearButton setTitle:TSLocalizedString(@"epo.console_clear") forState:UIControlStateNormal];
        [_clearButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _clearButton.titleLabel.font = TSFont_Body;
        _clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_clearButton addTarget:self action:@selector(onClearTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor colorWithRed:28/255.f green:28/255.f blue:34/255.f alpha:1.f];
        _textView.layer.cornerRadius = 10.f;
        _textView.editable = NO;
        _textView.textContainerInset = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
    }
    return _textView;
}

@end
