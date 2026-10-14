//
//  TSUgreenVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSUgreenVC.h"

#import <TopStepToolKit/TopStepToolKit.h>

#import "TSDeviceCoordinator.h"
#import "TSUgreenDisplay.h"
#import "TSUgreenOverlay.h"
#import "TSUgreenViews.h"

/** 接口日志里的方法名 */
static NSString *const kTSUgreenMethodSupport = @"isSupportConfig";
static NSString *const kTSUgreenMethodFetch = @"fetchConfig:";
static NSString *const kTSUgreenMethodSet = @"setConfig:completion:";

/** 三击提示在预览上停留的时长 */
static const NSTimeInterval kTSUgreenTripleOverlayDuration = 1.5;

/** 页面加载状态 */
typedef NS_ENUM(NSInteger, TSUgreenLoadState) {
    TSUgreenLoadStateLoading = 0,
    TSUgreenLoadStateLoaded,
    TSUgreenLoadStateFailed,
    TSUgreenLoadStateUnsupported,
};

/** 读取回调 */
typedef void (^TSUgreenFetchBlock)(TSUgreenConfigModel *_Nullable config, NSError *_Nullable error);

@interface TSUgreenVC ()
// 加载状态与失败原因
@property (nonatomic, assign) TSUgreenLoadState loadState;
@property (nonatomic, strong, nullable) NSError *loadError;
// 进入页面时的 isSupportConfig
@property (nonatomic, assign) BOOL supportsConfig;
// 上次从设备读到的配置 / 页面上的编辑 / 设备回读值
@property (nonatomic, strong, nullable) TSUgreenConfigModel *baseModel;
@property (nonatomic, strong, nullable) TSUgreenConfigModel *draftModel;
@property (nonatomic, strong, nullable) TSUgreenConfigModel *lastReadModel;
// 上次读取时间 / 上次与设备一致的时间
@property (nonatomic, strong, nullable) NSDate *lastReadAt;
@property (nonatomic, strong, nullable) NSDate *syncedAt;
// 屏端预览当前视图与三击提示
@property (nonatomic, assign) TSUgreenPreviewPage previewPage;
@property (nonatomic, strong, nullable) NSNumber *tripleOverlay;
@property (nonatomic, assign) NSUInteger tripleToken;
// 保存时合并的设备端改动（用于顶部说明条）
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *mergeKeptFields;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *mergeOverrodeFields;
@property (nonatomic, strong, nullable) TSUgreenConfigModel *mergeLatestModel;
// 防止过期的读取回调覆盖页面
@property (nonatomic, assign) NSUInteger loadToken;
// 保存 / 重新读取进行中
@property (nonatomic, assign, getter=isBusy) BOOL busy;
@property (nonatomic, strong, nullable) TSUgreenHUD *hud;
// 上一次的连接状态（用于重连提示）
@property (nonatomic, assign) BOOL wasConnected;
@end

@implementation TSUgreenVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ugreen.title");
    self.hue = [TSUgreenDisplay hue];
    self.usesDock = YES;
    self.previewPage = TSUgreenPreviewPageLyrics;
    self.loadState = TSUgreenLoadStateLoading;
    self.wasConnected = self.connected;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ts_connectionChanged)
                                                 name:TSDeviceConnectionSnapshotDidChangeNotification object:nil];
}

- (void)setupViews {
    [super setupViews];
    self.dock.compact = YES;
    self.dock.secondaryTitle = TSLocalizedString(@"ugreen.dock.revert");
    __weak typeof(self) weakSelf = self;
    self.dock.onSecondaryTap = ^{ [weakSelf ts_revert]; };
}

#pragma mark - 基类钩子

/** 是否已连接：以设备协调器的「就绪」为准 */
- (BOOL)connected {
    return [TSDeviceCoordinator sharedInstance].snapshot.isReady;
}

/** 进入页面：先判断能力，支持才读取 */
- (void)reload {
    id<TSUgreenInterface> ugreen = [self ts_ugreen];
    self.supportsConfig = ugreen && [ugreen isSupportConfig];
    if (ugreen) {
        TSHsdCallLogEntry *entry = [self beginCall:kTSUgreenMethodSupport params:nil];
        [self finishCall:entry success:YES error:nil result:self.supportsConfig ? @"YES" : @"NO"];
    }
    if (!self.supportsConfig) {
        self.loadState = TSUgreenLoadStateUnsupported;
        [self render];
        return;
    }
    [self ts_loadConfig];
}

- (void)render {
    self.dirty = [self ts_changedFields].count > 0;
    [super render];
    self.reloadItem.enabled = [self ts_canReload];
}

- (NSArray<UIView *> *)buildBlocks {
    self.chips = @[@"comKit.ugreen", [TSUgreenDisplay platformName],
                   self.supportsConfig ? @"isSupportConfig = YES" : @"isSupportConfig = NO"];
    NSMutableIndexSet *hueIndexes = [NSMutableIndexSet indexSetWithIndex:0];
    if (self.supportsConfig) { [hueIndexes addIndex:2]; }
    self.chipHueIndexes = hueIndexes;
    switch (self.loadState) {
        case TSUgreenLoadStateUnsupported: return [self ts_unsupportedBlocks];
        case TSUgreenLoadStateLoading:     return @[[self loadingBlock:TSLocalizedString(@"ugreen.loading")]];
        case TSUgreenLoadStateFailed:      return @[[self ts_errorCard]];
        case TSUgreenLoadStateLoaded:      return [self ts_contentBlocks];
    }
    return @[];
}

