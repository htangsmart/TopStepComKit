//
//  TSAIQALogSheet.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQALogSheet.h"

#import "TSAIQATheme.h"

@interface TSAIQALogSheet ()

// 初始日志行
@property (nonatomic, copy) NSArray<NSString *> *initialLines;
// 标题
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
// 关闭
@property (nonatomic, strong) UIButton *closeButton;
// 日志文本
@property (nonatomic, strong) UITextView *textView;

@end

@implementation TSAIQALogSheet

#pragma mark - 生命周期

- (instancetype)initWithLines:(NSArray<NSString *> *)lines {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initialLines = [lines copy] ?: @[];
        self.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subtitleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.textView];
    self.textView.text = [self.initialLines componentsJoinedByString:@"\n"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat top = 18.0;
    self.titleLabel.frame = CGRectMake(18.0, top, width - 80.0, 22.0);
    self.subtitleLabel.frame = CGRectMake(18.0, top + 24.0, width - 80.0, 14.0);
    self.closeButton.frame = CGRectMake(width - 18.0 - 28.0, top, 28.0, 28.0);
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = self.view.safeAreaInsets.bottom;
    }
    self.textView.frame = CGRectMake(12.0, top + 50.0, width - 24.0,
                                     CGRectGetHeight(self.view.bounds) - top - 50.0 - bottom - 12.0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottom];
}

#pragma mark - 公开方法

/** 追加一行并滚到底 */
- (void)appendLine:(NSString *)line {
    if (line.length == 0) {
        return;
    }
    if (!self.isViewLoaded) {
        self.initialLines = [self.initialLines arrayByAddingObject:line];
        return;
    }
    NSString *current = self.textView.text ?: @"";
    self.textView.text = current.length > 0 ? [current stringByAppendingFormat:@"\n%@", line] : line;
    [self scrollToBottom];
}

#pragma mark - 私有方法

/** 滚动到最新一行 */
- (void)scrollToBottom {
    NSUInteger length = self.textView.text.length;
    if (length > 0) {
        [self.textView scrollRangeToVisible:NSMakeRange(length - 1, 1)];
    }
}

#pragma mark - 事件

/** 关闭弹层 */
- (void)onCloseTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 属性（懒加载）

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"事件日志";
        _titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
        _titleLabel.textColor = TSAIQATextPrimaryColor();
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.text = @"主线程有序回调 · 文字问答与设备问答共用";
        _subtitleLabel.font = [UIFont systemFontOfSize:11.0];
        _subtitleLabel.textColor = TSAIQATextTertiaryColor();
    }
    return _subtitleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"×" forState:UIControlStateNormal];
        [_closeButton setTitleColor:TSAIQATextSecondaryColor() forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        _closeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.04];
        _closeButton.layer.cornerRadius = 14.0;
        [_closeButton addTarget:self action:@selector(onCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.font = TSAIQAMonoFont(10.5);
        _textView.textColor = TSAIQATextSecondaryColor();
        _textView.backgroundColor = TSAIQAPageBackgroundColor();
        _textView.layer.cornerRadius = 12.0;
        _textView.textContainerInset = UIEdgeInsetsMake(10.0, 8.0, 10.0, 8.0);
    }
    return _textView;
}

@end
