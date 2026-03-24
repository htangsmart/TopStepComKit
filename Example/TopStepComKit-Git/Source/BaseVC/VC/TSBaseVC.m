//
//  TSBaseVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/10.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

static const CGFloat kDefaultRowHeight  = 60.f;   // 标准单元格行高
static const CGFloat kSeparatorInset    = 60.f;   // 分隔线缩进，与图标列宽对齐

@implementation TSBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setupViews];
    [self layoutViews];
}

- (void)initData {
    self.view.backgroundColor = TSColor_Background;
}

- (void)setupViews {
    [self.view addSubview:self.sourceTableview];
}

- (void)layoutViews {
    // 使用导航栏实际高度，避免硬编码 64
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) {
        topOffset = self.view.safeAreaInsets.top;
    }
    self.sourceTableview.frame = CGRectMake(
        0, topOffset,
        self.view.frame.size.width,
        CGRectGetHeight(self.view.frame) - topOffset
    );
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self layoutViews];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kDefaultRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"kTSTableViewCell";
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row < (NSInteger)self.sourceArray.count) {
        id item = self.sourceArray[indexPath.row];
        if ([item isKindOfClass:[TSValueModel class]]) {
            [cell reloadCellWithModel:(TSValueModel *)item];
        } else {
            [cell reloadCellWithName:[self cellNameAtIndexPath:indexPath]];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helpers

- (NSString *)cellNameAtIndexPath:(NSIndexPath *)cellIndexPath {
    if (cellIndexPath.row < (NSInteger)self.sourceArray.count) {
        id item = self.sourceArray[cellIndexPath.row];
        if ([item isKindOfClass:[TSValueModel class]]) {
            return ((TSValueModel *)item).valueName;
        }
    }
    return @"";
}

#pragma mark - Lazy

- (UITableView *)sourceTableview {
    if (!_sourceTableview) {
        _sourceTableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _sourceTableview.delegate        = self;
        _sourceTableview.dataSource      = self;
        _sourceTableview.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
        _sourceTableview.separatorInset  = UIEdgeInsetsMake(0, kSeparatorInset, 0, 0);
        _sourceTableview.separatorColor  = TSColor_Separator;
        _sourceTableview.backgroundColor = TSColor_Background;
        _sourceTableview.showsVerticalScrollIndicator = YES;
        if (@available(iOS 15.0, *)) {
            _sourceTableview.sectionHeaderTopPadding = 0;
        }
    }
    return _sourceTableview;
}

#pragma mark - Alert

- (void)showAlertWithMsg:(NSString *)errorMsg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"general.hint")
                                                                   message:errorMsg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 空状态 / 加载状态

- (void)showEmptyViewWithTitle:(NSString *)title subtitle:(nullable NSString *)subtitle {
    // 先移除旧的空状态视图
    [self hideEmptyView];

    TSEmptyView *emptyView = [TSEmptyView viewWithIcon:@"tray" title:title subtitle:subtitle];
    emptyView.frame = self.sourceTableview.bounds;
    emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.sourceTableview addSubview:emptyView];
    emptyView.tag = 9001;
}

- (void)hideEmptyView {
    [[self.sourceTableview viewWithTag:9001] removeFromSuperview];
}

- (void)showLoading {
    [TSLoadingHUD showIn:self.view message:nil];
}

- (void)hideLoading {
    [TSLoadingHUD hideIn:self.view];
}

@end
