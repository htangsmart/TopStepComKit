//
//  TSContactVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSContactVC.h"
#import "TSContactEditVC.h"

static const CGFloat kCardCornerR     = 12.f;
static const CGFloat kCardShadowR     = 6.f;
static const CGFloat kRowH            = 56.f;
static const CGFloat kSectionHeaderH  = 44.f;
static const CGFloat kActionBtnH      = 48.f;
static const CGFloat kCardPad         = 16.f;

// ── Cell 复用 ID ──────────────────────────────────────────────────────────────
static NSString * const kContactCellID  = @"kContactCell";

@interface TSContactVC () <UITableViewDataSource, UITableViewDelegate>

// 主 ScrollView（包含两张卡片）
@property (nonatomic, strong) UIScrollView  *scrollView;

// ── 普通联系人卡片 ────────────────────────────────────────────────────────────
@property (nonatomic, strong) UIView        *normalCard;
@property (nonatomic, strong) UILabel       *normalHeaderLabel;
@property (nonatomic, strong) UITableView   *normalTableView;
@property (nonatomic, strong) UILabel       *normalEmptyLabel;
@property (nonatomic, strong) UIButton      *addContactButton;
@property (nonatomic, strong) UIButton      *syncContactsButton;

// ── 紧急联系人卡片 ────────────────────────────────────────────────────────────
@property (nonatomic, strong) UIView        *emergencyCard;
@property (nonatomic, strong) UILabel       *emergencyHeaderLabel;
@property (nonatomic, strong) UIView        *sosSwitchRow;
@property (nonatomic, strong) UILabel       *sosSwitchLabel;
@property (nonatomic, strong) UISwitch      *sosSwitch;
@property (nonatomic, strong) UIView        *sosSeparator;
// 开关关闭时显示
@property (nonatomic, strong) UILabel       *emergencyOffHintLabel;
// 开关打开时显示
@property (nonatomic, strong) UITableView   *emergencyTableView;
@property (nonatomic, strong) UILabel       *emergencyEmptyLabel;
@property (nonatomic, strong) UIButton      *selectEmergencyButton;
@property (nonatomic, strong) UIButton      *saveEmergencyButton;

// 加载指示器
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// 两个都不支持时展示的占位视图（图标 + 文案）
@property (nonatomic, strong) UIView   *unsupportedPlaceholderView;
@property (nonatomic, strong) UILabel  *unsupportedIconLabel;
@property (nonatomic, strong) UILabel  *unsupportedTextLabel;

// ── 数据与能力 ────────────────────────────────────────────────────────────────
@property (nonatomic, assign) BOOL supportsNormalContacts;
@property (nonatomic, assign) BOOL supportsEmergencyContacts;
@property (nonatomic, strong) NSMutableArray<TopStepContactModel *> *normalContacts;
@property (nonatomic, strong) NSMutableArray<TopStepContactModel *> *emergencyContacts;
@property (nonatomic, assign) BOOL sosOn;

// 标记是否有未同步改动
@property (nonatomic, assign) BOOL normalHasChanges;
@property (nonatomic, assign) BOOL emergencyHasChanges;

@end

@implementation TSContactVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchAllData];
    [self registerCallbacks];
}

#pragma mark - Override Base Setup

/**
 * 初始化数据，并查询设备是否支持普通/紧急联系人
 */
- (void)initData {
    [super initData];
    self.title = @"联系人管理";
    id contact = [[TopStepComKit sharedInstance] contact];
    _supportsNormalContacts    = [contact supportMaxContacts] > 0;
    _supportsEmergencyContacts = [contact isSupportEmergencyContacts];
    _normalContacts            = [NSMutableArray array];
    _emergencyContacts         = [NSMutableArray array];
    _sosOn                     = NO;
    _normalHasChanges          = NO;
    _emergencyHasChanges       = NO;
}

/**
 * 构建视图（不使用父类 tableView，完全自定义）
 */
