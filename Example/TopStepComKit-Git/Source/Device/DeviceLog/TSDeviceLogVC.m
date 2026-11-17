#import "TSDeviceLogVC.h"

#import "TSDeviceCoordinator.h"
#import "TSDeviceLogAppearance.h"
#import "TSDeviceRealtimeLogRecorder.h"
#import "TSDeviceRealtimeLogVC.h"

@interface TSDeviceLogVC ()
@property (nonatomic, strong) id<TSPeripheralLogInterface> peripheralLog;
@property (nonatomic, strong) TSDeviceConnectionSnapshot *snapshot;
@property (nonatomic, copy) NSArray<TSFileModel *> *logFiles;
@property (nonatomic, copy) NSArray<NSURL *> *downloadedFiles;
@property (nonatomic, assign) BOOL loadingList;
@property (nonatomic, assign) BOOL deleting;
@property (nonatomic, assign) NSUInteger listRequest;
@property (nonatomic, strong, nullable) NSUUID *transferIdentifier;
@property (nonatomic, copy) NSArray<TSFileModel *> *transferFiles;
@property (nonatomic, copy) NSString *transferFolder;
@property (nonatomic, assign) NSUInteger transferIndex;
@property (nonatomic, assign) BOOL bulkTransfer;
@property (nonatomic, assign) BOOL cancelRequested;
@property (nonatomic, assign) BOOL transferHadFailure;
@property (nonatomic, strong) UIStackView *deviceArea;
@property (nonatomic, strong) UIStackView *realtimeArea;
@property (nonatomic, strong) UIStackView *fileArea;
@property (nonatomic, strong) UILabel *fileCount;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIStackView *progressCard;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *bulkButton;
@property (nonatomic, strong) UIButton *resultsButton;
@property (nonatomic, strong) UIButton *deleteAllButton;
@property (nonatomic, strong) UIStackView *noticeCard;
@property (nonatomic, strong) UILabel *noticeLabel;
@end

@implementation TSDeviceLogVC

#pragma mark - 生命周期

// 设备日志和实时日志共用 SDK 门面及连接快照。
- (void)initData {
    [super initData];
    self.peripheralLog = [TopStepComKit sharedInstance].peripheralLog;
    self.snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    self.logFiles = @[];
    self.downloadedFiles = @[];
    self.navigationItem.backButtonTitle = TSLocalizedString(@"device_log.title");
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(connectionDidChange:)
                   name:TSDeviceConnectionSnapshotDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(realtimeDidChange:)
                   name:TSDeviceRealtimeLogRecorderDidChangeNotification object:nil];
}

