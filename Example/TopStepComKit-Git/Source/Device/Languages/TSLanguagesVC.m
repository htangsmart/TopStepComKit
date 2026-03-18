//
//  TSLanguagesVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/13.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSLanguagesVC.h"

static NSString *const kTSLanguageCellID = @"kTSLanguageCell";

@interface TSLanguagesVC () <UITableViewDelegate, UITableViewDataSource>

// 语言列表
@property (nonatomic, strong) UITableView *tableView;
// 加载中菊花
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
// 右上角保存按钮
@property (nonatomic, strong) UIBarButtonItem *saveButton;

/// 设备返回的全部支持语言
@property (nonatomic, strong) NSArray<TSLanguageModel *> *languages;
/// 当前已生效的语言（保存成功后同步更新）
@property (nonatomic, strong) TSLanguageModel *currentLanguage;
/// 用户在列表里选中的（待保存）语言
@property (nonatomic, strong) TSLanguageModel *selectedLanguage;

@end

@implementation TSLanguagesVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"languages.title");
    self.view.backgroundColor = TSColor_Background;

    [self setupUI];
    [self fetchData];
}

#pragma mark - 公开方法

#pragma mark - 私有方法

/**
 * 初始化 UI 布局
 */
- (void)setupUI {
    self.tableView.alpha = 0;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.loadingIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor      constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor   constraintEqualToAnchor:self.view.bottomAnchor],

        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];

    [self.loadingIndicator startAnimating];

    self.saveButton.enabled = NO;
    self.saveButton.tintColor = TSColor_Gray;
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

/**
 * 并发拉取支持语言列表与当前语言
 */
- (void)fetchData {
    __weak typeof(self) weakSelf = self;

    dispatch_group_t group = dispatch_group_create();
    __block NSArray<TSLanguageModel *> *fetchedLanguages = nil;
    __block TSLanguageModel *fetchedCurrent = nil;
    __block NSError *fetchError = nil;

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] language]
     getSupportedLanguages:^(NSArray<TSLanguageModel *> *languages, NSError *error) {
        fetchedLanguages = languages;
        if (error) fetchError = error;
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [[[TopStepComKit sharedInstance] language]
     getCurrentLanguage:^(TSLanguageModel *language, NSError *error) {
        fetchedCurrent = language;
        if (error && !fetchError) fetchError = error;
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.loadingIndicator stopAnimating];

        if (fetchedLanguages.count == 0) {
            NSString *msg = fetchError.localizedDescription ?: TSLocalizedString(@"languages.fetch_failed_hint");
            [weakSelf showAlertWithTitle:TSLocalizedString(@"languages.fetch_failed") message:msg];
            return;
        }

        weakSelf.languages = fetchedLanguages;
        weakSelf.currentLanguage = fetchedCurrent;
        weakSelf.selectedLanguage = fetchedCurrent;

        [weakSelf.tableView reloadData];
        [UIView animateWithDuration:0.25 animations:^{ weakSelf.tableView.alpha = 1; }];
    });
}

/**
 * 保存选中语言到设备
 */
- (void)saveLanguage {
    if (!self.selectedLanguage) return;

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [indicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] language]
     setLanguage:self.selectedLanguage
      completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navigationItem.rightBarButtonItem = weakSelf.saveButton;

            if (success) {
                TSLog(@"设置语言成功: %@",
                      weakSelf.selectedLanguage.chineseName ?: weakSelf.selectedLanguage.nativeName);
                weakSelf.currentLanguage = weakSelf.selectedLanguage;
                weakSelf.saveButton.enabled = NO;
                weakSelf.saveButton.tintColor = TSColor_Gray;
                NSString *langName = weakSelf.selectedLanguage.chineseName
                    ?: weakSelf.selectedLanguage.nativeName ?: @"";
                [weakSelf showToast:[NSString stringWithFormat:TSLocalizedString(@"languages.switched_format"), langName]];
            } else {
                TSLog(@"设置语言失败: %@", error.localizedDescription);
                weakSelf.saveButton.enabled = YES;
                weakSelf.saveButton.tintColor = TSColor_Primary;

                NSString *msg = error.localizedDescription ?: TSLocalizedString(@"languages.set_failed_retry");
                [weakSelf showAlertWithTitle:TSLocalizedString(@"languages.save_failed") message:msg];
            }
        });
    }];
}

/**
 * 展示单按钮 Alert 弹窗
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                             style:UIAlertActionStyleDefault
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 展示底部 Toast 提示
 */
- (void)showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text = message;
    toast.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor = [UIColor whiteColor];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    toast.layer.cornerRadius = 18.f;
    toast.layer.masksToBounds = YES;
    toast.numberOfLines = 0;
    toast.alpha = 0;

    CGFloat hPad = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: toast.font}
                                          context:nil].size;
    CGFloat w = textSz.width + hPad * 2;
    CGFloat h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);

    [self.view addSubview:toast];

    [UIView animateWithDuration:0.25 animations:^{
        toast.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL done) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.languages.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.languages.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:TSLocalizedString(@"languages.count_format"), (unsigned long)self.languages.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTSLanguageCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kTSLanguageCellID];
        cell.backgroundColor = TSColor_Card;
        cell.tintColor = TSColor_Primary;
        cell.textLabel.font = TSFont_Body;
        cell.textLabel.textColor = TSColor_TextPrimary;
        cell.detailTextLabel.font = TSFont_Caption;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
    }

    TSLanguageModel *lang = self.languages[indexPath.row];
    cell.textLabel.text = lang.nativeName.length > 0 ? lang.nativeName : lang.chineseName;
    cell.detailTextLabel.text = lang.chineseName;

    BOOL isSelected = self.selectedLanguage && (lang.type == self.selectedLanguage.type);
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TSLanguageModel *lang = self.languages[indexPath.row];

    if (self.selectedLanguage && lang.type == self.selectedLanguage.type) return;

    self.selectedLanguage = lang;
    [tableView reloadData];

    BOOL isDirty = !self.currentLanguage || (lang.type != self.currentLanguage.type);
    self.saveButton.enabled = isDirty;
    self.saveButton.tintColor = isDirty ? TSColor_Primary : TSColor_Gray;
}

#pragma mark - 属性（懒加载）

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorColor = TSColor_Separator;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _loadingIndicator.color = TSColor_Primary;
        _loadingIndicator.hidesWhenStopped = YES;
        _loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _loadingIndicator;
}

- (UIBarButtonItem *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.save")
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(saveLanguage)];
    }
    return _saveButton;
}

@end
