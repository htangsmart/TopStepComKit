//
//  TSDeviceLogVC.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/5/15.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSDeviceLogVC.h"

typedef NS_ENUM(NSInteger, TSDeviceLogSection) {
    TSDeviceLogSectionList    = 0,
    TSDeviceLogSectionActions = 1,
    TSDeviceLogSectionCount
};

typedef NS_ENUM(NSInteger, TSDeviceLogAction) {
    TSDeviceLogActionFetchAll = 0,
    TSDeviceLogActionCancel,
    TSDeviceLogActionDeleteAll,
    TSDeviceLogActionCount
};

#pragma mark - TSDeviceLogProgressOverlay

@interface TSDeviceLogProgressOverlay : UIView
@property (nonatomic, copy)   void (^onCancel)(void);
- (void)updateTitle:(NSString *)title percent:(NSInteger)percent detail:(nullable NSString *)detail;
- (void)setCancelHidden:(BOOL)hidden;
+ (instancetype)showIn:(UIView *)host title:(NSString *)title;
- (void)dismiss;
@end

@interface TSDeviceLogProgressOverlay ()
@property (nonatomic, strong) UIView   *card;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UILabel  *percentLabel;
@property (nonatomic, strong) UILabel  *detailLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation TSDeviceLogProgressOverlay

+ (instancetype)showIn:(UIView *)host title:(NSString *)title {
    TSDeviceLogProgressOverlay *overlay = [[self alloc] initWithFrame:host.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [overlay updateTitle:title percent:0 detail:nil];
    [host addSubview:overlay];
    return overlay;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35f];

    _card = [[UIView alloc] init];
    _card.backgroundColor = TSColor_Card;
    _card.layer.cornerRadius = TSRadius_LG;
    [self addSubview:_card];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = TSFont_H2;
    _titleLabel.textColor = TSColor_TextPrimary;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_card addSubview:_titleLabel];

    _percentLabel = [[UILabel alloc] init];
    _percentLabel.font = [UIFont systemFontOfSize:36.f weight:UIFontWeightSemibold];
    _percentLabel.textColor = TSColor_Primary;
    _percentLabel.textAlignment = NSTextAlignmentCenter;
    [_card addSubview:_percentLabel];

    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = TSFont_Caption;
    _detailLabel.textColor = TSColor_TextSecondary;
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    [_card addSubview:_detailLabel];

    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:TSLocalizedString(@"general.cancel") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = TSFont_Body;
    _cancelButton.layer.borderColor = TSColor_Primary.CGColor;
    _cancelButton.layer.borderWidth = 1.f;
    _cancelButton.layer.cornerRadius = TSRadius_SM;
    [_cancelButton addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
    [_card addSubview:_cancelButton];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cardW = MIN(280.f, CGRectGetWidth(self.bounds) - TSSpacing_XL);
    CGFloat cardH = 200.f;
    self.card.frame = CGRectMake((CGRectGetWidth(self.bounds) - cardW) / 2.f,
                                 (CGRectGetHeight(self.bounds) - cardH) / 2.f,
                                 cardW, cardH);
    CGFloat pad = TSSpacing_MD;
    self.titleLabel.frame   = CGRectMake(pad, pad, cardW - pad * 2, 22.f);
    self.percentLabel.frame = CGRectMake(pad, CGRectGetMaxY(self.titleLabel.frame) + TSSpacing_SM, cardW - pad * 2, 44.f);
    self.detailLabel.frame  = CGRectMake(pad, CGRectGetMaxY(self.percentLabel.frame) + TSSpacing_XS, cardW - pad * 2, 16.f);
    self.cancelButton.frame = CGRectMake(pad, cardH - pad - 36.f, cardW - pad * 2, 36.f);
}

- (void)updateTitle:(NSString *)title percent:(NSInteger)percent detail:(NSString *)detail {
    self.titleLabel.text = title;
    self.percentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)MAX(0, MIN(100, percent))];
    self.detailLabel.text = detail ?: @"";
}

- (void)setCancelHidden:(BOOL)hidden {
    self.cancelButton.hidden = hidden;
}

- (void)handleCancel {
    if (self.onCancel) {
        self.onCancel();
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{ self.alpha = 0; } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

#pragma mark - TSDeviceLogVC

@interface TSDeviceLogVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id<TSPeripheralLogInterface> peripheralLog;

@property (nonatomic, copy)   NSArray<TSFileModel *> *logFiles;
@property (nonatomic, assign) BOOL hasFetchedList;
@property (nonatomic, assign) BOOL isLoadingList;
@property (nonatomic, assign) BOOL isExporting;

@property (nonatomic, strong, nullable) TSDeviceLogProgressOverlay *progressOverlay;

@end

@implementation TSDeviceLogVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"device_log.title");
    self.peripheralLog = [[TopStepComKit sharedInstance] peripheralLog];
    self.logFiles = @[];
}

