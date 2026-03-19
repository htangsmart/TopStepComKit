//
//  TSLockEditorVC.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSLockEditorVC.h"
#import "TSLockPasswordValidator.h"
#import "TSLockEditorSaveService.h"

static const CGFloat kPadding         = TSSpacing_MD;
static const CGFloat kFieldHeight     = 48.f;
static const CGFloat kPickerHeight    = 160.f;
static const NSInteger kMaxPasswordLength = 6;

@interface TSLockEditorVC () <UITextFieldDelegate>

// 密码输入框
@property (nonatomic, strong) UITextField *passwordField;
// 密码格式提示
@property (nonatomic, strong) UILabel *passwordHintLabel;
// 游戏锁：开始时间标签
@property (nonatomic, strong) UILabel *startLabel;
// 游戏锁：开始时间选择器
@property (nonatomic, strong) UIDatePicker *startPicker;
// 游戏锁：结束时间标签
@property (nonatomic, strong) UILabel *endLabel;
// 游戏锁：结束时间选择器
@property (nonatomic, strong) UIDatePicker *endPicker;

@end

@implementation TSLockEditorVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    self.title = self.pageTitle.length > 0 ? self.pageTitle : TSLocalizedString(@"lock.password");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.cancel")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(ts_cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"lock.save")
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(ts_save)];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:self.passwordHintLabel];
    if (!self.isScreenLock) {
        [self.view addSubview:self.startLabel];
        [self.view addSubview:self.startPicker];
        [self.view addSubview:self.endLabel];
        [self.view addSubview:self.endPicker];
    }
    [self ts_loadInitialValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self ts_loadInitialValues];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.passwordField becomeFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat top = self.view.safeAreaInsets.top + TSSpacing_SM;
    CGFloat w = self.view.bounds.size.width - kPadding * 2;
    _passwordField.frame = CGRectMake(kPadding, top, w, kFieldHeight);
    _passwordHintLabel.frame = CGRectMake(kPadding, CGRectGetMaxY(_passwordField.frame) + TSSpacing_XS, w, 20.f);
    if (!self.isScreenLock) {
        CGFloat y = CGRectGetMaxY(_passwordHintLabel.frame) + TSSpacing_MD;
        _startLabel.frame = CGRectMake(kPadding, y, w, 22.f);
        y = CGRectGetMaxY(_startLabel.frame) + TSSpacing_XS;
        _startPicker.frame = CGRectMake(kPadding, y, w, kPickerHeight);
        y = CGRectGetMaxY(_startPicker.frame) + TSSpacing_MD;
        _endLabel.frame = CGRectMake(kPadding, y, w, 22.f);
        y = CGRectGetMaxY(_endLabel.frame) + TSSpacing_XS;
        _endPicker.frame = CGRectMake(kPadding, y, w, kPickerHeight);
    }
}

#pragma mark - 私有方法

/**
 * 将外部传入的初始值填充到输入框和时间选择器
 */
- (void)ts_loadInitialValues {
    if (self.initialPassword.length > 0) {
        self.passwordField.text = self.initialPassword;
    }
    if (self.isScreenLock) return;
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    self.startPicker.date = [self ts_dateFromMinutes:self.initialStartMinutes calendar:cal baseDate:today] ?: today;
    NSInteger clampedEnd = [self ts_clampEndMinutes:self.initialEndMinutes];
    self.endPicker.date = [self ts_dateFromMinutes:clampedEnd calendar:cal baseDate:today] ?: today;
}

/**
 * 将分钟数转换为当天对应时刻的 NSDate
 */
- (nullable NSDate *)ts_dateFromMinutes:(NSInteger)minutes calendar:(NSCalendar *)cal baseDate:(NSDate *)baseDate {
    NSDateComponents *c = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:baseDate];
    c.hour = minutes / 60;
    c.minute = minutes % 60;
    return [cal dateFromComponents:c];
}

/**
 * 将结束分钟数限制在合法范围内（最大 23:59）
 */
- (NSInteger)ts_clampEndMinutes:(NSInteger)endMinutes {
    NSInteger maxMinutes = 23 * 60 + 59;
    return (endMinutes >= 24 * 60) ? maxMinutes : endMinutes;
}

/**
 * 从日期取"距 0 点分钟数"
 */
