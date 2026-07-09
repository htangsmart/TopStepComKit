//
//  TSAIChatReportDialog.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatReportDialog.h"

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

#import "TSRootVC.h"

/// iOS 13+ 用系统等宽字体；iOS 12 回退到 Menlo
static inline UIFont *TSAIChatMonoFont(CGFloat size, UIFontWeight weight) {
    if (@available(iOS 13.0, *)) {
        return [UIFont monospacedSystemFontOfSize:size weight:weight];
    }
    return [UIFont fontWithName:@"Menlo" size:size] ?: [UIFont systemFontOfSize:size weight:weight];
}

@interface TSAIChatReportDialog ()

@property (nonatomic, strong) TSAIChatReport *report;
@property (nonatomic, copy, nullable) NSString *errorMessage;

@property (nonatomic, strong) UIView   *cardView;
@property (nonatomic, strong) UIView   *iconView;
@property (nonatomic, strong) UILabel  *iconLabel;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIStackView *rowStack;
@property (nonatomic, strong) UILabel  *taskIdLabel;
@property (nonatomic, strong) UIButton *copyButton;
@property (nonatomic, strong) UIButton *dismissButton;

@end

@implementation TSAIChatReportDialog

#pragma mark - 生命周期

- (instancetype)initWithReport:(TSAIChatReport *)report errorMessage:(NSString *)errorMessage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _report = report;
        _errorMessage = [errorMessage copy];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];

    [self.view addSubview:self.cardView];
    [self.cardView addSubview:self.iconView];
    [self.iconView addSubview:self.iconLabel];
    [self.cardView addSubview:self.titleLabel];
    [self.cardView addSubview:self.rowStack];
    [self.cardView addSubview:self.taskIdLabel];
    [self.cardView addSubview:self.copyButton];
    [self.cardView addSubview:self.dismissButton];

    [self setupConstraints];
    [self renderReport];
}

#pragma mark - 公开方法 / 无

#pragma mark - 私有方法

- (void)setupConstraints {
    self.cardView.translatesAutoresizingMaskIntoConstraints      = NO;
    self.iconView.translatesAutoresizingMaskIntoConstraints      = NO;
    self.iconLabel.translatesAutoresizingMaskIntoConstraints     = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints    = NO;
    self.rowStack.translatesAutoresizingMaskIntoConstraints      = NO;
    self.taskIdLabel.translatesAutoresizingMaskIntoConstraints   = NO;
    self.copyButton.translatesAutoresizingMaskIntoConstraints    = NO;
    self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.cardView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.cardView.widthAnchor   constraintEqualToAnchor:self.view.widthAnchor multiplier:0.86f],

        [self.iconView.topAnchor      constraintEqualToAnchor:self.cardView.topAnchor constant:24.f],
        [self.iconView.centerXAnchor  constraintEqualToAnchor:self.cardView.centerXAnchor],
        [self.iconView.widthAnchor    constraintEqualToConstant:56.f],
        [self.iconView.heightAnchor   constraintEqualToConstant:56.f],

        [self.iconLabel.centerXAnchor constraintEqualToAnchor:self.iconView.centerXAnchor],
        [self.iconLabel.centerYAnchor constraintEqualToAnchor:self.iconView.centerYAnchor],

        [self.titleLabel.topAnchor      constraintEqualToAnchor:self.iconView.bottomAnchor constant:12.f],
        [self.titleLabel.leadingAnchor  constraintEqualToAnchor:self.cardView.leadingAnchor  constant:24.f],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-24.f],

        [self.rowStack.topAnchor      constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:16.f],
        [self.rowStack.leadingAnchor  constraintEqualToAnchor:self.cardView.leadingAnchor  constant:24.f],
        [self.rowStack.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-24.f],

        [self.taskIdLabel.topAnchor      constraintEqualToAnchor:self.rowStack.bottomAnchor constant:12.f],
        [self.taskIdLabel.leadingAnchor  constraintEqualToAnchor:self.cardView.leadingAnchor  constant:24.f],
        [self.taskIdLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-24.f],

        [self.copyButton.topAnchor     constraintEqualToAnchor:self.taskIdLabel.bottomAnchor constant:16.f],
        [self.copyButton.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor   constant:24.f],
        [self.copyButton.heightAnchor  constraintEqualToConstant:42.f],

        [self.dismissButton.topAnchor      constraintEqualToAnchor:self.copyButton.topAnchor],
        [self.dismissButton.leadingAnchor  constraintEqualToAnchor:self.copyButton.trailingAnchor constant:8.f],
        [self.dismissButton.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor    constant:-24.f],
        [self.dismissButton.heightAnchor   constraintEqualToConstant:42.f],
        [self.dismissButton.widthAnchor    constraintEqualToAnchor:self.copyButton.widthAnchor],

        [self.copyButton.bottomAnchor constraintEqualToAnchor:self.cardView.bottomAnchor constant:-24.f],
    ]];
}

