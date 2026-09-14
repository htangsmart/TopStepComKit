//
//  TSPeripheralDialVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralDialVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSDeviceCoordinator.h"
#import "TSDialCell.h"
#import "TSDialEditorAppearance.h"
#import "TSDialEditorSheet.h"
#import "TSDialEditorState.h"
#import "TSDialEditorVC.h"
#import "TSDialPreviewView.h"

// 与已确认 HTML 对应的布局尺寸。
static const CGFloat kDialManagerMargin = 20;
static const CGFloat kDialManagerHeaderHeight = 49;
static const CGFloat kDialManagerPreviewHeight = 248;
static const CGFloat kDialManagerCellHeight = 154;
static const CGFloat kDialManagerColumnGap = 11;
static const NSTimeInterval kDialManagerQueryTimeout = 20;

@interface TSPeripheralDialVC () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
                                  UIDocumentPickerDelegate>
// 设备快照与请求代次，防止旧设备回调覆盖新设备。
@property (nonatomic, strong) TSPeripheral *peripheral;
@property (nonatomic, strong) TSPeripheralScreen *screen;
@property (nonatomic, strong) TSDialCapability *capability;
@property (nonatomic, strong) TSStorageSpace *storage;
@property (nonatomic, assign) NSUInteger sessionGeneration;
@property (nonatomic, assign) NSUInteger refreshGeneration;
@property (nonatomic, assign) NSUInteger eventGeneration;
@property (nonatomic, assign) NSUInteger operationGeneration;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL operationInProgress;
@property (nonatomic, assign) BOOL refreshPending;
@property (nonatomic, assign) BOOL hasDeviceSnapshot;
@property (nonatomic, copy) NSString *statusMessage;
// 设备表盘、当前状态与本地预览。
@property (nonatomic, copy) NSArray<TSDialModel *> *allDials;
@property (nonatomic, copy) NSArray<TSDialModel *> *visibleDials;
@property (nonatomic, strong) TSDialModel *currentDial;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *previewImages;
@property (nonatomic, assign) NSUInteger imageGeneration;
// 草稿与筛选状态。
@property (nonatomic, copy) NSArray<NSNumber *> *draftTypes;
@property (nonatomic, copy) NSDictionary<NSNumber *, UIImage *> *draftImages;
@property (nonatomic, assign) NSUInteger draftGeneration;
@property (nonatomic, assign) BOOL showsDrafts;
@property (nonatomic, assign) BOOL managing;
@property (nonatomic, assign) NSInteger selectedFilter;
// 自有导航与主内容。
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) TSDialPreviewView *currentPreview;
@property (nonatomic, strong) UILabel *previewCaption;
@property (nonatomic, strong) UILabel *currentNameLabel;
@property (nonatomic, strong) UILabel *currentDetailLabel;
@property (nonatomic, strong) UIButton *connectionButton;
@property (nonatomic, strong) UIButton *currentButton;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) UIButton *importButton;
@property (nonatomic, strong) UIButton *bannerButton;
// 页签、筛选和三列网格。
@property (nonatomic, strong) UIButton *deviceTab;
@property (nonatomic, strong) UIButton *draftTab;
@property (nonatomic, strong) UIButton *manageButton;
@property (nonatomic, strong) UIView *tabUnderline;
@property (nonatomic, strong) UIView *tabSeparator;
@property (nonatomic, copy) NSArray<UIButton *> *filterButtons;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIButton *emptyAction;
@property (nonatomic, strong) UILabel *footnoteLabel;
// 底部空间摘要。
@property (nonatomic, strong) UIView *storageBar;
@property (nonatomic, strong) UIButton *storageButton;
@property (nonatomic, strong) UILabel *storageLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIView *storageTrack;
@property (nonatomic, strong) UIView *storageFill;
// 所有详情和操作共用底部弹层。
@property (nonatomic, strong) TSDialEditorSheet *sheet;
@property (nonatomic, copy) NSString *detailDialId;
@property (nonatomic, strong) UILabel *toastLabel;
@property (nonatomic, assign) NSUInteger toastGeneration;
@property (nonatomic, assign) BOOL previousNavigationHidden;
@property (nonatomic, assign) BOOL previousPopEnabled;
// 导入会话保留文件，重试不重新选择。
@property (nonatomic, strong) NSURL *importURL;
@property (nonatomic, copy) NSString *importName;
@property (nonatomic, assign) unsigned long long importBytes;
@property (nonatomic, strong) TSPeripheral *importPeripheral;
@property (nonatomic, strong) TSDialArtifact *importArtifact;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL importing;
@property (nonatomic, assign) BOOL cancellationRequested;
@end

@implementation TSPeripheralDialVC

#pragma mark - 生命周期

// 只初始化真实数据容器，不加载原型演示数据。
- (void)initData {
    [super initData];
    self.allDials = @[];
    self.visibleDials = @[];
    self.draftTypes = @[];
    self.draftImages = @{};
    self.previewImages = [NSMutableDictionary dictionary];
    self.statusMessage = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidChange:)
        name:TSDeviceConnectionSnapshotDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingDidClear:)
        name:TSDeviceBindingDidClearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
        name:UIApplicationDidBecomeActiveNotification object:nil];
}

// 进入页面时重新取得事件所有权，并刷新设备与本机草稿。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.visible) {
        self.previousNavigationHidden = self.navigationController.navigationBarHidden;
        self.previousPopEnabled = self.navigationController.interactivePopGestureRecognizer.enabled;
    }
    self.visible = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self synchronizeConnection];
    [self registerDialEvents];
    [self reloadDrafts];
    [self refreshDevice];
}

// 系统文件选择器覆盖时保留导入会话；离开导航页面时停止查询。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.topViewController != self || self.isMovingFromParentViewController) {
        self.visible = NO;
        self.refreshGeneration++;
        self.eventGeneration++;
        self.loading = NO;
        [self.refreshControl endRefreshing];
        [self.navigationController setNavigationBarHidden:self.previousNavigationHidden animated:animated];
        self.navigationController.interactivePopGestureRecognizer.enabled = self.previousPopEnabled;
    }
}

// 安全区与旋转变化后重新排版。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

// SDK 的单一监听仅弱持有本页，不用空回调覆盖其他页面。
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentPreview suspend];
}

#pragma mark - 私有方法

// 直接还原 HTML 的导航、当前预览、入口、筛选、三列列表与空间底栏。
- (void)setupViews {
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    self.view.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
    [self.view addSubview:self.headerView];
    for (UIView *view in @[self.titleLabel, self.backButton, self.infoButton]) {
        [self.headerView addSubview:view];
    }
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.currentPreview];
    for (UIView *view in @[self.previewCaption, self.currentNameLabel, self.currentDetailLabel,
                           self.connectionButton, self.currentButton]) {
        [self.currentPreview addSubview:view];
    }
    for (UIView *view in @[self.createButton, self.importButton, self.bannerButton, self.deviceTab,
                           self.draftTab, self.manageButton, self.tabSeparator, self.tabUnderline,
                           self.collectionView, self.emptyLabel, self.emptyAction, self.footnoteLabel]) {
        [self.scrollView addSubview:view];
    }
    for (UIButton *button in self.filterButtons) {
        [self.scrollView addSubview:button];
    }
    [self.view addSubview:self.storageBar];
    [self.storageBar addSubview:self.storageButton];
    [self.storageButton addSubview:self.storageLabel];
    [self.storageButton addSubview:self.countLabel];
    [self.storageBar addSubview:self.storageTrack];
    [self.storageTrack addSubview:self.storageFill];
    [self renderPage];
}

