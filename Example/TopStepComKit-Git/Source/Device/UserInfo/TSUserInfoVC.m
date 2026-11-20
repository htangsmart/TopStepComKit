//
//  TSUserInfoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSUserInfoVC.h"

#import <math.h>

#import "TSDialEditorSheet.h"

// ── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kRowHeight      = 56.f;   // 表单每行高度
static const CGFloat kCardPadding    = 16.f;   // 卡片水平外边距 / 内边距
static const CGFloat kStepperBtnSize = 30.f;   // 步进按钮边长
static const CGFloat kCardCornerR    = 12.f;   // 卡片圆角
static const CGFloat kCardShadowR    = 6.f;    // 卡片阴影半径
static const CGFloat kFormRowCount   = 8.f;    // 表单行数（含生日和更新时间）

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

// 生日选择与只读更新时间
@property (nonatomic, strong) UILabel *birthdayTitleLabel;
@property (nonatomic, strong) UIButton *birthdaySelectionButton;
@property (nonatomic, strong) UILabel *birthdayDisclosureLabel;
@property (nonatomic, strong) TSDialEditorSheet *birthdaySheet;
@property (nonatomic, strong) UILabel *updateTimeTitleLabel;
@property (nonatomic, strong) UILabel *updateTimeValueLabel;
// 生日草稿只在确认选择或清空时改变。
@property (nonatomic, copy) NSString *currentBirthday;

// 保留设备返回的完整资料，保存时携带元数据。
@property (nonatomic, strong) TSUserInfoModel *currentUserInfo;

// 保存按钮（无改动时灰色禁用，有改动时蓝色高亮）
@property (nonatomic, strong) UIButton                *saveButton;

// 加载指示器
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// 当前表单状态
@property (nonatomic, assign) BOOL                    hasChanges;
@property (nonatomic, assign) NSInteger               currentAge;
@property (nonatomic, assign) CGFloat                 currentHeight;
@property (nonatomic, assign) CGFloat                 currentWeight;
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

// 离开页面时收起生日弹层。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.birthdaySheet dismiss];
}

#pragma mark - Override Base Setup

/**
 * 初始化数据，设置默认值
 */
- (void)initData {
    [super initData];
    self.title      = TSLocalizedString(@"user_info.title");
    _currentAge     = 25;
    _currentHeight  = 170;
    _currentWeight  = 65;
    _currentGender  = TSUserGenderMale;
    _currentBirthday = @"";
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
    [self.formCard addSubview:self.birthdayTitleLabel];
    [self.formCard addSubview:self.birthdaySelectionButton];
    [self.formCard addSubview:self.birthdayDisclosureLabel];
    [self.formCard addSubview:self.updateTimeTitleLabel];
    [self.formCard addSubview:self.updateTimeValueLabel];
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
    CGFloat visibleRowCount = self.updateTimeValueLabel.hidden ? kFormRowCount - 1 : kFormRowCount;
    CGFloat formCardH = visibleRowCount * kRowHeight;
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
    CGFloat labelW    = 84.f;
    CGFloat rightEdge = cardW - kCardPadding;

    // 行 0 — 姓名
    CGFloat r0Y = 0;
    self.nameTitleLabel.frame = CGRectMake(kCardPadding, r0Y, labelW, kRowHeight);
    CGFloat tfX = kCardPadding + labelW + 8.f;
    self.nameTextField.frame  = CGRectMake(tfX, r0Y + 12.f, rightEdge - tfX, kRowHeight - 24.f);

    // 行 1 — 性别
    CGFloat r1Y = kRowHeight;
    self.genderTitleLabel.frame = CGRectMake(kCardPadding, r1Y, labelW, kRowHeight);
    CGFloat segW = 180.f;
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

    // 生日整行可点击，右侧箭头提示进入选择。
    CGFloat birthdayRowY = 6 * kRowHeight;
    self.birthdayTitleLabel.frame = CGRectMake(kCardPadding, birthdayRowY, labelW, kRowHeight);
    self.birthdaySelectionButton.frame = CGRectMake(0, birthdayRowY, cardW, kRowHeight);
    self.birthdaySelectionButton.contentEdgeInsets = UIEdgeInsetsMake(0, tfX, 0, kCardPadding + 22.f);
    self.birthdayDisclosureLabel.frame = CGRectMake(rightEdge - 14.f, birthdayRowY, 14.f, kRowHeight);
    CGFloat updateTimeRowY = 7 * kRowHeight;
    self.updateTimeTitleLabel.frame = CGRectMake(kCardPadding, updateTimeRowY, labelW, kRowHeight);
    self.updateTimeValueLabel.frame = CGRectMake(tfX, updateTimeRowY, rightEdge - tfX, kRowHeight);
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
 * 在表单卡片中添加行间分割线子视图
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
    NSInteger visibleRowCount = self.updateTimeValueLabel.hidden ? (NSInteger)kFormRowCount - 1 : (NSInteger)kFormRowCount;
    for (NSInteger i = 1; i < kFormRowCount; i++) {
        UIView *line = [self.formCard viewWithTag:1000 + i];
        line.hidden = i >= visibleRowCount;
        line.frame   = CGRectMake(kCardPadding, i * kRowHeight, cardW - kCardPadding, 0.5f);
    }
}