- (TSHsdDockState)dockState {
    return [self ts_changedFields].count > 0 ? TSHsdDockStateDirty : TSHsdDockStateHidden;
}

- (NSString *)dockButtonTitle {
    return TSLocalizedString(@"ugreen.dock.save");
}

- (nullable NSString *)dockSmall {
    return self.connected ? TSLocalizedString(@"ugreen.dock.small") : TSLocalizedString(@"ugreen.dock.offline_small");
}

- (void)refreshDock {
    [super refreshDock];
    NSUInteger count = [self ts_changedFields].count;
    self.dock.message = self.connected ? [NSString stringWithFormat:TSLocalizedString(@"ugreen.dock.dirty_format"), (unsigned long)count]
                                       : TSLocalizedString(@"ugreen.dock.offline");
    self.dock.buttonEnabled = self.connected && !self.isBusy;
}

/** 返回：有未保存修改时先确认 */
- (void)handleBack {
    NSUInteger count = [self ts_changedFields].count;
    if (count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    TSUgreenAlertAction *keep = [TSUgreenAlertAction actionWithTitle:TSLocalizedString(@"general.continue_editing")
                                                               style:TSUgreenAlertActionStyleNormal handler:nil];
    TSUgreenAlertAction *discard = [TSUgreenAlertAction actionWithTitle:TSLocalizedString(@"general.discard")
                                                                  style:TSUgreenAlertActionStyleDestructive handler:^{
        weakSelf.dirty = NO;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [self ts_presentAlertWithSymbol:@"exclamationmark.triangle" tint:[TSHsdDisplay statusWarn]
                              title:TSLocalizedString(@"ugreen.discard.title")
                            message:[NSString stringWithFormat:TSLocalizedString(@"ugreen.discard.message_format"), (unsigned long)count]
                               code:nil actions:@[keep, discard]];
}

/** 右上角「重新读取」：有未保存修改时先确认 */
- (void)handleReload {
    if (![self ts_canReload]) { return; }
    NSUInteger count = [self ts_changedFields].count;
    if (count == 0) {
        [self ts_doReload];
        return;
    }
    __weak typeof(self) weakSelf = self;
    TSUgreenAlertAction *cancel = [TSUgreenAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                                                 style:TSUgreenAlertActionStyleNormal handler:nil];
    TSUgreenAlertAction *confirm = [TSUgreenAlertAction actionWithTitle:TSLocalizedString(@"ugreen.reload.confirm")
                                                                  style:TSUgreenAlertActionStyleStrong handler:^{ [weakSelf ts_doReload]; }];
    [self ts_presentAlertWithSymbol:@"arrow.clockwise" tint:self.hue
                              title:TSLocalizedString(@"ugreen.reload.title")
                            message:[NSString stringWithFormat:TSLocalizedString(@"ugreen.reload.message_format"), (unsigned long)count]
                               code:nil actions:@[cancel, confirm]];
}

/** 右上角「接口日志」：底部面板列出本页的 SDK 调用 */
- (void)openCallLog {
    NSSet<NSString *> *methods = [NSSet setWithObjects:kTSUgreenMethodSupport, kTSUgreenMethodFetch, kTSUgreenMethodSet, nil];
    NSMutableArray<UIView *> *rows = [NSMutableArray array];
    for (TSHsdCallLogEntry *entry in [TSHsdCallLog shared].entries) {
        if (![methods containsObject:entry.method]) { continue; }
        TSUgreenLogRowView *row = [[TSUgreenLogRowView alloc] init];
        [row configureWithEntry:entry];
        [rows addObject:row];
    }
    if (!rows.count) {
        [rows addObject:[self emptyWithSymbol:@"terminal" title:TSLocalizedString(@"ugreen.log.empty") text:nil code:nil]];
    }
    TSHsdSheet *sheet = [TSHsdSheet sheetWithTitle:TSLocalizedString(@"ugreen.log.title") buttonTitle:@""
                                            blocks:@[[self card:rows], [self foot:TSLocalizedString(@"ugreen.log.foot")]] onButton:nil];
    sheet.showsCloseButton = YES;
    [sheet presentFrom:self];
}

/** 保存：读取最新 → 只替换改过的字段 → 整包写入 → 回读比对 */
- (void)save {
    NSArray<NSNumber *> *changed = [self ts_changedFields];
    if (!self.connected || self.isBusy || !changed.count) { return; }
    self.busy = YES;
    [self refreshDock];
    TSUgreenConfigModel *draft = [self.draftModel copy];
    TSUgreenConfigModel *base = [self.baseModel copy];
    [self ts_showHUD:TSLocalizedString(@"ugreen.hud.prefetch") detail:[@"1/3 " stringByAppendingString:kTSUgreenMethodFetch]];
    __weak typeof(self) weakSelf = self;
    [self ts_fetchWithNote:TSLocalizedString(@"ugreen.log.prefetch") completion:^(TSUgreenConfigModel *latest, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (!latest) {
            [strongSelf ts_finishBusy];
            [strongSelf ts_alertError:error title:TSLocalizedString(@"ugreen.alert.prefetch_failed")];
            return;
        }
        [strongSelf ts_writeDraft:draft changed:changed base:base latest:latest];
    }];
}

#pragma mark - 私有方法 · 读写

/** 绿联接口（非 FitCloud / NPK / Persimwear 为 nil） */
- (nullable id<TSUgreenInterface>)ts_ugreen {
    return [TopStepComKit sharedInstance].ugreen;
}

/** 页面相对设备改过的字段 */
- (NSArray<NSNumber *> *)ts_changedFields {
    if (self.loadState != TSUgreenLoadStateLoaded || !self.baseModel || !self.draftModel) { return @[]; }
    return [TSUgreenDisplay changedFieldsFrom:self.baseModel to:self.draftModel];
}

/** 「重新读取」是否可用 */
- (BOOL)ts_canReload {
    return self.connected && self.supportsConfig && self.loadState == TSUgreenLoadStateLoaded && !self.isBusy;
}

/** 进入页面时读取 */
- (void)ts_loadConfig {
    NSUInteger token = ++self.loadToken;
    self.loadState = TSUgreenLoadStateLoading;
    self.loadError = nil;
    [self render];
    __weak typeof(self) weakSelf = self;
    [self ts_fetchWithNote:TSLocalizedString(@"ugreen.log.enter") completion:^(TSUgreenConfigModel *config, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || token != strongSelf.loadToken) { return; }
        if (!config) {
            strongSelf.loadState = TSUgreenLoadStateFailed;
            strongSelf.loadError = error;
            [strongSelf render];
            return;
        }
        [strongSelf ts_adopt:config];
        strongSelf.loadState = TSUgreenLoadStateLoaded;
        [strongSelf render];
    }];
}

/** 用户点「重新读取」 */
- (void)ts_doReload {
    self.busy = YES;
    [self refreshDock];
    [self ts_showHUD:TSLocalizedString(@"ugreen.hud.reload") detail:kTSUgreenMethodFetch];
    __weak typeof(self) weakSelf = self;
    [self ts_fetchWithNote:TSLocalizedString(@"ugreen.log.reload") completion:^(TSUgreenConfigModel *config, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf ts_finishBusy];
        if (!config) {
            [strongSelf ts_alertError:error title:TSLocalizedString(@"ugreen.alert.reload_failed")];
            return;
        }
        [strongSelf ts_adopt:config];
        [strongSelf ts_clearMergeNotice];
        [strongSelf render];
        [strongSelf ts_toast:TSLocalizedString(@"ugreen.toast.reloaded") bad:NO];
    }];
}

/** 保存第 2、3 步：合并写入，再回读 */
- (void)ts_writeDraft:(TSUgreenConfigModel *)draft changed:(NSArray<NSNumber *> *)changed
                 base:(TSUgreenConfigModel *)base latest:(TSUgreenConfigModel *)latest {
    TSUgreenConfigModel *merged = [latest copy];
    for (NSNumber *field in changed) { [TSUgreenDisplay copyField:field.integerValue from:draft to:merged]; }
    // 设备端在编辑期间改过的字段：没碰过的保留设备值，碰过的按用户选择覆盖
    NSArray<NSNumber *> *deviceChanged = [TSUgreenDisplay changedFieldsFrom:base to:latest];
    NSMutableArray<NSNumber *> *kept = [NSMutableArray array];
    NSMutableArray<NSNumber *> *overrode = [NSMutableArray array];
    for (NSNumber *field in deviceChanged) {
        if (![changed containsObject:field]) {
            [kept addObject:field];
        } else if (![[TSUgreenDisplay compareValueOfField:field.integerValue model:latest]
                     isEqualToString:[TSUgreenDisplay compareValueOfField:field.integerValue model:draft]]) {
            [overrode addObject:field];
        }
    }

    [self.hud updateText:TSLocalizedString(@"ugreen.hud.write") detail:[@"2/3 " stringByAppendingString:kTSUgreenMethodSet]];
    __weak typeof(self) weakSelf = self;
    [self ts_setConfig:merged completion:^(BOOL isSuccess, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (!isSuccess) {
            // 写入失败：页面以刚读到的设备值为底，保留用户的修改
            strongSelf.baseModel = [latest copy];
            strongSelf.lastReadModel = [latest copy];
            strongSelf.lastReadAt = [NSDate date];
            TSUgreenConfigModel *keepDraft = [latest copy];
            for (NSNumber *field in changed) { [TSUgreenDisplay copyField:field.integerValue from:draft to:keepDraft]; }
            strongSelf.draftModel = keepDraft;
            [strongSelf ts_finishBusy];
            [strongSelf ts_alertError:error title:nil];
            return;
        }
        [strongSelf ts_readBackSent:merged kept:kept overrode:overrode latest:latest];
    }];
}

/** 保存第 3 步：回读并逐字段比对 */
- (void)ts_readBackSent:(TSUgreenConfigModel *)sent kept:(NSArray<NSNumber *> *)kept
               overrode:(NSArray<NSNumber *> *)overrode latest:(TSUgreenConfigModel *)latest {
    [self.hud updateText:TSLocalizedString(@"ugreen.hud.readback") detail:[@"3/3 " stringByAppendingString:kTSUgreenMethodFetch]];
    __weak typeof(self) weakSelf = self;
    [self ts_fetchWithNote:TSLocalizedString(@"ugreen.log.readback") completion:^(TSUgreenConfigModel *readBack, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (!readBack) {
            strongSelf.baseModel = [sent copy];
            strongSelf.draftModel = [sent copy];
            [strongSelf ts_finishBusy];
            [strongSelf ts_alertError:error title:TSLocalizedString(@"ugreen.alert.readback_failed")];
            return;
        }
        [strongSelf ts_adopt:readBack];
        BOOL merged = (kept.count + overrode.count) > 0;
        strongSelf.mergeKeptFields = merged ? kept : nil;
        strongSelf.mergeOverrodeFields = merged ? overrode : nil;
        strongSelf.mergeLatestModel = merged ? [latest copy] : nil;
        NSArray<NSNumber *> *diff = [TSUgreenDisplay changedFieldsFrom:sent to:readBack];
        [strongSelf ts_finishBusy];
        if (merged) { [strongSelf.scrollView setContentOffset:CGPointMake(0, -strongSelf.scrollView.adjustedContentInset.top) animated:YES]; }
        if (diff.count) {
            [strongSelf ts_presentDiffSent:sent read:readBack fields:diff];
        } else {
            [strongSelf ts_toast:TSLocalizedString(@"ugreen.toast.saved") bad:NO];
        }
    }];
}

/** 读取并记录日志（回调在主线程） */
- (void)ts_fetchWithNote:(NSString *)note completion:(TSUgreenFetchBlock)completion {
    TSHsdCallLogEntry *entry = [self beginCall:kTSUgreenMethodFetch params:note];
    id<TSUgreenInterface> ugreen = [self ts_ugreen];
    if (!ugreen) {
        NSError *error = [NSError errorWithDomain:kTSErrorDomainUgreenName code:eTSErrorNotSupport
                                         userInfo:@{NSLocalizedDescriptionKey: @"comKit.ugreen is nil"}];
        [self finishCall:entry success:NO error:error result:nil];
        completion(nil, error);
        return;
    }
    __weak typeof(self) weakSelf = self;
    [ugreen fetchConfig:^(TSUgreenConfigModel *config, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf onMain:^{
            if (config) { entry.params = [NSString stringWithFormat:@"%@ → %@", note, config.description]; }
            [strongSelf finishCall:entry success:(config != nil) error:error result:config ? @"OK" : nil];
            completion(config, error);
        }];
    }];
}