// 原型首页：设备信息、实时日志入口、设备文件与批量操作。
- (void)setupViews {
    TSDeviceLogNavigation(self.navigationItem);
    UILabel *title = TSDeviceLogLabel(32, UIFontWeightBold, TSDeviceLogColor(0x13261e));
    title.text = TSLocalizedString(@"device_log.title");
    title.accessibilityTraits |= UIAccessibilityTraitHeader;
    self.deviceArea = TSDeviceLogStack(@[], UILayoutConstraintAxisVertical, 0);
    self.realtimeArea = TSDeviceLogStack(@[], UILayoutConstraintAxisVertical, 0);

    UILabel *heading = TSDeviceLogLabel(15, UIFontWeightBold, TSDeviceLogColor(0x13261e));
    heading.text = TSLocalizedString(@"device_log.design.history");
    heading.accessibilityTraits |= UIAccessibilityTraitHeader;
    self.fileCount = TSDeviceLogLabel(11, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    self.refreshButton = [self textButtonWithKey:@"device_log.design.refresh" action:@selector(refreshLogList) danger:NO];
    [self.refreshButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *header = TSDeviceLogStack(@[TSDeviceLogStack(@[heading, self.fileCount],
        UILayoutConstraintAxisVertical, 3), self.refreshButton], UILayoutConstraintAxisHorizontal, 8);
    self.fileArea = TSDeviceLogStack(@[], UILayoutConstraintAxisVertical, 0);
    UILabel *description = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    description.text = TSLocalizedString(@"device_log.design.history_caption");
    UIStackView *section = TSDeviceLogStack(@[header, self.fileArea, description], UILayoutConstraintAxisVertical, 8);

    self.progressLabel = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(0x234f3d));
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = TSDeviceLogColor(0x096650);
    self.progressView.accessibilityLabel = TSLocalizedString(@"device_log.design.progress");
    self.progressCard = TSDeviceLogStack(@[self.progressLabel, self.progressView], UILayoutConstraintAxisVertical, 6);
    self.progressCard.backgroundColor = TSDeviceLogColor(0xe6f0e9);
    self.progressCard.layer.cornerRadius = 12;
    TSDeviceLogInset(self.progressCard, UIEdgeInsetsMake(10, 11, 10, 11));
    self.bulkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.bulkButton.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    [self.bulkButton addTarget:self action:@selector(bulkTapped) forControlEvents:UIControlEventTouchUpInside];
    self.resultsButton = [self textButtonWithKey:@"device_log.design.results" action:@selector(showResults) danger:NO];
    self.deleteAllButton = [self textButtonWithKey:@"device_log.design.delete_all" action:@selector(confirmDeleteAll) danger:YES];
    UIStackView *actions = TSDeviceLogStack(@[self.progressCard, self.bulkButton, self.resultsButton, self.deleteAllButton],
                                            UILayoutConstraintAxisVertical, 6);
    self.noticeLabel = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(0x22543f));
    self.noticeCard = TSDeviceLogStack(@[self.noticeLabel], UILayoutConstraintAxisVertical, 0);
    self.noticeCard.layer.cornerRadius = 11;
    self.noticeCard.hidden = YES;
    TSDeviceLogInset(self.noticeCard, UIEdgeInsetsMake(9, 11, 9, 11));
    UIStackView *content = TSDeviceLogStack(@[title, self.deviceArea, self.realtimeArea, section, actions, self.noticeCard],
                                            UILayoutConstraintAxisVertical, 13);
    [content setCustomSpacing:16 afterView:self.realtimeArea];
    TSDeviceLogInstall(content, self.view);
    [self render];
    [self refreshLogList];
}