#pragma mark - Network

/**
 * 进入页面自动从设备获取用户信息
 */
- (void)fetchUserInfo {
    id<TSUserInfoInterface> userInfoService = [[TopStepComKit sharedInstance] userInfo];
    if (![userInfoService isSupportGetUserInfo]) {
        [self showToastWithMessage:TSLocalizedString(@"user_info.not_supported_hint") isSuccess:NO];
        return;
    }
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [userInfoService getUserInfoWithCompletion:^(TSUserInfoModel * _Nullable userInfo, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;

            if (error) {
                TSLog(@"获取用户信息失败: %@", error.localizedDescription);
                // SDK 在「当前设备/固件不支持用户信息」或「未连接设备」等情况下会返回「暂不支持该功能」
                NSString *tip = ([error.localizedDescription rangeOfString:@"不支持"].location != NSNotFound)
                    ? TSLocalizedString(@"user_info.not_supported_hint")
                    : error.localizedDescription;
                [weakSelf showToastWithMessage:tip isSuccess:NO];
                return;
            }
            if (userInfo) {
                // 姓名和用户标识属于应用元数据，设备回读不应清除已有值。
                TSUserInfoModel *savedUserInfo = weakSelf.currentUserInfo;
                if (savedUserInfo.name.length > 0) {
                    userInfo.name = savedUserInfo.name;
                }
                if (savedUserInfo.userId.length > 0) {
                    userInfo.userId = savedUserInfo.userId;
                }
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
    self.currentUserInfo = model;

    // 姓名
    self.nameTextField.text = model.name ?: @"";

    // 性别
    self.currentGender = model.gender;
    switch (model.gender) {
        case TSUserGenderMale:
            self.genderSegment.selectedSegmentIndex = 0;
            break;
        case TSUserGenderFemale:
            self.genderSegment.selectedSegmentIndex = 1;
            break;
        case TSUserGenderUnknown:
        default:
            self.currentGender = TSUserGenderUnknown;
            self.genderSegment.selectedSegmentIndex = 2;
            break;
    }

    // 年龄
    self.currentAge = model.age;
    self.ageValueLabel.text = [NSString stringWithFormat:TSLocalizedString(@"user_info.age_format"), (long)self.currentAge];

    // 身高
    self.currentHeight = model.height;
    self.heightValueLabel.text = [NSString stringWithFormat:@"%g cm", (double)self.currentHeight];

    // 体重
    self.currentWeight = model.weight;
    self.weightValueLabel.text = [NSString stringWithFormat:@"%g kg", (double)self.currentWeight];

    // 生日通过弹窗选择，更新时间有有效值时才展示。
    self.currentBirthday = model.birthday.length > 0 && ![model.birthday isEqualToString:@"0"]
        ? model.birthday : @"";
    [self updateBirthdayButton];
    BOOL hadUpdateTime = !self.updateTimeValueLabel.hidden;
    NSString *updateTimeText = nil;
    if (isfinite(model.updateTime) && model.updateTime > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
        updateTimeText = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.updateTime]];
    }
    BOOL hasUpdateTime = updateTimeText.length > 0;
    self.updateTimeValueLabel.text = updateTimeText;
    self.updateTimeTitleLabel.hidden = !hasUpdateTime;
    self.updateTimeValueLabel.hidden = !hasUpdateTime;

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
    if (hadIdCard != !self.userIdCard.hidden || hadUpdateTime != hasUpdateTime) {
        [self layoutViews];
    }
}

/**
 * 构建 Model 并保存到设备
 */
- (void)saveUserInfo {
    TSUserInfoModel *model = [[TSUserInfoModel alloc] init];
    model.userId = self.currentUserInfo.userId;
    // 编辑保存显式使用当前 Unix 整秒，协议起点转换由 SDK 处理。
    model.updateTime = floor([NSDate date].timeIntervalSince1970);
    model.birthday = self.currentBirthday ?: @"";
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
                [weakSelf showToastWithMessage:error.localizedDescription ?: TSLocalizedString(@"user_info.save_failed") isSuccess:NO];
                return;
            }

            TSLog(@"保存用户信息成功");
            [weakSelf populateFormWithModel:model];
            [weakSelf showToastWithMessage:TSLocalizedString(@"user_info.save_success") isSuccess:YES];
            // 仅有真实读取能力时回读，展示设备实际接受的资料。
            if ([[[TopStepComKit sharedInstance] userInfo] isSupportGetUserInfo]) {
                [weakSelf fetchUserInfo];
            }
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
        status = TSLocalizedString(@"user_info.bmi.underweight");  color = TSColor_Warning;
    } else if (bmi < 25.0f) {
        status = TSLocalizedString(@"user_info.bmi.normal");  color = TSColor_Success;
    } else if (bmi < 30.0f) {
        status = TSLocalizedString(@"user_info.bmi.overweight");  color = TSColor_Warning;
    } else {
        status = TSLocalizedString(@"user_info.bmi.obese");  color = TSColor_Danger;
    }

    self.bmiStatusLabel.text            = status;
    self.bmiStatusLabel.textColor       = color;
    self.bmiStatusLabel.backgroundColor = [color colorWithAlphaComponent:0.12f];
}