- (void)setupViews {
    [self.view addSubview:self.scrollView];

    // 普通联系人卡片
    [self.scrollView addSubview:self.normalCard];
    [self.normalCard addSubview:self.normalHeaderLabel];
    [self.normalCard addSubview:self.normalTableView];
    [self.normalCard addSubview:self.normalEmptyLabel];
    [self.normalCard addSubview:self.addContactButton];
    [self.normalCard addSubview:self.syncContactsButton];

    // 紧急联系人卡片
    [self.scrollView addSubview:self.emergencyCard];
    [self.emergencyCard addSubview:self.emergencyHeaderLabel];
    [self.emergencyCard addSubview:self.sosSwitchRow];
    [self.sosSwitchRow addSubview:self.sosSwitchLabel];
    [self.sosSwitchRow addSubview:self.sosSwitch];
    [self.emergencyCard addSubview:self.sosSeparator];
    [self.emergencyCard addSubview:self.emergencyOffHintLabel];
    [self.emergencyCard addSubview:self.emergencyTableView];
    [self.emergencyCard addSubview:self.emergencyEmptyLabel];
    [self.emergencyCard addSubview:self.selectEmergencyButton];
    [self.emergencyCard addSubview:self.saveEmergencyButton];

    // 两个都不支持时展示的占位视图
    [self.scrollView addSubview:self.unsupportedPlaceholderView];
    [self.unsupportedPlaceholderView addSubview:self.unsupportedIconLabel];
    [self.unsupportedPlaceholderView addSubview:self.unsupportedTextLabel];

    [self.view addSubview:self.loadingIndicator];
}

/**
 * Frame 布局（在 viewSafeAreaInsetsDidChange 里也会调用）
 */
- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset    = self.ts_navigationBarTotalHeight;
    if (topInset <= 0)  topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, kCardPad);

    self.scrollView.frame = CGRectMake(0, topInset, screenW, screenH - topInset);

    CGFloat cardW = screenW - kCardPad * 2;
    CGFloat curY  = kCardPad;

    
    BOOL anySupported = self.supportsNormalContacts || self.supportsEmergencyContacts;
    self.normalCard.hidden    = !self.supportsNormalContacts;
    self.emergencyCard.hidden = !self.supportsEmergencyContacts;
    self.unsupportedPlaceholderView.hidden = anySupported;

    // ── 普通联系人卡片（仅支持时展示）──────────────────────────────────────────
    if (self.supportsNormalContacts) {
        NSInteger normalCount  = (NSInteger)self.normalContacts.count;
        CGFloat normalTableH   = normalCount > 0 ? normalCount * kRowH : 0;
        CGFloat normalCardH    = kSectionHeaderH
                               + (normalCount > 0 ? normalTableH : 44.f)
                               + kActionBtnH + 8.f
                               + kActionBtnH + kCardPad;

        self.normalCard.frame             = CGRectMake(kCardPad, curY, cardW, normalCardH);
        self.normalCard.layer.cornerRadius = kCardCornerR;

        self.normalHeaderLabel.frame = CGRectMake(kCardPad, 0, cardW - kCardPad * 2, kSectionHeaderH);

        CGFloat tableTop = kSectionHeaderH;
        if (normalCount > 0) {
            self.normalTableView.hidden  = NO;
            self.normalEmptyLabel.hidden = YES;
            self.normalTableView.frame   = CGRectMake(0, tableTop, cardW, normalTableH);
            [self.normalTableView reloadData];
        } else {
            self.normalTableView.hidden  = YES;
            self.normalEmptyLabel.hidden = NO;
            self.normalEmptyLabel.frame  = CGRectMake(kCardPad, tableTop, cardW - kCardPad * 2, 44.f);
        }

        CGFloat controlsTopY = tableTop + (normalCount > 0 ? normalTableH : 44.f) + 8.f;
        self.addContactButton.frame = CGRectMake(kCardPad, controlsTopY, cardW - kCardPad * 2, kActionBtnH);
        self.addContactButton.layer.cornerRadius = kActionBtnH / 2.f;
        controlsTopY += kActionBtnH + 8.f;
        self.syncContactsButton.frame = CGRectMake(kCardPad, controlsTopY, cardW - kCardPad * 2, kActionBtnH);
        self.syncContactsButton.layer.cornerRadius = kActionBtnH / 2.f;

        curY += normalCardH + kCardPad;
    }

    // ── 紧急联系人卡片（仅支持时展示）──────────────────────────────────────────
    if (self.supportsEmergencyContacts) {
        BOOL sosEnabled = self.sosOn;

        // header
        CGFloat eCardCurY = 0;
        self.emergencyHeaderLabel.frame = CGRectMake(kCardPad, eCardCurY,
                                                      cardW - kCardPad * 2, kSectionHeaderH);
        eCardCurY += kSectionHeaderH;

        // SOS 开关行（文案占满开关左侧空间，避免「启用 SOS 紧急联系人」被截断）
        CGFloat switchW = 51.f, switchH = 31.f;
        CGFloat switchGap = 8.f;
        self.sosSwitchRow.frame         = CGRectMake(0, eCardCurY, cardW, kRowH);
        self.sosSwitch.frame            = CGRectMake(cardW - kCardPad - switchW,
                                                      (kRowH - switchH) / 2.f,
                                                      switchW, switchH);
        CGFloat labelW = cardW - kCardPad * 2 - switchW - switchGap;
        self.sosSwitchLabel.frame       = CGRectMake(kCardPad, 0, labelW, kRowH);
        eCardCurY += kRowH;

        // 分割线
        self.sosSeparator.frame         = CGRectMake(kCardPad, eCardCurY,
                                                      cardW - kCardPad, 0.5f);
        eCardCurY += 0.5f;

        // 关闭时：说明文字
        self.emergencyOffHintLabel.hidden  = sosEnabled;
        self.emergencyTableView.hidden     = !sosEnabled;
        self.emergencyEmptyLabel.hidden    = YES;
        self.selectEmergencyButton.hidden  = !sosEnabled;
        self.saveEmergencyButton.hidden    = !sosEnabled;

        if (!sosEnabled) {
            self.emergencyOffHintLabel.frame = CGRectMake(kCardPad, eCardCurY,
                                                           cardW - kCardPad * 2, 56.f);
            eCardCurY += 56.f + kCardPad;
        } else {
            // 打开时：联系人列表
            NSInteger eCount = (NSInteger)self.emergencyContacts.count;
            if (eCount > 0) {
                self.emergencyTableView.hidden   = NO;
                self.emergencyEmptyLabel.hidden  = YES;
                self.emergencyTableView.frame    = CGRectMake(0, eCardCurY, cardW, eCount * kRowH);
                [self.emergencyTableView reloadData];
                eCardCurY += eCount * kRowH + 8.f;
            } else {
                self.emergencyTableView.hidden   = YES;
                self.emergencyEmptyLabel.hidden  = NO;
                self.emergencyEmptyLabel.frame   = CGRectMake(kCardPad, eCardCurY,
                                                               cardW - kCardPad * 2, 44.f);
                eCardCurY += 44.f + 8.f;
            }

            // 从通讯录选择按钮
            self.selectEmergencyButton.frame      = CGRectMake(kCardPad, eCardCurY,
                                                                cardW - kCardPad * 2, kActionBtnH);
            self.selectEmergencyButton.layer.cornerRadius = kActionBtnH / 2.f;
            eCardCurY += kActionBtnH + 8.f;

            // 保存到设备按钮
            self.saveEmergencyButton.frame        = CGRectMake(kCardPad, eCardCurY,
                                                                cardW - kCardPad * 2, kActionBtnH);
            self.saveEmergencyButton.layer.cornerRadius = kActionBtnH / 2.f;
            eCardCurY += kActionBtnH + kCardPad;
        }

        CGFloat emergencyCardH = eCardCurY;
        self.emergencyCard.frame             = CGRectMake(kCardPad, curY, cardW, emergencyCardH);
        self.emergencyCard.layer.cornerRadius = kCardCornerR;
        curY += emergencyCardH + kCardPad;
    }

    // ── 两个都不支持：展示占位视图（图标 + 文案）────────────────────────────────
    if (!anySupported) {
        CGFloat placeW = 200.f;
        CGFloat placeH = 120.f;
        CGFloat placeY = (CGRectGetHeight(self.scrollView.bounds) - placeH) / 2.f;
        if (placeY < kCardPad) placeY = kCardPad;
        self.unsupportedPlaceholderView.frame = CGRectMake((screenW - placeW) / 2.f, placeY, placeW, placeH);
        self.unsupportedIconLabel.frame       = CGRectMake(0, 0, placeW, 50.f);
        self.unsupportedTextLabel.frame       = CGRectMake(0, 56.f, placeW, 44.f);
        curY = placeY + placeH;
    }

    curY += bottomInset;
    CGFloat contentH = curY;
    if (!anySupported) {
        contentH = MAX(contentH, CGRectGetHeight(self.scrollView.bounds));
    }
    self.scrollView.contentSize = CGSizeMake(screenW, contentH);

    self.loadingIndicator.center = CGPointMake(screenW / 2.f, (screenH - topInset) / 2.f + topInset);
}