- (void)layoutViews {
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - 页面渲染

- (UIButton *)textButtonWithKey:(NSString *)key action:(SEL)action danger:(BOOL)danger {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:
                             [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold]];
    button.titleLabel.numberOfLines = 0;
    [button setTitle:TSLocalizedString(key) forState:UIControlStateNormal];
    [button setTitleColor:TSDeviceLogColor(danger ? 0xa92e32 : 0x096650) forState:UIControlStateNormal];
    [button setTitleColor:TSDeviceLogColor(0x687971) forState:UIControlStateDisabled];
    if (action) {
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    return button;
}

- (BOOL)canUseFiles {
    return self.snapshot.isReady && [self.peripheralLog isSupport] && !self.transferIdentifier &&
           !self.loadingList && !self.deleting;
}

- (void)render {
    if (!self.isViewLoaded) {
        return;
    }
    BOOL connected = self.snapshot.isReady;
    NSString *badge = TSLocalizedString(connected ? @"device_log.design.on_device" : @"device_log.design.offline");
    [self.deviceArea.arrangedSubviews.firstObject removeFromSuperview];
    [self.deviceArea addArrangedSubview:TSDeviceLogDeviceCard(self.snapshot, badge,
        connected ? TSDeviceLogToneAccent : TSDeviceLogToneInactive)];
    [self renderRealtimeEntry];
    [self renderFiles];
    BOOL canUse = [self canUseFiles];
    BOOL canCancel = self.transferIdentifier && self.bulkTransfer && !self.cancelRequested;
    NSString *key = self.cancelRequested ? @"device_log.design.canceling"
        : (canCancel ? @"device_log.design.cancel_bulk" : @"device_log.design.download_all");
    TSDeviceLogPrimary(self.bulkButton, TSLocalizedString(key), canCancel || self.cancelRequested
        ? @"stop.fill" : @"arrow.down.to.line", canCancel, canCancel || (canUse && self.logFiles.count));
    self.refreshButton.enabled = canUse;
    self.deleteAllButton.enabled = canUse && self.logFiles.count;
    self.resultsButton.hidden = !self.downloadedFiles.count || self.transferIdentifier != nil;
    self.progressCard.hidden = self.transferIdentifier == nil;
}

- (void)renderRealtimeEntry {
    TSPeripheralRealtimeLogState state = [self.peripheralLog respondsToSelector:@selector(realtimeLogState)]
        ? [self.peripheralLog realtimeLogState] : TSPeripheralRealtimeLogStateIdle;
    NSString *key = @"device_log.design.live_idle";
    if (state == TSPeripheralRealtimeLogStateStarting) key = @"device_log.design.live_starting";
    if (state == TSPeripheralRealtimeLogStateRunning) key = @"device_log.design.live_running";
    if (state == TSPeripheralRealtimeLogStateStopping) key = @"device_log.design.live_stopping";
    UIButton *row = TSDeviceLogRow(@"waveform.path", TSLocalizedString(@"device_realtime_log.title"),
                                   TSLocalizedString(key), @"", YES, self.transferIdentifier == nil);
    TSDeviceLogCard(row, 14);
    row.backgroundColor = TSDeviceLogColor(0xe4f0e8);
    row.layer.borderColor = TSDeviceLogColor(0xcfdfd5).CGColor;
    [row addTarget:self action:@selector(openRealtime) forControlEvents:UIControlEventTouchUpInside];
    [self.realtimeArea.arrangedSubviews.firstObject removeFromSuperview];
    [self.realtimeArea addArrangedSubview:row];
}

- (void)renderFiles {
    BOOL connected = self.snapshot.isReady;
    self.fileCount.hidden = !connected || self.loadingList;
    self.fileCount.text = [NSString stringWithFormat:TSLocalizedString(@"device_log.design.file_count"),
                           (unsigned long)self.logFiles.count];
    NSMutableArray<UIButton *> *rows = [NSMutableArray array];
    BOOL canUse = [self canUseFiles];
    __weak typeof(self) weakSelf = self;
    if (connected && !self.loadingList) {
        for (TSFileModel *file in self.logFiles) {
            UIButton *row = TSDeviceLogRow(@"doc.text", file.path.lastPathComponent,
                                          TSDeviceLogBytes(file.size), @"", YES, canUse);
            [row addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
                [weakSelf showFile:file];
            }] forControlEvents:UIControlEventTouchUpInside];
            [rows addObject:row];
        }
    }
    NSString *emptyKey = !connected ? @"device_log.design.connect_caption"
        : (self.loadingList ? @"device_log.design.loading"
           : ([self.peripheralLog isSupport] ? @"device_log.design.empty" : @"device_log.design.unsupported"));
    [self.fileArea.arrangedSubviews.firstObject removeFromSuperview];
    [self.fileArea addArrangedSubview:TSDeviceLogFileList(rows, TSLocalizedString(emptyKey), 232)];
}

- (void)showNotice:(NSString *)notice error:(BOOL)error {
    self.noticeCard.hidden = notice.length == 0;
    self.noticeCard.backgroundColor = TSDeviceLogColor(error ? 0xfbe9e8 : 0xdceee5);
    self.noticeLabel.textColor = TSDeviceLogColor(error ? 0x842c32 : 0x22543f);
    self.noticeLabel.text = notice;
    if (notice.length) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notice);
    }
}

- (void)openRealtime {
    if (!self.transferIdentifier) {
        TSDeviceRealtimeLogVC *controller = [[TSDeviceRealtimeLogVC alloc] initWithPeripheralLog:self.peripheralLog];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)realtimeDidChange:(NSNotification *)notification {
    [self renderRealtimeEntry];
}

- (void)connectionDidChange:(NSNotification *)notification {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    BOOL changed = snapshot.isReady != self.snapshot.isReady ||
                   snapshot.connectionGeneration != self.snapshot.connectionGeneration;
    self.snapshot = snapshot;
    if (!changed) {
        [self render];
        return;
    }
    self.listRequest += 1;
    self.loadingList = NO;
    self.logFiles = @[];
    if (self.transferIdentifier) {
        [self finishTransferWithNotice:TSLocalizedString(@"device_log.design.interrupted") error:YES];
    }
    [self render];
    [self refreshLogList];
}

#pragma mark - 文件列表与详情

// 只使用当前连接的查询结果。
- (void)refreshLogList {
    if (![self canUseFiles]) {
        return;
    }
    self.loadingList = YES;
    NSUInteger request = ++self.listRequest;
    [self render];
    __weak typeof(self) weakSelf = self;
    [self.peripheralLog fetchPeripheralLogList:^(NSArray<TSFileModel *> *files, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || request != strongSelf.listRequest) {
                return;
            }
            strongSelf.loadingList = NO;
            strongSelf.logFiles = error ? @[] : (files ?: @[]);
            if (error) {
                [strongSelf showNotice:[strongSelf errorText:error] error:YES];
            }
            [strongSelf render];
        });
    }];
}