#pragma mark - 生日选择

// 日期字符串固定使用公历，选择器和格式化器保持相同时区。
- (NSDateFormatter *)birthdayDateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone defaultTimeZone];
    formatter.calendar = calendar;
    formatter.timeZone = calendar.timeZone;
    formatter.dateFormat = @"yyyy/MM/dd";
    formatter.lenient = NO;
    return formatter;
}

// 未设置生日时用选择提示代替格式占位符。
- (void)updateBirthdayButton {
    BOOL hasBirthday = self.currentBirthday.length > 0;
    NSString *title = hasBirthday ? self.currentBirthday : TSLocalizedString(@"user_info.select_birthday");
    [self.birthdaySelectionButton setTitle:title forState:UIControlStateNormal];
    [self.birthdaySelectionButton setTitleColor:hasBirthday ? TSColor_TextPrimary : TSColor_TextSecondary
                                      forState:UIControlStateNormal];
    self.birthdaySelectionButton.accessibilityValue = hasBirthday
        ? self.currentBirthday : TSLocalizedString(@"user_info.birthday_not_set");
}

// 只有确认后的新生日才改变草稿并激活保存。
- (void)applyBirthdaySelection:(NSString *)birthday {
    NSString *selection = birthday ?: @"";
    if ([self.currentBirthday isEqualToString:selection]) {
        return;
    }
    self.currentBirthday = selection;
    [self updateBirthdayButton];
    [self markAsChanged];
}

