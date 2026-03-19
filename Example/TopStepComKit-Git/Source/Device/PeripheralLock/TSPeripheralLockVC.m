//
//  TSPeripheralLockVC.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralLockVC.h"
#import "TSLockEditorVC.h"
#import "TSLockEditorSaveService.h"
#import <TopStepComKit/TopStepComKit.h>

typedef NS_ENUM(NSInteger, TSLockSection) {
    TSLockSectionScreen = 0,
    TSLockSectionGame   = 1,
    TSLockSectionCount  = 2,
};

typedef NS_ENUM(NSInteger, TSLockCardRow) {
    TSLockCardRowTitleSwitch = 0,
    TSLockCardRowPassword    = 1,
    TSLockCardRowTime        = 2,
};

static const NSInteger kTagScreenSwitch  = 900;
static const NSInteger kTagGameSwitch    = 901;
static const NSInteger kScreenLockRows   = 2;
static const NSInteger kGameLockRows     = 3;
static const NSInteger kMinutesPerDay    = 24 * 60;

@interface TSPeripheralLockVC () <UITableViewDelegate, UITableViewDataSource>

// 主列表
@property (nonatomic, strong) UITableView *tableView;
// 首次加载 loading
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
// 不支持时的占位视图
@property (nonatomic, strong) UIView *unsupportedPlaceholderView;
@property (nonatomic, strong) UILabel *unsupportedIconLabel;
@property (nonatomic, strong) UILabel *unsupportedTextLabel;
// 数据是否已加载
@property (nonatomic, assign) BOOL dataLoaded;

// 设备能力
@property (nonatomic, assign) BOOL screenLockSupported;
@property (nonatomic, assign) BOOL gameLockSupported;
@property (nonatomic, copy) NSArray<NSNumber *> *orderedSectionTypes;

// 屏幕锁状态
@property (nonatomic, assign) BOOL screenLockOn;
@property (nonatomic, copy, nullable) NSString *screenPassword;

// 游戏锁状态
@property (nonatomic, assign) BOOL gameLockOn;
@property (nonatomic, copy, nullable) NSString *gamePassword;
@property (nonatomic, assign) NSInteger gameBeginMinutes;
@property (nonatomic, assign) NSInteger gameEndMinutes;

@end

@implementation TSPeripheralLockVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"device.menu.lock");
    self.view.backgroundColor = TSColor_Background;
    self.screenLockOn = NO;
    self.screenPassword = nil;
    self.gameLockOn = NO;
    self.gamePassword = nil;
    self.gameBeginMinutes = 0;
    self.gameEndMinutes = kMinutesPerDay;
    [self ts_setupUI];
    [self ts_fetchState];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b = self.view.bounds;
    _tableView.frame = b;
    _loadingIndicator.center = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
    _unsupportedPlaceholderView.frame = b;
    CGFloat placeW = b.size.width - TSSpacing_XL * 2;
    CGFloat centerX = b.size.width / 2.f;
    _unsupportedIconLabel.frame = CGRectMake(centerX - placeW / 2.f, (b.size.height - 100.f) / 2.f - 50.f, placeW, 50.f);
    _unsupportedTextLabel.frame = CGRectMake(centerX - placeW / 2.f, CGRectGetMaxY(_unsupportedIconLabel.frame) + TSSpacing_MD, placeW, 44.f);
}

#pragma mark - 私有方法

/**
 * 初始化并添加所有子视图
 */
- (void)ts_setupUI {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.loadingIndicator];
    [self.view addSubview:self.unsupportedPlaceholderView];
    [_unsupportedPlaceholderView addSubview:self.unsupportedIconLabel];
    [_unsupportedPlaceholderView addSubview:self.unsupportedTextLabel];
    _unsupportedPlaceholderView.hidden = YES;
    [_loadingIndicator startAnimating];
}

/**
 * 查询设备能力并延迟展示结果
 */
- (void)ts_fetchState {
    [self ts_updateLockSupport];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.dataLoaded = YES;
        [weakSelf.loadingIndicator stopAnimating];
        if (weakSelf.orderedSectionTypes.count == 0) {
            weakSelf.tableView.hidden = YES;
            weakSelf.unsupportedPlaceholderView.hidden = NO;
        } else {
            weakSelf.tableView.hidden = NO;
            weakSelf.unsupportedPlaceholderView.hidden = YES;
            [weakSelf.tableView reloadData];
            [UIView animateWithDuration:0.25 animations:^{ weakSelf.tableView.alpha = 1; }];
        }
    });
}