- (void)showFile:(TSFileModel *)file {
    if (![self canUseFiles]) {
        return;
    }
    UILabel *name = TSDeviceLogLabel(14, UIFontWeightSemibold, TSDeviceLogColor(0x13261e));
    name.text = file.path.lastPathComponent;
    UILabel *size = TSDeviceLogLabel(13, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    size.text = TSDeviceLogBytes(file.size);
    UIButton *download = [UIButton buttonWithType:UIButtonTypeSystem];
    TSDeviceLogPrimary(download, TSLocalizedString(@"device_log.design.download"), @"arrow.down.to.line", NO, YES);
    [download.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    UIButton *remove = [self textButtonWithKey:@"device_log.design.delete_one" action:NULL danger:YES];
    NSUInteger connection = self.snapshot.connectionGeneration;
    __weak typeof(self) weakSelf = self;
    [download addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.snapshot.connectionGeneration == connection && [weakSelf.logFiles containsObject:file]) {
                [weakSelf startDownload:@[file] bulk:NO];
            }
        }];
    }] forControlEvents:UIControlEventTouchUpInside];
    [remove addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.snapshot.connectionGeneration == connection) {
                [weakSelf confirmDeletion:file];
            }
        }];
    }] forControlEvents:UIControlEventTouchUpInside];
    TSDeviceLogPresentDialog(self, TSLocalizedString(@"device_log.design.file_title"), @[name, size, download, remove], YES);
}

- (void)showResults {
    UILabel *description = TSDeviceLogLabel(13, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    description.text = TSLocalizedString(@"device_log.design.results_caption");
    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithObject:description];
    __weak typeof(self) weakSelf = self;
    for (NSURL *file in self.downloadedFiles) {
        UIButton *row = TSDeviceLogRow(@"doc.text", file.lastPathComponent, @"",
                                       TSLocalizedString(@"device_log.design.export"), NO, YES);
        TSDeviceLogCard(row, 10);
        [row addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [weakSelf shareFile:file];
            }];
        }] forControlEvents:UIControlEventTouchUpInside];
        [views addObject:row];
    }
    TSDeviceLogPresentDialog(self, TSLocalizedString(@"device_log.design.results_title"), views, YES);
}

