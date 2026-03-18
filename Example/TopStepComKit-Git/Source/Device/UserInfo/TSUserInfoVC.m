//
//  TSUserInfoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSUserInfoVC.h"

// ── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kRowHeight      = 56.f;   // 表单每行高度
static const CGFloat kCardPadding    = 16.f;   // 卡片水平外边距 / 内边距
static const CGFloat kStepperBtnSize = 30.f;   // 步进按钮边长
static const CGFloat kCardCornerR    = 12.f;   // 卡片圆角
static const CGFloat kCardShadowR    = 6.f;    // 卡片阴影半径
static const CGFloat kFormRowCount   = 6.f;    // 表单行数（姓名/性别/年龄/身高/体重/BMI）

// ── 私有接口 ──────────────────────────────────────────────────────────────────
@interface TSUserInfoVC () <UITextFieldDelegate>

// 滚动容器
@property (nonatomic, strong) UIScrollView            *scrollView;

// 用户 ID 卡片（无 userId 时隐藏）
@property (nonatomic, strong) UIView                  *userIdCard;
@property (nonatomic, strong) UILabel                 *userIdTitleLabel;
@property (nonatomic, strong) UILabel                 *userIdValueLabel;

// 信息表单卡片
@property (nonatomic, strong) UIView                  *formCard;

// 姓名行
@property (nonatomic, strong) UILabel                 *nameTitleLabel;
@property (nonatomic, strong) UITextField             *nameTextField;

// 性别行
@property (nonatomic, strong) UILabel                 *genderTitleLabel;
@property (nonatomic, strong) UISegmentedControl      *genderSegment;

// 年龄行
@property (nonatomic, strong) UILabel                 *ageTitleLabel;
@property (nonatomic, strong) UILabel                 *ageValueLabel;
@property (nonatomic, strong) UIButton                *ageMinusBtn;
@property (nonatomic, strong) UIButton                *agePlusBtn;

// 身高行
@property (nonatomic, strong) UILabel                 *heightTitleLabel;
@property (nonatomic, strong) UILabel                 *heightValueLabel;
@property (nonatomic, strong) UIButton                *heightMinusBtn;
@property (nonatomic, strong) UIButton                *heightPlusBtn;

// 体重行
@property (nonatomic, strong) UILabel                 *weightTitleLabel;
@property (nonatomic, strong) UILabel                 *weightValueLabel;
@property (nonatomic, strong) UIButton                *weightMinusBtn;
@property (nonatomic, strong) UIButton                *weightPlusBtn;

// BMI 行（只读，随身高/体重实时更新）
@property (nonatomic, strong) UILabel                 *bmiTitleLabel;
@property (nonatomic, strong) UILabel                 *bmiValueLabel;
@property (nonatomic, strong) UILabel                 *bmiStatusLabel;

// 保存按钮（无改动时灰色禁用，有改动时蓝色高亮）
@property (nonatomic, strong) UIButton                *saveButton;

// 加载指示器
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// 当前表单状态
@property (nonatomic, assign) BOOL                    hasChanges;
@property (nonatomic, assign) NSInteger               currentAge;
@property (nonatomic, assign) NSInteger               currentHeight;
@property (nonatomic, assign) NSInteger               currentWeight;
@property (nonatomic, assign) TSUserGender            currentGender;

@end

// ── 实现 ──────────────────────────────────────────────────────────────────────
@implementation TSUserInfoVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];        // super 会依次调用 initData / setupViews / layoutViews
    // BMI 保持默认 "--"，等获取到用户信息后在 populateFormWithModel 里再计算并展示
    [self fetchUserInfo];       // 进入页面后自动从设备读取用户信息
}

#pragma mark - Override Base Setup

/**
 * 初始化数据，设置默认值
 */
- (void)initData {
    [super initData];
    self.title      = @"用户信息";
    _currentAge     = 25;
    _currentHeight  = 170;
    _currentWeight  = 65;
    _currentGender  = TSUserGenderMale;
    _hasChanges     = NO;
}