// 所有坐标以 HTML 的 394 点内容宽度等比留白，列表本身保持三个等宽列。
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (width <= 0 || height <= 0) {
        return;
    }
    CGFloat top = self.view.safeAreaInsets.top;
    CGFloat bottom = self.view.safeAreaInsets.bottom;
    CGFloat contentWidth = width - kDialManagerMargin * 2;
    self.headerView.frame = CGRectMake(0, top, width, kDialManagerHeaderHeight);
    self.titleLabel.frame = CGRectMake(85, 0, width - 170, kDialManagerHeaderHeight);
    self.backButton.frame = CGRectMake(18, 0, 55, kDialManagerHeaderHeight);
    self.infoButton.frame = CGRectMake(width - 56, 0, 38, kDialManagerHeaderHeight);
    CGFloat storageHeight = 45 + bottom;
    self.storageBar.frame = CGRectMake(0, height - storageHeight, width, storageHeight);
    self.storageButton.frame = CGRectMake(20, 3, contentWidth, 34);
    self.storageLabel.frame = CGRectMake(0, 0, contentWidth * 0.61, 34);
    self.countLabel.frame = CGRectMake(contentWidth * 0.61, 0, contentWidth * 0.39, 34);
    self.storageTrack.frame = CGRectMake(20, 36, contentWidth, 3);
    CGFloat used = self.storage.total > 0 ?
        1 - (double)self.storage.available / self.storage.total : 0;
    self.storageFill.frame = CGRectMake(0, 0, contentWidth * MAX(0, MIN(1, used)), 3);
    CGFloat scrollTop = top + kDialManagerHeaderHeight;
    self.scrollView.frame = CGRectMake(0, scrollTop, width, MAX(0, height - scrollTop - storageHeight));
    self.currentPreview.frame = CGRectMake(0, 0, width, kDialManagerPreviewHeight);
    self.previewCaption.frame = CGRectMake(20, 15, 126, 25);
    self.connectionButton.frame = CGRectMake(width - 130, 10, 110, 34);
    self.currentNameLabel.frame = CGRectMake(20, 199, contentWidth - 102, 19);
    self.currentDetailLabel.frame = CGRectMake(20, 224, contentWidth - 102, 12);
    self.currentButton.frame = CGRectMake(width - 101, 204, 81, 33);
    self.createButton.frame = CGRectMake(20, 267, contentWidth - 103, 49);
    self.importButton.frame = CGRectMake(width - 113, 267, 93, 49);
    CGFloat sectionTop = 334;
    if (!self.bannerButton.hidden) {
        self.bannerButton.frame = CGRectMake(20, sectionTop, contentWidth, 48);
        sectionTop += 62;
    }
    CGFloat deviceTabWidth = ceil([self.deviceTab.titleLabel sizeThatFits:CGSizeMake(200, 44)].width);
    CGFloat draftLeft = 20 + deviceTabWidth + 23;
    self.deviceTab.frame = CGRectMake(20, sectionTop, deviceTabWidth, 44);
    self.draftTab.frame = CGRectMake(draftLeft, sectionTop, 77, 44);
    self.manageButton.frame = CGRectMake(width - 65, sectionTop, 45, 40);
    self.tabSeparator.frame = CGRectMake(20, sectionTop + 43, contentWidth, 1);
    self.tabUnderline.frame = CGRectMake(self.showsDrafts ? draftLeft : 20, sectionTop + 42, 21, 3);
    CGFloat listTop = sectionTop + 44;
    if (!self.showsDrafts) {
        CGFloat filterLeft = 20;
        for (UIButton *button in self.filterButtons) {
            CGFloat buttonWidth = button.tag == 3 ? 57 : 46;
            button.frame = CGRectMake(filterLeft, listTop + 15, buttonWidth, 30);
            filterLeft += buttonWidth + 7;
        }
        listTop += 61;
    } else {
        listTop += 16;
    }
    NSUInteger count = self.showsDrafts ? self.draftTypes.count : self.visibleDials.count;
    NSUInteger rows = (count + 2) / 3;
    CGFloat listHeight = rows ? rows * kDialManagerCellHeight + (rows - 1) * 16 : 166;
    self.collectionView.frame = CGRectMake(20, listTop, contentWidth, listHeight);
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGSize itemSize = CGSizeMake(floor((contentWidth - kDialManagerColumnGap * 2) / 3), kDialManagerCellHeight);
    if (!CGSizeEqualToSize(layout.itemSize, itemSize)) {
        layout.itemSize = itemSize;
        [layout invalidateLayout];
    }
    self.emptyLabel.frame = CGRectMake(35, listTop + 20, width - 70, 78);
    self.emptyAction.frame = CGRectMake((width - 138) / 2, listTop + 110, 138, 44);
    self.footnoteLabel.frame = CGRectMake(20, listTop + listHeight + 17, contentWidth, 38);
    self.scrollView.contentSize = CGSizeMake(width, CGRectGetMaxY(self.footnoteLabel.frame) + 24);
}

// 连接信息来自共享协调器，不抢占 SDK 的连接回调。
- (BOOL)isDeviceReady {
    return [TSDeviceCoordinator sharedInstance].snapshot.isReady &&
        [TopStepComKit sharedInstance].connectedPeripheral != nil;
}

// 换设备清空旧快照，断开同一设备则保留上次同步内容。
- (void)synchronizeConnection {
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    TSPeripheral *connected = [TopStepComKit sharedInstance].connectedPeripheral;
    if ([self isDeviceReady] && (self.peripheral != connected || self.sessionGeneration != snapshot.connectionGeneration)) {
        BOOL changedDevice = self.peripheral != connected;
        self.refreshGeneration++;
        self.eventGeneration++;
        self.imageGeneration++;
        self.loading = NO;
        self.peripheral = connected;
        self.sessionGeneration = snapshot.connectionGeneration;
        self.screen = connected.screenInfo;
        self.capability = [[TopStepComKit sharedInstance].dial dialCapability];
        self.storage = nil;
        if (self.operationInProgress) {
            self.operationGeneration++;
            self.importing = NO;
            [self setOperationBusy:NO];
            [self showFailure:@"设备连接已变化，请同步后确认表盘状态。" retry:nil];
        }
        if (changedDevice) {
            self.allDials = @[];
            self.currentDial = nil;
            self.hasDeviceSnapshot = NO;
            [self.previewImages removeAllObjects];
            if (!self.operationInProgress) {
                [self closeSheet];
            }
        }
    } else if (![self isDeviceReady]) {
        self.refreshGeneration++;
        self.loading = NO;
        self.managing = NO;
        [self.refreshControl endRefreshing];
        if (self.operationInProgress) {
            self.operationGeneration++;
            self.importing = NO;
            [self setOperationBusy:NO];
            [self showFailure:@"手表连接已断开，请连接后重新同步状态。" retry:nil];
        }
    }
    [self renderPage];
}

// 查询只接受当前页面、当前连接和当前代次的返回。
- (BOOL)acceptsRefresh:(NSUInteger)generation peripheral:(TSPeripheral *)peripheral {
    return self.visible && generation == self.refreshGeneration && [self isDeviceReady] &&
        peripheral == [TopStepComKit sharedInstance].connectedPeripheral && peripheral == self.peripheral;
}

// 合并连续事件，安装与切换进行中不并发发起设备查询。
- (void)refreshDevice {
    if (!self.visible || ![self isDeviceReady]) {
        [self.refreshControl endRefreshing];
        [self renderPage];
        return;
    }
    if (self.loading || self.operationInProgress) {
        self.refreshPending = YES;
        return;
    }
    self.loading = YES;
    self.refreshPending = NO;
    self.statusMessage = @"";
    NSUInteger generation = ++self.refreshGeneration;
    TSPeripheral *peripheral = self.peripheral;
    __weak typeof(self) weakSelf = self;
    [self renderPage];
    [[TopStepComKit sharedInstance].dial fetchAllDials:^(NSArray<TSDialModel *> *dials, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (![strongSelf acceptsRefresh:generation peripheral:peripheral]) {
                return;
            }
            if (error || !dials) {
                strongSelf.statusMessage = error.localizedDescription ?: @"同步失败，请重试";
            } else {
                strongSelf.allDials = dials;
                strongSelf.hasDeviceSnapshot = YES;
                strongSelf.currentDial = nil;
                for (TSDialModel *dial in dials) {
                    if (dial.isCurrent) {
                        strongSelf.currentDial = dial;
                        break;
                    }
                }
            }
            [strongSelf fetchCurrentForGeneration:generation peripheral:peripheral];
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDialManagerQueryTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if ([weakSelf acceptsRefresh:generation peripheral:peripheral] && weakSelf.loading) {
            weakSelf.refreshGeneration++;
            weakSelf.loading = NO;
            weakSelf.statusMessage = @"同步超时，请检查连接后重试";
            [weakSelf.refreshControl endRefreshing];
            [weakSelf renderPage];
        }
    });
}

// 查询当前表盘；查询失败时保留列表中已明确上报的 isCurrent。
- (void)fetchCurrentForGeneration:(NSUInteger)generation peripheral:(TSPeripheral *)peripheral {
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial fetchCurrentDial:^(TSDialModel *dial, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsRefresh:generation peripheral:peripheral]) {
                return;
            }
            if (!error) {
                weakSelf.currentDial = dial;
            } else if (!weakSelf.currentDial) {
                weakSelf.statusMessage = @"当前表盘读取失败，点此重试";
            }
            [weakSelf fetchStorageForGeneration:generation peripheral:peripheral];
        });
    }];
}

// 空间查询失败时不把未知当作零；不显示伪造的容量条。
- (void)fetchStorageForGeneration:(NSUInteger)generation peripheral:(TSPeripheral *)peripheral {
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial fetchDialStorage:^(TSStorageSpace *storage, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsRefresh:generation peripheral:peripheral]) {
                return;
            }
            weakSelf.storage = error ? nil : storage;
            weakSelf.loading = NO;
            [weakSelf.refreshControl endRefreshing];
            [weakSelf reloadPreviewImages];
            [weakSelf renderPage];
            if (weakSelf.detailDialId.length && weakSelf.sheet && !weakSelf.operationInProgress) {
                TSDialModel *detail = [weakSelf dialWithIdentifier:weakSelf.detailDialId];
                if (detail) {
                    [weakSelf showDialDetail:detail];
                } else {
                    [weakSelf closeSheet];
                }
            }
            if (weakSelf.refreshPending) {
                weakSelf.refreshPending = NO;
                [weakSelf refreshDevice];
            }
        });
    }];
}

// 监听单一表盘变化通道，统一回查列表、当前和空间，不猜测变化来源。
- (void)registerDialEvents {
    if (![self isDeviceReady]) {
        return;
    }
    NSUInteger generation = ++self.eventGeneration;
    TSPeripheral *peripheral = self.peripheral;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial registerDialListDidChangeHandler:
        ^(NSArray<TSDialModel *> *dials, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf.visible || generation != weakSelf.eventGeneration ||
                peripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
                return;
            }
            if (error) {
                weakSelf.statusMessage = @"表盘状态同步失败，点此重试";
                [weakSelf renderPage];
            } else {
                [weakSelf refreshDevice];
            }
        });
    }];
}

// 后台加载旧编辑器已经保存的成品图，不在滚动过程中反复读磁盘。
- (void)reloadPreviewImages {
    NSUInteger generation = ++self.imageGeneration;
    NSArray<TSDialModel *> *dials = self.currentDial ? [self.allDials arrayByAddingObject:self.currentDial] : self.allDials;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSMutableDictionary *images = [NSMutableDictionary dictionary];
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
                               stringByAppendingPathComponent:@"dialPreviews"];
        for (TSDialModel *dial in dials) {
            NSString *identifier = dial.dialId;
            if (!identifier.length || ![identifier isEqualToString:identifier.lastPathComponent]) {
                continue;
            }
            NSString *path = [directory stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                images[identifier] = image;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != weakSelf.imageGeneration) {
                return;
            }
            [weakSelf.previewImages addEntriesFromDictionary:images];
            [weakSelf renderPage];
            for (UIView *view in weakSelf.sheet.contentView.subviews) {
                if ([view isKindOfClass:TSDialPreviewView.class] && weakSelf.detailDialId.length) {
                    [(TSDialPreviewView *)view configureWithInstalledImage:images[weakSelf.detailDialId] screen:weakSelf.screen];
                }
            }
        });
    });
}