- (void)shareFile:(NSURL *)file {
    if (![[NSFileManager defaultManager] fileExistsAtPath:file.path]) {
        [self showNotice:TSLocalizedString(@"device_log.design.file_missing") error:YES];
        return;
    }
    UIActivityViewController *sheet = [[UIActivityViewController alloc] initWithActivityItems:@[file]
                                                                       applicationActivities:nil];
    sheet.popoverPresentationController.sourceView = self.bulkButton;
    sheet.popoverPresentationController.sourceRect = self.bulkButton.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - 下载

// 取消批量不会再请求新文件，手表正在传输的文件由 SDK 正常收尾。
- (void)bulkTapped {
    if (self.transferIdentifier && self.bulkTransfer && !self.cancelRequested) {
        self.cancelRequested = YES;
        [self render];
        self.progressLabel.text = TSLocalizedString(@"device_log.design.cancel_wait");
    } else if ([self canUseFiles] && self.logFiles.count) {
        [self startDownload:self.logFiles bulk:YES];
    }
}

- (void)startDownload:(NSArray<TSFileModel *> *)files bulk:(BOOL)bulk {
    if (![self canUseFiles] || !files.count) {
        return;
    }
    NSError *error = nil;
    self.transferFolder = [self createDownloadFolder:&error];
    if (!self.transferFolder) {
        [self showNotice:[self errorText:error] error:YES];
        return;
    }
    self.transferIdentifier = NSUUID.UUID;
    self.transferFiles = files;
    self.transferIndex = 0;
    self.bulkTransfer = bulk;
    self.cancelRequested = NO;
    self.transferHadFailure = NO;
    self.downloadedFiles = @[];
    [self showNotice:@"" error:NO];
    [self render];
    [self downloadNextFile];
}

- (NSString *)createDownloadFolder:(NSError **)error {
    NSURL *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                              inDomains:NSUserDomainMask].firstObject;
    NSURL *base = [documents URLByAppendingPathComponent:@"DeviceLogs" isDirectory:YES];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyyMMdd_HHmmss";
    NSString *stamp = [formatter stringFromDate:NSDate.date];
    NSString *unique = [NSString stringWithFormat:@"%@_%@", stamp, NSUUID.UUID.UUIDString];
    NSURL *folder = [base URLByAppendingPathComponent:unique isDirectory:YES];
    return [[NSFileManager defaultManager] createDirectoryAtURL:folder withIntermediateDirectories:YES
                                                    attributes:nil error:error] ? folder.path : nil;
}

// 每个成功文件立即收录到结果，后续取消或失败不会丢失结果。
- (void)downloadNextFile {
    if (self.cancelRequested || self.transferIndex == self.transferFiles.count) {
        NSString *notice = self.cancelRequested ? TSLocalizedString(@"device_log.design.canceled")
            : (self.transferHadFailure ? TSLocalizedString(@"device_log.design.partial") : @"");
        BOOL shareSingle = !self.bulkTransfer && self.downloadedFiles.count == 1 && !self.transferHadFailure;
        NSURL *file = self.downloadedFiles.firstObject;
        [self finishTransferWithNotice:notice error:self.transferHadFailure];
        if (shareSingle && self.view.window) {
            [self shareFile:file];
        }
        return;
    }
    NSUUID *operation = self.transferIdentifier;
    NSUInteger index = self.transferIndex;
    TSFileModel *file = self.transferFiles[index];
    [self updateProgress:0 forFile:file];
    __weak typeof(self) weakSelf = self;
    [self.peripheralLog startFetchPeripheralLogWithFile:file localFolderPath:self.transferFolder
        progress:^(TSFileTransferStatus state, NSInteger percent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.transferIdentifier isEqual:operation] && index == weakSelf.transferIndex) {
                    [weakSelf updateProgress:percent forFile:file];
                }
            });
        } success:^(TSFileTransferStatus state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf finishFile:file operation:operation index:index error:nil];
            });
        } failure:^(TSFileTransferStatus state, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = [weakSelf errorText:error];
                [weakSelf finishFile:file operation:operation index:index error:message];
            });
        }];
}

- (void)updateProgress:(NSInteger)percent forFile:(TSFileModel *)file {
    CGFloat progress = MIN(100, MAX(0, percent)) / 100.0;
    NSUInteger count = self.transferFiles.count;
    CGFloat total = count ? (self.transferIndex + progress) / count : 0;
    self.progressView.progress = total;
    NSString *text;
    if (self.cancelRequested) {
        text = TSLocalizedString(@"device_log.design.cancel_wait");
    } else if (self.bulkTransfer) {
        text = [NSString stringWithFormat:TSLocalizedString(@"device_log.design.bulk_progress"),
                (unsigned long)self.downloadedFiles.count, (unsigned long)count, (long)(total * 100)];
    } else {
        text = [NSString stringWithFormat:TSLocalizedString(@"device_log.design.single_progress"),
                file.path.lastPathComponent, (long)percent];
    }
    self.progressLabel.text = text;
}