/**
 * 构建视图层级（替换父类 tableView，使用自定义 scrollView）
 */
- (void)setupViews {
    // 不调用 super，避免添加父类 tableView
    [self.view addSubview:self.scrollView];

    // 用户 ID 卡片
    [self.scrollView addSubview:self.userIdCard];
    [self.userIdCard addSubview:self.userIdTitleLabel];
    [self.userIdCard addSubview:self.userIdValueLabel];

    // 信息表单卡片
    [self.scrollView addSubview:self.formCard];
    [self.formCard addSubview:self.nameTitleLabel];
    [self.formCard addSubview:self.nameTextField];
    [self.formCard addSubview:self.genderTitleLabel];
    [self.formCard addSubview:self.genderSegment];
    [self.formCard addSubview:self.ageTitleLabel];
    [self.formCard addSubview:self.ageValueLabel];
    [self.formCard addSubview:self.ageMinusBtn];
    [self.formCard addSubview:self.agePlusBtn];
    [self.formCard addSubview:self.heightTitleLabel];
    [self.formCard addSubview:self.heightValueLabel];
    [self.formCard addSubview:self.heightMinusBtn];
    [self.formCard addSubview:self.heightPlusBtn];
    [self.formCard addSubview:self.weightTitleLabel];
    [self.formCard addSubview:self.weightValueLabel];
    [self.formCard addSubview:self.weightMinusBtn];
    [self.formCard addSubview:self.weightPlusBtn];
    [self.formCard addSubview:self.bmiTitleLabel];
    [self.formCard addSubview:self.bmiValueLabel];
    [self.formCard addSubview:self.bmiStatusLabel];
    [self setupSeparators];

    // 保存按钮 & 加载指示器
    [self.scrollView addSubview:self.saveButton];
    [self.view addSubview:self.loadingIndicator];
}

/**
 * Frame 布局
 */
- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset    = self.ts_navigationBarTotalHeight;
    if (topInset <= 0)  topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, kCardPadding);

    // ScrollView 填满导航栏以下区域
    self.scrollView.frame = CGRectMake(0, topInset, screenW, CGRectGetHeight(self.view.bounds) - topInset);

    CGFloat cardW = screenW - kCardPadding * 2;
    CGFloat curY  = kCardPadding;

    // 用户 ID 卡片（有 userId 时显示）
    if (!self.userIdCard.hidden) {
        CGFloat idCardH = 56.f;
        self.userIdCard.frame       = CGRectMake(kCardPadding, curY, cardW, idCardH);
        self.userIdTitleLabel.frame = CGRectMake(kCardPadding, 0, 60.f, idCardH);
        self.userIdValueLabel.frame = CGRectMake(80.f, 0, cardW - 80.f - kCardPadding, idCardH);
        curY += idCardH + kCardPadding;
    }

    // 信息表单卡片
    CGFloat formCardH = kFormRowCount * kRowHeight;
    self.formCard.frame = CGRectMake(kCardPadding, curY, cardW, formCardH);
    [self layoutFormRows:cardW];
    [self layoutSeparators:cardW];
    curY += formCardH + kCardPadding * 1.5;

    // 保存按钮
    CGFloat saveBtnH = 52.f;
    self.saveButton.frame = CGRectMake(kCardPadding, curY, cardW, saveBtnH);
    curY += saveBtnH + bottomInset;

    // ScrollView 内容尺寸
    self.scrollView.contentSize = CGSizeMake(screenW, curY);

    // 加载指示器居中
    self.loadingIndicator.center = CGPointMake(screenW / 2.f, CGRectGetHeight(self.view.bounds) / 2.f);
}

#pragma mark - Layout Helpers

/**
 * 布局表单卡片内各行控件
 */