/** 写入并记录日志（回调在主线程） */
- (void)ts_setConfig:(TSUgreenConfigModel *)config completion:(TSCompletionBlock)completion {
    TSHsdCallLogEntry *entry = [self beginCall:kTSUgreenMethodSet params:config.description];
    __weak typeof(self) weakSelf = self;
    [[self ts_ugreen] setConfig:config completion:^(BOOL isSuccess, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf onMain:^{
            [strongSelf finishCall:entry success:isSuccess error:error result:isSuccess ? @"isSuccess = YES" : nil];
            completion(isSuccess, error);
        }];
    }];
}

/** 不支持时主动调用一次 fetchConfig:，验证 SDK 直接回调 NOTSUPPORT */
- (void)ts_forceFetch {
    __weak typeof(self) weakSelf = self;
    [self ts_fetchWithNote:TSLocalizedString(@"ugreen.log.force") completion:^(TSUgreenConfigModel *config, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (config) {
            [strongSelf ts_toast:TSLocalizedString(@"ugreen.toast.reloaded") bad:NO];
            return;
        }
        NSString *text = (error.code == eTSErrorNotSupport) ? TSLocalizedString(@"ugreen.toast.notsupport")
            : [NSString stringWithFormat:TSLocalizedString(@"ugreen.toast.callback_format"), [TSUgreenDisplay errorShortName:error]];
        [strongSelf ts_toast:text bad:YES];
    }];
}