/**
 * 根据 SDK 能力更新屏幕锁/游戏锁支持状态，并生成有序 section 列表
 */
- (void)ts_updateLockSupport {
    id<TSPeripheralLockInterface> lock = [TopStepComKit sharedInstance].peripheralLock;
    if (lock) {
        self.screenLockSupported = [lock isSupportScreenLock];
        self.gameLockSupported = [lock isSupportGameLock];
    } else {
        self.screenLockSupported = NO;
        self.gameLockSupported = NO;
    }
    NSMutableArray *order = [NSMutableArray array];
    if (self.screenLockSupported) [order addObject:@(TSLockSectionScreen)];
    if (self.gameLockSupported) [order addObject:@(TSLockSectionGame)];
    self.orderedSectionTypes = [order copy];
}

/**
 * 根据 section 下标返回对应的 TSLockSection 类型
 */
- (TSLockSection)ts_sectionTypeAtIndex:(NSInteger)sectionIndex {
    if (sectionIndex < 0 || sectionIndex >= (NSInteger)self.orderedSectionTypes.count) return TSLockSectionScreen;
    return (TSLockSection)[self.orderedSectionTypes[sectionIndex] integerValue];
}

/**
 * 将分钟数格式化为 HH:MM - HH:MM 字符串
 */
- (NSString *)ts_timeRangeStringFromStart:(NSInteger)start end:(NSInteger)end {
    NSInteger sh = start / 60, sm = start % 60;
    NSInteger eh = (end >= kMinutesPerDay) ? 24 : (end / 60);
    NSInteger em = (end >= kMinutesPerDay) ? 0 : (end % 60);
    return [NSString stringWithFormat:@"%02ld:%02ld - %02ld:%02ld", (long)sh, (long)sm, (long)eh, (long)em];
}

/**
 * 弹出通用 Alert
 */
- (void)ts_showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                             style:UIAlertActionStyleDefault
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 底部 Toast 提示
 */
- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text = message;
    toast.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor = UIColor.whiteColor;
    toast.textAlignment = NSTextAlignmentCenter;
    toast.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius = 18.f;
    toast.layer.masksToBounds = YES;
    toast.alpha = 0;
    CGFloat hPad = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: toast.font}
                                           context:nil].size;
    CGFloat w = textSz.width + hPad * 2, h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);
    [self.view addSubview:toast];
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL __) { [toast removeFromSuperview]; }];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)self.orderedSectionTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TSLockSection type = [self ts_sectionTypeAtIndex:section];
    return (type == TSLockSectionScreen) ? kScreenLockRows : kGameLockRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSLockSection type = [self ts_sectionTypeAtIndex:indexPath.section];
    if (type == TSLockSectionScreen) {
        if (indexPath.row == TSLockCardRowTitleSwitch) return [self ts_cellForScreenTitleAndSwitch:tableView];
        return [self ts_cellForPasswordRow:tableView isScreen:YES];
    }
    if (type == TSLockSectionGame) {
        if (indexPath.row == TSLockCardRowTitleSwitch) return [self ts_cellForGameTitleAndSwitch:tableView];
        if (indexPath.row == TSLockCardRowPassword) return [self ts_cellForPasswordRow:tableView isScreen:NO];
        return [self ts_cellForTimeRow:tableView];
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.f;
}

#pragma mark - Cells

/**
 * 屏幕锁标题+开关 Cell
 */