- (void)layoutFormRows:(CGFloat)cardW {
    CGFloat labelW    = 48.f;
    CGFloat rightEdge = cardW - kCardPadding;

    // 行 0 — 姓名
    CGFloat r0Y = 0;
    self.nameTitleLabel.frame = CGRectMake(kCardPadding, r0Y, labelW, kRowHeight);
    CGFloat tfX = kCardPadding + labelW + 8.f;
    self.nameTextField.frame  = CGRectMake(tfX, r0Y + 12.f, rightEdge - tfX, kRowHeight - 24.f);

    // 行 1 — 性别
    CGFloat r1Y = kRowHeight;
    self.genderTitleLabel.frame = CGRectMake(kCardPadding, r1Y, labelW, kRowHeight);
    CGFloat segW = 110.f;
    self.genderSegment.frame    = CGRectMake(rightEdge - segW, r1Y + (kRowHeight - 30.f) / 2.f, segW, 30.f);

    // 行 2 — 年龄
    [self layoutStepperAtRow:2
                 titleLabel:self.ageTitleLabel
                 valueLabel:self.ageValueLabel
                   minusBtn:self.ageMinusBtn
                    plusBtn:self.agePlusBtn
                      cardW:cardW];

    // 行 3 — 身高
    [self layoutStepperAtRow:3
                 titleLabel:self.heightTitleLabel
                 valueLabel:self.heightValueLabel
                   minusBtn:self.heightMinusBtn
                    plusBtn:self.heightPlusBtn
                      cardW:cardW];

    // 行 4 — 体重
    [self layoutStepperAtRow:4
                 titleLabel:self.weightTitleLabel
                 valueLabel:self.weightValueLabel
                   minusBtn:self.weightMinusBtn
                    plusBtn:self.weightPlusBtn
                      cardW:cardW];

    // 行 5 — BMI（只读）
    CGFloat r5Y     = 5 * kRowHeight;
    CGFloat statusW = 44.f, statusH = 22.f;
    self.bmiTitleLabel.frame  = CGRectMake(kCardPadding, r5Y, labelW, kRowHeight);
    self.bmiStatusLabel.frame = CGRectMake(rightEdge - statusW,
                                           r5Y + (kRowHeight - statusH) / 2.f,
                                           statusW, statusH);
    self.bmiValueLabel.frame  = CGRectMake(kCardPadding + labelW + 8.f,
                                           r5Y,
                                           rightEdge - (kCardPadding + labelW + 8.f) - statusW - 8.f,
                                           kRowHeight);
}

/**
 * 布局单个步进器行（[-] 值 [+] 靠右对齐）
 */
- (void)layoutStepperAtRow:(NSInteger)row
               titleLabel:(UILabel *)titleLabel
               valueLabel:(UILabel *)valueLabel
                 minusBtn:(UIButton *)minusBtn
                  plusBtn:(UIButton *)plusBtn
                    cardW:(CGFloat)cardW {
    CGFloat rowY      = row * kRowHeight;
    CGFloat rightEdge = cardW - kCardPadding;
    CGFloat btnY      = rowY + (kRowHeight - kStepperBtnSize) / 2.f;

    titleLabel.frame = CGRectMake(kCardPadding, rowY, 48.f, kRowHeight);

    // [+] 最右
    plusBtn.frame             = CGRectMake(rightEdge - kStepperBtnSize, btnY, kStepperBtnSize, kStepperBtnSize);
    plusBtn.layer.cornerRadius = kStepperBtnSize / 2.f;

    // 数值标签
    CGFloat valW  = 68.f;
    CGFloat valX  = CGRectGetMinX(plusBtn.frame) - 6.f - valW;
    valueLabel.frame = CGRectMake(valX, rowY, valW, kRowHeight);

    // [-]
    CGFloat minusX        = valX - 6.f - kStepperBtnSize;
    minusBtn.frame         = CGRectMake(minusX, btnY, kStepperBtnSize, kStepperBtnSize);
    minusBtn.layer.cornerRadius = kStepperBtnSize / 2.f;
}

/**
 * 在表单卡片中添加 5 条行间分割线子视图
 */