// 草稿只来自本地存储，默认编辑背景不会生成虚假的草稿卡片。
- (void)reloadDrafts {
    NSUInteger generation = ++self.draftGeneration;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray<NSNumber *> *types = [TSDialEditorState savedDraftTypes];
        NSMutableDictionary *images = [NSMutableDictionary dictionary];
        for (NSNumber *type in types) {
            UIImage *image = [TSDialEditorState savedThumbnailForType:type.integerValue];
            if (image) {
                images[type] = image;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation == weakSelf.draftGeneration) {
                weakSelf.draftTypes = types;
                weakSelf.draftImages = images;
                [weakSelf renderPage];
            }
        });
    });
}

// 查找设备返回的完整表盘模型，不根据 UI 标题重建标识。
- (TSDialModel *)dialWithIdentifier:(NSString *)identifier {
    for (TSDialModel *dial in self.allDials) {
        if ([dial.dialId isEqualToString:identifier]) {
            return dial;
        }
    }
    return [self.currentDial.dialId isEqualToString:identifier] ? self.currentDial : nil;
}

// 表盘来源标签。
- (NSString *)sourceForDial:(TSDialModel *)dial {
    switch (dial.dialType) {
        case eTSDialTypeBuiltIn: return @"内置";
        case eTSDialTypeCloud: return @"云端";
        case eTSDialTypeCustomer: return @"自定义";
        default: return @"其他";
    }
}

// 缺少名称时展示稳定标识，不伪造风景名称。
- (NSString *)nameForDial:(TSDialModel *)dial {
    return dial.dialName.length ? dial.dialName :
        dial.dialId.length ? [NSString stringWithFormat:@"%@表盘 %@", [self sourceForDial:dial], dial.dialId] : @"表盘";
}

// 四种创作入口使用已确认文案。
- (NSString *)titleForDraftType:(TSDialDraftType)type {
    switch (type) {
        case TSDialDraftTypeSingleImage: return @"照片表盘";
        case TSDialDraftTypeMultipleImage: return @"相册表盘";
        case TSDialDraftTypeVideo: return @"视频表盘";
        case TSDialDraftTypeDanMu: return @"弹幕表盘";
    }
    return @"表盘草稿";
}

// 最大可推送数量对应云端与自定义表盘，不包括内置表盘。
- (NSUInteger)installedCount {
    NSUInteger count = 0;
    for (TSDialModel *dial in self.allDials) {
        if (dial.dialType == eTSDialTypeCloud || dial.dialType == eTSDialTypeCustomer) {
            count++;
        }
    }
    return count;
}

// 字节与空间显示保持统一。
- (NSString *)formattedBytes:(unsigned long long)bytes {
    return [NSString stringWithFormat:@"%.1f MB", bytes / (1024.0 * 1024.0)];
}

// 页签数量使用 HTML 的独立小字号。
- (void)updateTab:(UIButton *)button title:(NSString *)title count:(NSUInteger)count selected:(BOOL)selected {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize:15 weight:selected ? UIFontWeightSemibold : UIFontWeightRegular],
        NSForegroundColorAttributeName:[TSDialEditorAppearance color:selected ? 0x252823 : 0x8D9485]}];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:
        [NSString stringWithFormat:@"  %lu", (unsigned long)count] attributes:@{
            NSFontAttributeName:[UIFont systemFontOfSize:11],
            NSForegroundColorAttributeName:[TSDialEditorAppearance color:0x8C9382]}]];
    [button setAttributedTitle:text forState:UIControlStateNormal];
}

// 单次渲染统一更新当前、分类、空态和空间，避免页面各区显示不同快照。
- (void)renderPage {
    BOOL connected = [self isDeviceReady];
    NSArray<NSNumber *> *filterTypes = @[@(-1), @(eTSDialTypeBuiltIn), @(eTSDialTypeCloud), @(eTSDialTypeCustomer)];
    NSMutableArray *filtered = [NSMutableArray array];
    for (TSDialModel *dial in self.allDials) {
        if (self.selectedFilter == 0 || dial.dialType == filterTypes[self.selectedFilter].integerValue) {
            [filtered addObject:dial];
        }
    }
    self.visibleDials = filtered;
    [self.currentPreview configureWithInstalledImage:self.previewImages[self.currentDial.dialId ?: @""] screen:self.screen];
    self.previewCaption.text = connected ? @"C U R R E N T  F A C E" : @"L A S T  S Y N C E D";
    self.currentNameLabel.text = self.currentDial ? [self nameForDial:self.currentDial] :
        self.loading ? @"正在同步表盘…" : @"还没有表盘信息";
    self.currentDetailLabel.text = self.currentDial ?
        [NSString stringWithFormat:@"%@表盘 · %@", [self sourceForDial:self.currentDial], connected ? @"当前使用" : @"上次同步"] :
        connected ? @"同步后查看当前表盘" : @"连接手表后同步当前表盘";
    [self.connectionButton setTitle:connected ? @"● 手表已连接" : @"● 手表未连接" forState:UIControlStateNormal];
    [self.currentButton setTitle:connected ? @"✓ 使用中" : @"查看详情" forState:UIControlStateNormal];
    self.currentButton.hidden = !self.currentDial;
    NSString *banner = !connected ? @"手表未连接，展示上次同步的表盘。  重新连接" : self.statusMessage;
    self.bannerButton.hidden = banner.length == 0;
    [self.bannerButton setTitle:banner forState:UIControlStateNormal];
    [self updateTab:self.deviceTab title:@"手表中的表盘" count:self.allDials.count selected:!self.showsDrafts];
    [self updateTab:self.draftTab title:@"草稿" count:self.draftTypes.count selected:self.showsDrafts];
    [self.deviceTab setTitleColor:[TSDialEditorAppearance color:self.showsDrafts ? 0x8D9485 : 0x252823]
                        forState:UIControlStateNormal];
    [self.draftTab setTitleColor:[TSDialEditorAppearance color:self.showsDrafts ? 0x252823 : 0x8D9485]
                       forState:UIControlStateNormal];
    self.deviceTab.titleLabel.font = [UIFont systemFontOfSize:15 weight:self.showsDrafts ? UIFontWeightRegular : UIFontWeightSemibold];
    self.draftTab.titleLabel.font = [UIFont systemFontOfSize:15 weight:self.showsDrafts ? UIFontWeightSemibold : UIFontWeightRegular];
    self.deviceTab.accessibilityTraits = UIAccessibilityTraitButton | (!self.showsDrafts ? UIAccessibilityTraitSelected : 0);
    self.draftTab.accessibilityTraits = UIAccessibilityTraitButton | (self.showsDrafts ? UIAccessibilityTraitSelected : 0);
    self.manageButton.hidden = self.showsDrafts;
    self.manageButton.enabled = connected && !self.loading && !self.operationInProgress && self.allDials.count > 0;
    [self.manageButton setTitle:self.managing ? @"完成" : @"管理" forState:UIControlStateNormal];
    for (UIButton *button in self.filterButtons) {
        BOOL selected = button.tag == self.selectedFilter;
        button.hidden = self.showsDrafts;
        button.backgroundColor = [TSDialEditorAppearance color:selected ? 0x2F3C2B : 0xF5F6F0];
        [button setTitleColor:[TSDialEditorAppearance color:selected ? 0xFFFFFF : 0x949B89] forState:UIControlStateNormal];
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
    }
    BOOL empty = self.showsDrafts ? self.draftTypes.count == 0 : self.visibleDials.count == 0;
    self.collectionView.hidden = empty;
    self.emptyLabel.hidden = self.emptyAction.hidden = !empty;
    NSString *emptyTitle = self.showsDrafts ? @"还没有保存的草稿" : self.loading ? @"正在同步表盘…" :
        self.selectedFilter == 0 ? @"手表中暂无表盘" :
        [NSString stringWithFormat:@"还没有%@表盘", self.filterButtons[self.selectedFilter].currentTitle];
    self.emptyLabel.text = [NSString stringWithFormat:@"%@\n%@", emptyTitle,
        self.showsDrafts ? @"创建并保存草稿，下次可以继续编辑。" : @"创建一个喜欢的表盘，留住你的好时刻。"];
    [self.emptyAction setTitle:!self.showsDrafts && self.selectedFilter == 2 ? @"导入表盘" : @"创建表盘"
                     forState:UIControlStateNormal];
    self.footnoteLabel.text = self.showsDrafts ? @"草稿保存在手机，不占用手表空间。每种类型保留一份。" :
        self.managing ? @"内置表盘无法删除。删除使用中的表盘前，会先切换至内置表盘。" :
        @"轻点表盘查看详情，切换喜欢的风格。";
    self.storageLabel.text = self.storage ?
        [@"表盘空间  剩余 " stringByAppendingString:[self formattedBytes:self.storage.available]] :
        self.loading ? @"表盘空间  正在读取…" : @"表盘空间  暂不可用";
    NSInteger limit = self.capability.maxInstallCount;
    self.countLabel.text = !self.hasDeviceSnapshot ? @"等待同步  ›" : limit > 0 ?
        [NSString stringWithFormat:@"已安装 %lu / %ld  ›", (unsigned long)[self installedCount], (long)limit] :
        [NSString stringWithFormat:@"已安装 %lu  ›", (unsigned long)[self installedCount]];
    self.storageTrack.hidden = !self.storage || self.storage.total == 0 || self.storage.available > self.storage.total;
    self.createButton.enabled = !self.operationInProgress;
    self.importButton.enabled = !self.operationInProgress && (!self.capability || self.capability.maxInstallCount != 0);
    self.backButton.enabled = !self.operationInProgress;
    self.infoButton.enabled = !self.operationInProgress;
    self.collectionView.userInteractionEnabled = !self.operationInProgress;
    [self.collectionView reloadData];
    [self.view setNeedsLayout];
}

