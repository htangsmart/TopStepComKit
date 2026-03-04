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

@property (nonatomic, strong) UITableView              *tableView;
@property (nonatomic, strong) UIActivityIndicatorView  *loadingIndicator;
@property (nonatomic, strong) UIBarButtonItem          *saveButton;

/// 设备返回的全部支持语言
@property (nonatomic, strong) NSArray<TSLanguageModel *> *languages;
/// 当前已生效的语言（保存成功后同步更新）
@property (nonatomic, strong) TSLanguageModel          *currentLanguage;
/// 用户在列表里选中的（待保存）语言
@property (nonatomic, strong) TSLanguageModel          *selectedLanguage;

@end

@implementation TSLanguagesVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"语言设置";
    self.view.backgroundColor = TSColor_Background;

    [self ts_setupUI];
    [self ts_fetchData];
}

#pragma mark - UI Setup

- (void)ts_setupUI {
    // Table view（加载完成后淡入）
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorColor  = TSColor_Separator;
    self.tableView.alpha           = 0;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    // 加载中菊花
    self.loadingIndicator = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color              = TSColor_Primary;
    self.loadingIndicator.hidesWhenStopped   = YES;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
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

    // 右上角保存按钮（初始灰色禁用）
    self.saveButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"保存"
                               style:UIBarButtonItemStyleDone
                              target:self
                              action:@selector(ts_save)];
    self.saveButton.enabled   = NO;
    self.saveButton.tintColor = TSColor_Gray;
    self.navigationItem.rightBarButtonItem = self.saveButton;
}

#pragma mark - Fetch

- (void)ts_fetchData {
    __weak typeof(self) weakSelf = self;

    dispatch_group_t group = dispatch_group_create();
    __block NSArray<TSLanguageModel *> *fetchedLanguages = nil;
    __block TSLanguageModel            *fetchedCurrent   = nil;
    __block NSError                    *fetchError       = nil;

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
            NSString *msg = fetchError.localizedDescription ?: @"无法获取语言列表，请检查设备连接";
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@"获取失败"
                                                         message:msg
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
            return;
        }

        weakSelf.languages        = fetchedLanguages;
        weakSelf.currentLanguage  = fetchedCurrent;
        weakSelf.selectedLanguage = fetchedCurrent;

        [weakSelf.tableView reloadData];
        [UIView animateWithDuration:0.25 animations:^{ weakSelf.tableView.alpha = 1; }];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.languages.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.languages.count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%lu 种语言", (unsigned long)self.languages.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTSLanguageCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kTSLanguageCellID];
        cell.backgroundColor               = TSColor_Card;
        cell.tintColor                     = TSColor_Primary;
        cell.textLabel.font                = TSFont_Body;
        cell.textLabel.textColor           = TSColor_TextPrimary;
        cell.detailTextLabel.font          = TSFont_Caption;
        cell.detailTextLabel.textColor     = TSColor_TextSecondary;
    }

    TSLanguageModel *lang          = self.languages[indexPath.row];
    cell.textLabel.text            = lang.nativeName.length > 0 ? lang.nativeName : lang.chineseName;
    cell.detailTextLabel.text      = lang.chineseName;

    BOOL isSelected = self.selectedLanguage && (lang.type == self.selectedLanguage.type);
    cell.accessoryType = isSelected
        ? UITableViewCellAccessoryCheckmark
        : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TSLanguageModel *lang = self.languages[indexPath.row];

    // 已经是当前勾选项，不做任何更改
    if (self.selectedLanguage && lang.type == self.selectedLanguage.type) return;

    self.selectedLanguage = lang;
    [tableView reloadData];

    // 只有选择与已生效语言不同时，保存按钮才高亮
    BOOL isDirty = !self.currentLanguage || (lang.type != self.currentLanguage.type);
    self.saveButton.enabled   = isDirty;
    self.saveButton.tintColor = isDirty ? TSColor_Primary : TSColor_Gray;
}

#pragma mark - Save

- (void)ts_save {
    if (!self.selectedLanguage) return;

    // 替换右按钮为菊花
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [indicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] language]
     setLanguage:self.selectedLanguage
      completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 恢复保存按钮
            weakSelf.navigationItem.rightBarButtonItem = weakSelf.saveButton;

            if (success) {
                TSLog(@"设置语言成功: %@",
                      weakSelf.selectedLanguage.chineseName ?: weakSelf.selectedLanguage.nativeName);
                weakSelf.currentLanguage      = weakSelf.selectedLanguage;
                weakSelf.saveButton.enabled   = NO;
                weakSelf.saveButton.tintColor = TSColor_Gray;
                NSString *langName = weakSelf.selectedLanguage.chineseName
                    ?: weakSelf.selectedLanguage.nativeName ?: @"";
                [weakSelf ts_showToast:[NSString stringWithFormat:@"已切换到 %@", langName]];
            } else {
                TSLog(@"设置语言失败: %@", error.localizedDescription);
                weakSelf.saveButton.enabled   = YES;
                weakSelf.saveButton.tintColor = TSColor_Primary;

                NSString *msg = error.localizedDescription ?: @"设置语言失败，请重试";
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"保存失败"
                                                             message:msg
                                                      preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark - Toast

- (void)ts_showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text            = message;
    toast.font            = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    toast.textColor       = [UIColor whiteColor];
    toast.textAlignment   = NSTextAlignmentCenter;
    toast.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    toast.layer.cornerRadius = 18.f;
    toast.layer.masksToBounds = YES;
    toast.numberOfLines   = 0;
    toast.alpha           = 0;

    CGFloat hPad = TSSpacing_LG, vPad = TSSpacing_SM;
    CGFloat maxW = self.view.bounds.size.width - TSSpacing_XL * 2;
    CGSize  textSz = [message boundingRectWithSize:CGSizeMake(maxW - hPad * 2, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: toast.font}
                                           context:nil].size;
    CGFloat w = textSz.width  + hPad * 2;
    CGFloat h = textSz.height + vPad * 2;
    CGFloat x = (self.view.bounds.size.width - w) / 2.f;
    CGFloat y = self.view.bounds.size.height - h - TSSpacing_XL
                - self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake(x, y, w, h);

    [self.view addSubview:toast];

    [UIView animateWithDuration:0.25 animations:^{
        toast.alpha = 1;
    } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL __) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

@end