// 整行点击展示日期滚轮，取消和遮罩关闭都不修改资料。
- (void)showBirthdayPicker {
    if (self.birthdaySheet || self.loadingIndicator.isAnimating) {
        return;
    }
    [self.view endEditing:YES];
    NSDateFormatter *formatter = [self birthdayDateFormatter];
    NSDate *selectedDate = [formatter dateFromString:self.currentBirthday];
    if (!selectedDate || ![[formatter stringFromDate:selectedDate] isEqualToString:self.currentBirthday]) {
        NSInteger suggestedAge = self.currentAge > 0 ? self.currentAge : 25;
        selectedDate = [formatter.calendar dateByAddingUnit:NSCalendarUnitYear
                                                    value:-suggestedAge
                                                   toDate:[NSDate date]
                                                  options:0];
    }

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.calendar = formatter.calendar;
    datePicker.timeZone = formatter.timeZone;
    datePicker.locale = [NSLocale currentLocale];
    datePicker.maximumDate = [NSDate date];
    if ([selectedDate compare:datePicker.maximumDate] == NSOrderedDescending) {
        selectedDate = datePicker.maximumDate;
    }
    datePicker.date = selectedDate ?: [NSDate date];
    if (@available(iOS 13.4, *)) {
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    datePicker.translatesAutoresizingMaskIntoConstraints = NO;

    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    // 复用的面板为浅色，日期滚轮与操作颜色保持一致。
    if (@available(iOS 13.0, *)) {
        sheet.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    sheet.title = TSLocalizedString(@"user_info.birthday_picker_title");
    sheet.contentHeight = 260.f;
    sheet.accessibilityViewIsModal = YES;
    [sheet.primaryButton setTitle:TSLocalizedString(@"general.confirm") forState:UIControlStateNormal];
    sheet.primaryButton.backgroundColor = TSColor_Primary;
    sheet.primaryButton.layer.borderColor = TSColor_Primary.CGColor;
    sheet.primaryButton.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    [sheet.secondaryButton setTitle:TSLocalizedString(@"general.cancel") forState:UIControlStateNormal];
    [sheet.secondaryButton setTitleColor:TSColor_TextSecondary forState:UIControlStateNormal];
    sheet.secondaryButton.backgroundColor = TSColor_Background;
    sheet.secondaryButton.layer.borderColor = TSColor_Separator.CGColor;
    sheet.secondaryButton.titleLabel.font = [UIFont systemFontOfSize:16.f];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:TSLocalizedString(@"user_info.clear_birthday") forState:UIControlStateNormal];
    [clearButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    clearButton.titleLabel.font = TSFont_Body;
    clearButton.enabled = self.currentBirthday.length > 0;
    clearButton.alpha = clearButton.enabled ? 1.f : 0.4f;
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [clearButton addTarget:self action:@selector(clearBirthdaySelection) forControlEvents:UIControlEventTouchUpInside];
    [sheet.contentView addSubview:clearButton];
    [sheet.contentView addSubview:datePicker];
    NSLayoutConstraint *pickerWidth = [datePicker.widthAnchor constraintEqualToAnchor:sheet.contentView.widthAnchor];
    pickerWidth.priority = UILayoutPriorityDefaultHigh;
    [NSLayoutConstraint activateConstraints:@[
        [clearButton.topAnchor constraintEqualToAnchor:sheet.contentView.topAnchor],
        [clearButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:sheet.contentView.leadingAnchor],
        [clearButton.trailingAnchor constraintEqualToAnchor:sheet.contentView.trailingAnchor],
        [clearButton.heightAnchor constraintEqualToConstant:44.f],
        [clearButton.widthAnchor constraintGreaterThanOrEqualToConstant:44.f],
        [datePicker.topAnchor constraintEqualToAnchor:clearButton.bottomAnchor],
        [datePicker.centerXAnchor constraintEqualToAnchor:sheet.contentView.centerXAnchor],
        [datePicker.widthAnchor constraintLessThanOrEqualToConstant:420.f],
        [datePicker.heightAnchor constraintEqualToConstant:216.f],
        pickerWidth
    ]];

    self.birthdaySheet = sheet;
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{
        [weakSelf applyBirthdaySelection:[formatter stringFromDate:datePicker.date]];
        [weakSelf.birthdaySheet dismiss];
    };
    sheet.onSecondary = ^{
        [weakSelf.birthdaySheet dismiss];
    };
    sheet.onDismiss = ^{
        weakSelf.birthdaySheet = nil;
        if (weakSelf.view.window) {
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, weakSelf.birthdaySelectionButton);
        }
    };
    UIView *hostView = self.navigationController.view ?: self.view;
    [sheet showInView:hostView];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, datePicker);
}