- (UITableViewCell *)ts_cellForScreenTitleAndSwitch:(UITableView *)tableView {
    static NSString *kID = @"screenTitle";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = TSFont_H2;
        cell.textLabel.textColor = TSColor_Primary;
        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = kTagScreenSwitch;
        sw.onTintColor = TSColor_Primary;
        cell.accessoryView = sw;
        [sw addTarget:self action:@selector(ts_screenSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    cell.textLabel.text = TSLocalizedString(@"lock.screen_lock");
    ((UISwitch *)cell.accessoryView).on = self.screenLockOn;
    return cell;
}

/**
 * 游戏锁标题+开关 Cell
 */
- (UITableViewCell *)ts_cellForGameTitleAndSwitch:(UITableView *)tableView {
    static NSString *kID = @"gameTitle";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kID];
        cell.backgroundColor = TSColor_Card;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = TSFont_H2;
        cell.textLabel.textColor = TSColor_Primary;
        UISwitch *sw = [[UISwitch alloc] init];
        sw.tag = kTagGameSwitch;
        sw.onTintColor = TSColor_Primary;
        cell.accessoryView = sw;
        [sw addTarget:self action:@selector(ts_gameSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    cell.textLabel.text = TSLocalizedString(@"lock.game_lock");
    ((UISwitch *)cell.accessoryView).on = self.gameLockOn;
    return cell;
}

/**
 * 密码行 Cell（屏幕锁/游戏锁通用）
 */
- (UITableViewCell *)ts_cellForPasswordRow:(UITableView *)tableView isScreen:(BOOL)isScreen {
    static NSString *kID = @"pwdRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kID];
        cell.backgroundColor = TSColor_Card;
        cell.textLabel.font = TSFont_Body;
        cell.textLabel.textColor = TSColor_TextPrimary;
        cell.detailTextLabel.font = TSFont_Body;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = TSLocalizedString(@"lock.password");
    NSString *pwd = isScreen ? self.screenPassword : self.gamePassword;
    cell.detailTextLabel.text = (pwd.length > 0) ? pwd : TSLocalizedString(@"lock.password_not_set");
    BOOL switchOn = isScreen ? self.screenLockOn : self.gameLockOn;
    cell.selectionStyle = switchOn ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    return cell;
}

/**
 * 游戏锁时间段行 Cell
 */
- (UITableViewCell *)ts_cellForTimeRow:(UITableView *)tableView {
    static NSString *kID = @"timeRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kID];
        cell.backgroundColor = TSColor_Card;
        cell.textLabel.font = TSFont_Body;
        cell.textLabel.textColor = TSColor_TextPrimary;
        cell.detailTextLabel.font = TSFont_Body;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = TSLocalizedString(@"lock.effective_time");
    cell.detailTextLabel.text = [self ts_timeRangeStringFromStart:self.gameBeginMinutes end:self.gameEndMinutes];
    cell.selectionStyle = self.gameLockOn ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSLockSection type = [self ts_sectionTypeAtIndex:indexPath.section];
    if (type == TSLockSectionScreen && indexPath.row == TSLockCardRowPassword) {
        if (!self.screenLockOn) return;
        [self ts_presentEditorForSection:TSLockSectionScreen fromSwitchON:NO];
        return;
    }
    if (type == TSLockSectionGame && (indexPath.row == TSLockCardRowPassword || indexPath.row == TSLockCardRowTime)) {
        if (!self.gameLockOn) return;
        [self ts_presentEditorForSection:TSLockSectionGame fromSwitchON:NO];
    }
}

#pragma mark - Switch

/**
 * 屏幕锁开关变化：打开时弹出编辑页，关闭时直接写入设备
 */
- (void)ts_screenSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self ts_presentEditorForSection:TSLockSectionScreen fromSwitchON:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [TSLockEditorSaveService setScreenLockEnabled:NO
                                        password:self.screenPassword
                                      completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            weakSelf.screenLockOn = NO;
            NSInteger idx = [weakSelf.orderedSectionTypes indexOfObject:@(TSLockSectionScreen)];
            if (idx != NSNotFound) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [weakSelf ts_showToast:TSLocalizedString(@"lock.save_success")];
        } else {
            sender.on = YES;
            [weakSelf ts_showToast:TSLocalizedString(@"lock.save_failed")];
        }
    }];
}

/**
 * 游戏锁开关变化：打开时弹出编辑页，关闭时直接写入设备
 */
- (void)ts_gameSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self ts_presentEditorForSection:TSLockSectionGame fromSwitchON:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [TSLockEditorSaveService setGameLockEnabled:NO
                                      password:self.gamePassword
                                 startMinutes:self.gameBeginMinutes
                                   endMinutes:self.gameEndMinutes
                                   completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            weakSelf.gameLockOn = NO;
            NSInteger idx = [weakSelf.orderedSectionTypes indexOfObject:@(TSLockSectionGame)];
            if (idx != NSNotFound) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [weakSelf ts_showToast:TSLocalizedString(@"lock.save_success")];
        } else {
            sender.on = YES;
            [weakSelf ts_showToast:TSLocalizedString(@"lock.save_failed")];
        }
    }];
}