// 底部弹层直接使用编辑器的同一组件，内容按 HTML 坐标排版。
- (TSDialEditorSheet *)presentSheetWithTitle:(NSString *)title height:(CGFloat)height {
    [self closeSheet];
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = title;
    sheet.contentHeight = height;
    sheet.stacksActions = YES;
    sheet.primaryButton.hidden = YES;
    sheet.secondaryButton.hidden = YES;
    sheet.accessibilityViewIsModal = YES;
    __weak typeof(self) weakSelf = self;
    __weak TSDialEditorSheet *weakSheet = sheet;
    sheet.onDismiss = ^{
        if (weakSelf.sheet == weakSheet) {
            weakSelf.sheet = nil;
            weakSelf.detailDialId = nil;
        }
    };
    self.sheet = sheet;
    [sheet showInView:self.view];
    return sheet;
}

// 关闭确认页不修改设备和本地草稿。
- (void)closeSheet {
    if (self.operationInProgress) {
        return;
    }
    self.detailDialId = nil;
    [self.sheet dismiss];
    self.sheet = nil;
}

// 弹层正文使用原型字号与色值。
- (UILabel *)sheetText:(NSString *)text frame:(CGRect)frame size:(CGFloat)size color:(NSUInteger)color {
    UILabel *label = [TSDialEditorAppearance label:text size:size color:color];
    label.frame = frame;
    label.numberOfLines = 0;
    [self.sheet.contentView addSubview:label];
    return label;
}

// 详情属性行包含细分隔线。
- (void)addDetailRow:(NSString *)title value:(NSString *)value top:(CGFloat)top {
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    CGFloat left = MAX(0, 20 - self.sheet.horizontalContentInset);
    [self sheetText:title frame:CGRectMake(left, top, width / 2, 45) size:12 color:0x8A947E];
    UILabel *valueLabel = [self sheetText:value frame:CGRectMake(left + width / 2, top, width / 2, 45) size:12 color:0x58664C];
    valueLabel.textAlignment = NSTextAlignmentRight;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(left, top + 44, width, 1)];
    line.backgroundColor = [TSDialEditorAppearance color:0xE9EAE4];
    [self.sheet.contentView addSubview:line];
}

// 详情用底部弹层，不切换到旧的独立详情页面。
- (void)showDialDetail:(TSDialModel *)dial {
    if (self.operationInProgress || !dial) {
        return;
    }
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"表盘详情" height:548];
    sheet.horizontalContentInset = 0;
    self.detailDialId = dial.dialId;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    TSDialPreviewView *preview = [[TSDialPreviewView alloc] initWithFrame:CGRectMake(0, 0, width, 260)];
    preview.installedPreviewScale = 0.76;
    [preview configureWithInstalledImage:self.previewImages[dial.dialId ?: @""] screen:self.screen];
    [sheet.contentView addSubview:preview];
    UILabel *name = [self sheetText:[self nameForDial:dial] frame:CGRectMake(20, 280, width - 40, 24)
                              size:19 color:0x252823];
    name.font = [UIFont systemFontOfSize:19 weight:UIFontWeightSemibold];
    name.textAlignment = NSTextAlignmentCenter;
    BOOL current = [dial.dialId isEqualToString:self.currentDial.dialId];
    NSString *description = [NSString stringWithFormat:@"%@表盘%@", [self sourceForDial:dial],
        current ? ([self isDeviceReady] ? @" · 当前使用" : @" · 上次使用") : @""];
    UILabel *subtitle = [self sheetText:description frame:CGRectMake(20, 311, width - 40, 17) size:12 color:0x8E9882];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [self addDetailRow:@"所在位置" value:@"手表" top:340];
    [self addDetailRow:@"表盘来源" value:[self sourceForDial:dial] top:385];
    UIButton *select = [TSDialEditorAppearance button:current ? @"正在使用" :
                        [self isDeviceReady] ? @"设为当前表盘" : @"连接手表后使用" primary:YES];
    select.frame = CGRectMake(20, 448, width - 40, 46);
    select.enabled = !current && [self isDeviceReady] && !self.loading;
    select.alpha = select.enabled ? 1 : 0.35;
    [select addTarget:self action:@selector(selectDetailDial) forControlEvents:UIControlEventTouchUpInside];
    [sheet.contentView addSubview:select];
    if (dial.dialType != eTSDialTypeBuiltIn) {
        UIButton *remove = [self textButton:@"从手表删除" size:12 color:0xC27455 action:@selector(deleteDetailDial)];
        remove.frame = CGRectMake(20, 499, width - 40, 42);
        remove.enabled = [self isDeviceReady] && !self.loading;
        [sheet.contentView addSubview:remove];
    } else {
        UILabel *hint = [self sheetText:@"内置表盘保留在手表中，无法删除。"
                                 frame:CGRectMake(20, 505, width - 40, 24) size:10 color:0x979D91];
        hint.textAlignment = NSTextAlignmentCenter;
    }
    [sheet setNeedsLayout];
}

// 显式点击使用才发起切换。
- (void)selectDetailDial {
    TSDialModel *dial = [self dialWithIdentifier:self.detailDialId];
    if (dial) {
        [self selectDial:dial];
    }
}

// 详情中的删除入口和列表减号共享确认流程。
- (void)deleteDetailDial {
    [self confirmRemoval:[self dialWithIdentifier:self.detailDialId]];
}

// 操作开始后锁定返回和弹层关闭，回调必须通过连接代次校验。
- (void)setOperationBusy:(BOOL)busy {
    self.operationInProgress = busy;
    self.sheet.allowsDismissal = !busy;
    self.navigationController.interactivePopGestureRecognizer.enabled = busy ? NO : self.previousPopEnabled;
    [self.sheet setNeedsLayout];
    [self renderPage];
}

// 当前设备操作结果只在原连接会话内有效。
- (BOOL)acceptsOperation:(NSUInteger)generation {
    return generation == self.operationGeneration && [self isDeviceReady] &&
        self.peripheral == [TopStepComKit sharedInstance].connectedPeripheral &&
        self.sessionGeneration == [TSDeviceCoordinator sharedInstance].snapshot.connectionGeneration;
}

// 统一设备操作前检查，查询尚未完成时禁止使用旧列表做破坏性操作。
- (BOOL)canOperate {
    if (![self isDeviceReady]) {
        [self reconnectDevice];
        return NO;
    }
    if (self.loading || self.operationInProgress) {
        [self showToastMessage:@"正在同步或处理表盘，请稍候"];
        return NO;
    }
    if (self.statusMessage.length) {
        [self showToastMessage:@"请先完成表盘同步，再进行操作"];
        [self refreshDevice];
        return NO;
    }
    return YES;
}

// 切换成功后回查当前与空间，不把点击操作当作设备成功。
- (void)selectDial:(TSDialModel *)dial {
    if (![self canOperate] || !dial.dialId.length) {
        return;
    }
    [self presentSheetWithTitle:@"切换表盘" height:96];
    [self sheetText:@"正在切换表盘…" frame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds) - 40, 50)
              size:14 color:0x58664C];
    [self setOperationBusy:YES];
    NSUInteger generation = ++self.operationGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial selectDial:dial.dialId completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsOperation:generation]) {
                return;
            }
            [weakSelf setOperationBusy:NO];
            if (success && !error) {
                weakSelf.currentDial = dial;
                [weakSelf closeSheet];
                [weakSelf refreshDevice];
                [weakSelf showToastMessage:@"切换成功，正在同步手表状态"];
            } else {
                [weakSelf showFailure:error.localizedDescription ?: @"未能确认切换结果，请同步后重试。"
                               retry:^{ [weakSelf selectDial:dial]; }];
                [weakSelf refreshDevice];
            }
        });
    }];
}

// 删除正在使用的表盘前明确告知会先切换到哪一个内置表盘。
- (void)confirmRemoval:(TSDialModel *)dial {
    if (!dial || dial.dialType == eTSDialTypeBuiltIn || ![self canOperate]) {
        return;
    }
    TSDialModel *replacement = nil;
    for (TSDialModel *candidate in self.allDials) {
        if (candidate.dialType == eTSDialTypeBuiltIn && candidate.dialId.length) {
            replacement = candidate;
            break;
        }
    }
    BOOL current = [dial.dialId isEqualToString:self.currentDial.dialId];
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"从手表删除" height:182];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    [self sheetText:[self nameForDial:dial] frame:CGRectMake(0, 8, width, 27) size:16 color:0x252823];
    NSString *message = current ? replacement ?
        [NSString stringWithFormat:@"此表盘正在使用。\n将先切换到「%@」，成功后再删除此表盘。", [self nameForDial:replacement]] :
        @"此表盘正在使用，请先切换到其他表盘，再删除当前表盘。" :
        @"删除后将从手表移除。手机中保存的创作草稿会保留，重新使用需要再次安装。";
    [self sheetText:message frame:CGRectMake(0, 50, width, 90) size:12 color:0x8E9882];
    sheet.primaryButton.hidden = NO;
    sheet.secondaryButton.hidden = NO;
    sheet.primaryButton.enabled = !current || replacement != nil;
    [sheet.primaryButton setTitle:current ? @"切换并删除" : @"确认删除" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"保留表盘" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    sheet.onPrimary = ^{ [weakSelf removeDial:dial replacement:current ? replacement : nil]; };
    [sheet setNeedsLayout];
}