- (void)setupViews {
    [self.view addSubview:self.tableView];
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    self.tableView.frame = CGRectMake(0, topOffset,
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) - topOffset);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self.peripheralLog isSupport]) {
        [self showEmptyViewWithTitle:TSLocalizedString(@"device_log.unsupported.title")
                            subtitle:TSLocalizedString(@"device_log.unsupported.subtitle")];
        self.tableView.hidden = YES;
        return;
    }
    [self refreshLogList];
}

#pragma mark - 列表数据源 / 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSDeviceLogSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ((TSDeviceLogSection)section) {
        case TSDeviceLogSectionList:
            return MAX((NSInteger)self.logFiles.count, 1); // 至少一行用于占位（loading / empty）
        case TSDeviceLogSectionActions:
            return TSDeviceLogActionCount;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = TSColor_Background;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = TSFont_Caption;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.text = (section == TSDeviceLogSectionList)
        ? TSLocalizedString(@"device_log.section.list")
        : TSLocalizedString(@"device_log.section.actions");
    [header addSubview:titleLabel];
    titleLabel.frame = CGRectMake(TSSpacing_MD, 12.f,
                                   CGRectGetWidth(tableView.bounds) - TSSpacing_MD * 2, 22.f);
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    if (section == TSDeviceLogSectionList) {
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [refreshBtn setTitle:TSLocalizedString(@"device_log.action.refresh") forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = TSFont_Caption;
        [refreshBtn setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        [refreshBtn addTarget:self action:@selector(refreshLogList) forControlEvents:UIControlEventTouchUpInside];
        refreshBtn.frame = CGRectMake(CGRectGetWidth(tableView.bounds) - 80.f, 8.f, 64.f, 28.f);
        refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        refreshBtn.enabled = !self.isLoadingList;
        [header addSubview:refreshBtn];
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TSDeviceLogSectionList) {
        return [self listCellAtIndex:indexPath.row tableView:tableView];
    }
    return [self actionCellAtIndex:indexPath.row tableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == TSDeviceLogSectionList) {
        if (indexPath.row < (NSInteger)self.logFiles.count) {
            [self handleLogFileTapped:self.logFiles[indexPath.row]];
        }
        return;
    }

    switch ((TSDeviceLogAction)indexPath.row) {
        case TSDeviceLogActionFetchAll:  [self handleFetchAllTapped];  break;
        case TSDeviceLogActionCancel:    [self handleCancelTapped];    break;
        case TSDeviceLogActionDeleteAll: [self handleDeleteAllTapped]; break;
        default: break;
    }
}

#pragma mark - 单元格构建

- (TSTableViewCell *)listCellAtIndex:(NSInteger)row tableView:(UITableView *)tableView {
    static NSString *kID = @"kTSDeviceLogListCell";
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[TSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kID];
    }

    if (self.logFiles.count == 0) {
        NSString *placeholder;
        if (self.isLoadingList) {
            placeholder = TSLocalizedString(@"device_log.list.loading");
        } else if (self.hasFetchedList) {
            placeholder = TSLocalizedString(@"device_log.list.empty");
        } else {
            placeholder = TSLocalizedString(@"device_log.list.idle");
        }
        TSValueModel *model = [TSValueModel valueWithName:placeholder
                                                  kitType:eTSKitLog
                                                   vcName:nil
                                                 iconName:@"doc.text"
                                                iconColor:TSColor_Gray
                                                 subtitle:nil];
        model.enabled = NO;
        [cell reloadCellWithModel:model];
        return cell;
    }

    TSFileModel *file = self.logFiles[row];
    NSString *title = file.path.lastPathComponent.length > 0 ? file.path.lastPathComponent : file.path;
    NSString *subtitle = [self humanReadableSize:file.size];
    TSValueModel *model = [TSValueModel valueWithName:title
                                              kitType:eTSKitLog
                                               vcName:nil
                                             iconName:@"doc.text"
                                            iconColor:TSColor_Primary
                                             subtitle:subtitle];
    [cell reloadCellWithModel:model];
    return cell;
}