#pragma mark - Network

/**
 * 进入页面自动拉取普通联系人和紧急联系人
 */
- (void)fetchAllData {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    dispatch_group_t group = dispatch_group_create();

    // 普通联系人（仅支持时拉取）
    if (self.supportsNormalContacts) {
        dispatch_group_enter(group);
        [[[TopStepComKit sharedInstance] contact] getAllContacts:^(NSArray<TopStepContactModel *> *allContacts, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error && allContacts) {
                    [weakSelf.normalContacts setArray:allContacts];
                }
                dispatch_group_leave(group);
            });
        }];
    }

    // 紧急联系人（仅支持时拉取）
    if (self.supportsEmergencyContacts) {
        dispatch_group_enter(group);
        [[[TopStepComKit sharedInstance] contact] getEmergencyContacts:^(NSArray<TopStepContactModel *> *emergencyContact, BOOL isSosOn, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    [weakSelf.emergencyContacts setArray:emergencyContact ?: @[]];
                    weakSelf.sosOn = isSosOn;
                    weakSelf.sosSwitch.on = isSosOn;  // 同步开关显示与设备状态
                }
                dispatch_group_leave(group);
            });
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.loadingIndicator stopAnimating];
        weakSelf.scrollView.userInteractionEnabled = YES;
        [weakSelf layoutViews];
        [weakSelf updateSyncButtonStates];
    });
}

/**
 * 同步普通联系人到设备
 */
- (void)syncNormalContacts {
    [self.loadingIndicator startAnimating];
    self.syncContactsButton.enabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] contact] setAllContacts:self.normalContacts completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            if (success) {
                weakSelf.normalHasChanges = NO;
                [weakSelf updateSyncButtonStates];
                [weakSelf showToast:@"联系人同步成功" success:YES];
            } else {
                weakSelf.syncContactsButton.enabled = YES;
                [weakSelf showToast:error.localizedDescription ?: @"同步失败" success:NO];
            }
        });
    }];
}

/**
 * 保存紧急联系人到设备
 */
- (void)saveEmergencyContacts {
    [self.loadingIndicator startAnimating];
    self.saveEmergencyButton.enabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] contact] setEmergencyContacts:self.emergencyContacts
                                                             sosOn:self.sosOn
                                                        completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            if (success) {
                weakSelf.emergencyHasChanges = NO;
                [weakSelf updateSyncButtonStates];
                [weakSelf showToast:@"紧急联系人保存成功" success:YES];
            } else {
                weakSelf.saveEmergencyButton.enabled = YES;
                [weakSelf showToast:error.localizedDescription ?: @"保存失败" success:NO];
            }
        });
    }];
}