- (NSInteger)ts_minutesFromMidnightForDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *c = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    return (NSInteger)c.hour * 60 + (NSInteger)c.minute;
}

/**
 * 显示密码格式提示弹窗
 */
- (void)ts_showPasswordHintAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"general.hint")
                                                                   message:TSLocalizedString(@"lock.password_hint")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 显示保存失败错误弹窗
 */
- (void)ts_showErrorAlert:(NSError * _Nullable)error {
    NSString *msg = error.localizedDescription.length > 0 ? error.localizedDescription : TSLocalizedString(@"lock.save_failed");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"general.hint")
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 进入保存中状态：右上角替换为 loading
 */
- (void)ts_startSavingState {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [indicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
}

/**
 * 结束保存中状态：恢复保存按钮
 */
- (void)ts_stopSavingState {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"lock.save")
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(ts_save)];
}

#pragma mark - 取消与保存

/**
 * 取消：回调后 dismiss
 */
- (void)ts_cancel {
    if (self.onCancel) self.onCancel();
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 * 保存流程：校验输入 → 调保存服务 → 根据结果更新 UI
 */
- (void)ts_save {
    NSString *raw = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [TSLockPasswordValidator validatedPasswordFromRawInput:raw];
    if (!password) {
        [self ts_showPasswordHintAlert];
        return;
    }

    NSInteger start = 0, end = 0;
    if (!self.isScreenLock) {
        start = [self ts_minutesFromMidnightForDate:self.startPicker.date];
        end = [self ts_minutesFromMidnightForDate:self.endPicker.date];
    }

    [self ts_startSavingState];
    __weak typeof(self) weakSelf = self;
    [TSLockEditorSaveService saveWithScreenLock:self.isScreenLock
                                      password:password
                                 startMinutes:start
                                   endMinutes:end
                                   completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            if (weakSelf.onSave) weakSelf.onSave(password, start, end);
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [weakSelf ts_stopSavingState];
            [weakSelf ts_showErrorAlert:error];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length > kMaxPasswordLength) return NO;
    return [string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound;
}

#pragma mark - 属性（懒加载）

- (UITextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[UITextField alloc] init];
        _passwordField.placeholder = TSLocalizedString(@"lock.password_placeholder");
        _passwordField.font = TSFont_Body;
        _passwordField.textColor = TSColor_TextPrimary;
        _passwordField.secureTextEntry = NO;
        _passwordField.keyboardType = UIKeyboardTypeNumberPad;
        _passwordField.backgroundColor = TSColor_Card;
        _passwordField.layer.cornerRadius = TSRadius_SM;
        _passwordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TSSpacing_SM, 1)];
        _passwordField.leftViewMode = UITextFieldViewModeAlways;
        _passwordField.delegate = self;
    }
    return _passwordField;
}

- (UILabel *)passwordHintLabel {
    if (!_passwordHintLabel) {
        _passwordHintLabel = [[UILabel alloc] init];
        _passwordHintLabel.text = TSLocalizedString(@"lock.password_hint");
        _passwordHintLabel.font = TSFont_Caption;
        _passwordHintLabel.textColor = TSColor_TextSecondary;
    }
    return _passwordHintLabel;
}

- (UILabel *)startLabel {
    if (!_startLabel) {
        _startLabel = [[UILabel alloc] init];
        _startLabel.text = TSLocalizedString(@"lock.effective_time");
        _startLabel.font = TSFont_Caption;
        _startLabel.textColor = TSColor_TextSecondary;
    }
    return _startLabel;
}

- (UIDatePicker *)startPicker {
    if (!_startPicker) {
        _startPicker = [[UIDatePicker alloc] init];
        _startPicker.datePickerMode = UIDatePickerModeTime;
        if (@available(iOS 13.4, *)) _startPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    return _startPicker;
}

- (UILabel *)endLabel {
    if (!_endLabel) {
        _endLabel = [[UILabel alloc] init];
        _endLabel.text = TSLocalizedString(@"lock.effective_time");
        _endLabel.font = TSFont_Caption;
        _endLabel.textColor = TSColor_TextSecondary;
    }
    return _endLabel;
}

- (UIDatePicker *)endPicker {
    if (!_endPicker) {
        _endPicker = [[UIDatePicker alloc] init];
        _endPicker.datePickerMode = UIDatePickerModeTime;
        if (@available(iOS 13.4, *)) _endPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    return _endPicker;
}

@end