// 先回查当前表盘，防止用户在手表端切换后按旧状态卸载。
- (void)removeDial:(TSDialModel *)dial replacement:(TSDialModel *)replacement {
    if (![self canOperate]) {
        return;
    }
    [self setOperationBusy:YES];
    NSUInteger generation = ++self.operationGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial fetchCurrentDial:^(TSDialModel *current, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsOperation:generation]) {
                return;
            }
            if (error || !current.dialId.length) {
                [weakSelf setOperationBusy:NO];
                [weakSelf showFailure:@"无法确认当前表盘，未执行删除。请同步后重试。" retry:nil];
                return;
            }
            weakSelf.currentDial = current;
            if ([current.dialId isEqualToString:dial.dialId]) {
                if (!replacement) {
                    [weakSelf setOperationBusy:NO];
                    [weakSelf confirmRemoval:dial];
                } else {
                    [weakSelf selectReplacement:replacement removing:dial generation:generation];
                }
            } else {
                [weakSelf uninstallDial:dial generation:generation];
            }
        });
    }];
}

// 先切换成功再卸载；切换失败时保留原表盘。
- (void)selectReplacement:(TSDialModel *)replacement removing:(TSDialModel *)dial generation:(NSUInteger)generation {
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial selectDial:replacement.dialId completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsOperation:generation]) {
                return;
            }
            if (!success || error) {
                [weakSelf setOperationBusy:NO];
                [weakSelf showFailure:error.localizedDescription ?: @"切换失败，未删除当前表盘。" retry:nil];
                return;
            }
            weakSelf.currentDial = replacement;
            [[TopStepComKit sharedInstance].dial fetchCurrentDial:^(TSDialModel *current, NSError *queryError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![weakSelf acceptsOperation:generation]) {
                        return;
                    }
                    if (queryError || ![current.dialId isEqualToString:replacement.dialId]) {
                        [weakSelf setOperationBusy:NO];
                        [weakSelf showFailure:@"未能确认切换结果，原表盘已保留。请同步后重试。" retry:nil];
                    } else {
                        weakSelf.currentDial = current;
                        [weakSelf uninstallDial:dial generation:generation];
                    }
                });
            }];
        });
    }];
}

// 卸载失败不撤销已经成功的切换，也不从列表提前移除表盘。
- (void)uninstallDial:(TSDialModel *)dial generation:(NSUInteger)generation {
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial uninstallDial:dial.dialId completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsOperation:generation]) {
                return;
            }
            [weakSelf setOperationBusy:NO];
            if (success && !error) {
                [weakSelf closeSheet];
                [weakSelf refreshDevice];
                [weakSelf showToastMessage:@"已从手表删除，手机草稿已保留"];
            } else {
                [weakSelf showFailure:error.localizedDescription ?: @"删除失败，表盘已保留。" retry:nil];
                [weakSelf refreshDevice];
            }
        });
    }];
}

// 类型能力完全使用当前接口，视频时长和弹幕开关不猜测。
- (BOOL)supportsDraftType:(TSDialDraftType)type {
    if (!self.capability.supportsCustom) {
        return NO;
    }
    switch (type) {
        case TSDialDraftTypeSingleImage: return YES;
        case TSDialDraftTypeMultipleImage: return self.capability.supportsSlideshow;
        case TSDialDraftTypeVideo: return self.capability.supportsVideo && self.capability.maxVideoDuration > 0;
        case TSDialDraftTypeDanMu: return self.capability.supportsDanMu;
    }
    return NO;
}

// 创建入口使用 HTML 两列卡片和同一底部弹层。
- (void)showCreateSheet {
    if (self.operationInProgress) {
        return;
    }
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"创建表盘" height:350];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    [self sheetText:@"选择一种方式，制作你的专属表盘。" frame:CGRectMake(0, 0, width, 26) size:11 color:0x929A88];
    NSArray *icons = @[@"photo", @"album", @"video", @"danmu"];
    NSArray *descriptions = @[@"一张照片，一个好时刻", @"多张照片，依次轮播",
                              @"将喜欢的片段戴在腕上", @"文字滚动，让心情动起来"];
    CGFloat cardWidth = (width - 12) / 2;
    for (NSUInteger index = 0; index < icons.count; index++) {
        TSDialDraftType type = TSDialDraftTypeSingleImage + index;
        UIButton *button = [TSDialEditorAppearance button:@"" primary:NO];
        button.tag = type;
        button.frame = CGRectMake((index % 2) * (cardWidth + 12), 42 + (index / 2) * 132, cardWidth, 120);
        button.backgroundColor = [TSDialEditorAppearance color:0xFAFBF7];
        button.layer.cornerRadius = 15;
        button.enabled = [self isDeviceReady] && [self supportsDraftType:type];
        button.alpha = button.enabled ? 1 : 0.35;
        button.accessibilityLabel = [self titleForDraftType:type];
        UIImageView *image = [[UIImageView alloc] initWithImage:[TSDialEditorAppearance icon:icons[index]]];
        image.frame = CGRectMake(18, 18, 23, 23);
        image.tintColor = [TSDialEditorAppearance color:0x80916E];
        UILabel *title = [TSDialEditorAppearance label:[self titleForDraftType:type] size:14 color:0x252823];
        title.frame = CGRectMake(18, 53, cardWidth - 36, 20);
        UILabel *detail = [TSDialEditorAppearance label:descriptions[index] size:10 color:0x959D8B];
        detail.frame = CGRectMake(18, 78, cardWidth - 36, 28);
        detail.numberOfLines = 2;
        [button addSubview:image];
        [button addSubview:title];
        [button addSubview:detail];
        [button addTarget:self action:@selector(createTypeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [sheet.contentView addSubview:button];
    }
    [self sheetText:[self isDeviceReady] ? @"已有草稿会自动恢复；不可用类型由当前设备能力决定。" :
                   @"连接手表后可创建表盘；已保存的草稿仍可查看。"
             frame:CGRectMake(0, 314, width, 32) size:11 color:0x929A88];
}

// 卡片路由只传入草稿类型。
- (void)createTypeTapped:(UIButton *)sender {
    [self openEditorForType:sender.tag];
}

// 恢复草稿放到后台，完成后进入已存在的原生编辑器。
- (void)openEditorForType:(TSDialDraftType)type {
    if ([self isDeviceReady] && ![self supportsDraftType:type]) {
        [self showToastMessage:@"当前设备不支持此类型，草稿已保留"];
        return;
    }
    [self closeSheet];
    [self showToastMessage:@"正在读取草稿…"];
    NSUInteger generation = ++self.draftGeneration;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        TSDialEditorState *state = [TSDialEditorState stateForType:type];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf.visible || generation != weakSelf.draftGeneration || weakSelf.navigationController.topViewController != weakSelf) {
                return;
            }
            TSDialEditorVC *editor = [[TSDialEditorVC alloc] initWithState:state];
            editor.onPushSuccess = ^{ weakSelf.refreshPending = YES; };
            [weakSelf.navigationController pushViewController:editor animated:YES];
        });
    });
}

// 导入入口保留 HTML 的文件选择流程，不跳到旧的推送页。
- (void)showImportSheet {
    if (self.operationInProgress) {
        return;
    }
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"导入表盘" height:204];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UIImageView *icon = [[UIImageView alloc] initWithImage:[TSDialEditorAppearance icon:@"album"]];
    icon.tintColor = [TSDialEditorAppearance color:0x8C977F];
    icon.frame = CGRectMake((width - 31) / 2, 20, 31, 31);
    [sheet.contentView addSubview:icon];
    UILabel *title = [self sheetText:@"选择表盘文件" frame:CGRectMake(0, 66, width, 25) size:14 color:0x58664C];
    title.textAlignment = NSTextAlignmentCenter;
    UILabel *hint = [self sheetText:@"使用适配当前手表的表盘文件。\n支持 .dial、.bin、.zip、.tar"
                             frame:CGRectMake(0, 100, width, 55) size:11 color:0x8C977F];
    hint.textAlignment = NSTextAlignmentCenter;
    sheet.primaryButton.hidden = NO;
    [sheet.primaryButton setTitle:@"从手机文件中选择" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{ [weakSelf chooseImportFile]; };
    [sheet setNeedsLayout];
}

// 文件由系统选择器导入，再复制到 App 自有目录以便失败重试。
- (void)chooseImportFile {
    if (self.operationInProgress) {
        return;
    }
    [self closeSheet];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[@"com.topstep.dial", @"com.topstep.bin-dial", @"public.zip-archive", @"public.tar-archive"]
        inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

// 文件选择成功后显示名称和大小，不把扩展名通过当作兼容性校验通过。
- (void)showImportReady {
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"安装表盘" height:183];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    [self sheetText:self.importName ?: @"表盘文件" frame:CGRectMake(0, 8, width, 50) size:16 color:0x252823];
    [self sheetText:[NSString stringWithFormat:@"%@ · 云端表盘", [self formattedBytes:self.importBytes]]
             frame:CGRectMake(0, 66, width, 24) size:12 color:0x8E9882];
    [self sheetText:@"请确认文件适配当前手表。安装失败可保留文件重试。"
             frame:CGRectMake(0, 105, width, 60) size:11 color:0x929A88];
    sheet.primaryButton.hidden = NO;
    sheet.secondaryButton.hidden = NO;
    [sheet.primaryButton setTitle:@"安装到手表" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"重新选择" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{ [weakSelf prepareImport]; };
    sheet.onSecondary = ^{ [weakSelf chooseImportFile]; };
    [sheet setNeedsLayout];
}

// 安装前重新读取空间，不能使用页面停留期间已过期的容量。
- (void)prepareImport {
    if (![self canOperate] || !self.importURL) {
        return;
    }
    if (!self.capability || self.capability.maxInstallCount == 0) {
        [self showFailure:@"当前设备未提供可用的表盘安装能力。" retry:nil];
        return;
    }
    if (self.capability.maxInstallCount > 0 && [self installedCount] >= self.capability.maxInstallCount) {
        [self showInsufficientStorage];
        return;
    }
    self.importPeripheral = self.peripheral;
    [self setOperationBusy:YES];
    NSUInteger generation = ++self.operationGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial fetchDialStorage:^(TSStorageSpace *storage, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsOperation:generation]) {
                return;
            }
            [weakSelf setOperationBusy:NO];
            weakSelf.storage = error ? nil : storage;
            if (storage && !error && storage.available < weakSelf.importBytes) {
                [weakSelf showInsufficientStorage];
            } else {
                [weakSelf startImport];
            }
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDialManagerQueryTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if ([weakSelf acceptsOperation:generation] && weakSelf.operationInProgress && !weakSelf.importing) {
            weakSelf.operationGeneration++;
            [weakSelf setOperationBusy:NO];
            [weakSelf showFailure:@"空间读取超时，请重新同步后重试。" retry:^{ [weakSelf prepareImport]; }];
        }
    });
}