#pragma mark - Callbacks

/**
 * 注册 SDK 联系人变化监听
 */
- (void)registerCallbacks {
    __weak typeof(self) weakSelf = self;

    [[[TopStepComKit sharedInstance] contact] registerContactsDidChangedBlock:^(NSArray<TopStepContactModel *> *allContacts, NSError *error) {
        if (error || !allContacts) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.normalContacts setArray:allContacts];
            [weakSelf layoutViews];
        });
    }];

    [[[TopStepComKit sharedInstance] contact] registerEmergencyContactsDidChangedBlock:^(NSArray<TopStepContactModel *> *allContacts, NSError *error) {
        if (error || !allContacts) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.emergencyContacts setArray:allContacts];
            [weakSelf layoutViews];
        });
    }];
}

#pragma mark - Actions

/**
 * 点击「+ 添加联系人」，打开系统通讯录选择器，已有联系人显示为已选中
 */
- (void)addContactTapped {
    NSInteger maxCount = [[[TopStepComKit sharedInstance] contact] supportMaxContacts];
    __weak typeof(self) weakSelf = self;
    TSContactEditVC *picker = [[TSContactEditVC alloc] initWithSelectedContacts:self.normalContacts
                                                                 maxSelectCount:maxCount
                                                                     completion:^(NSArray<TopStepContactModel *> *selectedContacts) {
        [weakSelf.normalContacts setArray:selectedContacts];
        weakSelf.normalHasChanges = YES;
        [weakSelf layoutViews];
        [weakSelf updateSyncButtonStates];
    }];
    [self.navigationController pushViewController:picker animated:YES];
}

/**
 * 点击「同步到设备」
 */
- (void)syncContactsTapped {
    [self syncNormalContacts];
}

/**
 * SOS 开关切换
 */
- (void)sosSwitchChanged:(UISwitch *)sender {
    self.sosOn = sender.isOn;
    self.emergencyHasChanges = YES;
    // 关闭开关时清空紧急联系人列表并立即保存到设备
    if (!sender.isOn) {
        [self.emergencyContacts removeAllObjects];
        [self saveEmergencyContacts];
    }
    [self layoutViews];
    [self updateSyncButtonStates];
}

/**
 * 点击「+ 从通讯录选择」，打开系统通讯录选择器（单选模式）
 */
- (void)selectEmergencyTapped {
    __weak typeof(self) weakSelf = self;
    TSContactEditVC *picker = [[TSContactEditVC alloc] initWithSelectedContacts:self.emergencyContacts
                                                                 maxSelectCount:1
                                                                     completion:^(NSArray<TopStepContactModel *> *selectedContacts) {
        [weakSelf.emergencyContacts setArray:selectedContacts];
        weakSelf.emergencyHasChanges = YES;
        [weakSelf layoutViews];
        [weakSelf updateSyncButtonStates];
    }];
    [self.navigationController pushViewController:picker animated:YES];
}

/**
 * 点击「保存到设备」
 */
- (void)saveEmergencyTapped {
    [self saveEmergencyContacts];
}


#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.normalTableView) {
        return (NSInteger)self.normalContacts.count;
    }
    return (NSInteger)self.emergencyContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kContactCellID];
        cell.textLabel.font        = TSFont_Body;
        cell.textLabel.textColor   = TSColor_TextPrimary;
        cell.detailTextLabel.font  = TSFont_Body;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
    }

    TopStepContactModel *contact;
    if (tableView == self.normalTableView) {
        contact = self.normalContacts[indexPath.row];
    } else {
        contact = self.emergencyContacts[indexPath.row];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text       = contact.name;
    cell.detailTextLabel.text = contact.phoneNum;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 普通联系人列表点击行不做跳转，统一通过「添加联系人」按钮进入选择器
    (void)tableView;
    (void)indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;

    if (tableView == self.normalTableView) {
        [self.normalContacts removeObjectAtIndex:indexPath.row];
        self.normalHasChanges = YES;
    } else {
        [self.emergencyContacts removeObjectAtIndex:indexPath.row];
        self.emergencyHasChanges = YES;
    }
    [self layoutViews];
    [self updateSyncButtonStates];
}

