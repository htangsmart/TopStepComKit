//
//  TSAppLanguageVC.m
//  TopStepComKit_Example
//
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAppLanguageVC.h"
#import "TSAppLanguageManager.h"
#import "TSRootVC.h"

static NSString *const kTSAppLanguageCellID = @"TSAppLanguageCell";

/// 单行数据：code 为 nil 表示跟随系统
@interface TSAppLanguageItem : NSObject
@property (nonatomic, copy, nullable) NSString *languageCode;
@property (nonatomic, copy) NSString *displayName;
+ (instancetype)itemWithCode:(nullable NSString *)code name:(NSString *)name;
@end

@implementation TSAppLanguageItem
+ (instancetype)itemWithCode:(NSString *)code name:(NSString *)name {
    TSAppLanguageItem *item = [[TSAppLanguageItem alloc] init];
    item.languageCode = code;
    item.displayName = name;
    return item;
}
@end

@interface TSAppLanguageVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<TSAppLanguageItem *> *items;
/// 是否有待确认的选项（弹窗未关）
@property (nonatomic, assign) BOOL hasPendingSelection;
/// 待确认的语言 code，nil 表示跟随系统
@property (nonatomic, copy, nullable) NSString *pendingLanguageCode;
@end

@implementation TSAppLanguageVC

- (void)initData {
    [super initData];
    NSString *followSystem = TSLocalizedString(@"mine.follow_system");
    self.items = @[
        [TSAppLanguageItem itemWithCode:nil name:followSystem],
        [TSAppLanguageItem itemWithCode:@"en" name:@"English"],
        [TSAppLanguageItem itemWithCode:@"zh-Hans" name:@"简体中文"],
        [TSAppLanguageItem itemWithCode:@"hi" name:@"हिंदी"],
    ];
}

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    self.title = TSLocalizedString(@"mine.language_setting");
    [self.view addSubview:self.tableView];
}

- (void)layoutViews {
    CGFloat top = self.ts_navigationBarTotalHeight > 0 ? self.ts_navigationBarTotalHeight : self.view.safeAreaInsets.top;
    self.tableView.frame = CGRectMake(0, top, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - top);
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self layoutViews];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTSAppLanguageCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTSAppLanguageCellID];
        cell.backgroundColor = TSColor_Card;
        cell.tintColor = TSColor_Primary;
        cell.textLabel.font = TSFont_Body;
        cell.textLabel.textColor = TSColor_TextPrimary;
    }
    TSAppLanguageItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.displayName;

    NSString *stored = [[NSUserDefaults standardUserDefaults] stringForKey:TSAppLanguageUserDefaultsKey];
    NSString *effectiveCode = self.hasPendingSelection ? self.pendingLanguageCode : (stored.length > 0 ? stored : nil);
    BOOL isSelected = (item.languageCode.length == 0 && (effectiveCode == nil || effectiveCode.length == 0)) ||
                      (item.languageCode.length > 0 && effectiveCode != nil && [item.languageCode isEqualToString:effectiveCode]);
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSAppLanguageItem *item = self.items[indexPath.row];
    self.hasPendingSelection = YES;
    self.pendingLanguageCode = item.languageCode.length > 0 ? item.languageCode : nil;
    [tableView reloadData];

    NSString *msg = TSLocalizedString(@"mine.language_restart_hint");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"mine.language_restart_later")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.hasPendingSelection = NO;
        weakSelf.pendingLanguageCode = nil;
        [weakSelf.tableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"mine.language_restart_now")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [TSAppLanguageManager savePreferredLanguageCode:weakSelf.pendingLanguageCode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        exit(0);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 属性（懒加载）

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorColor = TSColor_Separator;
    }
    return _tableView;
}

@end