- (void)finishFile:(TSFileModel *)file operation:(NSUUID *)operation index:(NSUInteger)index error:(NSString *)error {
    if (![self.transferIdentifier isEqual:operation] || self.transferIndex != index) {
        return;
    }
    NSString *folder = self.transferFolder.stringByStandardizingPath;
    NSString *candidate = [[folder stringByAppendingPathComponent:file.path] stringByStandardizingPath];
    BOOL directory = NO;
    if (!error && [candidate hasPrefix:[folder stringByAppendingString:@"/"]] &&
        [[NSFileManager defaultManager] fileExistsAtPath:candidate isDirectory:&directory] && !directory) {
        self.downloadedFiles = [self.downloadedFiles arrayByAddingObject:[NSURL fileURLWithPath:candidate]];
    } else {
        self.transferHadFailure = YES;
        if (!self.bulkTransfer) {
            [self finishTransferWithNotice:error ?: TSLocalizedString(@"device_log.design.file_missing") error:YES];
            return;
        }
    }
    self.transferIndex += 1;
    [self downloadNextFile];
}

- (void)finishTransferWithNotice:(NSString *)message error:(BOOL)error {
    NSString *saved = [NSString stringWithFormat:TSLocalizedString(@"device_log.design.downloaded_count"),
                       (unsigned long)self.downloadedFiles.count];
    self.transferIdentifier = nil;
    self.transferFiles = @[];
    self.cancelRequested = NO;
    NSString *notice = message.length ? [NSString stringWithFormat:@"%@ %@", message, saved] : saved;
    [self showNotice:notice error:error];
    [self render];
}

#pragma mark - 删除确认

- (void)confirmDeleteAll {
    [self confirmDeletion:nil];
}

// 用文件名或文件数量明确删除范围。
- (void)confirmDeletion:(TSFileModel *)file {
    if (![self canUseFiles] || !self.logFiles.count || (file && ![self.logFiles containsObject:file])) {
        return;
    }
    NSUInteger connection = self.snapshot.connectionGeneration;
    UILabel *message = TSDeviceLogLabel(13, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    message.text = file ? [NSString stringWithFormat:TSLocalizedString(@"device_log.design.delete_one_caption"),
                           file.path.lastPathComponent]
        : [NSString stringWithFormat:TSLocalizedString(@"device_log.design.delete_all_caption"),
           (unsigned long)self.logFiles.count];
    UIButton *cancel = [self textButtonWithKey:@"general.cancel" action:NULL danger:NO];
    cancel.backgroundColor = TSDeviceLogColor(0xe7eee8);
    cancel.layer.cornerRadius = 14;
    UIButton *remove = [UIButton buttonWithType:UIButtonTypeSystem];
    TSDeviceLogPrimary(remove, TSLocalizedString(@"general.delete"), @"trash", YES, YES);
    [remove.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    __weak typeof(self) weakSelf = self;
    [cancel addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }] forControlEvents:UIControlEventTouchUpInside];
    [remove addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.snapshot.connectionGeneration == connection) {
                [weakSelf deleteFile:file];
            }
        }];
    }] forControlEvents:UIControlEventTouchUpInside];
    UIStackView *actions = TSDeviceLogStack(@[cancel, remove], UILayoutConstraintAxisHorizontal, 6);
    actions.distribution = UIStackViewDistributionFillEqually;
    TSDeviceLogPresentDialog(self, TSLocalizedString(file ? @"device_log.alert.delete_one.title"
        : @"device_log.alert.delete_all.title"), @[message, actions], NO);
}

- (void)deleteFile:(TSFileModel *)file {
    if (![self canUseFiles]) {
        return;
    }
    self.deleting = YES;
    [self render];
    __weak typeof(self) weakSelf = self;
    TSCompletionBlock completion = ^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.deleting = NO;
            [strongSelf showNotice:success ? TSLocalizedString(file ? @"device_log.toast.delete_success"
                : @"device_log.toast.delete_all_success") : [strongSelf errorText:error] error:!success];
            [strongSelf render];
            [strongSelf refreshLogList];
        });
    };
    if (file) {
        [self.peripheralLog deletePeripheralLogWithFile:file completion:completion];
    } else {
        [self.peripheralLog deleteAllPeripheralLogs:completion];
    }
}

- (NSString *)errorText:(NSError *)error {
    return error.localizedDescription ?: TSLocalizedString(@"general.unknown_error");
}

@end