// 清空同样只更新本地草稿，仍由保存按钮提交。
- (void)clearBirthdaySelection {
    [self applyBirthdaySelection:@""];
    [self.birthdaySheet dismiss];
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
    if (delta > 0 && self.currentAge < 3) {
        val = 3;
    }
    if (val < 3 || val > 120) return;
    self.currentAge             = val;
    self.ageValueLabel.text     = [NSString stringWithFormat:TSLocalizedString(@"user_info.age_format"), (long)val];
    [self markAsChanged];
}

/**
 * 调整身高值（有效范围 80-220），同步刷新 BMI
 */
- (void)adjustHeight:(NSInteger)delta {
    CGFloat val = self.currentHeight + delta;
    if (delta > 0 && self.currentHeight < 80) {
        val = 80;
    }
    if (val < 80 || val > 220) return;
    self.currentHeight          = val;
    self.heightValueLabel.text  = [NSString stringWithFormat:@"%g cm", (double)val];
    [self updateBMI];
    [self markAsChanged];
}

/**
 * 调整体重值（有效范围 20-200），同步刷新 BMI
 */
- (void)adjustWeight:(NSInteger)delta {
    CGFloat val = self.currentWeight + delta;
    if (delta > 0 && self.currentWeight < 20) {
        val = 20;
    }
    if (val < 20 || val > 200) return;
    self.currentWeight          = val;
    self.weightValueLabel.text  = [NSString stringWithFormat:@"%g kg", (double)val];
    [self updateBMI];
    [self markAsChanged];
}

#pragma mark - Gender Action

/**
 * 性别 SegmentedControl 切换回调
 */
- (void)genderChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.currentGender = TSUserGenderMale;
            break;
        case 1:
            self.currentGender = TSUserGenderFemale;
            break;
        default:
            self.currentGender = TSUserGenderUnknown;
            break;
    }
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
        _userIdTitleLabel.text      = TSLocalizedString(@"user_info.user_id");
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
        _nameTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.name")];
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
    if (!_genderTitleLabel) { _genderTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.gender")]; }
    return _genderTitleLabel;
}