- (void)renderReport {
    BOOL isError = (self.report.endReason == TSAIChatEndReasonError) || self.errorMessage.length > 0;

    self.iconLabel.text = isError ? @"!" : @"✓";
    self.iconView.backgroundColor = isError
        ? [TSColor_Danger colorWithAlphaComponent:0.15f]
        : [TSColor_Success colorWithAlphaComponent:0.15f];
    self.iconLabel.textColor = isError ? TSColor_Danger : TSColor_Success;
    self.titleLabel.text = isError ? @"会话异常结束" : @"会话结束";

    [self.rowStack addArrangedSubview:[self rowWithKey:@"结束原因"
                                                 value:[self readableEndReason:self.report.endReason]]];
    [self.rowStack addArrangedSubview:[self rowWithKey:@"开始时间"
                                                 value:[self formatTime:self.report.startTime]]];
    [self.rowStack addArrangedSubview:[self rowWithKey:@"结束时间"
                                                 value:[self formatTime:self.report.endTime]]];
    [self.rowStack addArrangedSubview:[self rowWithKey:@"会话时长"
                                                 value:[NSString stringWithFormat:@"%.1f 秒", self.report.duration]]];
    [self.rowStack addArrangedSubview:[self rowWithKey:@"问答轮次"
                                                 value:[NSString stringWithFormat:@"%ld 轮", (long)self.report.roundCount]]];
    if (self.errorMessage.length > 0) {
        UIView *errRow = [self rowWithKey:@"错误信息" value:self.errorMessage];
        for (UIView *sub in errRow.subviews) {
            if ([sub isKindOfClass:[UILabel class]] && sub.tag == 2) {
                ((UILabel *)sub).textColor = TSColor_Danger;
            }
        }
        [self.rowStack addArrangedSubview:errRow];
    }

    self.taskIdLabel.text = [NSString stringWithFormat:@"taskId: %@", self.report.taskId ?: @"-"];
}

/// 单行 key/value，左 secondary 右 primary
- (UIView *)rowWithKey:(NSString *)key value:(NSString *)value {
    UIView *row = [[UIView alloc] init];

    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.font = TSFont_Caption;
    keyLabel.textColor = TSColor_TextSecondary;
    keyLabel.text = key;
    keyLabel.tag = 1;
    keyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:keyLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.font = TSFont_Body;
    valueLabel.textColor = TSColor_TextPrimary;
    valueLabel.text = value;
    valueLabel.tag = 2;
    valueLabel.numberOfLines = 0;
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:valueLabel];

    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = TSColor_Separator;
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:separator];

    [NSLayoutConstraint activateConstraints:@[
        [keyLabel.topAnchor      constraintEqualToAnchor:row.topAnchor constant:6.f],
        [keyLabel.leadingAnchor  constraintEqualToAnchor:row.leadingAnchor],

        [valueLabel.topAnchor      constraintEqualToAnchor:row.topAnchor constant:6.f],
        [valueLabel.leadingAnchor  constraintEqualToAnchor:keyLabel.trailingAnchor constant:8.f],
        [valueLabel.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [valueLabel.bottomAnchor   constraintEqualToAnchor:row.bottomAnchor constant:-6.f],

        [separator.heightAnchor    constraintEqualToConstant:0.5f],
        [separator.leadingAnchor   constraintEqualToAnchor:row.leadingAnchor],
        [separator.trailingAnchor  constraintEqualToAnchor:row.trailingAnchor],
        [separator.bottomAnchor    constraintEqualToAnchor:row.bottomAnchor],
    ]];

    return row;
}