- (TSTableViewCell *)actionCellAtIndex:(NSInteger)row tableView:(UITableView *)tableView {
    static NSString *kID = @"kTSDeviceLogActionCell";
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[TSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kID];
    }

    TSValueModel *model;
    switch ((TSDeviceLogAction)row) {
        case TSDeviceLogActionFetchAll: {
            model = [TSValueModel valueWithName:TSLocalizedString(@"device_log.action.fetch_all")
                                        kitType:eTSKitLog
                                         vcName:nil
                                       iconName:@"arrow.down.doc"
                                      iconColor:TSColor_Primary
                                       subtitle:TSLocalizedString(@"device_log.action.fetch_all.sub")];
            model.enabled = !self.isExporting;
            break;
        }
        case TSDeviceLogActionCancel: {
            model = [TSValueModel valueWithName:TSLocalizedString(@"device_log.action.cancel")
                                        kitType:eTSKitLog
                                         vcName:nil
                                       iconName:@"stop.circle"
                                      iconColor:TSColor_Warning
                                       subtitle:TSLocalizedString(@"device_log.action.cancel.sub")];
            model.enabled = self.isExporting;
            break;
        }
        case TSDeviceLogActionDeleteAll: {
            model = [TSValueModel valueWithName:TSLocalizedString(@"device_log.action.delete_all")
                                        kitType:eTSKitLog
                                         vcName:nil
                                       iconName:@"trash"
                                      iconColor:TSColor_Danger
                                       subtitle:TSLocalizedString(@"device_log.action.delete_all.sub")];
            model.enabled = !self.isExporting;
            break;
        }
        default: break;
    }
    if (model) {
        [cell reloadCellWithModel:model];
    }
    return cell;
}

#pragma mark - 列表操作

- (void)refreshLogList {
    if (self.isLoadingList) {
        return;
    }
    self.isLoadingList = YES;
    [self.tableView reloadData];

    __weak typeof(self) weakSelf = self;
    [self.peripheralLog fetchPeripheralLogList:^(NSArray<TSFileModel *> * _Nullable logFiles, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.isLoadingList = NO;
        strongSelf.hasFetchedList = YES;
        if (error) {
            strongSelf.logFiles = @[];
            [strongSelf.tableView reloadData];
            [strongSelf showResultToast:[strongSelf descriptionForError:error] success:NO];
            return;
        }
        strongSelf.logFiles = logFiles ?: @[];
        [strongSelf.tableView reloadData];
    }];
}

- (void)handleLogFileTapped:(TSFileModel *)file {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:file.path.lastPathComponent
                                                                   message:[self humanReadableSize:file.size]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"device_log.row.download")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf downloadSingleLog:file];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"device_log.row.delete")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf confirmDeleteSingleLog:file];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - 业务：下载单文件

- (void)downloadSingleLog:(TSFileModel *)file {
    NSString *folder = [self generateLocalFolderPath];
    self.progressOverlay = [TSDeviceLogProgressOverlay showIn:self.view
                                                        title:TSLocalizedString(@"device_log.progress.downloading")];
    [self.progressOverlay setCancelHidden:YES];

    __weak typeof(self) weakSelf = self;
    [self.peripheralLog startFetchPeripheralLogWithFile:file
                                        localFolderPath:folder
                                               progress:^(TSFileTransferStatus state, NSInteger progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressOverlay updateTitle:TSLocalizedString(@"device_log.progress.downloading")
                                          percent:progress
                                           detail:nil];
        });
    } success:^(TSFileTransferStatus state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressOverlay dismiss];
            weakSelf.progressOverlay = nil;
            [weakSelf showResultToast:[NSString stringWithFormat:TSLocalizedString(@"device_log.toast.download_success_fmt"), folder]
                              success:YES];
        });
    } failure:^(TSFileTransferStatus state, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressOverlay dismiss];
            weakSelf.progressOverlay = nil;
            [weakSelf showResultToast:[weakSelf descriptionForError:error] success:NO];
        });
    }];
}

#pragma mark - 业务：删除单文件

- (void)confirmDeleteSingleLog:(TSFileModel *)file {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"device_log.alert.delete_one.title")
                                                                   message:file.path.lastPathComponent
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.delete")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteSingleLog:file];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteSingleLog:(TSFileModel *)file {
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self.peripheralLog deletePeripheralLogWithFile:file completion:^(BOOL isSuccess, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideLoading];
            if (isSuccess) {
                [weakSelf showResultToast:TSLocalizedString(@"device_log.toast.delete_success") success:YES];
                [weakSelf refreshLogList];
            } else {
                [weakSelf showResultToast:[weakSelf descriptionForError:error] success:NO];
            }
        });
    }];
}

#pragma mark - 业务：导出全部