// 清理空间后继续使用原文件，不自动删表盘或覆盖未知槽位。
- (void)showInsufficientStorage {
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"需要清理表盘" height:144];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    NSString *message = [NSString stringWithFormat:@"手表空间不足\n本次需要 %@，可用 %@。\n清理后可继续安装，已选文件会保留。",
                         [self formattedBytes:self.importBytes], [self formattedBytes:self.storage.available]];
    if (self.capability.maxInstallCount > 0 && [self installedCount] >= self.capability.maxInstallCount) {
        message = @"已达到手表可安装的表盘数量上限。\n请先删除一个云端或自定义表盘。\n清理后可继续安装，已选文件会保留。";
    }
    UILabel *label = [self sheetText:message frame:CGRectMake(0, 10, width, 110) size:13 color:0x58664C];
    label.textAlignment = NSTextAlignmentCenter;
    sheet.primaryButton.hidden = NO;
    [sheet.primaryButton setTitle:@"去管理表盘" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{
        [weakSelf closeSheet];
        weakSelf.managing = YES;
        weakSelf.showsDrafts = NO;
        weakSelf.selectedFilter = 0;
        [weakSelf renderPage];
        [weakSelf showToastMessage:@"清理后点击导入表盘，可继续安装已选文件"];
    };
    [sheet setNeedsLayout];
}

// 使用一个真实 SDK 安装任务，最终结果由完成回调决定。
- (void)startImport {
    if (self.operationInProgress || self.importPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
        [self showToastMessage:@"连接已变化，请重新确认安装"];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.importURL.path]) {
        [self showFailure:@"所选文件已不存在，请重新选择。" retry:nil];
        return;
    }
    self.importArtifact = [TSDialArtifact artifactWithDialType:eTSDialTypeCloud
        dialId:[@"cloud_" stringByAppendingString:NSUUID.UUID.UUIDString] filePath:self.importURL.path];
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"安装表盘" height:210];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    [self sheetText:self.importName frame:CGRectMake(0, 5, width, 40) size:14 color:0x252823];
    self.progressLabel = [self sheetText:@"准备传输" frame:CGRectMake(0, 70, width, 50) size:24 color:0x394530];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0, 135, width, 5);
    self.progressView.progressTintColor = [TSDialEditorAppearance color:0xF16D43];
    self.progressView.trackTintColor = [TSDialEditorAppearance color:0xE9EDDF];
    [sheet.contentView addSubview:self.progressView];
    UILabel *hint = [self sheetText:@"请将手表靠近手机" frame:CGRectMake(0, 165, width, 24) size:11 color:0x979D91];
    hint.textAlignment = NSTextAlignmentCenter;
    sheet.secondaryButton.hidden = NO;
    [sheet.secondaryButton setTitle:@"取消安装" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onSecondary = ^{ [weakSelf cancelImport]; };
    self.importing = YES;
    self.cancellationRequested = NO;
    [self setOperationBusy:YES];
    NSUInteger generation = ++self.operationGeneration;
    [[TopStepComKit sharedInstance].dial installDial:self.importArtifact
        progressBlock:^(TSDialInstallResult result, NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![weakSelf acceptsOperation:generation] || !weakSelf.importing || weakSelf.cancellationRequested) {
                    return;
                }
                NSInteger value = MAX(0, MIN(100, progress));
                weakSelf.progressLabel.text = [NSString stringWithFormat:@"正在传输 · %ld%%", (long)value];
                [weakSelf.progressView setProgress:value / 100.0 animated:YES];
            });
        } completion:^(TSDialInstallResult result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![weakSelf acceptsOperation:generation] || !weakSelf.importing) {
                    return;
                }
                weakSelf.importing = NO;
                [weakSelf setOperationBusy:NO];
                if (result == eTSDialInstallResultSuccess && !error) {
                    [weakSelf showImportSuccess];
                } else if (weakSelf.cancellationRequested) {
                    [weakSelf closeSheet];
                    [weakSelf refreshDevice];
                    [weakSelf showToastMessage:@"安装已结束，正在同步实际表盘状态"];
                } else {
                    [weakSelf showFailure:error.localizedDescription ?: @"安装未完成，请检查连接后重试。"
                                   retry:^{ [weakSelf prepareImport]; }];
                    [weakSelf refreshDevice];
                }
            });
        }];
}

// 取消指令成功后仍等待安装完成回调，避免提前开放下一次传输。
- (void)cancelImport {
    if (!self.importing || self.cancellationRequested) {
        return;
    }
    self.cancellationRequested = YES;
    self.progressLabel.text = @"正在取消…";
    self.sheet.secondaryButton.enabled = NO;
    NSUInteger generation = self.operationGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial cancelDialInstall:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf acceptsOperation:generation] || !weakSelf.importing) {
                return;
            }
            if (success && !error) {
                weakSelf.progressLabel.text = @"正在结束传输…";
            } else {
                weakSelf.cancellationRequested = NO;
                weakSelf.sheet.secondaryButton.enabled = YES;
                weakSelf.progressLabel.text = @"取消未成功，正在等待安装结果";
            }
        });
    }];
}

// 成功安装后让用户决定是否切换，不把安装等同于已经使用。
- (void)showImportSuccess {
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"安装完成" height:186];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UILabel *symbol = [self sheetText:@"✓" frame:CGRectMake((width - 58) / 2, 8, 58, 58) size:27 color:0x718B55];
    symbol.backgroundColor = [TSDialEditorAppearance color:0xEFF4E7];
    symbol.layer.cornerRadius = 29;
    symbol.clipsToBounds = YES;
    symbol.textAlignment = NSTextAlignmentCenter;
    UILabel *title = [self sheetText:@"已添加到手表" frame:CGRectMake(0, 82, width, 27) size:19 color:0x252823];
    title.textAlignment = NSTextAlignmentCenter;
    UILabel *hint = [self sheetText:@"正在同步手表，可返回管理或选择设为当前表盘。"
                             frame:CGRectMake(0, 125, width, 42) size:11 color:0x929A88];
    hint.textAlignment = NSTextAlignmentCenter;
    sheet.primaryButton.hidden = NO;
    sheet.secondaryButton.hidden = NO;
    [sheet.primaryButton setTitle:@"设为当前表盘" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"返回表盘管理" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{
        TSDialModel *dial = [weakSelf dialWithIdentifier:weakSelf.importArtifact.dialId];
        if (dial) {
            [weakSelf selectDial:dial];
        } else if (!weakSelf.loading) {
            [weakSelf closeSheet];
            weakSelf.showsDrafts = NO;
            weakSelf.selectedFilter = 2;
            [weakSelf renderPage];
            [weakSelf showToastMessage:@"请选择手表返回的已安装表盘，再设为当前表盘"];
        } else {
            [weakSelf showToastMessage:@"请等待同步后，在列表中选择已安装表盘"];
            [weakSelf refreshDevice];
        }
    };
    sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    [sheet setNeedsLayout];
    [self refreshDevice];
}

// 空间面板保留原型的容量摘要和管理入口。
- (void)showStorageSheet {
    if (self.operationInProgress) {
        return;
    }
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"表盘空间" height:238];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    NSString *title = self.storage ? [[self formattedBytes:self.storage.available] stringByAppendingString:@" 可用"] : @"空间信息暂不可用";
    UILabel *label = [self sheetText:title frame:CGRectMake(0, 8, width, 28) size:19 color:0x252823];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *description = self.storage.total > 0 ?
        [NSString stringWithFormat:@"总空间 %@ · 用于安装表盘", [self formattedBytes:self.storage.total]] : @"设备未提供总空间信息";
    UILabel *subtitle = [self sheetText:description frame:CGRectMake(0, 46, width, 20) size:12 color:0x8E9882];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [self addDetailRow:@"云端与自定义表盘" value:self.countLabel.text top:80];
    [self addDetailRow:@"内置表盘" value:[NSString stringWithFormat:@"%lu 个",
        (unsigned long)(self.allDials.count - [self installedCount])] top:125];
    [self sheetText:@"内置表盘不能删除。手机中的草稿不占用手表空间。"
             frame:CGRectMake(0, 188, width, 36) size:11 color:0x929A88];
    sheet.primaryButton.hidden = NO;
    sheet.primaryButton.enabled = [self isDeviceReady] && !self.loading;
    [sheet.primaryButton setTitle:@"管理手表中的表盘" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{
        [weakSelf closeSheet];
        weakSelf.showsDrafts = NO;
        weakSelf.selectedFilter = 0;
        weakSelf.managing = YES;
        [weakSelf renderPage];
    };
    [sheet setNeedsLayout];
}

// 页面帮助保留产品说明，不带原型模拟开关或 SDK 实现细节。
- (void)showHelpSheet {
    [self presentSheetWithTitle:@"表盘使用说明" height:248];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    [self sheetText:@"手表中的表盘" frame:CGRectMake(0, 0, width, 26) size:14 color:0x252823];
    [self sheetText:@"轻点表盘查看详情，选择“设为当前表盘”后切换。管理模式可删除云端和自定义表盘，内置表盘不可删除。"
             frame:CGRectMake(0, 36, width, 65) size:12 color:0x8A947F];
    [self sheetText:@"手机中的草稿" frame:CGRectMake(0, 119, width, 26) size:14 color:0x252823];
    [self sheetText:@"每种类型保留一份草稿，不占用手表空间。无预览图的表盘仍可正常使用。向下拉动列表可重新同步。"
             frame:CGRectMake(0, 155, width, 70) size:12 color:0x8A947F];
}