/**
 * 弹出编辑页：fromSwitchON=YES 时取消需刷新列表使开关保持关闭
 */
- (void)ts_presentEditorForSection:(TSLockSection)section fromSwitchON:(BOOL)fromSwitchON {
    BOOL isScreen = (section == TSLockSectionScreen);
    TSLockEditorVC *vc = [[TSLockEditorVC alloc] init];
    [self ts_configureEditorVC:vc forSection:section];
    [self ts_setupEditorCallbacks:vc forSection:section fromSwitchON:fromSwitchON];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
    (void)isScreen;
}

/**
 * 配置编辑页的初始值
 */
- (void)ts_configureEditorVC:(TSLockEditorVC *)vc forSection:(TSLockSection)section {
    BOOL isScreen = (section == TSLockSectionScreen);
    vc.isScreenLock = isScreen;
    vc.pageTitle = isScreen ? TSLocalizedString(@"lock.set_password_title_screen") : TSLocalizedString(@"lock.set_password_title_game");
    if (isScreen) {
        vc.initialPassword = self.screenPassword;
        vc.initialStartMinutes = 0;
        vc.initialEndMinutes = kMinutesPerDay;
    } else {
        vc.initialPassword = self.gamePassword;
        vc.initialStartMinutes = self.gameBeginMinutes;
        vc.initialEndMinutes = self.gameEndMinutes;
    }
}

/**
 * 配置编辑页的保存/取消回调
 */
- (void)ts_setupEditorCallbacks:(TSLockEditorVC *)vc forSection:(TSLockSection)section fromSwitchON:(BOOL)fromSwitchON {
    BOOL isScreen = (section == TSLockSectionScreen);
    __weak typeof(self) weakSelf = self;
    vc.onCancel = fromSwitchON ? ^{ [weakSelf.tableView reloadData]; } : nil;
    vc.onSave = ^(NSString *password, NSInteger startMinutes, NSInteger endMinutes) {
        if (isScreen) {
            weakSelf.screenLockOn = YES;
            weakSelf.screenPassword = password.length > 0 ? password : nil;
            NSInteger idx = [weakSelf.orderedSectionTypes indexOfObject:@(TSLockSectionScreen)];
            if (idx != NSNotFound) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } else {
            weakSelf.gameLockOn = YES;
            weakSelf.gamePassword = password.length > 0 ? password : nil;
            weakSelf.gameBeginMinutes = startMinutes;
            weakSelf.gameEndMinutes = endMinutes;
            NSInteger idx = [weakSelf.orderedSectionTypes indexOfObject:@(TSLockSectionGame)];
            if (idx != NSNotFound) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        [weakSelf ts_showToast:TSLocalizedString(@"lock.save_success")];
    };
}

#pragma mark - 属性（懒加载）

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorColor = TSColor_Separator;
        _tableView.alpha = 0;
    }
    return _tableView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _loadingIndicator.color = TSColor_Primary;
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

- (UIView *)unsupportedPlaceholderView {
    if (!_unsupportedPlaceholderView) {
        _unsupportedPlaceholderView = [[UIView alloc] init];
        _unsupportedPlaceholderView.backgroundColor = [UIColor clearColor];
    }
    return _unsupportedPlaceholderView;
}

- (UILabel *)unsupportedIconLabel {
    if (!_unsupportedIconLabel) {
        _unsupportedIconLabel = [[UILabel alloc] init];
        _unsupportedIconLabel.text = @"🔒";
        _unsupportedIconLabel.font = [UIFont systemFontOfSize:44.f];
        _unsupportedIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _unsupportedIconLabel;
}

- (UILabel *)unsupportedTextLabel {
    if (!_unsupportedTextLabel) {
        _unsupportedTextLabel = [[UILabel alloc] init];
        _unsupportedTextLabel.text = TSLocalizedString(@"lock.not_supported");
        _unsupportedTextLabel.font = TSFont_Body;
        _unsupportedTextLabel.textColor = TSColor_TextSecondary;
        _unsupportedTextLabel.textAlignment = NSTextAlignmentCenter;
        _unsupportedTextLabel.numberOfLines = 0;
    }
    return _unsupportedTextLabel;
}

@end
