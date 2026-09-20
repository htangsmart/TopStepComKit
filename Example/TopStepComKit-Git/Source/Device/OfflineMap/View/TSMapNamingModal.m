//
//  TSMapNamingModal.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMapNamingModal.h"

#import "TSRootVC.h"

/// 输入框最大字符数
static const NSInteger kTSMapNameMaxLength = 20;
/// 弹窗卡片宽度
static const CGFloat kTSModalWidth = 280.f;

@interface TSMapNamingModal () <UITextFieldDelegate>

// 半透明遮罩
@property (nonatomic, strong) UIView *backdropView;
// 卡片容器
@property (nonatomic, strong) UIView *card;
// 输入框
@property (nonatomic, strong) UITextField *nameField;
// 内联错误提示
@property (nonatomic, strong) UILabel *hintLabel;
// 当前键盘高度（相对自身坐标）
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation TSMapNamingModal

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ts_buildUI];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ts_keyboardWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 公开方法

/// 展示弹窗
- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:self];

    self.backdropView.alpha = 0.f;
    self.card.alpha = 0.f;
    self.card.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:0.2 animations:^{
        self.backdropView.alpha = 1.f;
        self.card.alpha = 1.f;
        self.card.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.nameField becomeFirstResponder];
    }];
}

/// 展示内联错误
- (void)showError:(NSString *)errorText {
    self.hintLabel.text = errorText;
    self.hintLabel.hidden = (errorText.length == 0);
}

/// 关闭弹窗
- (void)dismiss {
    [self.nameField resignFirstResponder];
    [UIView animateWithDuration:0.18 animations:^{
        self.backdropView.alpha = 0.f;
        self.card.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 私有方法

/// 构建 UI
- (void)ts_buildUI {
    self.backdropView = [[UIView alloc] initWithFrame:self.bounds];
    self.backdropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backdropView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    [self addSubview:self.backdropView];

    self.card = [[UIView alloc] init];
    self.card.backgroundColor = TSColor_Card;
    self.card.layer.cornerRadius = 14.f;
    self.card.layer.masksToBounds = YES;
    [self addSubview:self.card];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TSLocalizedString(@"offline_map.naming.title");
    titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold];
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.card addSubview:titleLabel];

    self.nameField = [[UITextField alloc] init];
    self.nameField.placeholder = TSLocalizedString(@"offline_map.naming.placeholder");
    self.nameField.font = [UIFont systemFontOfSize:14.f];
    self.nameField.textColor = TSColor_TextPrimary;
    self.nameField.borderStyle = UITextBorderStyleNone;
    self.nameField.layer.borderColor = TSColor_Separator.CGColor;
    self.nameField.layer.borderWidth = 0.5f;
    self.nameField.layer.cornerRadius = 6.f;
    self.nameField.delegate = self;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.returnKeyType = UIReturnKeyDone;
    // 左内边距
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.f, 1.f)];
    self.nameField.leftView = padding;
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    [self.card addSubview:self.nameField];

    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.font = [UIFont systemFontOfSize:11.f];
    self.hintLabel.textColor = TSColor_Danger;
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.hidden = YES;
    [self.card addSubview:self.hintLabel];

    UIView *hLine = [[UIView alloc] init];
    hLine.backgroundColor = TSColor_Separator;
    [self.card addSubview:hLine];

    UIView *vLine = [[UIView alloc] init];
    vLine.backgroundColor = TSColor_Separator;
    [self.card addSubview:vLine];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:TSLocalizedString(@"general.cancel") forState:UIControlStateNormal];
    [cancelButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [cancelButton addTarget:self action:@selector(ts_cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:cancelButton];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmButton setTitle:TSLocalizedString(@"offline_map.naming.confirm") forState:UIControlStateNormal];
    [confirmButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold];
    [confirmButton addTarget:self action:@selector(ts_confirmTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:confirmButton];

    [self ts_layoutCardWithTitle:titleLabel hLine:hLine vLine:vLine cancel:cancelButton confirm:confirmButton];
}

/// 布局卡片内部元素
- (void)ts_layoutCardWithTitle:(UILabel *)titleLabel
                         hLine:(UIView *)hLine
                         vLine:(UIView *)vLine
                        cancel:(UIButton *)cancelButton
                       confirm:(UIButton *)confirmButton {
    CGFloat pad = 16.f;
    CGFloat width = kTSModalWidth;
    CGFloat y = 20.f;

    titleLabel.frame = CGRectMake(pad, y, width - pad * 2, 22.f);
    y += 22.f + 14.f;

    self.nameField.frame = CGRectMake(pad, y, width - pad * 2, 36.f);
    y += 36.f + 6.f;

    // 错误提示占位高度（动态展示，但预留一行）
    self.hintLabel.frame = CGRectMake(pad, y, width - pad * 2, 16.f);
    y += 16.f + 12.f;

    CGFloat buttonH = 44.f;
    hLine.frame = CGRectMake(0, y, width, 0.5f);
    self.card.frame = CGRectMake(0, 0, width, y + buttonH);

    cancelButton.frame = CGRectMake(0, y, width / 2.f, buttonH);
    confirmButton.frame = CGRectMake(width / 2.f, y, width / 2.f, buttonH);
    vLine.frame = CGRectMake(width / 2.f, y, 0.5f, buttonH);
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    [self ts_recenterCard];
}

/// 将卡片居中于键盘上方的可视区
- (void)ts_recenterCard {
    CGFloat availableHeight = self.bounds.size.height - self.keyboardHeight;
    if (availableHeight < self.card.bounds.size.height) {
        availableHeight = self.bounds.size.height;
    }
    self.card.center = CGPointMake(self.bounds.size.width / 2.f, availableHeight / 2.f);
}

#pragma mark - 键盘

/// 键盘弹出/收起时，重新居中卡片
- (void)ts_keyboardWillChange:(NSNotification *)note {
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect endInSelf = [self convertRect:endFrame fromView:nil];
    CGFloat overlap = CGRectGetHeight(self.bounds) - CGRectGetMinY(endInSelf);
    self.keyboardHeight = MAX(0.f, overlap);

    NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self ts_recenterCard];
    }];
}

#pragma mark - 事件

- (void)ts_cancelTapped {
    [self dismiss];
}

- (void)ts_confirmTapped {
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.onConfirm) self.onConfirm(name);
}

#pragma mark - UITextFieldDelegate

/// 限制最大长度
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (string.length == 0) return YES;  // 允许删除
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return result.length <= kTSMapNameMaxLength;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self ts_confirmTapped];
    return NO;
}

@end
