//
//  TSWorkoutPushVC.m
//  TopStepComKit_Example
//

#import "TSWorkoutPushVC+Internal.h"

@implementation TSWorkoutPushVC

#pragma mark - 生命周期

/** 页面加载完成后读取云端运动和设备槽位 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadWorkoutData];
}

/** 页面销毁时取消仍在执行的 Demo 下载 */
- (void)dealloc {
    [self.cloudService cancelDownload];
    if (self.isInstalling) {
        [[self workoutInterface] cancelWorkoutInstallation:^(BOOL success, NSError *error) {
            (void)success;
            (void)error;
        }];
    }
}

#pragma mark - 公开方法

/** 初始化页面数据 */
- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"workout_push.page_title");
    self.cloudResources = @[];
    self.workoutSlots = @[];
    self.recentTitle = TSLocalizedString(@"workout_push.ready");
    self.recentDetail = TSLocalizedString(@"workout_push.pull_refresh");
}

/** 同时加载 Cloud Workout 与设备运动槽位 */
- (void)reloadWorkoutData {
    self.cloudLoading = YES;
    self.slotLoading = YES;
    [self.refreshControl beginRefreshing];
    self.deviceDetailLabel.text = TSLocalizedString(@"workout_push.loading");

    __weak typeof(self) weakSelf = self;
    [self.cloudService fetchResources:^(NSArray<TSWorkoutCloudResource *> *resources, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.cloudLoading = NO;
        strongSelf.cloudResources = resources ?: @[];
        if (error) {
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.cloud_failed")
                                   detail:error.localizedDescription];
        }
        [strongSelf.workoutTableView reloadData];
        [strongSelf finishRefreshIfNeeded];
    }];

    [[self workoutInterface] fetchWorkoutSlots:^(NSArray<TSWorkoutSlotModel *> *slots, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.slotLoading = NO;
        strongSelf.workoutSlots = slots ?: @[];
        NSUInteger replaceableCount = [[strongSelf.workoutSlots filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(TSWorkoutSlotModel *slot, NSDictionary *bindings) {
                return slot.isReplaceable;
            }]] count];
        strongSelf.deviceTitleLabel.text = [TopStepComKit sharedInstance].connectedPeripheral.systemInfo.bleName ?: @"Fit Watch";
        strongSelf.deviceDetailLabel.text = error.localizedDescription ?: [NSString stringWithFormat:
            TSLocalizedString(@"workout_push.slot_summary"), (unsigned long)replaceableCount];
        if (error) {
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.slot_failed")
                                   detail:error.localizedDescription];
        } else if (!strongSelf.isCloudLoading) {
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.loaded")
                                   detail:[NSString stringWithFormat:TSLocalizedString(@"workout_push.loaded_detail"),
                                           (unsigned long)strongSelf.cloudResources.count,
                                           (unsigned long)replaceableCount]];
        }
        [strongSelf.workoutTableView reloadData];
        [strongSelf finishRefreshIfNeeded];
    }];
}

/** 两类数据均完成后结束刷新动画 */
- (void)finishRefreshIfNeeded {
    if (!self.isCloudLoading && !self.isSlotLoading) {
        [self.refreshControl endRefreshing];
    }
}

/** 更新最近操作 */
- (void)updateRecentTitle:(NSString *)title detail:(NSString *)detail {
    self.recentTitle = title ?: @"";
    self.recentDetail = detail ?: @"";
    [self.workoutTableView reloadSections:[NSIndexSet indexSetWithIndex:2]
                         withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 私有方法

/** 获取 SDK 运动安装接口 */
- (id<TSWorkoutInterface>)workoutInterface {
    return [TopStepComKit sharedInstance].workout;
}

/** 返回运动槽位展示名 */
- (NSString *)displayNameForSlot:(TSWorkoutSlotModel *)slot {
    switch (slot.workoutType.integerValue) {
        case TSSportTypeOutdoorRunning: return TSLocalizedString(@"workout.outdoor_running");
        case TSSportTypeFootball: return TSLocalizedString(@"workout.football");
        case TSSportTypeRopeSkipping: return TSLocalizedString(@"workout.jump_rope");
        case TSSportTypeFreeTraining: return TSLocalizedString(@"workout.free_training");
        default: return slot.workoutType ? [NSString stringWithFormat:@"Type 0x%lX", (long)slot.workoutType.integerValue]
                                        : TSLocalizedString(@"workout_push.unknown_workout");
    }
}

/** 格式化文件大小 */
- (NSString *)formattedSize:(NSUInteger)size {
    if (size >= 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f MB", size / 1024.0 / 1024.0];
    }
    return [NSString stringWithFormat:@"%.0f KB", MAX(1, size) / 1024.0];
}

#pragma mark - 属性懒加载 Getter

/** 返回运动列表 */
- (UITableView *)workoutTableView {
    if (!_workoutTableView) {
        _workoutTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _workoutTableView.dataSource = self;
        _workoutTableView.delegate = self;
        _workoutTableView.backgroundColor = TSColor_Background;
        _workoutTableView.rowHeight = 66.f;
        _workoutTableView.refreshControl = self.refreshControl;
    }
    return _workoutTableView;
}

/** 返回下拉刷新控件 */
- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(reloadWorkoutData) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

/** 返回进度遮罩 */
- (UIView *)operationOverlay {
    if (!_operationOverlay) {
        _operationOverlay = [[UIView alloc] init];
        _operationOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.36f];
        _operationOverlay.hidden = YES;
    }
    return _operationOverlay;
}

/** 返回进度卡片 */
- (UIView *)operationCardView {
    if (!_operationCardView) {
        _operationCardView = [[UIView alloc] init];
        _operationCardView.backgroundColor = TSColor_Card;
        _operationCardView.layer.cornerRadius = 18.f;
    }
    return _operationCardView;
}

/** 返回进度标题 */
- (UILabel *)operationTitleLabel {
    if (!_operationTitleLabel) {
        _operationTitleLabel = [[UILabel alloc] init];
        _operationTitleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightSemibold];
        _operationTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _operationTitleLabel;
}

/** 返回进度说明 */
- (UILabel *)operationDetailLabel {
    if (!_operationDetailLabel) {
        _operationDetailLabel = [[UILabel alloc] init];
        _operationDetailLabel.font = [UIFont systemFontOfSize:13.f];
        _operationDetailLabel.textColor = TSColor_TextSecondary;
        _operationDetailLabel.textAlignment = NSTextAlignmentCenter;
        _operationDetailLabel.numberOfLines = 2;
    }
    return _operationDetailLabel;
}

/** 返回传输进度条 */
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = TSColor_Primary;
    }
    return _progressView;
}

/** 返回取消按钮 */
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:TSLocalizedString(@"workout_push.cancel") forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [TSColor_Danger colorWithAlphaComponent:0.10f];
        _cancelButton.layer.cornerRadius = 12.f;
        [_cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

/** 返回云端业务服务 */
- (TSWorkoutCloudService *)cloudService {
    if (!_cloudService) {
        _cloudService = [[TSWorkoutCloudService alloc] init];
    }
    return _cloudService;
}

@end