- (void)setupSeparators {
    for (NSInteger i = 1; i < kFormRowCount; i++) {
        UIView *line        = [[UIView alloc] init];
        line.backgroundColor = TSColor_Separator;
        line.tag            = 1000 + i;
        [self.formCard addSubview:line];
    }
}

/**
 * 布局行间分割线（在 layoutFormRows 之后调用）
 */
- (void)layoutSeparators:(CGFloat)cardW {
    for (NSInteger i = 1; i < kFormRowCount; i++) {
        UIView *line = [self.formCard viewWithTag:1000 + i];
        line.frame   = CGRectMake(kCardPadding, i * kRowHeight, cardW - kCardPadding, 0.5f);
    }
}

#pragma mark - Network

/**
 * 进入页面自动从设备获取用户信息
 */
- (void)fetchUserInfo {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] userInfo] getUserInfoWithCompletion:^(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;

            if (error) {
                TSLog(@"获取用户信息失败: %@", error.localizedDescription);
                // SDK 在「当前设备/固件不支持用户信息」或「未连接设备」等情况下会返回「暂不支持该功能」
                NSString *tip = ([error.localizedDescription rangeOfString:@"不支持"].location != NSNotFound)
                    ? @"当前设备不支持获取用户信息，您仍可手动填写并保存"
                    : error.localizedDescription;
                [weakSelf showToastWithMessage:tip isSuccess:NO];
                return;
            }
            if (userInfo) {
                TSLog(@"获取用户信息成功: %@", userInfo.debugDescription);
                [weakSelf populateFormWithModel:userInfo];
            }
        });
    }];
}

/**
 * 将 Model 数据填充到所有表单控件
 */
- (void)populateFormWithModel:(TSUserInfoModel *)model {
    // 姓名
    self.nameTextField.text = model.name ?: @"";

    // 性别
    self.currentGender = (model.gender == TSUserGenderFemale) ? TSUserGenderFemale : TSUserGenderMale;
    self.genderSegment.selectedSegmentIndex = (self.currentGender == TSUserGenderMale) ? 0 : 1;

    // 年龄
    self.currentAge = model.age > 0 ? model.age : 25;
    self.ageValueLabel.text = [NSString stringWithFormat:@"%ld 岁", (long)self.currentAge];

    // 身高
    self.currentHeight = model.height > 0 ? (NSInteger)model.height : 170;
    self.heightValueLabel.text = [NSString stringWithFormat:@"%ld cm", (long)self.currentHeight];

    // 体重
    self.currentWeight = model.weight > 0 ? (NSInteger)model.weight : 65;
    self.weightValueLabel.text = [NSString stringWithFormat:@"%ld kg", (long)self.currentWeight];

    // 用户 ID（有值才展示卡片）
    BOOL hadIdCard = !self.userIdCard.hidden;
    if (model.userId.length > 0) {
        self.userIdValueLabel.text = model.userId;
        self.userIdCard.hidden     = NO;
    } else {
        self.userIdCard.hidden = YES;
    }

    // 更新 BMI
    [self updateBMI];

    // 填充来自设备，标记为"未修改"
    _hasChanges = NO;
    [self updateSaveButtonState];

    // userId 卡片显隐变化时需要重新布局
    if (hadIdCard != !self.userIdCard.hidden) {
        [self layoutViews];
    }
}

/**
 * 构建 Model 并保存到设备
 */
- (void)saveUserInfo {
    TSUserInfoModel *model = [[TSUserInfoModel alloc] init];
    model.name   = self.nameTextField.text;
    model.gender = self.currentGender;
    model.age    = (UInt8)self.currentAge;
    model.height = (CGFloat)self.currentHeight;
    model.weight = (CGFloat)self.currentWeight;

    // 本地数据校验
    NSError *validationError = [model validate];
    if (validationError) {
        TSLog(@"用户信息校验失败: %@", validationError.localizedDescription);
        [self showToastWithMessage:validationError.localizedDescription isSuccess:NO];
        return;
    }

    self.saveButton.enabled = NO;
    [self.loadingIndicator startAnimating];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] userInfo] setUserInfo:model completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];

            if (!success || error) {
                TSLog(@"保存用户信息失败: %@", error.localizedDescription);
                weakSelf.saveButton.enabled = YES;
                [weakSelf showToastWithMessage:error.localizedDescription ?: @"保存失败" isSuccess:NO];
                return;
            }

            TSLog(@"保存用户信息成功");
            weakSelf.hasChanges = NO;
            [weakSelf updateSaveButtonState];
            [weakSelf showToastWithMessage:@"保存成功" isSuccess:YES];
        });
    }];
}