- (void)handleFetchAllTapped {
    if (self.isExporting) {
        return;
    }

    NSString *folder = [self generateLocalFolderPath];
    self.isExporting = YES;
    [self.tableView reloadData];

    self.progressOverlay = [TSDeviceLogProgressOverlay showIn:self.view
                                                        title:TSLocalizedString(@"device_log.progress.exporting")];
    __weak typeof(self) weakSelf = self;
    self.progressOverlay.onCancel = ^{
        [weakSelf handleCancelTapped];
    };

    [self.peripheralLog startFetchAllPeripheralLogsAtLocalFolderPath:folder
                                                            progress:^(TSFileTransferStatus state, NSInteger progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressOverlay updateTitle:TSLocalizedString(@"device_log.progress.exporting")
                                          percent:progress
                                           detail:nil];
        });
    } success:^(TSFileTransferStatus state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isExporting = NO;
            [weakSelf.progressOverlay dismiss];
            weakSelf.progressOverlay = nil;
            [weakSelf.tableView reloadData];
            [weakSelf showResultToast:[NSString stringWithFormat:TSLocalizedString(@"device_log.toast.export_success_fmt"), folder]
                              success:YES];
        });
    } failure:^(TSFileTransferStatus state, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isExporting = NO;
            [weakSelf.progressOverlay dismiss];
            weakSelf.progressOverlay = nil;
            [weakSelf.tableView reloadData];
            if (state == eTSFileTransferStatusCanceled) {
                [weakSelf showResultToast:TSLocalizedString(@"device_log.toast.canceled") success:NO];
            } else {
                [weakSelf showResultToast:[weakSelf descriptionForError:error] success:NO];
            }
        });
    }];
}

#pragma mark - 业务：取消导出

- (void)handleCancelTapped {
    if (!self.isExporting) {
        return;
    }
    [self.peripheralLog cancelLogFetch:nil];
}

#pragma mark - 业务：删除全部

- (void)handleDeleteAllTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"device_log.alert.delete_all.title")
                                                                   message:TSLocalizedString(@"device_log.alert.delete_all.message")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.delete")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doDeleteAll];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doDeleteAll {
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self.peripheralLog deleteAllPeripheralLogs:^(BOOL isSuccess, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideLoading];
            if (isSuccess) {
                [weakSelf showResultToast:TSLocalizedString(@"device_log.toast.delete_all_success") success:YES];
                [weakSelf refreshLogList];
            } else {
                [weakSelf showResultToast:[weakSelf descriptionForError:error] success:NO];
            }
        });
    }];
}

#pragma mark - 辅助

/// 生成本地保存目录：Documents/DeviceLogs/<yyyyMMdd_HHmmss>，并确保目录已创建
- (NSString *)generateLocalFolderPath {
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd_HHmmss";
    NSString *stamp = [formatter stringFromDate:[NSDate date]];
    NSString *folder = [[documents stringByAppendingPathComponent:@"DeviceLogs"] stringByAppendingPathComponent:stamp];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    return folder;
}

- (NSString *)humanReadableSize:(NSUInteger)bytes {
    if (bytes < 1024) return [NSString stringWithFormat:@"%lu B", (unsigned long)bytes];
    double kb = bytes / 1024.0;
    if (kb < 1024) return [NSString stringWithFormat:@"%.1f KB", kb];
    double mb = kb / 1024.0;
    if (mb < 1024) return [NSString stringWithFormat:@"%.2f MB", mb];
    return [NSString stringWithFormat:@"%.2f GB", mb / 1024.0];
}

- (NSString *)descriptionForError:(NSError *)error {
    if (error.code == eTSErrorNotSupport) {
        return TSLocalizedString(@"general.not_supported");
    }
    return error.localizedDescription ?: TSLocalizedString(@"general.unknown_error");
}

- (void)showResultToast:(NSString *)message success:(BOOL)success {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = success
        ? [TSColor_Success colorWithAlphaComponent:0.92f]
        : [[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1.f] colorWithAlphaComponent:0.92f];
    toast.layer.cornerRadius = TSRadius_SM;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = TSFont_Body;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - TSSpacing_XL * 2;
    CGSize fit = [label sizeThatFits:CGSizeMake(maxW - TSSpacing_MD * 2, CGFLOAT_MAX)];
    CGFloat toastW = MIN(fit.width + TSSpacing_MD * 2, maxW);
    CGFloat toastH = fit.height + TSSpacing_SM * 2;
    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
                              CGRectGetHeight(self.view.bounds) * 0.78f, toastW, toastH);
    label.frame = CGRectMake(TSSpacing_MD, TSSpacing_SM, toastW - TSSpacing_MD * 2, fit.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 1.f; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 0; } completion:^(BOOL done) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 60.f, 0, 0);
        _tableView.separatorColor = TSColor_Separator;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

@end