/** 以设备值为准刷新页面 */
- (void)ts_adopt:(TSUgreenConfigModel *)model {
    self.baseModel = [model copy];
    self.draftModel = [model copy];
    self.lastReadModel = [model copy];
    self.lastReadAt = [NSDate date];
    self.syncedAt = self.lastReadAt;
}

/** 结束保存 / 重读 */
- (void)ts_finishBusy {
    self.busy = NO;
    [self ts_hideHUD];
    [self render];
}

/** 还原为设备上的值 */
- (void)ts_revert {
    if (!self.baseModel || self.isBusy) { return; }
    self.draftModel = [self.baseModel copy];
    [self render];
    [self ts_toast:TSLocalizedString(@"ugreen.toast.reverted") bad:NO];
}

/** 修改草稿并切到对应的预览视图 */
- (void)ts_editDraft:(void (^)(TSUgreenConfigModel *draft))edit page:(TSUgreenPreviewPage)page {
    if (!self.draftModel || self.isBusy) { return; }
    edit(self.draftModel);
    self.previewPage = page;
    [self render];
}

/** 选三击功能：预览上闪一下目标功能 */
- (void)ts_selectTriple:(TSUgreenTriplePressFunction)function {
    if (!self.draftModel || self.isBusy) { return; }
    self.draftModel.triplePressFunction = function;
    self.tripleOverlay = @(function);
    NSUInteger token = ++self.tripleToken;
    [self render];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSUgreenTripleOverlayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || token != strongSelf.tripleToken) { return; }
        strongSelf.tripleOverlay = nil;
        [strongSelf render];
    });
}

