//
//  TSAILogView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAILogView.h"

@interface TSAILogView ()

@property (nonatomic, strong) UITextView       *logTextView;
@property (nonatomic, strong) UIButton         *clearButton;
@property (nonatomic, strong) UILabel          *titleLabel;
@property (nonatomic, strong) NSDateFormatter  *timestampFormatter;

@end

@implementation TSAILogView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;

        [self addSubview:self.titleLabel];
        [self addSubview:self.clearButton];
        [self addSubview:self.logTextView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat padding = 8.0;
    CGFloat headerHeight = 24.0;

    self.titleLabel.frame = CGRectMake(padding, padding,
                                        CGRectGetWidth(self.bounds) - padding * 2 - 60.0,
                                        headerHeight);
    self.clearButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 60.0 - padding, padding,
                                         60.0, headerHeight);
    self.logTextView.frame = CGRectMake(padding,
                                         padding + headerHeight + 4.0,
                                         CGRectGetWidth(self.bounds) - padding * 2,
                                         CGRectGetHeight(self.bounds) - headerHeight - padding * 3 - 4.0);
}

#pragma mark - 公开方法

- (void)appendLine:(NSString *)line {
    if (line.length == 0) return;

    NSString *timestamp = [self.timestampFormatter stringFromDate:[NSDate date]];
    NSString *fullLine = [NSString stringWithFormat:@"[%@] %@\n", timestamp, line];

    if ([NSThread isMainThread]) {
        [self appendOnMainThread:fullLine];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self appendOnMainThread:fullLine];
        });
    }
}

- (void)appendLineWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *line = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [self appendLine:line];
}

- (void)clear {
    if ([NSThread isMainThread]) {
        self.logTextView.text = @"";
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logTextView.text = @"";
        });
    }
}

#pragma mark - 私有方法

/// 主线程追加文本并滚动到底
- (void)appendOnMainThread:(NSString *)line {
    NSString *current = self.logTextView.text ?: @"";
    self.logTextView.text = [current stringByAppendingString:line];

    NSRange end = NSMakeRange(self.logTextView.text.length, 0);
    [self.logTextView scrollRangeToVisible:end];
}

/// 清空按钮回调
- (void)onClearButtonTapped {
    [self clear];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.text = @"Logs";
    }
    return _titleLabel;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        _clearButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_clearButton addTarget:self
                          action:@selector(onClearButtonTapped)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (UITextView *)logTextView {
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] init];
        _logTextView.editable = NO;
        _logTextView.backgroundColor = [UIColor whiteColor];
        _logTextView.font = [UIFont fontWithName:@"Menlo" size:11.0] ?: [UIFont systemFontOfSize:11.0];
        _logTextView.textColor = [UIColor blackColor];
        _logTextView.layer.cornerRadius = 4.0;
        _logTextView.alwaysBounceVertical = YES;
    }
    return _logTextView;
}

- (NSDateFormatter *)timestampFormatter {
    if (!_timestampFormatter) {
        _timestampFormatter = [[NSDateFormatter alloc] init];
        _timestampFormatter.dateFormat = @"HH:mm:ss.SSS";
    }
    return _timestampFormatter;
}

@end