#pragma mark - UI State

/**
 * 标记表单已修改，激活保存按钮
 */
- (void)markAsChanged {
    if (!_hasChanges) {
        _hasChanges = YES;
        [self updateSaveButtonState];
    }
}

/**
 * 根据 hasChanges 更新保存按钮的颜色和可点击状态
 */
- (void)updateSaveButtonState {
    BOOL enabled = _hasChanges;
    self.saveButton.enabled         = enabled;
    self.saveButton.backgroundColor = enabled ? TSColor_Primary : TSColor_Separator;
    [UIView animateWithDuration:0.2 animations:^{
        self.saveButton.alpha = enabled ? 1.0f : 0.6f;
    }];
}

/**
 * 根据当前身高/体重实时计算并刷新 BMI 行
 * 直接用 BMI = 体重(kg) / 身高(m)² 公式计算，不依赖 SDK 内部校验
 */
- (void)updateBMI {
    if (self.currentHeight <= 0 || self.currentWeight <= 0) {
        self.bmiValueLabel.text             = @"--";
        self.bmiStatusLabel.text            = @"--";
        self.bmiStatusLabel.textColor       = TSColor_TextSecondary;
        self.bmiStatusLabel.backgroundColor = [UIColor clearColor];
        return;
    }

    float heightM = self.currentHeight / 100.f;
    float bmi     = self.currentWeight / (heightM * heightM);

    if (bmi <= 0) {
        self.bmiValueLabel.text          = @"--";
        self.bmiStatusLabel.text         = @"--";
        self.bmiStatusLabel.textColor    = TSColor_TextSecondary;
        self.bmiStatusLabel.backgroundColor = [UIColor clearColor];
        return;
    }

    self.bmiValueLabel.text = [NSString stringWithFormat:@"%.1f", bmi];

    NSString *status;
    UIColor  *color;

    if (bmi < 18.5f) {
        status = @"偏轻";  color = TSColor_Warning;
    } else if (bmi < 25.0f) {
        status = @"正常";  color = TSColor_Success;
    } else if (bmi < 30.0f) {
        status = @"偏重";  color = TSColor_Warning;
    } else {
        status = @"肥胖";  color = TSColor_Danger;
    }

    self.bmiStatusLabel.text            = status;
    self.bmiStatusLabel.textColor       = color;
    self.bmiStatusLabel.backgroundColor = [color colorWithAlphaComponent:0.12f];
}

#pragma mark - Stepper Actions

- (void)ageMinus    { [self adjustAge:-1];    }
- (void)agePlus     { [self adjustAge:+1];    }
- (void)heightMinus { [self adjustHeight:-1]; }
- (void)heightPlus  { [self adjustHeight:+1]; }
- (void)weightMinus { [self adjustWeight:-1]; }
- (void)weightPlus  { [self adjustWeight:+1]; }

/**
 * 调整年龄值（有效范围 3-120）
 */
- (void)adjustAge:(NSInteger)delta {
    NSInteger val = self.currentAge + delta;
    if (val < 3 || val > 120) return;
    self.currentAge             = val;
    self.ageValueLabel.text     = [NSString stringWithFormat:@"%ld 岁", (long)val];
    [self markAsChanged];
}

/**
 * 调整身高值（有效范围 80-220），同步刷新 BMI
 */