/** 设备连接变化：刷新页面，重连时提示不会自动重读 */
- (void)ts_connectionChanged {
    __weak typeof(self) weakSelf = self;
    [self onMain:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        BOOL connected = strongSelf.connected;
        if (connected == strongSelf.wasConnected) { return; }
        strongSelf.wasConnected = connected;
        [strongSelf render];
        if (connected && strongSelf.loadState == TSUgreenLoadStateLoaded) {
            [strongSelf ts_toast:TSLocalizedString(@"ugreen.toast.reconnected") bad:NO];
        }
    }];
}

/** 清除合并说明 */
- (void)ts_clearMergeNotice {
    self.mergeKeptFields = nil;
    self.mergeOverrodeFields = nil;
    self.mergeLatestModel = nil;
}

#pragma mark - 私有方法 · 积木

/** 不支持：说明卡 + 「仍然调用 fetchConfig:」 */
- (NSArray<UIView *> *)ts_unsupportedBlocks {
    BOOL hasInterface = ([self ts_ugreen] != nil);
    NSString *codeFormat = hasInterface ? TSLocalizedString(@"ugreen.unsupported.code_format") : TSLocalizedString(@"ugreen.unsupported.code_nil_format");
    TSHsdEmptyView *empty = [self emptyWithSymbol:@"earbuds.case" title:TSLocalizedString(@"ugreen.unsupported.title")
                                             text:TSLocalizedString(@"ugreen.unsupported.text")
                                             code:[NSString stringWithFormat:codeFormat, [TSUgreenDisplay platformName]]];
    empty.hue = [TSHsdDisplay hueTools];
    if (hasInterface) {
        __weak typeof(self) weakSelf = self;
        empty.actionTitle = TSLocalizedString(@"ugreen.unsupported.force");
        empty.actionSoft = YES;
        empty.onAction = ^{ [weakSelf ts_forceFetch]; };
    }
    return @[[self card:@[empty]], [self foot:TSLocalizedString(@"ugreen.unsupported.foot")]];
}

/** 读取失败：错误卡 + 重试 */
- (UIView *)ts_errorCard {
    NSError *error = self.loadError;
    TSHsdEmptyView *empty = [self emptyWithSymbol:@"exclamationmark.triangle"
                                            title:[NSString stringWithFormat:TSLocalizedString(@"ugreen.error.load_title_format"), [TSUgreenDisplay errorTitle:error]]
                                             text:[TSUgreenDisplay errorText:error]
                                             code:[NSString stringWithFormat:@"%@ · %@", kTSUgreenMethodFetch, [TSUgreenDisplay errorCode:error]]];
    empty.hue = [TSHsdDisplay statusBad];
    empty.actionSymbol = @"arrow.clockwise";
    empty.actionTitle = TSLocalizedString(@"general.retry");
    empty.actionEnabled = self.connected;
    __weak typeof(self) weakSelf = self;
    empty.onAction = ^{ [weakSelf ts_loadConfig]; };
    return [self card:@[empty]];
}

