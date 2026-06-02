//
//  TSAIStreamTextView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIStreamTextView.h"

@interface TSAIStreamTextView ()

@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UITextView *contentTextView;

@end

@implementation TSAIStreamTextView

@synthesize textColor = _textColor;
@synthesize contentBackgroundColor = _contentBackgroundColor;

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;

        [self addSubview:self.titleLabel];
        [self addSubview:self.contentTextView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat padding = 8.0;
    CGFloat headerHeight = 22.0;

    CGFloat accessoryWidth = 0.0;
    if (self.accessoryView && !self.accessoryView.hidden) {
        CGSize fit = [self.accessoryView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        accessoryWidth = MAX(fit.width, CGRectGetWidth(self.accessoryView.bounds));
        if (accessoryWidth <= 0) {
            accessoryWidth = 100.0;
        }
        accessoryWidth = MIN(accessoryWidth, CGRectGetWidth(self.bounds) * 0.6);
        self.accessoryView.frame = CGRectMake(CGRectGetWidth(self.bounds) - padding - accessoryWidth,
                                               padding,
                                               accessoryWidth,
                                               headerHeight);
        accessoryWidth += 8.0;
    }

    self.titleLabel.frame = CGRectMake(padding, padding,
                                        CGRectGetWidth(self.bounds) - padding * 2 - accessoryWidth,
                                        headerHeight);
    self.contentTextView.frame = CGRectMake(padding,
                                             padding + headerHeight + 4.0,
                                             CGRectGetWidth(self.bounds) - padding * 2,
                                             CGRectGetHeight(self.bounds) - headerHeight - padding * 3 - 4.0);
}

#pragma mark - 公开方法

- (void)reset {
    self.text = @"";
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
}

- (void)setText:(NSString *)text {
    _text = [text copy];

    if ([NSThread isMainThread]) {
        [self applyTextOnMainThread];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self applyTextOnMainThread];
        });
    }
}

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView == accessoryView) return;
    [_accessoryView removeFromSuperview];
    _accessoryView = accessoryView;
    if (accessoryView) {
        [self addSubview:accessoryView];
    }
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor ?: [UIColor blackColor];
    self.contentTextView.textColor = _textColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor {
    _contentBackgroundColor = contentBackgroundColor ?: [UIColor whiteColor];
    self.contentTextView.backgroundColor = _contentBackgroundColor;
}

- (UIColor *)contentBackgroundColor {
    if (!_contentBackgroundColor) {
        _contentBackgroundColor = [UIColor whiteColor];
    }
    return _contentBackgroundColor;
}

#pragma mark - 私有方法

/// 主线程刷新文本并滚到底
- (void)applyTextOnMainThread {
    self.contentTextView.text = self.text ?: @"";
    NSRange end = NSMakeRange(self.contentTextView.text.length, 0);
    [self.contentTextView scrollRangeToVisible:end];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor darkGrayColor];
    }
    return _titleLabel;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.editable = NO;
        _contentTextView.backgroundColor = [UIColor whiteColor];
        _contentTextView.font = [UIFont systemFontOfSize:14.0];
        _contentTextView.textColor = [UIColor blackColor];
        _contentTextView.layer.cornerRadius = 4.0;
        _contentTextView.alwaysBounceVertical = YES;
    }
    return _contentTextView;
}

@end