// 使用全局绑定协调器重连，不注册第二个 BLE 监听。
- (void)reconnectDevice {
    if (self.operationInProgress) {
        return;
    }
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"连接手表" height:164];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UILabel *label = [self sheetText:@"将手表靠近手机\n请确认手表已开机、蓝牙已开启。\n连接后会重新同步表盘状态。"
                              frame:CGRectMake(0, 15, width, 116) size:13 color:0x58664C];
    label.textAlignment = NSTextAlignmentCenter;
    sheet.primaryButton.hidden = NO;
    [sheet.primaryButton setTitle:@"重新连接" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    __weak TSDialEditorSheet *weakSheet = sheet;
    sheet.onPrimary = ^{
        weakSelf.sheet.primaryButton.enabled = NO;
        [[TSDeviceCoordinator sharedInstance] reconnectWithCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf.visible || weakSelf.sheet != weakSheet) {
                    return;
                }
                if (success && !error) {
                    [weakSelf closeSheet];
                    [weakSelf synchronizeConnection];
                    [weakSelf registerDialEvents];
                    [weakSelf refreshDevice];
                } else {
                    weakSelf.sheet.primaryButton.enabled = YES;
                    [weakSelf showToastMessage:error.localizedDescription ?: @"连接未成功，请检查手表"];
                }
            });
        }];
    };
    [sheet setNeedsLayout];
}

// 失败页面保留上次状态，重试动作由原调用方明确提供。
- (void)showFailure:(NSString *)message retry:(void (^)(void))retry {
    TSDialEditorSheet *sheet = [self presentSheetWithTitle:@"操作未完成" height:145];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UILabel *label = [self sheetText:message frame:CGRectMake(0, 15, width, 108) size:13 color:0x8A947F];
    label.textAlignment = NSTextAlignmentCenter;
    sheet.primaryButton.hidden = retry == nil;
    sheet.secondaryButton.hidden = NO;
    [sheet.primaryButton setTitle:@"重试" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"返回" forState:UIControlStateNormal];
    sheet.onPrimary = retry;
    __weak typeof(self) weakSelf = self;
    sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    [sheet setNeedsLayout];
}

// 提示不改变设备状态，连续提示只保留最后一条。
- (void)showToastMessage:(NSString *)message {
    self.toastLabel.text = message;
    CGFloat width = MIN(CGRectGetWidth(self.view.bounds) - 48, 310);
    CGSize size = [self.toastLabel sizeThatFits:CGSizeMake(width - 28, 100)];
    self.toastLabel.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - width) / 2,
        CGRectGetHeight(self.view.bounds) - self.view.safeAreaInsets.bottom - 105, width, MAX(44, size.height + 20));
    [self.view addSubview:self.toastLabel];
    NSUInteger generation = ++self.toastGeneration;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (generation == weakSelf.toastGeneration) {
            [weakSelf.toastLabel removeFromSuperview];
        }
    });
}

// 导航操作在设备写入期间保持禁用。
- (void)goBack {
    if (!self.operationInProgress) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 连接状态入口。
- (void)connectionTapped {
    if ([self isDeviceReady]) {
        [self showStorageSheet];
    } else {
        [self reconnectDevice];
    }
}

// 当前表盘详情入口。
- (void)currentTapped {
    if (self.currentDial) {
        [self showDialDetail:self.currentDial];
    }
}

// 同步提示可重试或重新连接。
- (void)bannerTapped {
    if ([self isDeviceReady]) {
        [self refreshDevice];
    } else {
        [self reconnectDevice];
    }
}

// 切换到设备列表，保留上一次来源筛选。
- (void)deviceTabTapped {
    self.showsDrafts = NO;
    [self renderPage];
}

// 本机草稿独立于设备存储。
- (void)draftTabTapped {
    self.showsDrafts = YES;
    self.managing = NO;
    [self reloadDrafts];
    [self renderPage];
}

// 管理模式仅提供非内置表盘删除。
- (void)manageTapped {
    if (self.operationInProgress || self.loading || ![self isDeviceReady]) {
        return;
    }
    self.managing = !self.managing;
    [self renderPage];
}

// 筛选顺序与 HTML 保持一致。
- (void)filterTapped:(UIButton *)sender {
    self.selectedFilter = sender.tag;
    [self renderPage];
}

// 保留待安装文件，清理空间后可继续安装。
- (void)importTapped {
    if (self.operationInProgress) {
        return;
    }
    if (self.importURL) {
        [self showImportReady];
    } else {
        [self showImportSheet];
    }
}

// 空列表引导至对应入口。
- (void)emptyTapped {
    if (!self.showsDrafts && self.selectedFilter == 2) {
        [self importTapped];
    } else {
        [self showCreateSheet];
    }
}

#pragma mark - Delegate / DataSource 回调

// 协调器通知统一切回主线程处理。
- (void)connectionDidChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.visible) {
            return;
        }
        [self synchronizeConnection];
        [self registerDialEvents];
        [self refreshDevice];
    });
}

// 解绑后立即移除设备快照，保留本机草稿。
- (void)bindingDidClear:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.refreshGeneration++;
        self.eventGeneration++;
        self.imageGeneration++;
        self.operationGeneration++;
        self.importing = NO;
        self.loading = NO;
        [self setOperationBusy:NO];
        [self closeSheet];
        self.peripheral = nil;
        self.screen = nil;
        self.storage = nil;
        self.capability = nil;
        self.currentDial = nil;
        self.allDials = @[];
        self.hasDeviceSnapshot = NO;
        [self.previewImages removeAllObjects];
        [self.refreshControl endRefreshing];
        [self renderPage];
    });
}

// 回到前台重新同步，后台期间不推断设备状态。
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.visible) {
        [self synchronizeConnection];
        [self registerDialEvents];
        [self refreshDevice];
    }
}

// 两个页签共用相同的三列网格。
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.showsDrafts ? self.draftTypes.count : self.visibleDials.count;
}

// 卡片仅展示真实名称、来源与已缓存的预览。
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSDialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DialTile" forIndexPath:indexPath];
    cell.screen = self.screen;
    cell.current = NO;
    cell.managing = NO;
    cell.removable = NO;
    cell.onRemove = nil;
    if (self.showsDrafts) {
        NSNumber *type = self.draftTypes[indexPath.item];
        [cell configureWithTitle:[self titleForDraftType:type.integerValue]
            subtitle:@"保存在手机 · 继续编辑" image:self.draftImages[type]];
    } else {
        TSDialModel *dial = self.visibleDials[indexPath.item];
        cell.current = [dial.dialId isEqualToString:self.currentDial.dialId];
        cell.managing = self.managing;
        cell.removable = dial.dialType != eTSDialTypeBuiltIn;
        NSString *subtitle = cell.current ? @"当前使用" : [self sourceForDial:dial];
        [cell configureWithTitle:[self nameForDial:dial] subtitle:subtitle image:self.previewImages[dial.dialId ?: @""]];
        __weak typeof(self) weakSelf = self;
        cell.onRemove = ^{ [weakSelf confirmRemoval:dial]; };
    }
    return cell;
}

// 草稿继续编辑，设备表盘进入详情。
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.operationInProgress) {
        return;
    }
    if (self.showsDrafts) {
        [self openEditorForType:self.draftTypes[indexPath.item].integerValue];
    } else {
        [self showDialDetail:self.visibleDials[indexPath.item]];
    }
}

// 文件先复制到本机，离开系统授权范围后仍可重试安装。
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *source = urls.firstObject;
    if (!source || ![@[@"dial", @"bin", @"zip", @"tar"] containsObject:source.pathExtension.lowercaseString]) {
        [self showFailure:@"请选择 .dial、.bin、.zip 或 .tar 格式的表盘文件。" retry:nil];
        return;
    }
    NSUInteger generation = ++self.operationGeneration;
    [self showToastMessage:@"正在读取表盘文件…"];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSError *error = nil;
        NSURL *localURL = [TSDialEditorState importFile:source error:&error];
        NSDictionary *attributes = localURL ? [[NSFileManager defaultManager] attributesOfItemAtPath:localURL.path error:&error] : nil;
        unsigned long long bytes = [attributes fileSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf || generation != weakSelf.operationGeneration || !weakSelf.visible) {
                return;
            }
            [weakSelf.toastLabel removeFromSuperview];
            if (!localURL || error || bytes == 0) {
                [weakSelf showFailure:error.localizedDescription ?: @"文件为空或无法读取，请重新选择。" retry:nil];
                return;
            }
            weakSelf.importURL = localURL;
            weakSelf.importName = source.lastPathComponent;
            weakSelf.importBytes = bytes;
            [weakSelf showImportReady];
        });
    });
}

// 取消系统文件选择后保留之前选中的文件。
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (self.importURL) {
        [self showImportReady];
    }
}

#pragma mark - 属性懒加载 Getter

// 统一轻量文字按钮。
- (UIButton *)textButton:(NSString *)title size:(CGFloat)size color:(NSUInteger)color action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[TSDialEditorAppearance color:color] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:size];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 顶部使用编辑器同色导航背景。
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
    }
    return _headerView;
}

// 页面标题。
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [TSDialEditorAppearance label:@"表盘管理" size:17 color:0x252823];
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

// 原生导航返回入口。
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [self textButton:@"返回" size:14 color:0x647757 action:@selector(goBack)];
        // 按 HTML 的 20×24 SVG 路径绘制，避免字体箭头的字形和基线差异。
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(17, 22)];
        UIImage *arrow = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            CGContextScaleCTM(context.CGContext, 17.0 / 20, 22.0 / 24);
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(13, 4)];
            [path addLineToPoint:CGPointMake(5, 12)];
            [path addLineToPoint:CGPointMake(13, 20)];
            path.lineWidth = 2.2;
            path.lineCapStyle = kCGLineCapRound;
            path.lineJoinStyle = kCGLineJoinRound;
            [UIColor.blackColor setStroke];
            [path stroke];
        }];
        [_backButton setImage:[arrow imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _backButton.tintColor = [TSDialEditorAppearance color:0x647757];
        _backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backButton.accessibilityLabel = @"返回";
    }
    return _backButton;
}