#pragma mark - UI State

/**
 * 根据 hasChanges 标志更新两个同步/保存按钮的状态
 */
- (void)updateSyncButtonStates {
    [self setSaveButton:self.syncContactsButton enabled:self.normalHasChanges];
    [self setSaveButton:self.saveEmergencyButton enabled:self.emergencyHasChanges];
}

/**
 * 统一设置保存按钮的启用状态和颜色
 */
- (void)setSaveButton:(UIButton *)button enabled:(BOOL)enabled {
    button.enabled          = enabled;
    button.backgroundColor  = enabled ? TSColor_Primary : TSColor_Separator;
    button.alpha            = enabled ? 1.0f : 0.6f;
}

#pragma mark - Toast

/**
 * 底部 Toast 提示（1.5 秒自动消失）
 */
- (void)showToast:(NSString *)message success:(BOOL)success {
    UIView *toast        = [[UIView alloc] init];
    UIColor *bgColor     = success
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
    toast.frame    = CGRectMake((CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
                                CGRectGetHeight(self.view.bounds) * 0.72f,
                                toastW, toastH);
    label.frame    = CGRectMake(16.f, 10.f, toastW - 32.f, size.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1.0f; }
                     completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL done) { [toast removeFromSuperview]; }];
        });
    }];
}

#pragma mark - Lazy Properties

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor           = TSColor_Background;
        _scrollView.alwaysBounceVertical       = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.keyboardDismissMode        = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}

// ── 不支持联系人时的占位视图 ───────────────────────────────────────────────────

- (UIView *)unsupportedPlaceholderView {
    if (!_unsupportedPlaceholderView) {
        _unsupportedPlaceholderView = [[UIView alloc] init];
        _unsupportedPlaceholderView.backgroundColor = [UIColor clearColor];
        _unsupportedPlaceholderView.hidden = YES;
    }
    return _unsupportedPlaceholderView;
}