- (void)adjustHeight:(NSInteger)delta {
    NSInteger val = self.currentHeight + delta;
    if (val < 80 || val > 220) return;
    self.currentHeight          = val;
    self.heightValueLabel.text  = [NSString stringWithFormat:@"%ld cm", (long)val];
    [self updateBMI];
    [self markAsChanged];
}

/**
 * 调整体重值（有效范围 20-200），同步刷新 BMI
 */
- (void)adjustWeight:(NSInteger)delta {
    NSInteger val = self.currentWeight + delta;
    if (val < 20 || val > 200) return;
    self.currentWeight          = val;
    self.weightValueLabel.text  = [NSString stringWithFormat:@"%ld kg", (long)val];
    [self updateBMI];
    [self markAsChanged];
}

#pragma mark - Gender Action

/**
 * 性别 SegmentedControl 切换回调
 */
- (void)genderChanged:(UISegmentedControl *)sender {
    self.currentGender = (sender.selectedSegmentIndex == 0) ? TSUserGenderMale : TSUserGenderFemale;
    [self markAsChanged];
}

#pragma mark - Save Button Action

/**
 * 保存按钮点击
 */
- (void)saveButtonTapped {
    [self.view endEditing:YES];
    [self saveUserInfo];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self markAsChanged];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self markAsChanged];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Toast

/**
 * 在屏幕下方显示轻提示，1.5 秒后自动消失
 */
- (void)showToastWithMessage:(NSString *)message isSuccess:(BOOL)isSuccess {
    UIView *toast        = [[UIView alloc] init];
    UIColor *bgColor     = isSuccess
        ? [TSColor_Success colorWithAlphaComponent:0.92f]
        : [[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1.f] colorWithAlphaComponent:0.88f];
    toast.backgroundColor    = bgColor;
    toast.layer.cornerRadius = 10.f;
    toast.alpha              = 0;

    UILabel *label      = [[UILabel alloc] init];
    label.text          = message;
    label.textColor     = [UIColor whiteColor];
    label.font          = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW   = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize  size   = [label sizeThatFits:CGSizeMake(maxW - 32.f, CGFLOAT_MAX)];
    CGFloat toastW = MIN(size.width + 32.f, maxW);
    CGFloat toastH = size.height + 20.f;

    toast.frame = CGRectMake(
        (CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
        CGRectGetHeight(self.view.bounds) * 0.72f,
        toastW, toastH
    );
    label.frame = CGRectMake(16.f, 10.f, toastW - 32.f, size.height);

    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:1.5 animations:^{
        toast.alpha = 1.0f;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL fin) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - Lazy Properties

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor          = TSColor_Background;
        _scrollView.alwaysBounceVertical      = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.keyboardDismissMode       = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}

- (UIView *)userIdCard {
    if (!_userIdCard) {
        _userIdCard                      = [[UIView alloc] init];
        _userIdCard.backgroundColor      = TSColor_Card;
        _userIdCard.layer.cornerRadius   = kCardCornerR;
        _userIdCard.layer.shadowColor    = [UIColor blackColor].CGColor;
        _userIdCard.layer.shadowOpacity  = 0.05f;
        _userIdCard.layer.shadowOffset   = CGSizeMake(0, 2);
        _userIdCard.layer.shadowRadius   = kCardShadowR;
        _userIdCard.hidden               = YES;
    }
    return _userIdCard;
}

- (UILabel *)userIdTitleLabel {
    if (!_userIdTitleLabel) {
        _userIdTitleLabel           = [[UILabel alloc] init];
        _userIdTitleLabel.text      = @"用户 ID";
        _userIdTitleLabel.font      = TSFont_Body;
        _userIdTitleLabel.textColor = TSColor_TextSecondary;
    }
    return _userIdTitleLabel;
}

- (UILabel *)userIdValueLabel {
    if (!_userIdValueLabel) {
        _userIdValueLabel                          = [[UILabel alloc] init];
        _userIdValueLabel.font                     = TSFont_Caption;
        _userIdValueLabel.textColor                = TSColor_TextSecondary;
        _userIdValueLabel.textAlignment            = NSTextAlignmentRight;
        _userIdValueLabel.adjustsFontSizeToFitWidth = YES;
        _userIdValueLabel.minimumScaleFactor       = 0.7f;
    }
    return _userIdValueLabel;
}

- (UIView *)formCard {
    if (!_formCard) {
        _formCard                    = [[UIView alloc] init];
        _formCard.backgroundColor    = TSColor_Card;
        _formCard.layer.cornerRadius = kCardCornerR;
        _formCard.layer.shadowColor  = [UIColor blackColor].CGColor;
        _formCard.layer.shadowOpacity = 0.05f;
        _formCard.layer.shadowOffset = CGSizeMake(0, 2);
        _formCard.layer.shadowRadius = kCardShadowR;
    }
    return _formCard;
}

- (UILabel *)nameTitleLabel {
    if (!_nameTitleLabel) {
        _nameTitleLabel = [self makeTitleLabel:@"姓名"];
        _nameTitleLabel.textColor = TSColor_TextSecondary;  // 姓名栏整体灰色，仅展示
    }
    return _nameTitleLabel;
}

- (UITextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField                  = [[UITextField alloc] init];
        _nameTextField.font              = TSFont_Body;
        _nameTextField.textColor         = TSColor_TextSecondary;
        _nameTextField.textAlignment     = NSTextAlignmentRight;
        _nameTextField.placeholder       = @"--";
        _nameTextField.enabled           = NO;  // 不可输入，仅展示设备返回的姓名
        _nameTextField.backgroundColor   = [UIColor clearColor];
    }
    return _nameTextField;
}