// 说明图标复用 HTML 资源。
- (UIButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [self textButton:@"" size:16 color:0x78836E action:@selector(showHelpSheet)];
        // 资源没有 scale 元数据，先转为 HTML 的 21 点图标，不能使用原始像素作为点尺寸。
        UIImage *source = [TSDialEditorAppearance icon:@"info"];
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(21, 21)];
        UIImage *icon = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [source drawInRect:CGRectMake(0, 0, 21, 21)];
        }];
        [_infoButton setImage:[icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _infoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _infoButton.tintColor = [TSDialEditorAppearance color:0x78836E];
        _infoButton.accessibilityLabel = @"表盘管理说明";
    }
    return _infoButton;
}

// 内容共用一个滚动区域，底部空间栏始终固定。
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.refreshControl = self.refreshControl;
    }
    return _scrollView;
}

// 下拉同步真实设备数据。
- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.tintColor = [TSDialEditorAppearance color:0x8A957D];
        [_refreshControl addTarget:self action:@selector(refreshDevice) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

// 与自定义编辑器使用同一表壳、表带和背景。
- (TSDialPreviewView *)currentPreview {
    if (!_currentPreview) {
        _currentPreview = [[TSDialPreviewView alloc] init];
        _currentPreview.installedPreviewScale = 0.67;
    }
    return _currentPreview;
}

// 预览左上角英文眉题。
- (UILabel *)previewCaption {
    if (!_previewCaption) {
        _previewCaption = [TSDialEditorAppearance label:@"C U R R E N T  F A C E" size:8 color:0x7F8B71];
    }
    return _previewCaption;
}

// 当前名称与来源。
- (UILabel *)currentNameLabel {
    if (!_currentNameLabel) {
        _currentNameLabel = [TSDialEditorAppearance label:@"" size:15 color:0x252823];
        _currentNameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    }
    return _currentNameLabel;
}

// 当前状态副标题。
- (UILabel *)currentDetailLabel {
    if (!_currentDetailLabel) {
        _currentDetailLabel = [TSDialEditorAppearance label:@"" size:10 color:0x89937C];
    }
    return _currentDetailLabel;
}

// 连接状态按钮。
- (UIButton *)connectionButton {
    if (!_connectionButton) {
        _connectionButton = [self textButton:@"" size:10 color:0x7F9272 action:@selector(connectionTapped)];
        _connectionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _connectionButton;
}

// 当前使用状态胶囊。
- (UIButton *)currentButton {
    if (!_currentButton) {
        _currentButton = [self textButton:@"✓ 使用中" size:11 color:0x252823 action:@selector(currentTapped)];
        _currentButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.82];
        _currentButton.layer.cornerRadius = 16.5;
        _currentButton.layer.borderWidth = 1;
        _currentButton.layer.borderColor = [TSDialEditorAppearance color:0xDEE2D7].CGColor;
    }
    return _currentButton;
}

// 橙色创建入口。
- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [TSDialEditorAppearance button:@"＋  创建表盘" primary:YES];
        _createButton.layer.cornerRadius = 13;
        _createButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        [_createButton addTarget:self action:@selector(showCreateSheet) forControlEvents:UIControlEventTouchUpInside];
    }
    return _createButton;
}

// 次级导入入口。
- (UIButton *)importButton {
    if (!_importButton) {
        _importButton = [TSDialEditorAppearance button:@"导入表盘" primary:NO];
        _importButton.layer.cornerRadius = 13;
        _importButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_importButton addTarget:self action:@selector(importTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _importButton;
}

// 连接与同步失败只在需要时插入提示。
- (UIButton *)bannerButton {
    if (!_bannerButton) {
        _bannerButton = [self textButton:@"" size:11 color:0xA1714E action:@selector(bannerTapped)];
        _bannerButton.backgroundColor = [TSDialEditorAppearance color:0xFFF3E9];
        _bannerButton.layer.cornerRadius = 10;
        _bannerButton.titleLabel.numberOfLines = 2;
        _bannerButton.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 12);
    }
    return _bannerButton;
}

// 设备列表页签。
- (UIButton *)deviceTab {
    if (!_deviceTab) {
        _deviceTab = [self textButton:@"手表中的表盘" size:15 color:0x252823 action:@selector(deviceTabTapped)];
        _deviceTab.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _deviceTab.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 12, 0);
    }
    return _deviceTab;
}

// 本机草稿页签。
- (UIButton *)draftTab {
    if (!_draftTab) {
        _draftTab = [self textButton:@"草稿" size:15 color:0x8D9485 action:@selector(draftTabTapped)];
        _draftTab.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _draftTab.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 12, 0);
    }
    return _draftTab;
}

// 管理与完成共用入口。
- (UIButton *)manageButton {
    if (!_manageButton) {
        _manageButton = [self textButton:@"管理" size:12 color:0xBD6746 action:@selector(manageTapped)];
        _manageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _manageButton;
}

// 当前页签的短橙色下划线。
- (UIView *)tabUnderline {
    if (!_tabUnderline) {
        _tabUnderline = [[UIView alloc] init];
        _tabUnderline.backgroundColor = [TSDialEditorAppearance color:0xF16D43];
        _tabUnderline.layer.cornerRadius = 1.5;
    }
    return _tabUnderline;
}

// 页签底部分隔线。
- (UIView *)tabSeparator {
    if (!_tabSeparator) {
        _tabSeparator = [[UIView alloc] init];
        _tabSeparator.backgroundColor = [TSDialEditorAppearance color:0xE8EBE2];
    }
    return _tabSeparator;
}

// 固定顺序，不依赖 SDK 枚举值顺序。
- (NSArray<UIButton *> *)filterButtons {
    if (!_filterButtons) {
        NSMutableArray *buttons = [NSMutableArray array];
        NSArray *titles = @[@"全部", @"内置", @"云端", @"自定义"];
        for (NSUInteger index = 0; index < titles.count; index++) {
            UIButton *button = [self textButton:titles[index] size:11 color:0x949B89 action:@selector(filterTapped:)];
            button.tag = index;
            button.layer.cornerRadius = 8;
            [buttons addObject:button];
        }
        _filterButtons = buttons;
    }
    return _filterButtons;
}

// 三列卡片由外层滚动区域统一滚动。
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = kDialManagerColumnGap;
        layout.minimumLineSpacing = 16;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.clipsToBounds = NO;
        _collectionView.scrollEnabled = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:TSDialCell.class forCellWithReuseIdentifier:@"DialTile"];
    }
    return _collectionView;
}

// 空态文案。
- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [TSDialEditorAppearance label:@"" size:12 color:0x929B85];
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _emptyLabel;
}

// 空态操作入口。
- (UIButton *)emptyAction {
    if (!_emptyAction) {
        _emptyAction = [TSDialEditorAppearance button:@"创建表盘" primary:NO];
        [_emptyAction addTarget:self action:@selector(emptyTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emptyAction;
}

// 列表尾部的轻量说明。
- (UILabel *)footnoteLabel {
    if (!_footnoteLabel) {
        _footnoteLabel = [TSDialEditorAppearance label:@"" size:10 color:0x9CA38F];
        _footnoteLabel.numberOfLines = 2;
    }
    return _footnoteLabel;
}

// 固定底栏。
- (UIView *)storageBar {
    if (!_storageBar) {
        _storageBar = [[UIView alloc] init];
        _storageBar.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
        _storageBar.layer.shadowColor = [TSDialEditorAppearance color:0xDADED1].CGColor;
        _storageBar.layer.shadowOpacity = 0.3;
        _storageBar.layer.shadowOffset = CGSizeMake(0, -1);
        _storageBar.layer.shadowRadius = 0;
    }
    return _storageBar;
}

// 空间详情点击区域。
- (UIButton *)storageButton {
    if (!_storageButton) {
        _storageButton = [self textButton:@"" size:11 color:0x849074 action:@selector(showStorageSheet)];
        _storageButton.accessibilityLabel = @"查看表盘空间";
    }
    return _storageButton;
}

// 剩余容量。
- (UILabel *)storageLabel {
    if (!_storageLabel) {
        _storageLabel = [TSDialEditorAppearance label:@"" size:11 color:0x849074];
    }
    return _storageLabel;
}

// 数量与详情箭头。
- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [TSDialEditorAppearance label:@"" size:11 color:0x849074];
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

// 仅已知总空间时展示使用比例。
- (UIView *)storageTrack {
    if (!_storageTrack) {
        _storageTrack = [[UIView alloc] init];
        _storageTrack.backgroundColor = [TSDialEditorAppearance color:0xF1F3ED];
        _storageTrack.layer.cornerRadius = 1.5;
        _storageTrack.clipsToBounds = YES;
        _storageTrack.userInteractionEnabled = NO;
    }
    return _storageTrack;
}

// 空间使用量色条。
- (UIView *)storageFill {
    if (!_storageFill) {
        _storageFill = [[UIView alloc] init];
        _storageFill.backgroundColor = [TSDialEditorAppearance color:0x95A283];
        _storageFill.layer.cornerRadius = 1.5;
    }
    return _storageFill;
}

// 短暂提示采用 HTML 的深绿色圆角样式。
- (UILabel *)toastLabel {
    if (!_toastLabel) {
        _toastLabel = [TSDialEditorAppearance label:@"" size:12 color:0xFFFFFF];
        _toastLabel.backgroundColor = [TSDialEditorAppearance color:0x303C2B];
        _toastLabel.layer.cornerRadius = 12;
        _toastLabel.clipsToBounds = YES;
        _toastLabel.numberOfLines = 0;
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.accessibilityTraits = UIAccessibilityTraitStaticText;
    }
    return _toastLabel;
}

@end
