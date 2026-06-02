//
//  TSAIInterpreterLanguageSheetVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterLanguageSheetVC.h"

#import "TSAIInterpreterFormatter.h"
#import "TSRootVC.h"

@interface TSAIInterpreterLanguageSheetVC () <UITableViewDataSource, UITableViewDelegate>

/// 顶部小号居中标题
@property (nonatomic, strong) UILabel *sheetTitleLabel;
/// 圆角白卡承载的列表
@property (nonatomic, strong) UITableView *languageTableView;
/// 底部红色 Cancel 按钮
@property (nonatomic, strong) UIButton *cancelButton;
/// 数据源 (NSNumber 装箱的 TSAILanguage)
@property (nonatomic, copy) NSArray<NSNumber *> *languages;
/// 当前选中语言
@property (nonatomic, assign) TSAILanguage currentLanguage;
/// 标题文本
@property (nonatomic, copy) NSString *sheetTitleText;
/// 选中回调
@property (nonatomic, copy) void (^onPickHandler)(TSAILanguage);

@end

@implementation TSAIInterpreterLanguageSheetVC

#pragma mark - 生命周期

- (instancetype)initWithTitle:(NSString *)title
                     languages:(NSArray<NSNumber *> *)languages
                       current:(TSAILanguage)current
                        onPick:(void (^)(TSAILanguage))onPick {
    self = [super init];
    if (self) {
        _sheetTitleText = [title copy];
        _languages = [languages copy];
        _currentLanguage = current;
        _onPickHandler = [onPick copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self.view addSubview:self.sheetTitleLabel];
    [self.view addSubview:self.languageTableView];
    [self.view addSubview:self.cancelButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat side = 16.0;
    CGFloat innerW = width - side * 2;
    CGFloat y = 16.0;

    CGSize titleSize = [self.sheetTitleLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)];
    self.sheetTitleLabel.frame = CGRectMake(side, y, innerW, titleSize.height);
    y += titleSize.height + 12.0;

    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat cancelH = 50.0;
    CGFloat cancelY = CGRectGetHeight(self.view.bounds) - bottomInset - cancelH - 16.0;
    self.cancelButton.frame = CGRectMake(side, cancelY, innerW, cancelH);
    self.cancelButton.layer.cornerRadius = 10.0;

    CGFloat listH = cancelY - 10.0 - y;
    self.languageTableView.frame = CGRectMake(side, y, innerW, listH);
    self.languageTableView.layer.cornerRadius = 10.0;
}

#pragma mark - 私有方法

- (void)onCancelTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"TSAIInterpreterLanguageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:identifier];
    }
    TSAILanguage language = (TSAILanguage)self.languages[indexPath.row].integerValue;
    cell.textLabel.text = [TSAIInterpreterFormatter displayNameForLanguage:language];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.text = (language == TSAILanguageAuto)
        ? TSLocalizedString(@"ai_interpreter.lang_auto_hint") : nil;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    if (language == self.currentLanguage) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor labelColor];
    }
    cell.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAILanguage language = (TSAILanguage)self.languages[indexPath.row].integerValue;
    return language == TSAILanguageAuto ? 60.0 : 48.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TSAILanguage picked = (TSAILanguage)self.languages[indexPath.row].integerValue;
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.onPickHandler) weakSelf.onPickHandler(picked);
    }];
}

#pragma mark - 属性（懒加载）

- (UILabel *)sheetTitleLabel {
    if (!_sheetTitleLabel) {
        _sheetTitleLabel = [[UILabel alloc] init];
        _sheetTitleLabel.font = [UIFont systemFontOfSize:13.0];
        _sheetTitleLabel.textColor = [UIColor secondaryLabelColor];
        _sheetTitleLabel.textAlignment = NSTextAlignmentCenter;
        _sheetTitleLabel.text = self.sheetTitleText;
        _sheetTitleLabel.numberOfLines = 0;
    }
    return _sheetTitleLabel;
}

- (UITableView *)languageTableView {
    if (!_languageTableView) {
        _languageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _languageTableView.dataSource = self;
        _languageTableView.delegate = self;
        _languageTableView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        _languageTableView.separatorInset = UIEdgeInsetsMake(0, 16.0, 0, 16.0);
        _languageTableView.clipsToBounds = YES;
        _languageTableView.tableFooterView = [UIView new];
    }
    return _languageTableView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:TSLocalizedString(@"general.cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        _cancelButton.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        [_cancelButton addTarget:self action:@selector(onCancelTap)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