- (UISegmentedControl *)genderSegment {
    if (!_genderSegment) {
        _genderSegment = [[UISegmentedControl alloc] initWithItems:@[TSLocalizedString(@"user_info.male"),
                                                                   TSLocalizedString(@"user_info.female"), @"未知"]];
        _genderSegment.selectedSegmentIndex = 0;
        [_genderSegment addTarget:self action:@selector(genderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _genderSegment;
}

- (UILabel *)ageTitleLabel {
    if (!_ageTitleLabel) { _ageTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.age")]; }
    return _ageTitleLabel;
}

- (UILabel *)ageValueLabel {
    if (!_ageValueLabel) {
        _ageValueLabel = [self makeValueLabel:[NSString stringWithFormat:TSLocalizedString(@"user_info.age_format"), (long)_currentAge]];
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
    if (!_heightTitleLabel) { _heightTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.height")]; }
    return _heightTitleLabel;
}

- (UILabel *)heightValueLabel {
    if (!_heightValueLabel) {
        _heightValueLabel = [self makeValueLabel:[NSString stringWithFormat:@"%g cm", (double)_currentHeight]];
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
    if (!_weightTitleLabel) { _weightTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.weight")]; }
    return _weightTitleLabel;
}

- (UILabel *)weightValueLabel {
    if (!_weightValueLabel) {
        _weightValueLabel = [self makeValueLabel:[NSString stringWithFormat:@"%g kg", (double)_currentWeight]];
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

// 生日标题由整行选择按钮统一提供无障碍说明。
- (UILabel *)birthdayTitleLabel {
    if (!_birthdayTitleLabel) {
        _birthdayTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.birthday")];
        _birthdayTitleLabel.isAccessibilityElement = NO;
    }
    return _birthdayTitleLabel;
}

// 整行点击选择生日，不唤起输入键盘。
- (UIButton *)birthdaySelectionButton {
    if (!_birthdaySelectionButton) {
        _birthdaySelectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _birthdaySelectionButton.titleLabel.font = TSFont_Body;
        _birthdaySelectionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _birthdaySelectionButton.titleLabel.minimumScaleFactor = 0.8f;
        _birthdaySelectionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_birthdaySelectionButton setTitle:TSLocalizedString(@"user_info.select_birthday") forState:UIControlStateNormal];
        [_birthdaySelectionButton setTitleColor:TSColor_TextSecondary forState:UIControlStateNormal];
        [_birthdaySelectionButton addTarget:self action:@selector(showBirthdayPicker)
                          forControlEvents:UIControlEventTouchUpInside];
        _birthdaySelectionButton.accessibilityLabel = TSLocalizedString(@"user_info.birthday");
        _birthdaySelectionButton.accessibilityValue = TSLocalizedString(@"user_info.birthday_not_set");
        _birthdaySelectionButton.accessibilityHint = TSLocalizedString(@"user_info.birthday_picker_hint");
    }
    return _birthdaySelectionButton;
}

// 向右箭头提示生日行可打开选择器。
- (UILabel *)birthdayDisclosureLabel {
    if (!_birthdayDisclosureLabel) {
        _birthdayDisclosureLabel = [[UILabel alloc] init];
        _birthdayDisclosureLabel.text = @"›";
        _birthdayDisclosureLabel.font = [UIFont systemFontOfSize:24.f];
        _birthdayDisclosureLabel.textColor = TSColor_TextSecondary;
        _birthdayDisclosureLabel.textAlignment = NSTextAlignmentRight;
        _birthdayDisclosureLabel.isAccessibilityElement = NO;
    }
    return _birthdayDisclosureLabel;
}

// 更新时间只展示设备资料中的值。
- (UILabel *)updateTimeTitleLabel {
    if (!_updateTimeTitleLabel) {
        _updateTimeTitleLabel = [self makeTitleLabel:TSLocalizedString(@"user_info.update_time")];
        _updateTimeTitleLabel.hidden = YES;
    }
    return _updateTimeTitleLabel;
}

// 更新时间缺省时不显示整行。
- (UILabel *)updateTimeValueLabel {
    if (!_updateTimeValueLabel) {
        _updateTimeValueLabel = [self makeValueLabel:@""];
        _updateTimeValueLabel.font = TSFont_Caption;
        _updateTimeValueLabel.textColor = TSColor_TextSecondary;
        _updateTimeValueLabel.textAlignment = NSTextAlignmentRight;
        _updateTimeValueLabel.numberOfLines = 2;
        _updateTimeValueLabel.hidden = YES;
    }
    return _updateTimeValueLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:TSLocalizedString(@"daily_goal.save_to_device") forState:UIControlStateNormal];
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