/** 已读取：完整页面 */
- (NSArray<UIView *> *)ts_contentBlocks {
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];
    TSUgreenConfigModel *draft = self.draftModel;
    NSArray<NSNumber *> *changed = [self ts_changedFields];

    if (self.mergeKeptFields.count || self.mergeOverrodeFields.count) { [blocks addObject:[self ts_mergeBanner]]; }
    if (!self.connected) {
        TSUgreenNoticeBanner *offline = [[TSUgreenNoticeBanner alloc] init];
        offline.warn = YES;
        offline.symbol = @"wifi.slash";
        offline.text = TSLocalizedString(@"ugreen.offline_banner");
        [blocks addObject:offline];
    }
    [blocks addObject:[self ts_previewCardWithDirty:changed.count > 0]];

    // 屏幕显示：桌搭模式
    [blocks addObject:[self ts_sec:TSLocalizedString(@"ugreen.sec.display") right:@"desktopModeEnabled"]];
    __weak typeof(self) weakSelf = self;
    TSHsdRowView *deskRow = [self ts_switchRowWithSymbol:@"display" title:TSLocalizedString(@"ugreen.field.desk")
                                                subtitle:TSLocalizedString(@"ugreen.desk.sub") on:draft.isDesktopModeEnabled
                                                deviceOn:self.baseModel.isDesktopModeEnabled onToggle:^(BOOL on) {
        [weakSelf ts_editDraft:^(TSUgreenConfigModel *model) { model.desktopModeEnabled = on; } page:TSUgreenPreviewPageStand];
    }];
    [blocks addObject:[self card:@[deskRow]]];
    [blocks addObject:[self foot:TSLocalizedString(@"ugreen.desk.foot")]];

    // 常亮页面
    [blocks addObject:[self ts_sec:TSLocalizedString(@"ugreen.sec.aon")
                             right:[NSString stringWithFormat:@"alwaysOnPages = 0x%02lX", (unsigned long)draft.alwaysOnPages]]];
    [blocks addObject:[self card:@[[self ts_alwaysOnRow:TSUgreenAlwaysOnPageMusicControl], [self ts_alwaysOnRow:TSUgreenAlwaysOnPageStatus]]]];
    [blocks addObject:[self foot:TSLocalizedString(@"ugreen.aon.foot")]];

    // 充电盒三击
    [blocks addObject:[self ts_sec:TSLocalizedString(@"ugreen.sec.triple")
                             right:[NSString stringWithFormat:@"triplePressFunction = %ld", (long)draft.triplePressFunction]]];
    TSUgreenTripleChoiceView *choices = [[TSUgreenTripleChoiceView alloc] init];
    choices.hue = self.hue;
    choices.selected = draft.triplePressFunction;
    choices.deviceValue = self.baseModel.triplePressFunction;
    choices.onSelect = ^(TSUgreenTriplePressFunction function) { [weakSelf ts_selectTriple:function]; };
    [choices reload];
    [blocks addObject:choices];
    [blocks addObject:[self foot:TSLocalizedString(@"ugreen.triple.foot")]];

    // 歌词
    [blocks addObject:[self ts_sec:TSLocalizedString(@"ugreen.sec.lyrics")
                             right:[NSString stringWithFormat:@"lyricsTheme = %ld", (long)draft.lyricsTheme]]];
    [blocks addObject:[self card:@[[self ts_lyricsPanel]]]];
    [blocks addObject:[self foot:TSLocalizedString(@"ugreen.lyrics.foot")]];

    // 设备回读值
    NSString *readAt = self.lastReadAt ? [NSString stringWithFormat:TSLocalizedString(@"ugreen.readback.time_format"),
                                          [TSUgreenDisplay clockSecondsString:self.lastReadAt]] : nil;
    [blocks addObject:[self sec:TSLocalizedString(@"ugreen.sec.readback") right:readAt]];
    TSUgreenCodeBlock *code = [[TSUgreenCodeBlock alloc] init];
    code.text = self.lastReadModel.description ?: @"";
    [blocks addObject:code];

    if (!changed.count && self.syncedAt) {
        TSUgreenSyncedPill *synced = [[TSUgreenSyncedPill alloc] init];
        synced.text = [NSString stringWithFormat:TSLocalizedString(@"ugreen.synced_format"), [TSUgreenDisplay clockString:self.syncedAt]];
        [blocks addObject:synced];
    }
    return blocks;
}

/** 分组标题：右侧为等宽字段名 / 取值 */
- (TSHsdSecView *)ts_sec:(NSString *)title right:(NSString *)right {
    TSHsdSecView *sec = [self sec:title right:right];
    sec.rightMono = YES;
    return sec;
}

/** 屏端预览卡 */
- (TSUgreenPreviewCard *)ts_previewCardWithDirty:(BOOL)dirty {
    TSUgreenPreviewCard *preview = [[TSUgreenPreviewCard alloc] init];
    preview.spec = [TSUgreenScreenSpec currentSpec];
    preview.model = self.draftModel;
    preview.dirty = dirty;
    preview.page = self.previewPage;
    preview.tripleOverlay = self.tripleOverlay;
    __weak typeof(self) weakSelf = self;
    preview.onSelectPage = ^(TSUgreenPreviewPage page) {
        weakSelf.previewPage = page;
        [weakSelf render];
    };
    [preview reload];
    return preview;
}

/** 开关行：整行可点；改过时标题带圆点、副标题写出设备上的值 */
- (TSHsdRowView *)ts_switchRowWithSymbol:(NSString *)symbol title:(NSString *)title subtitle:(NSString *)subtitle
                                      on:(BOOL)on deviceOn:(BOOL)deviceOn onToggle:(void (^)(BOOL on))onToggle {
    TSHsdRowView *row = [self switchRowWithSymbol:symbol color:nil title:title subtitle:subtitle on:on onToggle:onToggle];
    BOOL modified = (on != deviceOn);
    UIFont *titleFont = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
    row.attributedTitle = [TSUgreenDisplay title:title font:titleFont color:[TSHsdDisplay ink] modifiedDotColor:modified ? self.hue : nil];
    NSMutableAttributedString *sub = [[NSMutableAttributedString alloc] initWithString:subtitle attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:12.5f], NSForegroundColorAttributeName: [TSHsdDisplay textSecondary]}];
    if (modified) {
        NSString *value = deviceOn ? TSLocalizedString(@"ugreen.value.on") : TSLocalizedString(@"ugreen.value.off");
        [sub appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:TSLocalizedString(@"ugreen.was_switch_format"), value]
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold],
                                                                                 NSForegroundColorAttributeName: self.hue}]];
    }
    row.attributedSubtitle = sub;
    row.onTap = ^{ if (onToggle) { onToggle(!on); } };
    row.accessibilityLabel = title;
    return row;
}

