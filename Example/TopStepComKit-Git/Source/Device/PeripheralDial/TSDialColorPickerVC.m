//
//  TSDialColorPickerVC.m
//  TopStepComKit_Example
//

#import "TSDialColorPickerVC.h"
#import "TSDialEditorAppearance.h"

@interface TSDialColorPickerVC () <UIColorPickerViewControllerDelegate, UITextFieldDelegate>
// 临时颜色，确定前不更新宿主。
@property (nonatomic, strong) UIColor *pendingColor;
@property (nonatomic, copy) NSString *subtitle;
// 系统颜色面板。
@property (nonatomic, strong) UIViewController *pickerController;
// 共用确认取消按钮与数值输入。
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UITextField *hexField;
@property (nonatomic, strong) UIView *colorSample;
// 低版本调色网格。
@property (nonatomic, strong) UIView *fallbackGrid;
@property (nonatomic, strong) NSMutableArray<UIButton *> *gridButtons;
// 键盘遮挡高度。
@property (nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation TSDialColorPickerVC

#pragma mark - 生命周期

// 选色对象独立于时间或弹幕的具体业务。
- (instancetype)initWithColor:(UIColor *)color subtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        _pendingColor = color;
        _subtitle = [subtitle copy];
        self.modalPresentationStyle = UIModalPresentationPageSheet;
        self.preferredContentSize = CGSizeMake(394, 600);
    }
    return self;
}

// 每次安全区变化重新布局。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

// 释放键盘监听。
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 公开方法

// iOS 14 及以上直接复用系统选色器，保留显式确认。
- (void)setupViews {
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    self.view.backgroundColor = UIColor.whiteColor;
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelSelection) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmSelection) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.tintColor = self.confirmButton.tintColor = [TSDialEditorAppearance color:0x647757];
    self.titleLabel = [TSDialEditorAppearance label:@"颜色" size:17 color:0x252823];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel = [TSDialEditorAppearance label:self.subtitle size:11 color:0x93958E];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.hexField = [[UITextField alloc] init];
    self.hexField.delegate = self;
    self.hexField.borderStyle = UITextBorderStyleRoundedRect;
    self.hexField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.hexField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.hexField.returnKeyType = UIReturnKeyDone;
    self.hexField.text = [TSDialEditorAppearance hexFromColor:self.pendingColor];
    self.hexField.placeholder = @"6 位十六进制颜色";
    [self.hexField addTarget:self action:@selector(changeHex) forControlEvents:UIControlEventEditingChanged];
    self.colorSample = [[UIView alloc] init];
    self.colorSample.backgroundColor = self.pendingColor;
    self.colorSample.layer.cornerRadius = 20;
    self.colorSample.layer.borderColor = [TSDialEditorAppearance color:0xE9EAE4].CGColor;
    self.colorSample.layer.borderWidth = 1;
    for (UIView *view in @[self.cancelButton, self.confirmButton, self.titleLabel, self.subtitleLabel,
                          self.hexField, self.colorSample]) {
        [self.view addSubview:view];
    }
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.selectedColor = self.pendingColor;
        picker.supportsAlpha = NO;
        picker.delegate = self;
        self.pickerController = picker;
        [self addChildViewController:picker];
        [self.view addSubview:picker.view];
        [picker didMoveToParentViewController:self];
    } else {
        [self buildFallbackGrid];
    }
}