- (UILabel *)unsupportedIconLabel {
    if (!_unsupportedIconLabel) {
        _unsupportedIconLabel               = [[UILabel alloc] init];
        _unsupportedIconLabel.text          = @"📇";
        _unsupportedIconLabel.font          = [UIFont systemFontOfSize:44.f];
        _unsupportedIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _unsupportedIconLabel;
}

- (UILabel *)unsupportedTextLabel {
    if (!_unsupportedTextLabel) {
        _unsupportedTextLabel               = [[UILabel alloc] init];
        _unsupportedTextLabel.text          = @"不支持联系人功能";
        _unsupportedTextLabel.font          = TSFont_Body;
        _unsupportedTextLabel.textColor      = TSColor_TextSecondary;
        _unsupportedTextLabel.textAlignment = NSTextAlignmentCenter;
        _unsupportedTextLabel.numberOfLines = 0;
    }
    return _unsupportedTextLabel;
}

// ── 普通联系人卡片 ─────────────────────────────────────────────────────────────

- (UIView *)normalCard {
    if (!_normalCard) {
        _normalCard                     = [[UIView alloc] init];
        _normalCard.backgroundColor     = TSColor_Card;
        _normalCard.layer.shadowColor   = [UIColor blackColor].CGColor;
        _normalCard.layer.shadowOpacity = 0.05f;
        _normalCard.layer.shadowOffset  = CGSizeMake(0, 2);
        _normalCard.layer.shadowRadius  = kCardShadowR;
        _normalCard.clipsToBounds       = NO;
    }
    return _normalCard;
}

- (UILabel *)normalHeaderLabel {
    if (!_normalHeaderLabel) {
        _normalHeaderLabel               = [[UILabel alloc] init];
        _normalHeaderLabel.font          = TSFont_H2;
        _normalHeaderLabel.textColor     = TSColor_TextPrimary;
        _normalHeaderLabel.text          = [NSString stringWithFormat:@"普通联系人（最多 %ld 个）",
                                            (long)[[[TopStepComKit sharedInstance] contact] supportMaxContacts]];
    }
    return _normalHeaderLabel;
}

- (UITableView *)normalTableView {
    if (!_normalTableView) {
        _normalTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _normalTableView.delegate         = self;
        _normalTableView.dataSource       = self;
        _normalTableView.scrollEnabled    = NO;
        _normalTableView.backgroundColor  = [UIColor clearColor];
        _normalTableView.separatorColor   = TSColor_Separator;
        _normalTableView.separatorInset   = UIEdgeInsetsMake(0, kCardPad, 0, 0);
        if (@available(iOS 15.0, *)) { _normalTableView.sectionHeaderTopPadding = 0; }
    }
    return _normalTableView;
}

- (UILabel *)normalEmptyLabel {
    if (!_normalEmptyLabel) {
        _normalEmptyLabel               = [[UILabel alloc] init];
        _normalEmptyLabel.text          = @"暂无联系人，点击下方按钮添加";
        _normalEmptyLabel.font          = TSFont_Body;
        _normalEmptyLabel.textColor     = TSColor_TextSecondary;
        _normalEmptyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _normalEmptyLabel;
}

- (UIButton *)addContactButton {
    if (!_addContactButton) {
        _addContactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addContactButton setTitle:@"+ 添加联系人" forState:UIControlStateNormal];
        [_addContactButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _addContactButton.titleLabel.font    = TSFont_Body;
        _addContactButton.backgroundColor    = [UIColor clearColor];
        _addContactButton.layer.borderColor  = TSColor_Primary.CGColor;
        _addContactButton.layer.borderWidth  = 1.5f;
        [_addContactButton addTarget:self action:@selector(addContactTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addContactButton;
}

- (UIButton *)syncContactsButton {
    if (!_syncContactsButton) {
        _syncContactsButton = [self makePrimaryButton:@"同步到设备"
                                               action:@selector(syncContactsTapped)];
        [self setSaveButton:_syncContactsButton enabled:NO];
    }
    return _syncContactsButton;
}

// ── 紧急联系人卡片 ─────────────────────────────────────────────────────────────

- (UIView *)emergencyCard {
    if (!_emergencyCard) {
        _emergencyCard                     = [[UIView alloc] init];
        _emergencyCard.backgroundColor     = TSColor_Card;
        _emergencyCard.layer.shadowColor   = [UIColor blackColor].CGColor;
        _emergencyCard.layer.shadowOpacity = 0.05f;
        _emergencyCard.layer.shadowOffset  = CGSizeMake(0, 2);
        _emergencyCard.layer.shadowRadius  = kCardShadowR;
        _emergencyCard.clipsToBounds       = NO;
    }
    return _emergencyCard;
}

- (UILabel *)emergencyHeaderLabel {
    if (!_emergencyHeaderLabel) {
        _emergencyHeaderLabel           = [[UILabel alloc] init];
        _emergencyHeaderLabel.font      = TSFont_H2;
        _emergencyHeaderLabel.textColor = TSColor_TextPrimary;
        _emergencyHeaderLabel.text      = @"紧急联系人（SOS）";
    }
    return _emergencyHeaderLabel;
}

- (UIView *)sosSwitchRow {
    if (!_sosSwitchRow) {
        _sosSwitchRow              = [[UIView alloc] init];
        _sosSwitchRow.backgroundColor = [UIColor clearColor];
    }
    return _sosSwitchRow;
}

- (UILabel *)sosSwitchLabel {
    if (!_sosSwitchLabel) {
        _sosSwitchLabel           = [[UILabel alloc] init];
        _sosSwitchLabel.text      = @"启用 SOS 紧急联系人";
        _sosSwitchLabel.font      = TSFont_Body;
        _sosSwitchLabel.textColor = TSColor_TextPrimary;
    }
    return _sosSwitchLabel;
}

- (UISwitch *)sosSwitch {
    if (!_sosSwitch) {
        _sosSwitch = [[UISwitch alloc] init];
        _sosSwitch.onTintColor = TSColor_Primary;
        [_sosSwitch addTarget:self action:@selector(sosSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _sosSwitch;
}

- (UIView *)sosSeparator {
    if (!_sosSeparator) {
        _sosSeparator                 = [[UIView alloc] init];
        _sosSeparator.backgroundColor = TSColor_Separator;
    }
    return _sosSeparator;
}

- (UILabel *)emergencyOffHintLabel {
    if (!_emergencyOffHintLabel) {
        _emergencyOffHintLabel               = [[UILabel alloc] init];
        _emergencyOffHintLabel.text          = @"打开开关后，可从通讯录选择一位紧急联系人同步到设备";
        _emergencyOffHintLabel.font          = TSFont_Body;
        _emergencyOffHintLabel.textColor     = TSColor_TextSecondary;
        _emergencyOffHintLabel.numberOfLines = 0;
        _emergencyOffHintLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _emergencyOffHintLabel;
}

- (UITableView *)emergencyTableView {
    if (!_emergencyTableView) {
        _emergencyTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _emergencyTableView.delegate        = self;
        _emergencyTableView.dataSource      = self;
        _emergencyTableView.scrollEnabled   = NO;
        _emergencyTableView.backgroundColor = [UIColor clearColor];
        _emergencyTableView.separatorColor  = TSColor_Separator;
        _emergencyTableView.separatorInset  = UIEdgeInsetsMake(0, kCardPad, 0, 0);
        if (@available(iOS 15.0, *)) { _emergencyTableView.sectionHeaderTopPadding = 0; }
    }
    return _emergencyTableView;
}

- (UILabel *)emergencyEmptyLabel {
    if (!_emergencyEmptyLabel) {
        _emergencyEmptyLabel               = [[UILabel alloc] init];
        _emergencyEmptyLabel.text          = @"暂未设置紧急联系人";
        _emergencyEmptyLabel.font          = TSFont_Body;
        _emergencyEmptyLabel.textColor     = TSColor_TextSecondary;
        _emergencyEmptyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _emergencyEmptyLabel;
}

- (UIButton *)selectEmergencyButton {
    if (!_selectEmergencyButton) {
        _selectEmergencyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectEmergencyButton setTitle:@"+ 从通讯录选择" forState:UIControlStateNormal];
        [_selectEmergencyButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _selectEmergencyButton.titleLabel.font   = TSFont_Body;
        _selectEmergencyButton.backgroundColor   = [UIColor clearColor];
        _selectEmergencyButton.layer.borderColor = TSColor_Primary.CGColor;
        _selectEmergencyButton.layer.borderWidth = 1.5f;
        [_selectEmergencyButton addTarget:self action:@selector(selectEmergencyTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectEmergencyButton;
}

- (UIButton *)saveEmergencyButton {
    if (!_saveEmergencyButton) {
        _saveEmergencyButton = [self makePrimaryButton:@"保存到设备"
                                                action:@selector(saveEmergencyTapped)];
        [self setSaveButton:_saveEmergencyButton enabled:NO];
    }
    return _saveEmergencyButton;
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
 * 创建蓝色填充主按钮
 */
- (UIButton *)makePrimaryButton:(NSString *)title action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6f] forState:UIControlStateDisabled];
    btn.titleLabel.font    = TSFont_H2;
    btn.backgroundColor    = TSColor_Primary;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