- (NSString *)readableEndReason:(TSAIChatEndReason)reason {
    switch (reason) {
        case TSAIChatEndReasonUserStop:  return @"用户主动结束";
        case TSAIChatEndReasonTimeout:   return @"超时自动结束";
        case TSAIChatEndReasonCancelled: return @"用户取消";
        case TSAIChatEndReasonError:     return @"运行出错";
        default: return @"未知";
    }
}

- (NSString *)formatTime:(NSDate *)date {
    if (!date) return @"-";
    static NSDateFormatter *fmt;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"HH:mm:ss";
    });
    return [fmt stringFromDate:date];
}

#pragma mark - 事件

- (void)onCopyTapped {
    NSString *json = [self buildReportJSONString];
    [UIPasteboard generalPasteboard].string = json;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:@"已复制到剪贴板"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)onDismissTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 把 report 拼成可读 JSON 字符串
- (NSString *)buildReportJSONString {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"taskId"]    = self.report.taskId ?: @"";
    dict[@"startTime"] = [self formatTime:self.report.startTime];
    dict[@"endTime"]   = [self formatTime:self.report.endTime];
    dict[@"duration"]  = @(self.report.duration);
    dict[@"roundCount"] = @(self.report.roundCount);
    dict[@"endReason"] = [self readableEndReason:self.report.endReason];
    if (self.errorMessage.length > 0) dict[@"errorMessage"] = self.errorMessage;

    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&err];
    if (err || data.length == 0) return [dict description];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - 属性（懒加载）

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = TSColor_Card;
        _cardView.layer.cornerRadius = 18.f;
    }
    return _cardView;
}

- (UIView *)iconView {
    if (!_iconView) {
        _iconView = [[UIView alloc] init];
        _iconView.layer.cornerRadius = 28.f;
    }
    return _iconView;
}

- (UILabel *)iconLabel {
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] init];
        _iconLabel.font = [UIFont systemFontOfSize:30.f weight:UIFontWeightBold];
    }
    return _iconLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TSFont_H1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = TSColor_TextPrimary;
    }
    return _titleLabel;
}

- (UIStackView *)rowStack {
    if (!_rowStack) {
        _rowStack = [[UIStackView alloc] init];
        _rowStack.axis = UILayoutConstraintAxisVertical;
        _rowStack.alignment = UIStackViewAlignmentFill;
        _rowStack.spacing = 0.f;
    }
    return _rowStack;
}

- (UILabel *)taskIdLabel {
    if (!_taskIdLabel) {
        _taskIdLabel = [[UILabel alloc] init];
        _taskIdLabel.font = TSAIChatMonoFont(11.f, UIFontWeightRegular);
        _taskIdLabel.textColor = TSColor_TextSecondary;
        _taskIdLabel.numberOfLines = 0;
    }
    return _taskIdLabel;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_copyButton setTitle:@"复制 JSON" forState:UIControlStateNormal];
        _copyButton.titleLabel.font = TSFont_H2;
        [_copyButton setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
        _copyButton.backgroundColor = TSColor_Background;
        _copyButton.layer.cornerRadius = TSRadius_SM;
        [_copyButton addTarget:self
                        action:@selector(onCopyTapped)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _copyButton;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_dismissButton setTitle:@"好的" forState:UIControlStateNormal];
        _dismissButton.titleLabel.font = TSFont_H2;
        [_dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _dismissButton.backgroundColor = TSColor_Primary;
        _dismissButton.layer.cornerRadius = TSRadius_SM;
        [_dismissButton addTarget:self
                           action:@selector(onDismissTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

@end