/** 常亮页面的一行 */
- (TSHsdRowView *)ts_alwaysOnRow:(TSUgreenAlwaysOnPage)page {
    BOOL music = (page == TSUgreenAlwaysOnPageMusicControl);
    BOOL on = (self.draftModel.alwaysOnPages & page) != 0;
    BOOL deviceOn = (self.baseModel.alwaysOnPages & page) != 0;
    TSUgreenPreviewPage previewPage = music ? TSUgreenPreviewPageMusic : TSUgreenPreviewPageStatus;
    __weak typeof(self) weakSelf = self;
    return [self ts_switchRowWithSymbol:music ? @"music.note" : @"face.smiling"
                                  title:TSLocalizedString(music ? @"ugreen.page.music" : @"ugreen.page.status")
                               subtitle:TSLocalizedString(music ? @"ugreen.page.music.sub" : @"ugreen.page.status.sub")
                                     on:on deviceOn:deviceOn onToggle:^(BOOL value) {
        [weakSelf ts_editDraft:^(TSUgreenConfigModel *model) {
            model.alwaysOnPages = value ? (model.alwaysOnPages | page) : (model.alwaysOnPages & ~page);
        } page:previewPage];
    }];
}

/** 歌词面板 */
- (TSUgreenLyricsPanel *)ts_lyricsPanel {
    TSUgreenLyricsPanel *panel = [[TSUgreenLyricsPanel alloc] init];
    panel.hue = self.hue;
    panel.theme = self.draftModel.lyricsTheme;
    panel.deviceTheme = self.baseModel.lyricsTheme;
    panel.color = self.draftModel.lyricsColor ?: [UIColor whiteColor];
    panel.deviceColor = self.baseModel.lyricsColor ?: [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    panel.onSelectTheme = ^(TSUgreenLyricsTheme theme) {
        [weakSelf ts_editDraft:^(TSUgreenConfigModel *model) { model.lyricsTheme = theme; } page:TSUgreenPreviewPageLyrics];
    };
    panel.onSelectColor = ^(NSString *hex) {
        UIColor *color = [TSUgreenDisplay colorFromHex:hex];
        if (!color) { return; }
        [weakSelf ts_editDraft:^(TSUgreenConfigModel *model) { model.lyricsColor = color; } page:TSUgreenPreviewPageLyrics];
    };
    panel.onOpenColorSheet = ^{ [weakSelf ts_openColorSheet]; };
    [panel reload];
    return panel;
}

/** 保存时合并了设备端改动的说明条 */
- (TSUgreenNoticeBanner *)ts_mergeBanner {
    NSMutableString *text = [NSMutableString string];
    NSString *separator = TSLocalizedString(@"ugreen.list_separator");
    if (self.mergeKeptFields.count) {
        NSMutableArray<NSString *> *parts = [NSMutableArray array];
        for (NSNumber *field in self.mergeKeptFields) {
            TSUgreenField f = field.integerValue;
            NSString *value = self.mergeLatestModel ? [TSUgreenDisplay displayValueOfField:f model:self.mergeLatestModel] : @"";
            [parts addObject:[NSString stringWithFormat:TSLocalizedString(@"ugreen.merge.value_format"), [TSUgreenDisplay fieldName:f], value]];
        }
        [text appendFormat:TSLocalizedString(@"ugreen.merge.kept_format"), [parts componentsJoinedByString:separator]];
    }
    if (self.mergeOverrodeFields.count) {
        NSMutableArray<NSString *> *parts = [NSMutableArray array];
        for (NSNumber *field in self.mergeOverrodeFields) {
            [parts addObject:[NSString stringWithFormat:@"<b>%@</b>", [TSUgreenDisplay fieldName:field.integerValue]]];
        }
        [text appendFormat:TSLocalizedString(@"ugreen.merge.overrode_format"), [parts componentsJoinedByString:separator]];
    }
    TSUgreenNoticeBanner *banner = [[TSUgreenNoticeBanner alloc] init];
    banner.hue = self.hue;
    banner.symbol = @"square.stack.3d.up";
    banner.text = text;
    __weak typeof(self) weakSelf = self;
    banner.onClose = ^{
        [weakSelf ts_clearMergeNotice];
        [weakSelf render];
    };
    return banner;
}

#pragma mark - 私有方法 · 面板与提示

/** 歌词颜色面板：仅「自定义」主题可用 */
- (void)ts_openColorSheet {
    if (!self.draftModel || self.isBusy) { return; }
    if (self.draftModel.lyricsTheme != TSUgreenLyricsThemeCustom) {
        [self ts_toast:TSLocalizedString(@"ugreen.toast.pick_custom") bad:NO];
        return;
    }
    __block NSString *hex = [TSUgreenDisplay hexRGBOfColor:self.draftModel.lyricsColor ?: [UIColor whiteColor]];
    TSUgreenColorPreviewBlock *preview = [[TSUgreenColorPreviewBlock alloc] init];
    preview.spec = [TSUgreenScreenSpec currentSpec];
    preview.color = [TSUgreenDisplay colorFromHex:hex] ?: [UIColor whiteColor];
    TSUgreenColorPickerBlock *picker = [[TSUgreenColorPickerBlock alloc] init];
    picker.hex = hex;
    TSUgreenLinkFootView *systemLink = [[TSUgreenLinkFootView alloc] init];
    systemLink.hue = self.hue;
    systemLink.text = TSLocalizedString(@"ugreen.color.system_text");
    systemLink.linkText = TSLocalizedString(@"ugreen.color.system_link");
    TSHsdCTAButton *apply = [[TSHsdCTAButton alloc] init];
    [apply setTitle:[NSString stringWithFormat:TSLocalizedString(@"ugreen.color.apply_format"), hex] symbol:nil];
    __weak TSUgreenColorPreviewBlock *weakPreview = preview;
    __weak TSHsdCTAButton *weakApply = apply;
    picker.onChange = ^(NSString *newHex) {
        hex = newHex;
        weakPreview.color = [TSUgreenDisplay colorFromHex:newHex] ?: [UIColor whiteColor];
        [weakApply setTitle:[NSString stringWithFormat:TSLocalizedString(@"ugreen.color.apply_format"), newHex] symbol:nil];
    };

    TSHsdSheet *sheet = [TSHsdSheet sheetWithTitle:TSLocalizedString(@"ugreen.field.color") buttonTitle:@""
                                            blocks:@[preview, [self card:@[picker]], systemLink, apply] onButton:nil];
    sheet.showsCloseButton = YES;
    __weak TSHsdSheet *weakSheet = sheet;
    __weak TSUgreenColorPickerBlock *weakPicker = picker;
    [systemLink addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
        if (weakSheet) { [weakPicker presentSystemPickerFrom:weakSheet]; }
    }] forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    apply.onTap = ^{
        [weakSheet dismiss];
        UIColor *color = [TSUgreenDisplay colorFromHex:hex];
        if (!color) { return; }
        [weakSelf ts_editDraft:^(TSUgreenConfigModel *model) { model.lyricsColor = color; } page:TSUgreenPreviewPageLyrics];
    };
    [self dismissKeyboard];
    [sheet presentFrom:self];
}