// 系统面板保留自身网格、光谱与滑块交互。
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds), height = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.view.safeAreaInsets.top;
    self.cancelButton.frame = CGRectMake(16, top + 8, 60, 44);
    self.confirmButton.frame = CGRectMake(width - 76, top + 8, 60, 44);
    self.titleLabel.frame = CGRectMake(80, top + 8, width - 160, 44);
    self.subtitleLabel.frame = CGRectMake(20, top + 52, width - 40, 22);
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, self.keyboardHeight);
    CGFloat inputTop = MAX(top + 90, height - bottomInset - 65);
    self.pickerController.view.frame = CGRectMake(0, top + 80, width, MAX(0, inputTop - top - 95));
    self.pickerController.view.clipsToBounds = YES;
    CGFloat gridWidth = width - 40;
    CGFloat gridHeight = MIN(240, MAX(0, inputTop - top - 105));
    self.fallbackGrid.frame = CGRectMake(20, top + 90, gridWidth, gridHeight);
    for (NSUInteger index = 0; index < self.gridButtons.count; index++) {
        self.gridButtons[index].frame = CGRectMake(index % 12 * gridWidth / 12, index / 12 * gridHeight / 10,
                                                   gridWidth / 12, gridHeight / 10);
    }
    self.colorSample.frame = CGRectMake(24, inputTop, 40, 40);
    self.hexField.frame = CGRectMake(80, inputTop, width - 104, 40);
}

#pragma mark - 私有方法

// HEX 输入始终位于键盘上方，取消与确定按钮保持可见。
- (void)keyboardChanged:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect local = [self.view convertRect:frame fromView:nil];
    self.keyboardHeight = CGRectGetHeight(CGRectIntersection(self.view.bounds, local));
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{ [self layoutViews]; }];
}

// 低版本提供真实可用的调色和 HEX 输入。
- (void)buildFallbackGrid {
    self.fallbackGrid = [[UIView alloc] init];
    self.gridButtons = [NSMutableArray array];
    [self.view addSubview:self.fallbackGrid];
    for (NSUInteger index = 0; index < 120; index++) {
        NSUInteger row = index / 12, column = index % 12;
        UIColor *color = row == 0 ? [UIColor colorWithWhite:1 - column / 11.0 alpha:1] :
            [UIColor colorWithHue:column / 12.0 saturation:row < 5 ? (row + 1) / 6.0 : 1
                       brightness:row < 5 ? 1 : 1 - (row - 4) * 0.14 alpha:1];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = color;
        [button addTarget:self action:@selector(selectGridColor:) forControlEvents:UIControlEventTouchUpInside];
        [self.fallbackGrid addSubview:button];
        [self.gridButtons addObject:button];
    }
}

// 网格选择只更新临时颜色。
- (void)selectGridColor:(UIButton *)sender {
    self.pendingColor = sender.backgroundColor;
    self.hexField.text = [TSDialEditorAppearance hexFromColor:self.pendingColor];
    self.colorSample.backgroundColor = self.pendingColor;
    self.confirmButton.enabled = YES;
}

// 非法颜色禁用确定，不能默默提交旧值。
- (void)changeHex {
    NSString *value = self.hexField.text;
    NSCharacterSet *invalid = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"] invertedSet];
    BOOL valid = value.length == 6 && [value rangeOfCharacterFromSet:invalid].location == NSNotFound;
    self.confirmButton.enabled = valid;
    if (valid) {
        self.pendingColor = [TSDialEditorAppearance colorFromHex:value];
        self.colorSample.backgroundColor = self.pendingColor;
        if (@available(iOS 14.0, *)) {
            ((UIColorPickerViewController *)self.pickerController).selectedColor = self.pendingColor;
        }
    }
}

// 取消完全不回传新颜色。
- (void)cancelSelection {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 确认后才通知宿主。
- (void)confirmSelection {
    if (!self.confirmButton.enabled) {
        return;
    }
    UIColor *color = self.pendingColor;
    void (^completion)(UIColor *) = self.onConfirm;
    [self dismissViewControllerAnimated:YES completion:^{
        if (completion) {
            completion(color);
        }
    }];
}

#pragma mark - Delegate

// 系统选择变化只存入临时副本。
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.pendingColor = viewController.selectedColor;
    self.hexField.text = [TSDialEditorAppearance hexFromColor:self.pendingColor];
    self.colorSample.backgroundColor = self.pendingColor;
    self.confirmButton.enabled = YES;
}

// 系统关闭不等于本页面确认。
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
}

// 收起 HEX 输入键盘。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