- (UILabel *)genderTitleLabel {
    if (!_genderTitleLabel) { _genderTitleLabel = [self makeTitleLabel:@"性别"]; }
    return _genderTitleLabel;
}

- (UISegmentedControl *)genderSegment {
    if (!_genderSegment) {
        _genderSegment = [[UISegmentedControl alloc] initWithItems:@[@"男", @"女"]];
        _genderSegment.selectedSegmentIndex = 0;
        [_genderSegment addTarget:self action:@selector(genderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _genderSegment;
}

- (UILabel *)ageTitleLabel {
    if (!_ageTitleLabel) { _ageTitleLabel = [self makeTitleLabel:@"年龄"]; }
    return _ageTitleLabel;
}

- (UILabel *)ageValueLabel {
    if (!_ageValueLabel) {
        _ageValueLabel = [self makeValueLabel:[NSString stringWithFormat:@"%ld 岁", (long)_currentAge]];
    }
    return _ageValueLabel;
}

- (UIButton *)ageMinusBtn {
    if (!_ageMinusBtn) { _ageMinusBtn = [self makeStepperButton:@"−" action:@selector(ageMinus)]; }
    return _ageMinusBtn;
}

- (UIButton *)agePlusBtn {
    if (!_agePlusBtn) { _agePlusBtn = [self makeStepperButton:@"+" action:@selector(agePlus)]; }
    return _agePlusBtn;
}

- (UILabel *)heightTitleLabel {
    if (!_heightTitleLabel) { _heightTitleLabel = [self makeTitleLabel:@"身高"]; }
    return _heightTitleLabel;
}

- (UILabel *)heightValueLabel {
    if (!_heightValueLabel) {
        _heightValueLabel = [self makeValueLabel:[NSString stringWithFormat:@"%ld cm", (long)_currentHeight]];
    }
    return _heightValueLabel;
}

- (UIButton *)heightMinusBtn {
    if (!_heightMinusBtn) { _heightMinusBtn = [self makeStepperButton:@"−" action:@selector(heightMinus)]; }
    return _heightMinusBtn;
}

- (UIButton *)heightPlusBtn {
    if (!_heightPlusBtn) { _heightPlusBtn = [self makeStepperButton:@"+" action:@selector(heightPlus)]; }
    return _heightPlusBtn;
}

- (UILabel *)weightTitleLabel {
    if (!_weightTitleLabel) { _weightTitleLabel = [self makeTitleLabel:@"体重"]; }
    return _weightTitleLabel;
}

- (UILabel *)weightValueLabel {
    if (!_weightValueLabel) {
        _weightValueLabel = [self makeValueLabel:[NSString stringWithFormat:@"%ld kg", (long)_currentWeight]];
    }
    return _weightValueLabel;
}

- (UIButton *)weightMinusBtn {
    if (!_weightMinusBtn) { _weightMinusBtn = [self makeStepperButton:@"−" action:@selector(weightMinus)]; }
    return _weightMinusBtn;
}

- (UIButton *)weightPlusBtn {
    if (!_weightPlusBtn) { _weightPlusBtn = [self makeStepperButton:@"+" action:@selector(weightPlus)]; }
    return _weightPlusBtn;
}

- (UILabel *)bmiTitleLabel {
    if (!_bmiTitleLabel) { _bmiTitleLabel = [self makeTitleLabel:@"BMI"]; }
    return _bmiTitleLabel;
}

- (UILabel *)bmiValueLabel {
    if (!_bmiValueLabel) {
        _bmiValueLabel               = [[UILabel alloc] init];
        _bmiValueLabel.font          = TSFont_Body;
        _bmiValueLabel.textColor     = TSColor_TextPrimary;
        _bmiValueLabel.textAlignment = NSTextAlignmentRight;
        _bmiValueLabel.text          = @"--";
    }
    return _bmiValueLabel;
}

- (UILabel *)bmiStatusLabel {
    if (!_bmiStatusLabel) {
        _bmiStatusLabel                    = [[UILabel alloc] init];
        _bmiStatusLabel.font               = [UIFont systemFontOfSize:12.f weight:UIFontWeightMedium];
        _bmiStatusLabel.textAlignment      = NSTextAlignmentCenter;
        _bmiStatusLabel.layer.cornerRadius = 4.f;
        _bmiStatusLabel.clipsToBounds      = YES;
        _bmiStatusLabel.text               = @"--";
        _bmiStatusLabel.textColor          = TSColor_TextSecondary;
    }
    return _bmiStatusLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:@"保存到设备" forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6f] forState:UIControlStateDisabled];
        _saveButton.titleLabel.font    = TSFont_H2;
        _saveButton.backgroundColor    = TSColor_Separator;
        _saveButton.layer.cornerRadius = TSRadius_MD;
        _saveButton.enabled            = NO;
        _saveButton.alpha              = 0.6f;
        [_saveButton addTarget:self action:@selector(saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        if (@available(iOS 13.0, *)) {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

#pragma mark - Factory Helpers

/**
 * 创建行标题标签（左对齐，主色文字）
 */
- (UILabel *)makeTitleLabel:(NSString *)text {
    UILabel *lbl    = [[UILabel alloc] init];
    lbl.text        = text;
    lbl.font        = TSFont_Body;
    lbl.textColor   = TSColor_TextPrimary;
    return lbl;
}

/**
 * 创建步进器数值标签（居中对齐）
 */
- (UILabel *)makeValueLabel:(NSString *)text {
    UILabel *lbl        = [[UILabel alloc] init];
    lbl.text            = text;
    lbl.font            = TSFont_Body;
    lbl.textColor       = TSColor_TextPrimary;
    lbl.textAlignment   = NSTextAlignmentCenter;
    return lbl;
}

/**
 * 创建圆形步进器按钮（主色边框，透明背景）
 */
- (UIButton *)makeStepperButton:(NSString *)title action:(SEL)action {
    UIButton *btn           = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    btn.titleLabel.font     = [UIFont systemFontOfSize:18.f weight:UIFontWeightLight];
    btn.layer.borderColor   = TSColor_Primary.CGColor;
    btn.layer.borderWidth   = 1.5f;
    btn.backgroundColor     = [UIColor clearColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