/** 回读差异面板 */
- (void)ts_presentDiffSent:(TSUgreenConfigModel *)sent read:(TSUgreenConfigModel *)read fields:(NSArray<NSNumber *> *)fields {
    NSMutableArray<TSHsdDiffItem *> *items = [NSMutableArray array];
    for (NSNumber *field in fields) {
        TSUgreenField f = field.integerValue;
        [items addObject:[TSHsdDiffItem itemWithField:[TSUgreenDisplay sdkFieldName:f]
                                                 sent:[TSUgreenDisplay sdkValueOfField:f model:sent]
                                                 read:[TSUgreenDisplay sdkValueOfField:f model:read]]];
    }
    TSHsdCTAButton *ok = [[TSHsdCTAButton alloc] init];
    [ok setTitle:TSLocalizedString(@"general.got_it") symbol:nil];
    TSHsdSheet *sheet = [TSHsdSheet sheetWithTitle:TSLocalizedString(@"ugreen.diff.title") buttonTitle:@""
                                            blocks:@[[self banner:TSLocalizedString(@"ugreen.diff.intro") warn:YES],
                                                     [TSHsdSheet diffTableCardWithItems:items], ok]
                                          onButton:nil];
    sheet.showsCloseButton = YES;
    __weak TSHsdSheet *weakSheet = sheet;
    ok.onTap = ^{ [weakSheet dismiss]; };
    [sheet presentFrom:self];
}

/** 错误弹窗：title 为空时用错误本身的标题 */
- (void)ts_alertError:(nullable NSError *)error title:(nullable NSString *)title {
    NSString *errorTitle = [TSUgreenDisplay errorTitle:error];
    NSString *errorText = [TSUgreenDisplay errorText:error];
    NSString *message = title ? [NSString stringWithFormat:TSLocalizedString(@"ugreen.error.join_format"), errorTitle, errorText] : errorText;
    TSUgreenAlertAction *ok = [TSUgreenAlertAction actionWithTitle:TSLocalizedString(@"general.got_it")
                                                             style:TSUgreenAlertActionStyleStrong handler:nil];
    [self ts_presentAlertWithSymbol:@"exclamationmark.triangle" tint:[TSHsdDisplay statusBad] title:title ?: errorTitle
                            message:message code:[TSUgreenDisplay errorCode:error] actions:@[ok]];
}

/** 弹窗 */
- (void)ts_presentAlertWithSymbol:(NSString *)symbol tint:(UIColor *)tint title:(NSString *)title message:(nullable NSString *)message
                             code:(nullable NSString *)code actions:(NSArray<TSUgreenAlertAction *> *)actions {
    TSUgreenAlertController *alert = [TSUgreenAlertController alertWithSymbol:symbol tint:tint title:title message:message code:code actions:actions];
    [alert presentFrom:self];
}

/** 提示与 HUD 的容器：盖住导航栏，与原型一致 */
- (UIView *)ts_overlayHost {
    return self.navigationController.view ?: self.view;
}

- (void)ts_toast:(NSString *)text bad:(BOOL)bad {
    [TSUgreenToast showText:text bad:bad inView:[self ts_overlayHost]];
}

- (void)ts_showHUD:(NSString *)text detail:(nullable NSString *)detail {
    [self.hud removeFromSuperview];
    self.hud = [TSUgreenHUD showInView:[self ts_overlayHost] text:text detail:detail hue:self.hue];
}

- (void)ts_hideHUD {
    [self.hud dismiss];
    self.hud = nil;
}

@end
