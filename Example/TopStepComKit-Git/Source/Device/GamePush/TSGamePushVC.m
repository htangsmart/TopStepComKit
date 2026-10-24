//
//  TSGamePushVC.m
//  TopStepComKit_Example
//

#import "TSGamePushVC.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import <stdint.h>

#import "TSDeviceCoordinator.h"
#import "UIViewController+TSToast.h"

static const CGFloat kGamePageInset = 16;
static const CGFloat kGameCardRadius = 16;
static const CGFloat kGameButtonHeight = 48;

// 主线程回调立即收尾，避免额外派发让已结束任务仍能触发取消。
static void TSGamePerformOnMain(dispatch_block_t action) {
    if (NSThread.isMainThread) {
        action();
    } else {
        dispatch_async(dispatch_get_main_queue(), action);
    }
}

// 底部弹层的交互类型。
typedef NS_ENUM(NSUInteger, TSGameSheetKind) {
    TSGameSheetKindNone,
    TSGameSheetKindConfiguration,
    TSGameSheetKindProgress,
    TSGameSheetKindCancel,
    TSGameSheetKindResult,
    TSGameSheetKindInformation,
    TSGameSheetKindReplacement,
};

@interface TSGamePushVC () <UIDocumentPickerDelegate>
// 页面滚动容器与内容栈。
@property (nonatomic, strong) UIScrollView *pageScrollView;
// 页面卡片内容栈。
@property (nonatomic, strong) UIStackView *pageStack;
// 下拉刷新控件。
@property (nonatomic, strong) UIRefreshControl *refreshControl;
// 底部弹层及滚动内容。
@property (nonatomic, strong) UIView *sheetOverlay;
// 底部圆角面板。
@property (nonatomic, strong) UIView *sheetPanel;
// 弹层内容滚动容器。
@property (nonatomic, strong) UIScrollView *sheetScrollView;
// 弹层纵向内容栈。
@property (nonatomic, strong) UIStackView *sheetStack;
// 当前弹层标题。
@property (nonatomic, strong) UILabel *sheetTitleLabel;
// 关闭弹层按钮。
@property (nonatomic, strong) UIButton *sheetCloseButton;
// 按内容与可用高度调整的面板高度。
@property (nonatomic, strong) NSLayoutConstraint *sheetHeightConstraint;
// 固定面板宽度，避免内容测量将外层弹窗压窄。
@property (nonatomic, strong) NSLayoutConstraint *sheetWidthConstraint;
// 固定在页面底部的面板约束。
@property (nonatomic, strong) NSLayoutConstraint *sheetBottomConstraint;
// 当前弹层类型。
@property (nonatomic, assign) TSGameSheetKind sheetKind;
// 确认参数后的推送按钮。
@property (nonatomic, strong) UIButton *submitButton;
// 参数校验提示。
@property (nonatomic, strong) UILabel *formErrorLabel;
// 按设备顺序排列的槽位选择按钮。
@property (nonatomic, copy) NSArray<UIButton *> *slotButtons;
// 真实进度视图，不使用模拟定时器。
@property (nonatomic, strong) CAShapeLayer *progressLayer;
// 实际传输百分比。
@property (nonatomic, strong) UILabel *progressLabel;
// 当前操作状态文案。
@property (nonatomic, strong) UILabel *progressTitleLabel;
// 发起取消确认的按钮。
@property (nonatomic, strong) UIButton *cancelButton;
// 当前连接和查询批次。
@property (nonatomic, strong) TSDeviceConnectionSnapshot *sessionSnapshot;
// 最近就绪设备用于跨断连保留取消和结果待确认提示。
@property (nonatomic, strong) TSDeviceConnectionSnapshot *lastReadySnapshot;
// 本轮查询使用的原始接口。
@property (nonatomic, strong) id<TSGamePushInterface> queryInterface;
// 用于过滤迟到查询的本地批次。
@property (nonatomic, assign) NSUInteger refreshGeneration;
// 当前批次尚未完成的查询。
@property (nonatomic, strong) NSMutableSet<NSString *> *pendingQueries;
// 各查询分别保留成功结果和失败原因，nil 不当作空列表。
@property (nonatomic, copy) NSArray<TSGameModel *> *installedGames;
// 设备返回的有序槽位列表。
@property (nonatomic, copy) NSArray<TSGameSlotModel *> *gameSlots;
// 设备支持的原始游戏类型列表。
@property (nonatomic, copy) NSArray<NSNumber *> *supportedTypes;
// 设备返回的游戏空间汇总。
@property (nonatomic, strong) TSStorageSpace *gameStorage;
// 按查询类别保留的失败信息。
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSError *> *queryErrors;
// 文件导入快照及用户输入。
@property (nonatomic, copy) NSString *importDirectory;
// 本页拥有的游戏包副本路径。
@property (nonatomic, copy) NSString *localFilePath;
// 本地游戏包副本的字节数。
@property (nonatomic, assign) unsigned long long fileSize;
// 是否正在协调读取文件。
@property (nonatomic, assign) BOOL importing;
// 文件导入操作的独立身份。
@property (nonatomic, strong) NSUUID *importToken;
// 系统文件选择器也绑定打开时的设备会话。
@property (nonatomic, strong) TSDeviceConnectionSnapshot *documentPickerSnapshot;
// 用户明确选择的设备槽位索引。
@property (nonatomic, copy) NSNumber *selectedSlotIndex;
// 替换确认时冻结的包路径与槽位，防止确认后写入其他目标。
@property (nonatomic, strong) TSGamePushRequest *replacementRequest;
// 替换确认绑定的原设备会话。
@property (nonatomic, strong) TSDeviceConnectionSnapshot *replacementSnapshot;
// 替换提示所展示的原槽位内容。
@property (nonatomic, assign) uint64_t replacementIdentifier;
// 原任务身份及回调终态门禁。
@property (nonatomic, strong) id<TSGamePushInterface> activeInterface;
// 原始推送所属的设备会话。
@property (nonatomic, strong) TSDeviceConnectionSnapshot *activeSnapshot;
// 原始推送的回调身份。
@property (nonatomic, strong) NSUUID *operationToken;
// 原始推送的参数快照。
@property (nonatomic, strong) TSGamePushRequest *activeRequest;
// 原始推送尚未收到终态。
@property (nonatomic, assign) BOOL pushing;
// 取消请求正在等待原任务结束。
@property (nonatomic, assign) BOOL cancelRequested;
// 设备当前阶段拒绝取消。
@property (nonatomic, assign) BOOL cancelRejected;
// 成功前保持小于百分之百的实际进度。
@property (nonatomic, assign) NSInteger transferProgress;
// 未确认结果不能由列表刷新解除；取消后采用保守重连策略。
@property (nonatomic, assign) BOOL installationUncertain;
// 按设备保留未确认结果，切换设备再返回不解除限制。
@property (nonatomic, strong) NSMutableArray<TSDeviceConnectionSnapshot *> *uncertainSnapshots;
// 取消后是否需要建立新会话。
@property (nonatomic, assign) BOOL reconnectRequired;
// 被取消任务所属的连接代次。
@property (nonatomic, assign) NSUInteger cancelledGeneration;
// 是否正在恢复设备连接。
@property (nonatomic, assign) BOOL reconnecting;
// 两阶段恢复流程的身份，离开页面后不再发起后半段重连。
@property (nonatomic, strong) NSUUID *recoveryToken;
// 最近操作摘要及导航状态。
@property (nonatomic, copy) NSString *recentMessage;
// 最近操作摘要是否使用警示色。
@property (nonatomic, assign) BOOL recentWarning;
// 进入页面前的侧滑返回状态。
@property (nonatomic, assign) BOOL previousPopGestureEnabled;
// 仅首次进入时保存导航手势，系统文件选择器返回不覆盖原值。
@property (nonatomic, assign) BOOL capturedPopGestureState;
@end

@implementation TSGamePushVC

#pragma mark - 生命周期

// 初始化状态，数据仅来自真实 SDK。
- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"game_push.title");
    self.localFilePath = @"";
    self.pendingQueries = [NSMutableSet set];
    self.queryErrors = [NSMutableDictionary dictionary];
    self.uncertainSnapshots = [NSMutableArray array];
    self.sessionSnapshot = [self currentSnapshot];
    self.lastReadySnapshot = self.sessionSnapshot.isReady ? self.sessionSnapshot : nil;
}

// 在基类创建页面后监听统一连接快照。
- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(connectionDidChange:)
                   name:TSDeviceConnectionSnapshotDidChangeNotification object:TSDeviceCoordinator.sharedInstance];
    [center addObserver:self selector:@selector(applicationDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(bindingDidClear:)
                   name:TSDeviceBindingDidClearNotification object:TSDeviceCoordinator.sharedInstance];
    [self reloadGameData];
}

// 回到页面时校验设备会话，避免文件选择器期间换设备。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.capturedPopGestureState) {
        self.previousPopGestureEnabled = self.navigationController.interactivePopGestureRecognizer.enabled;
        self.capturedPopGestureState = YES;
    }
    [self synchronizeSession];
    [self updateNavigationAvailability];
}

// 真正离开页面时恢复其他页面的返回手势。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.navigationController.isBeingDismissed) {
        self.navigationController.interactivePopGestureRecognizer.enabled = self.previousPopGestureEnabled;
        self.recoveryToken = nil;
    }
}

// 根据实际内容与安全区调整底部弹层。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateSheetHeight];
}

// 仅删除本页拥有且不再由活动任务读取的文件。
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    if (!_pushing && _importDirectory.length) {
        [NSFileManager.defaultManager removeItemAtPath:_importDirectory error:nil];
    }
    TSLog(@"[GamePush][TSGamePushVC] dealloc pushing=%d importing=%d", _pushing, _importing);
}

#pragma mark - 私有方法：页面布局

// 用原生导航栏与自动布局还原原型，不创建基类调试表格。
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView addSubview:self.pageStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.pageScrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.pageScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.pageScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.pageScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.pageStack.topAnchor constraintEqualToAnchor:self.pageScrollView.contentLayoutGuide.topAnchor constant:3],
        [self.pageStack.leadingAnchor constraintEqualToAnchor:self.pageScrollView.contentLayoutGuide.leadingAnchor constant:kGamePageInset],
        [self.pageStack.trailingAnchor constraintEqualToAnchor:self.pageScrollView.contentLayoutGuide.trailingAnchor constant:-kGamePageInset],
        [self.pageStack.bottomAnchor constraintEqualToAnchor:self.pageScrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [self.pageStack.widthAnchor constraintEqualToAnchor:self.pageScrollView.frameLayoutGuide.widthAnchor constant:-32]
    ]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self iconNamed:@"refresh"]
        style:UIBarButtonItemStylePlain target:self action:@selector(reloadGameData)];
    self.navigationItem.rightBarButtonItem.accessibilityLabel = TSLocalizedString(@"game_push.ui.refresh");
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    [back setImage:[self iconNamed:@"back"] forState:UIControlStateNormal];
    [back setTitle:TSLocalizedString(@"game_push.ui.back") forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:15];
    [back.heightAnchor constraintEqualToConstant:44].active = YES;
    [back addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    [self renderPage];
}

// 自动布局接管尺寸，避免基类使用固定表格 frame。
- (void)layoutViews {
    [self.view setNeedsLayout];
}

// 创建可换行的系统字体标签。
- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

// 创建原型中的圆角主次按钮。
- (UIButton *)button:(NSString *)title primary:(BOOL)primary action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    button.backgroundColor = primary ? TSColor_Primary : TSColor_Background;
    [button setTitleColor:primary ? UIColor.whiteColor : TSColor_TextSecondary forState:UIControlStateNormal];
    button.layer.cornerRadius = 12;
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:kGameButtonHeight].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 保持禁用态与 HTML 中的浅灰按钮一致。
- (void)setPrimaryButton:(UIButton *)button enabled:(BOOL)enabled {
    button.enabled = enabled;
    button.backgroundColor = enabled ? TSColor_Primary : [self softColor:0xDDE2EB dark:0x353943];
    [button setTitleColor:enabled ? UIColor.whiteColor : TSColor_TextSecondary forState:UIControlStateNormal];
}

// 创建同一套浅色和深色自适应色。
- (UIColor *)softColor:(NSUInteger)light dark:(NSUInteger)dark {
    UIColor *(^color)(NSUInteger) = ^UIColor *(NSUInteger value) {
        return [UIColor colorWithRed:((value >> 16) & 255) / 255.0
                               green:((value >> 8) & 255) / 255.0 blue:(value & 255) / 255.0 alpha:1];
    };
    return TSAdaptiveColor(color(light), color(dark));
}

// 创建按内容自适应高度的纵向栈。
- (UIStackView *)verticalStack:(CGFloat)spacing {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = spacing;
    return stack;
}

// 为内容加上白色卡片和内边距。
- (UIView *)cardWithContent:(UIView *)content inset:(CGFloat)inset {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = kGameCardRadius;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:card.topAnchor constant:inset],
        [content.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:inset],
        [content.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-inset],
        [content.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-inset]
    ]];
    return card;
}

// 加载原型导出的模板矢量图标，兼容 iOS 12。
- (UIImage *)iconNamed:(NSString *)name {
    return [[UIImage imageNamed:[@"ts_game_icon_" stringByAppendingString:name]]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

// 创建固定大小的图标底座。
- (UIView *)iconTile:(NSString *)name size:(CGFloat)size {
    UIView *tile = [[UIView alloc] init];
    tile.backgroundColor = [self softColor:0xEAF2FF dark:0x182D49];
    tile.layer.cornerRadius = size * 0.3;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self iconNamed:name]];
    imageView.tintColor = TSColor_Primary;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [tile addSubview:imageView];
    [NSLayoutConstraint activateConstraints:@[
        [tile.widthAnchor constraintEqualToConstant:size], [tile.heightAnchor constraintEqualToConstant:size],
        [imageView.centerXAnchor constraintEqualToAnchor:tile.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:tile.centerYAnchor],
        [imageView.widthAnchor constraintEqualToConstant:size * 0.55],
        [imageView.heightAnchor constraintEqualToConstant:size * 0.55]
    ]];
    return tile;
}

// 创建左右两栏的信息行。
- (UIView *)informationRow:(NSString *)title value:(NSString *)value {
    UILabel *titleLabel = [self label:title size:12 weight:UIFontWeightRegular color:TSColor_TextSecondary];
    UILabel *valueLabel = [self label:value size:12 weight:UIFontWeightRegular color:TSColor_TextPrimary];
    valueLabel.textAlignment = NSTextAlignmentRight;
    [titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1
                                              forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, valueLabel]];
    row.spacing = 14;
    row.alignment = UIStackViewAlignmentCenter;
    UIView *container = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:row];
    UIView *separator = [[UIView alloc] init];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = [self softColor:0xECEEF3 dark:0x38383A];
    [container addSubview:separator];
    [NSLayoutConstraint activateConstraints:@[
        [container.heightAnchor constraintGreaterThanOrEqualToConstant:43],
        [row.topAnchor constraintEqualToAnchor:container.topAnchor constant:12],
        [row.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-12],
        [row.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [row.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [separator.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [separator.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [separator.heightAnchor constraintEqualToConstant:1]
    ]];
    return container;
}

// 清空栈中的旧视图，避免多次刷新重复叠加。
- (void)clearStack:(UIStackView *)stack {
    for (UIView *view in stack.arrangedSubviews) {
        [stack removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

// 渲染设备状态、导入入口、已安装游戏与空间摘要。
- (void)renderPage {
    if (!self.isViewLoaded) {
        return;
    }
    [self clearStack:self.pageStack];
    UIView *connection = [self connectionView];
    [self.pageStack addArrangedSubview:connection];
    [self.pageStack setCustomSpacing:19 afterView:connection];
    NSString *notice = [self pageNotice];
    if (notice.length) {
        [self.pageStack addArrangedSubview:[self noticeView:notice]];
    }
    UIView *importCard = [self importCard];
    [self.pageStack addArrangedSubview:importCard];
    [self.pageStack setCustomSpacing:23 afterView:importCard];
    NSString *count = self.installedGames ? [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.game_count"),
        (unsigned long)self.installedGames.count] : @"";
    if (self.pendingQueries.count) {
        count = TSLocalizedString(@"general.loading");
    }
    UIView *heading = [self sectionTitle:TSLocalizedString(@"game_push.ui.watch_games") detail:count];
    [self.pageStack addArrangedSubview:heading];
    [self.pageStack setCustomSpacing:12 afterView:heading];
    if (self.pendingQueries.count) {
        [self.pageStack addArrangedSubview:[self messageCard:TSLocalizedString(@"general.loading") detail:nil]];
    } else if (!self.sessionSnapshot.isReady || ![self gameInterface].isSupport) {
        [self.pageStack addArrangedSubview:[self messageCard:TSLocalizedString(@"game_push.ui.unavailable_title")
            detail:TSLocalizedString(@"game_push.ui.unavailable_detail")]];
    } else if (self.queryErrors[@"games"] || !self.installedGames) {
        [self.pageStack addArrangedSubview:[self messageCard:TSLocalizedString(@"game_push.ui.query_failed")
            detail:TSLocalizedString(@"game_push.ui.query_retry")]];
    } else if (!self.installedGames.count) {
        [self.pageStack addArrangedSubview:[self messageCard:TSLocalizedString(@"game_push.ui.empty_title")
            detail:TSLocalizedString(@"game_push.ui.empty_detail")]];
    } else {
        [self addGameGrid];
    }
    if ([self gameInterface].isSupport) {
        [self.pageStack setCustomSpacing:14 afterView:self.pageStack.arrangedSubviews.lastObject];
        [self.pageStack addArrangedSubview:[self storageButton]];
    }
    if (self.recentMessage.length) {
        UILabel *message = [self label:self.recentMessage size:12 weight:UIFontWeightRegular
            color:self.recentWarning ? [self softColor:0xA65B11 dark:0xF3BF7B] : [self softColor:0x258551 dark:0x66CC8B]];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[self iconNamed:self.recentWarning ? @"info" : @"check"]];
        icon.tintColor = message.textColor;
        [icon.widthAnchor constraintEqualToConstant:17].active = YES;
        [icon.heightAnchor constraintEqualToConstant:17].active = YES;
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[icon, message]];
        row.spacing = 8;
        row.alignment = UIStackViewAlignmentCenter;
        UIView *recent = [self cardWithContent:row inset:12];
        recent.layer.cornerRadius = 12;
        recent.backgroundColor = self.recentWarning ? [self softColor:0xFFF4E5 dark:0x35291D] :
            [self softColor:0xEDF8F1 dark:0x193629];
        [self.pageStack addArrangedSubview:recent];
    }
    UIButton *details = [self button:TSLocalizedString(@"game_push.ui.device_details") primary:NO
                             action:@selector(showCapabilities)];
    details.backgroundColor = UIColor.clearColor;
    details.titleLabel.font = [UIFont systemFontOfSize:12];
    [details setImage:[self iconNamed:@"info"] forState:UIControlStateNormal];
    details.tintColor = TSColor_TextSecondary;
    details.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 6);
    [self.pageStack addArrangedSubview:details];
    [self updateNavigationAvailability];
}

// 显示分区标题和数量，不混淆未知与零。
- (UIView *)sectionTitle:(NSString *)title detail:(NSString *)detail {
    UILabel *titleLabel = [self label:title size:16 weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    UILabel *detailLabel = [self label:detail size:12 weight:UIFontWeightRegular color:TSColor_TextSecondary];
    detailLabel.textAlignment = NSTextAlignmentRight;
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, detailLabel]];
    row.spacing = 8;
    row.alignment = UIStackViewAlignmentCenter;
    [row.heightAnchor constraintGreaterThanOrEqualToConstant:20].active = YES;
    return row;
}

// 显示真实设备名称和连接状态。
- (UIView *)connectionView {
    BOOL ready = self.sessionSnapshot.isReady;
    NSString *name = self.sessionSnapshot.peripheral.systemInfo.bleName;
    UIStackView *copy = [self verticalStack:2];
    [copy addArrangedSubview:[self label:name.length ? name : TSLocalizedString(@"game_push.ui.device")
        size:14 weight:UIFontWeightSemibold color:TSColor_TextPrimary]];
    NSString *detail = ready && [self gameInterface].isSupport ? @"game_push.ui.device_ready" : @"game_push.ui.device_wait";
    [copy addArrangedSubview:[self label:TSLocalizedString(detail) size:12 weight:UIFontWeightRegular
        color:TSColor_TextSecondary]];
    NSString *status = ready ? @"game_push.ui.connected" : self.sessionSnapshot.isTransitioning ?
        @"game_push.ui.connecting" : @"game_push.ui.disconnected";
    UILabel *badge = [self label:[@"● " stringByAppendingString:TSLocalizedString(status)] size:11
        weight:UIFontWeightRegular color:ready ? [self softColor:0x258551 dark:0x66CC8B] : TSColor_TextSecondary];
    [badge setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [badge setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIView *pill = [self cardWithContent:badge inset:6];
    pill.layer.cornerRadius = 13;
    pill.backgroundColor = ready ? [self softColor:0xEDF8F1 dark:0x193629] : TSColor_Separator;
    UIView *watch = [self iconTile:@"watch" size:38];
    watch.backgroundColor = [self softColor:0xE5E8EF dark:0x292D36];
    ((UIImageView *)watch.subviews.firstObject).tintColor = [self softColor:0x5F697C dark:0xA3AABD];
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[watch, copy, pill]];
    row.spacing = 10;
    row.alignment = UIStackViewAlignmentCenter;
    return row;
}

// 只显示与当前状态有关的可恢复提示。
- (NSString *)pageNotice {
    if (self.reconnecting || self.sessionSnapshot.isTransitioning) {
        return TSLocalizedString(@"game_push.ui.connecting_detail");
    }
    if (!self.sessionSnapshot.isReady) {
        return TSLocalizedString(@"game_push.ui.disconnected_detail");
    }
    if (![self gameInterface].isSupport) {
        return TSLocalizedString(@"game_push.ui.unsupported_detail");
    }
    if (self.installationUncertain) {
        return TSLocalizedString(@"game_push.ui.uncertain_detail");
    }
    if (self.reconnectRequired) {
        return TSLocalizedString(@"game_push.ui.reconnect_detail");
    }
    if (self.queryErrors[@"games"]) {
        return TSLocalizedString(@"game_push.ui.installed_query_failed");
    }
    if (self.queryErrors.count) {
        return TSLocalizedString(@"game_push.ui.partial_failure");
    }
    return nil;
}

// 提示卡遵循浅橙背景；恢复操作使用单个文字按钮。
- (UIView *)noticeView:(NSString *)message {
    UIStackView *content = [self verticalStack:4];
    [content addArrangedSubview:[self label:message size:12 weight:UIFontWeightRegular
        color:[self softColor:0xA65B11 dark:0xF3BF7B]]];
    if ([message isEqualToString:[self pageNotice]] &&
        (self.reconnectRequired || !self.sessionSnapshot.isReady || self.installationUncertain || self.queryErrors.count)) {
        NSString *title = self.reconnectRequired || !self.sessionSnapshot.isReady ?
            @"game_push.ui.reconnect" : @"game_push.ui.check_games";
        UIButton *action = [self button:TSLocalizedString(title) primary:NO action:@selector(recoverTapped)];
        action.backgroundColor = UIColor.clearColor;
        action.enabled = !self.pushing && !self.reconnecting && !self.sessionSnapshot.isTransitioning;
        [content addArrangedSubview:action];
    }
    UIView *card = [self cardWithContent:content inset:12];
    card.backgroundColor = [self softColor:0xFFF4E5 dark:0x35291D];
    return card;
}

// 导入入口在空文件和已有文件两种状态间切换。
- (UIView *)importCard {
    BOOL hasFile = self.localFilePath.length > 0;
    BOOL canContinue = hasFile && [self canPrepareInstallation];
    BOOL canImport = [self canImportGamePackage];
    UIStackView *copy = [self verticalStack:3];
    NSString *title = hasFile ? @"game_push.ui.package_ready" : @"game_push.ui.add_game";
    [copy addArrangedSubview:[self label:TSLocalizedString(title) size:18 weight:UIFontWeightSemibold color:TSColor_TextPrimary]];
    NSString *detail = hasFile ? [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.local_size"),
        [self formattedBytes:self.fileSize]] : TSLocalizedString(@"game_push.ui.add_detail");
    [copy addArrangedSubview:[self label:detail size:12 weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    UIStackView *heading = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self iconTile:hasFile ? @"file" : @"game" size:56], copy]];
    heading.spacing = 14;
    heading.alignment = UIStackViewAlignmentCenter;
    UIStackView *content = [self verticalStack:16];
    [content addArrangedSubview:heading];
    NSString *buttonKey = self.importing ? @"game_push.ui.importing" : canContinue ?
        @"game_push.ui.continue" : hasFile ? @"game_push.ui.change_file" : @"game_push.ui.import";
    UIButton *button = [self button:TSLocalizedString(buttonKey) primary:YES action:@selector(importTapped)];
    [button setImage:[self iconNamed:canContinue ? @"next" : @"plus"] forState:UIControlStateNormal];
    button.tintColor = canImport ? UIColor.whiteColor : TSColor_TextSecondary;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 4);
    [self setPrimaryButton:button enabled:canImport];
    [content addArrangedSubview:button];
    UILabel *caption = [self label:hasFile ? self.localFilePath.lastPathComponent :
        TSLocalizedString(@"game_push.ui.import_hint") size:11 weight:UIFontWeightRegular color:TSColor_TextSecondary];
    caption.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:caption];
    if (hasFile && !canContinue && !self.importing && !self.pushing) {
        NSString *reason = [self pageNotice] ?: TSLocalizedString(@"game_push.ui.wait_for_device_info");
        UILabel *hint = [self label:reason size:12 weight:UIFontWeightRegular color:TSColor_TextSecondary];
        hint.textAlignment = NSTextAlignmentCenter;
        [content addArrangedSubview:hint];
    }
    return [self cardWithContent:content inset:20];
}

// 空态和失败态使用相同卡片结构但保留不同文案。
- (UIView *)messageCard:(NSString *)title detail:(NSString *)detail {
    UIStackView *content = [self verticalStack:8];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[self iconNamed:@"game"]];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.tintColor = [self softColor:0x92A0B7 dark:0x8090AB];
    [icon.heightAnchor constraintEqualToConstant:33].active = YES;
    [content addArrangedSubview:icon];
    UILabel *titleLabel = [self label:title size:14 weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:titleLabel];
    if (detail.length) {
        UILabel *detailLabel = [self label:detail size:12 weight:UIFontWeightRegular color:TSColor_TextSecondary];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        [content addArrangedSubview:detailLabel];
    }
    return [self cardWithContent:content inset:28];
}

// 保留设备返回的顺序和重复条目，按两列排布游戏。
- (void)addGameGrid {
    for (NSUInteger index = 0; index < self.installedGames.count; index += 2) {
        UIView *first = [self gameCardAtIndex:index];
        UIView *second = index + 1 < self.installedGames.count ? [self gameCardAtIndex:index + 1] : [[UIView alloc] init];
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[first, second]];
        row.distribution = UIStackViewDistributionFillEqually;
        row.spacing = 12;
        [self.pageStack addArrangedSubview:row];
        [self.pageStack setCustomSpacing:12 afterView:row];
    }
}

// 插画表示游戏类型，不伪装成设备返回的真实封面。
- (UIView *)coverForGame:(TSGameModel *)game {
    NSString *asset = game.gameType == 1 ? @"merge" : game.gameType == 6 ? @"maze" : game.gameType == 9 ? @"tetris" : nil;
    UIView *cover = [[UIView alloc] init];
    cover.backgroundColor = game.gameType == 1 ? [self softColor:0xFBF0DF dark:0x3D3023] :
        game.gameType == 6 ? [self softColor:0xE8F2EF dark:0x203B35] : [self softColor:0xE9EFFF dark:0x232F49];
    cover.layer.cornerRadius = 10;
    UIImage *image = asset ? [UIImage imageNamed:[@"ts_game_cover_" stringByAppendingString:asset]] : [self iconNamed:@"game"];
    UIImageView *artwork = [[UIImageView alloc] initWithImage:image];
    artwork.translatesAutoresizingMaskIntoConstraints = NO;
    artwork.contentMode = UIViewContentModeScaleAspectFit;
    artwork.tintColor = TSColor_Primary;
    [cover addSubview:artwork];
    [NSLayoutConstraint activateConstraints:@[
        [cover.heightAnchor constraintEqualToConstant:96],
        [artwork.centerXAnchor constraintEqualToAnchor:cover.centerXAnchor],
        [artwork.centerYAnchor constraintEqualToAnchor:cover.centerYAnchor],
        [artwork.heightAnchor constraintEqualToConstant:asset ? 96 : 38],
        [artwork.widthAnchor constraintEqualToConstant:asset ? 120 : 38]
    ]];
    if (game.isBuiltIn) {
        UILabel *badge = [self label:TSLocalizedString(@"game_push.ui.builtin") size:10
            weight:UIFontWeightRegular color:TSColor_TextSecondary];
        badge.translatesAutoresizingMaskIntoConstraints = NO;
        [cover addSubview:badge];
        [NSLayoutConstraint activateConstraints:@[[badge.topAnchor constraintEqualToAnchor:cover.topAnchor constant:7],
            [badge.trailingAnchor constraintEqualToAnchor:cover.trailingAnchor constant:-7]]];
    }
    return cover;
}

// 以点击卡片打开详情，不增加 SDK 没有的启动和删除操作。
- (UIView *)gameCardAtIndex:(NSUInteger)index {
    TSGameModel *game = self.installedGames[index];
    UIStackView *content = [self verticalStack:7];
    [content addArrangedSubview:[self coverForGame:game]];
    NSString *name = [self gameName:game.gameType];
    [content addArrangedSubview:[self label:name size:14 weight:UIFontWeightSemibold color:TSColor_TextPrimary]];
    NSString *detail = game.isBuiltIn ? TSLocalizedString(@"game_push.ui.builtin_detail") :
        [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.skin_installed"), game.skinNumber];
    [content addArrangedSubview:[self label:detail size:11 weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    UIView *card = [self cardWithContent:content inset:10];
    content.accessibilityElementsHidden = YES;
    UIButton *button = [self overlayButtonOnView:card action:@selector(gameTapped:)];
    button.tag = index;
    button.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", name, detail];
    return card;
}

// 使用透明按钮扩大整卡点击区域。
- (UIButton *)overlayButtonOnView:(UIView *)view action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    [NSLayoutConstraint activateConstraints:@[[button.topAnchor constraintEqualToAnchor:view.topAnchor],
        [button.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
        [button.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [button.trailingAnchor constraintEqualToAnchor:view.trailingAnchor]]];
    return button;
}

// 未命名游戏保留原始类型编号。
- (NSString *)gameName:(NSInteger)type {
    NSString *localizationKey = [NSString stringWithFormat:@"game_push.ui.type_%ld", (long)type];
    NSString *localizedName = TSLocalizedString(localizationKey);
    if (localizedName.length && ![localizedName isEqualToString:localizationKey]) {
        return localizedName;
    }
    return [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.unknown_type"), (long)type];
}

// 容量统一按二进制单位显示。
- (NSString *)formattedBytes:(unsigned long long)bytes {
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%llu B", bytes];
    }
    if (bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.0f KB", bytes / 1024.0];
    }
    return [NSString stringWithFormat:@"%.1f MB", bytes / (1024.0 * 1024.0)];
}

// 容量入口仅展示设备查询结果，不把槽位总容量当作实际文件用量。
- (UIView *)storageButton {
    NSString *detail = TSLocalizedString(@"game_push.ui.storage_unknown");
    if (self.gameStorage) {
        detail = [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.available_space"),
            [self formattedBytes:self.gameStorage.available]];
    }
    if (self.gameSlots) {
        detail = [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.slots_summary"),
            (unsigned long)self.gameSlots.count, detail];
    }
    UIStackView *copy = [self verticalStack:3];
    [copy addArrangedSubview:[self label:TSLocalizedString(@"game_push.ui.positions") size:14
        weight:UIFontWeightSemibold color:TSColor_TextPrimary]];
    [copy addArrangedSubview:[self label:detail size:11 weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    UIImageView *chevron = [[UIImageView alloc] initWithImage:[self iconNamed:@"next"]];
    chevron.tintColor = TSColor_TextSecondary;
    [chevron.widthAnchor constraintEqualToConstant:18].active = YES;
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[[self iconTile:@"slots" size:36], copy, chevron]];
    row.spacing = 12;
    row.alignment = UIStackViewAlignmentCenter;
    UIView *card = [self cardWithContent:row inset:16];
    row.accessibilityElementsHidden = YES;
    UIButton *button = [self overlayButtonOnView:card action:@selector(showStorage)];
    button.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", TSLocalizedString(@"game_push.ui.positions"), detail];
    return card;
}

#pragma mark - 私有方法：底部弹层

// 所有弹层共用可滚动容器，窄屏及长内容下保持按钮可达。
- (void)openSheet:(NSString *)title kind:(TSGameSheetKind)kind {
    [self.view endEditing:YES];
    if (!_sheetOverlay) {
        [self buildSheet];
    }
    [self clearStack:self.sheetStack];
    self.sheetKind = kind;
    self.sheetTitleLabel.text = title;
    self.sheetCloseButton.hidden = self.pushing;
    self.sheetOverlay.hidden = NO;
    self.sheetOverlay.accessibilityViewIsModal = YES;
    self.pageScrollView.accessibilityElementsHidden = YES;
    self.sheetScrollView.contentOffset = CGPointZero;
    [self.view bringSubviewToFront:self.sheetOverlay];
    [self updateNavigationAvailability];
    [self.view setNeedsLayout];
    if (!UIAccessibilityIsReduceMotionEnabled()) {
        [self.sheetPanel.layer removeAllAnimations];
        self.sheetPanel.alpha = 0.5;
        self.sheetPanel.transform = CGAffineTransformMakeTranslation(0, 35);
        [UIView animateWithDuration:0.22 animations:^{
            self.sheetPanel.alpha = 1;
            self.sheetPanel.transform = CGAffineTransformIdentity;
        }];
    }
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.sheetTitleLabel);
}

// 创建底部面板、遮罩及关闭按钮。
- (void)buildSheet {
    self.sheetOverlay = [[UIView alloc] init];
    self.sheetOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.sheetOverlay.backgroundColor = [[self softColor:0x17243C dark:0x000000] colorWithAlphaComponent:0.33];
    [self.view addSubview:self.sheetOverlay];
    UIButton *scrim = [UIButton buttonWithType:UIButtonTypeCustom];
    scrim.translatesAutoresizingMaskIntoConstraints = NO;
    scrim.accessibilityElementsHidden = YES;
    [scrim addTarget:self action:@selector(closeSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetOverlay addSubview:scrim];
    self.sheetPanel = [[UIView alloc] init];
    self.sheetPanel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sheetPanel.backgroundColor = TSColor_Card;
    self.sheetPanel.layer.cornerRadius = 24;
    self.sheetPanel.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.sheetPanel.clipsToBounds = YES;
    [self.sheetOverlay addSubview:self.sheetPanel];
    UIView *handle = [[UIView alloc] init];
    handle.translatesAutoresizingMaskIntoConstraints = NO;
    handle.backgroundColor = TSColor_Separator;
    handle.layer.cornerRadius = 2;
    [self.sheetPanel addSubview:handle];
    self.sheetTitleLabel = [self label:@"" size:18 weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    self.sheetTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sheetPanel addSubview:self.sheetTitleLabel];
    self.sheetCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sheetCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sheetCloseButton.tintColor = TSColor_TextSecondary;
    [self.sheetCloseButton setImage:[self iconNamed:@"close"] forState:UIControlStateNormal];
    self.sheetCloseButton.accessibilityLabel = TSLocalizedString(@"game_push.ui.close");
    [self.sheetCloseButton addTarget:self action:@selector(closeSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetPanel addSubview:self.sheetCloseButton];
    self.sheetScrollView = [[UIScrollView alloc] init];
    self.sheetScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sheetScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.sheetScrollView.alwaysBounceHorizontal = NO;
    [self.sheetPanel addSubview:self.sheetScrollView];
    self.sheetStack = [self verticalStack:16];
    self.sheetStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sheetScrollView addSubview:self.sheetStack];
    self.sheetHeightConstraint = [self.sheetPanel.heightAnchor constraintEqualToConstant:400];
    self.sheetWidthConstraint = [self.sheetPanel.widthAnchor constraintEqualToConstant:MIN(500, self.view.bounds.size.width)];
    self.sheetBottomConstraint = [self.sheetPanel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [self.sheetOverlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.sheetOverlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.sheetOverlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.sheetOverlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrim.topAnchor constraintEqualToAnchor:self.sheetOverlay.topAnchor],
        [scrim.bottomAnchor constraintEqualToAnchor:self.sheetOverlay.bottomAnchor],
        [scrim.leadingAnchor constraintEqualToAnchor:self.sheetOverlay.leadingAnchor],
        [scrim.trailingAnchor constraintEqualToAnchor:self.sheetOverlay.trailingAnchor],
        self.sheetBottomConstraint, self.sheetHeightConstraint, self.sheetWidthConstraint,
        [self.sheetPanel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [handle.topAnchor constraintEqualToAnchor:self.sheetPanel.topAnchor constant:9],
        [handle.centerXAnchor constraintEqualToAnchor:self.sheetPanel.centerXAnchor],
        [handle.widthAnchor constraintEqualToConstant:36], [handle.heightAnchor constraintEqualToConstant:4],
        [self.sheetTitleLabel.topAnchor constraintEqualToAnchor:self.sheetPanel.topAnchor constant:29],
        [self.sheetTitleLabel.heightAnchor constraintGreaterThanOrEqualToConstant:27],
        [self.sheetTitleLabel.leadingAnchor constraintEqualToAnchor:self.sheetPanel.leadingAnchor constant:21],
        [self.sheetTitleLabel.trailingAnchor constraintEqualToAnchor:self.sheetCloseButton.leadingAnchor constant:-8],
        [self.sheetCloseButton.centerYAnchor constraintEqualToAnchor:self.sheetTitleLabel.centerYAnchor],
        [self.sheetCloseButton.trailingAnchor constraintEqualToAnchor:self.sheetPanel.trailingAnchor constant:-10],
        [self.sheetCloseButton.widthAnchor constraintEqualToConstant:44],
        [self.sheetCloseButton.heightAnchor constraintEqualToConstant:44],
        [self.sheetScrollView.topAnchor constraintEqualToAnchor:self.sheetTitleLabel.bottomAnchor constant:15],
        [self.sheetScrollView.leadingAnchor constraintEqualToAnchor:self.sheetPanel.leadingAnchor],
        [self.sheetScrollView.trailingAnchor constraintEqualToAnchor:self.sheetPanel.trailingAnchor],
        [self.sheetScrollView.bottomAnchor constraintEqualToAnchor:self.sheetPanel.safeAreaLayoutGuide.bottomAnchor constant:-12],
        [self.sheetStack.topAnchor constraintEqualToAnchor:self.sheetScrollView.contentLayoutGuide.topAnchor],
        [self.sheetStack.bottomAnchor constraintEqualToAnchor:self.sheetScrollView.contentLayoutGuide.bottomAnchor constant:-8],
        [self.sheetStack.leadingAnchor constraintEqualToAnchor:self.sheetScrollView.contentLayoutGuide.leadingAnchor constant:21],
        [self.sheetStack.trailingAnchor constraintEqualToAnchor:self.sheetScrollView.contentLayoutGuide.trailingAnchor constant:-21],
        [self.sheetStack.widthAnchor constraintEqualToAnchor:self.sheetScrollView.frameLayoutGuide.widthAnchor constant:-42]
    ]];
}

// 按内容高度收缩弹层，长内容允许滚动。
- (void)updateSheetHeight {
    if (!_sheetOverlay || self.sheetOverlay.hidden) {
        return;
    }
    CGFloat panelWidth = MIN(500, self.view.bounds.size.width);
    if (panelWidth <= 0) {
        return;
    }
    self.sheetWidthConstraint.constant = panelWidth;
    CGFloat contentWidth = panelWidth - 42;
    CGFloat contentHeight = [self.sheetStack systemLayoutSizeFittingSize:CGSizeMake(contentWidth, UILayoutFittingCompressedSize.height)
        withHorizontalFittingPriority:UILayoutPriorityRequired verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height;
    CGFloat titleHeight = MAX(27, [self.sheetTitleLabel sizeThatFits:CGSizeMake(panelWidth - 83, CGFLOAT_MAX)].height);
    CGFloat available = self.view.bounds.size.height - self.view.safeAreaInsets.top - 12;
    available = MIN(available, self.view.bounds.size.height * 0.9);
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat height = MIN(available, contentHeight + titleHeight + 64 + bottomInset);
    if (fabs(self.sheetHeightConstraint.constant - height) > 0.5) {
        self.sheetHeightConstraint.constant = MAX(100, height);
    }
}

// 活动推送通过取消确认退出，其他弹层可直接关闭。
- (void)closeSheet {
    if (self.pushing) {
        [self askCancel];
        return;
    }
    [self.view endEditing:YES];
    self.sheetOverlay.hidden = YES;
    self.sheetKind = TSGameSheetKindNone;
    self.replacementRequest = nil;
    self.replacementSnapshot = nil;
    self.pageScrollView.accessibilityElementsHidden = NO;
    [self updateNavigationAvailability];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.pageStack);
}

// 确认包文件及安装位置，不要求人工填写游戏元数据。
- (void)configureInstallation {
    if (![self canPrepareInstallation] || !self.localFilePath.length) {
        [self closeSheet];
        return;
    }
    self.replacementRequest = nil;
    self.replacementSnapshot = nil;
    [self openSheet:TSLocalizedString(@"game_push.ui.configure") kind:TSGameSheetKindConfiguration];
    UIStackView *summary = [self verticalStack:4];
    [summary addArrangedSubview:[self label:self.localFilePath.lastPathComponent size:14
        weight:UIFontWeightSemibold color:TSColor_TextPrimary]];
    [summary addArrangedSubview:[self label:[self formattedBytes:self.fileSize] size:12
        weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    UIStackView *summaryRow = [[UIStackView alloc] initWithArrangedSubviews:@[[self iconTile:@"file" size:44], summary]];
    summaryRow.spacing = 12;
    summaryRow.alignment = UIStackViewAlignmentCenter;
    UIView *summaryCard = [self cardWithContent:summaryRow inset:13];
    summaryCard.layer.cornerRadius = 12;
    summaryCard.backgroundColor = [self softColor:0xF3F6FB dark:0x252A34];
    [self.sheetStack addArrangedSubview:summaryCard];
    self.slotButtons = @[];
    BOOL needsContentRefresh = NO;
    if ([self gameInterface].isSupportGameSlots) {
        [self.sheetStack addArrangedSubview:[self sectionTitle:TSLocalizedString(@"game_push.ui.select_position") detail:nil]];
        NSMutableArray *buttons = [NSMutableArray array];
        for (NSUInteger index = 0; index < self.gameSlots.count; index++) {
            UIButton *button = [self slotOptionAtIndex:index];
            [buttons addObject:button];
            needsContentRefresh |= [[self slotUnavailableReason:self.gameSlots[index]]
                isEqualToString:TSLocalizedString(@"game_push.ui.slot_content_unknown")];
            [self.sheetStack addArrangedSubview:button];
            [self.sheetStack setCustomSpacing:8 afterView:button];
        }
        self.slotButtons = buttons;
    }
    self.formErrorLabel = [self label:@"" size:12 weight:UIFontWeightRegular color:TSColor_Warning];
    [self.sheetStack addArrangedSubview:self.formErrorLabel];
    self.submitButton = [self button:TSLocalizedString(@"game_push.ui.start_push") primary:YES action:@selector(startPush)];
    [self.sheetStack addArrangedSubview:self.submitButton];
    if (needsContentRefresh) {
        [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.check_games")
            primary:NO action:@selector(recoverTapped)]];
    }
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.change_file")
        primary:NO action:@selector(chooseFile)]];
    [self updateConfiguration];
}

// 将槽位、状态和容量按原型排为带单选圆点的一行。
- (UIButton *)slotOptionAtIndex:(NSUInteger)index {
    TSGameSlotModel *slot = self.gameSlots[index];
    NSString *reason = [self slotUnavailableReason:slot];
    NSString *state = reason ?: (slot.isEmpty ? TSLocalizedString(@"game_push.ui.empty_slot") :
        [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.replace_game"), [self gameName:slot.gameType]]);
    UIButton *button = [self button:@"" primary:NO action:@selector(selectSlot:)];
    button.tag = index;
    button.enabled = reason == nil;
    button.alpha = reason ? 0.55 : 1;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setImage:[self selectionImage:NO] forState:UIControlStateNormal];
    [button setImage:[self selectionImage:YES] forState:UIControlStateSelected];
    UIStackView *copy = [self verticalStack:3];
    [copy addArrangedSubview:[self label:[self slotName:slot] size:13 weight:UIFontWeightMedium color:TSColor_TextPrimary]];
    [copy addArrangedSubview:[self label:state size:11
        weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    NSString *capacity = slot.capacityBytes ? [self formattedBytes:slot.capacityBytes] : @"—";
    UILabel *size = [self label:capacity size:12 weight:UIFontWeightRegular color:TSColor_TextSecondary];
    [size setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[copy, size]];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.userInteractionEnabled = NO;
    row.spacing = 10;
    row.alignment = UIStackViewAlignmentCenter;
    [button addSubview:row];
    [NSLayoutConstraint activateConstraints:@[[row.topAnchor constraintEqualToAnchor:button.topAnchor constant:11],
        [row.bottomAnchor constraintEqualToAnchor:button.bottomAnchor constant:-11],
        [row.leadingAnchor constraintEqualToAnchor:button.leadingAnchor constant:40],
        [row.trailingAnchor constraintEqualToAnchor:button.trailingAnchor constant:-11]]];
    button.accessibilityLabel = [NSString stringWithFormat:@"%@, %@, %@", [self slotName:slot],
        state, capacity];
    return button;
}

// 绘制原生单选圆点，兼容没有系统符号库的 iOS 版本。
- (UIImage *)selectionImage:(BOOL)selected {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(19, 19), NO, 0);
    [(selected ? TSColor_Primary : TSColor_Separator) setStroke];
    UIBezierPath *outline = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, 17, 17)];
    outline.lineWidth = 1.5;
    [outline stroke];
    if (selected) {
        [TSColor_Primary setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(5, 5, 9, 9)] fill];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

// 显示设备返回的真实位置编号，不假定固件编号起点。
- (NSString *)slotName:(TSGameSlotModel *)slot {
    if (slot.slotIndex == NSNotFound || slot.slotIndex < 0) {
        return TSLocalizedString(@"game_push.ui.unknown_position");
    }
    return [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.position_number"), (long)slot.slotIndex];
}

// 空槽只校验容量；占用槽必须确认所有匹配的原游戏均非内置。
- (NSString *)slotUnavailableReason:(TSGameSlotModel *)slot {
    if (slot.slotIndex == NSNotFound || slot.slotIndex < 0) {
        return TSLocalizedString(@"game_push.ui.index_unknown");
    }
    if (!slot.capacityBytes) {
        return TSLocalizedString(@"game_push.ui.capacity_unknown");
    }
    if (self.fileSize > slot.capacityBytes) {
        return TSLocalizedString(@"game_push.ui.insufficient_space");
    }
    if (!slot.isEmpty) {
        if (!self.installedGames || self.queryErrors[@"games"] || [self.pendingQueries containsObject:@"games"]) {
            return TSLocalizedString(@"game_push.ui.slot_content_unknown");
        }
        BOOL matched = NO;
        for (TSGameModel *game in self.installedGames) {
            if (game.gameType == slot.gameType && game.skinNumber == slot.skinNumber) {
                if (game.isBuiltIn) {
                    return TSLocalizedString(@"game_push.ui.builtin_protected");
                }
                matched = YES;
            }
        }
        if (!matched) {
            return TSLocalizedString(@"game_push.ui.slot_content_unknown");
        }
    }
    return nil;
}

// 返回首个阻止提交的问题，只要求当前目标所需的查询成功。
- (NSString *)configurationIssue {
    if (![self canPrepareInstallation]) {
        return [self pageNotice] ?: TSLocalizedString(@"game_push.ui.not_ready");
    }
    if (!self.localFilePath.length || !self.fileSize) {
        return TSLocalizedString(@"game_push.ui.invalid_file");
    }
    if ([self gameInterface].isSupportGameSlots) {
        for (TSGameSlotModel *slot in self.gameSlots) {
            if (self.selectedSlotIndex && slot.slotIndex == self.selectedSlotIndex.integerValue) {
                return [self slotUnavailableReason:slot];
            }
        }
        return TSLocalizedString(@"game_push.ui.choose_slot");
    }
    if (!self.gameStorage || self.fileSize > self.gameStorage.available) {
        return TSLocalizedString(@"game_push.ui.insufficient_space");
    }
    return nil;
}

// 位置变化同步单选状态、提示及提交按钮。
- (void)updateConfiguration {
    NSString *issue = [self configurationIssue];
    BOOL missingSelection = [issue isEqualToString:TSLocalizedString(@"game_push.ui.choose_slot")];
    self.formErrorLabel.text = missingSelection ? nil : issue;
    self.formErrorLabel.hidden = self.formErrorLabel.text.length == 0;
    [self.submitButton setTitle:issue ?: TSLocalizedString(@"game_push.ui.start_push") forState:UIControlStateNormal];
    [self setPrimaryButton:self.submitButton enabled:issue == nil];
    for (UIButton *button in self.slotButtons) {
        if (button.tag < 0 || button.tag >= self.gameSlots.count) {
            continue;
        }
        TSGameSlotModel *slot = self.gameSlots[button.tag];
        BOOL selected = self.selectedSlotIndex && slot.slotIndex == self.selectedSlotIndex.integerValue;
        button.selected = selected;
        button.layer.borderWidth = selected ? 1.5 : 1;
        button.layer.borderColor = selected ? TSColor_Primary.CGColor : TSColor_Separator.CGColor;
        button.backgroundColor = selected ? [self softColor:0xF1F7FF dark:0x1D3049] : TSColor_Card;
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0) |
            (button.enabled ? 0 : UIAccessibilityTraitNotEnabled);
    }
    [self.view setNeedsLayout];
}

// 使用条目的真实槽位索引，绝不把数组位置或打包标识作为目标。
- (void)selectSlot:(UIButton *)sender {
    if (sender.tag < 0 || sender.tag >= self.gameSlots.count) {
        return;
    }
    TSGameSlotModel *slot = self.gameSlots[sender.tag];
    if ([self slotUnavailableReason:slot]) {
        return;
    }
    self.selectedSlotIndex = @(slot.slotIndex);
    [self updateConfiguration];
}

// 游戏详情只显示查询到的属性。
- (void)gameTapped:(UIButton *)sender {
    if (sender.tag < 0 || sender.tag >= self.installedGames.count || self.pushing) {
        return;
    }
    TSGameModel *game = self.installedGames[sender.tag];
    [self openSheet:[self gameName:game.gameType] kind:TSGameSheetKindInformation];
    UIView *cover = [self coverForGame:game];
    for (NSLayoutConstraint *constraint in cover.constraints) {
        if (constraint.firstItem == cover && constraint.firstAttribute == NSLayoutAttributeHeight && !constraint.secondItem) {
            constraint.constant = 140;
        }
    }
    [self.sheetStack addArrangedSubview:cover];
    [self.sheetStack setCustomSpacing:15 afterView:cover];
    UIStackView *details = [self verticalStack:0];
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.source")
        value:TSLocalizedString(game.isBuiltIn ? @"game_push.ui.builtin" : @"game_push.ui.phone_install")]];
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.skin_number")
        value:[NSString stringWithFormat:@"%d", game.skinNumber]]];
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.game_type")
        value:[NSString stringWithFormat:@"%ld", (long)game.gameType]]];
    [self.sheetStack addArrangedSubview:details];
    [self.sheetStack setCustomSpacing:12 afterView:details];
    [self.sheetStack addArrangedSubview:[self label:TSLocalizedString(@"game_push.ui.game_detail_hint") size:12
        weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.done") primary:YES action:@selector(closeSheet)]];
}

// 槽位信息按设备顺序展示，不进行容量分摊或占用量推算。
- (void)showStorage {
    if (self.pushing) {
        return;
    }
    [self openSheet:TSLocalizedString(@"game_push.ui.positions") kind:TSGameSheetKindInformation];
    UIStackView *rows = [self verticalStack:0];
    for (TSGameSlotModel *slot in self.gameSlots) {
        NSString *capacity = slot.capacityBytes ? [self formattedBytes:slot.capacityBytes] :
            TSLocalizedString(@"game_push.ui.capacity_unknown");
        NSString *state = slot.isEmpty ? TSLocalizedString(@"game_push.ui.empty_slot") : [self gameName:slot.gameType];
        [rows addArrangedSubview:[self informationRow:[self slotName:slot]
            value:[NSString stringWithFormat:@"%@ · %@", state, capacity]]];
    }
    if ([self gameInterface].isSupportGameSlots && !self.gameSlots.count) {
        [self.sheetStack addArrangedSubview:[self label:TSLocalizedString(self.gameSlots ?
            @"game_push.ui.no_slots" : @"game_push.ui.storage_unknown") size:14
            weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    }
    if (self.gameStorage && ![self gameInterface].isSupportGameSlots) {
        [rows addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.available")
            value:[self formattedBytes:self.gameStorage.available]]];
        [rows addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.total")
            value:self.gameStorage.total ? [self formattedBytes:self.gameStorage.total] : TSLocalizedString(@"game_push.ui.capacity_unknown")]];
    }
    [self.sheetStack addArrangedSubview:rows];
    [self.sheetStack setCustomSpacing:12 afterView:rows];
    UILabel *hintLabel = [self label:TSLocalizedString([self gameInterface].isSupportGameSlots ?
        @"game_push.ui.slot_capacity_hint" : @"game_push.ui.storage_hint") size:11
        weight:UIFontWeightRegular color:TSColor_TextSecondary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 18;
    hintLabel.attributedText = [[NSAttributedString alloc] initWithString:hintLabel.text
        attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    [self.sheetStack addArrangedSubview:hintLabel];
    [self.sheetStack setCustomSpacing:18 afterView:hintLabel];
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"general.got_it") primary:YES action:@selector(closeSheet)]];
}

// 将能力和原始参数放入详情，不干扰主操作路径。
- (void)showCapabilities {
    if (self.pushing) {
        return;
    }
    [self openSheet:TSLocalizedString(@"game_push.ui.device_details") kind:TSGameSheetKindInformation];
    TSPeripheral *peripheral = self.sessionSnapshot.peripheral;
    NSString *deviceName = peripheral.systemInfo.bleName;
    UIStackView *details = [self verticalStack:0];
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.device_name")
        value:deviceName.length ? deviceName : TSLocalizedString(@"game_push.ui.not_loaded")]];
    NSString *declaration = TSLocalizedString(@"game_push.ui.not_loaded");
    if (self.sessionSnapshot.isReady && peripheral.capability.featureAbility) {
        declaration = TSLocalizedString(peripheral.capability.featureAbility.isSupportGamePush ?
            @"general.supported" : @"general.not_supported");
    }
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.declared_capability")
        value:declaration]];
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.push_capability")
        value:TSLocalizedString([self canPrepareInstallation] ? @"game_push.ui.supported" : @"game_push.ui.unavailable")]];
    [details addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.fixed_slots")
        value:TSLocalizedString([self gameInterface].isSupportGameSlots ? @"game_push.ui.supported" : @"game_push.ui.unavailable")]];
    [self.sheetStack addArrangedSubview:details];
    [self.sheetStack setCustomSpacing:20 afterView:details];
    UILabel *heading = [self label:TSLocalizedString(@"game_push.ui.supported_types") size:13
        weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    [self.sheetStack addArrangedSubview:heading];
    [self.sheetStack setCustomSpacing:10 afterView:heading];
    if (self.supportedTypes.count) {
        [self.sheetStack addArrangedSubview:[self gameTypeChips]];
    } else {
        [self.sheetStack addArrangedSubview:[self label:TSLocalizedString(self.supportedTypes ?
            @"game_push.empty" : @"game_push.ui.not_loaded") size:12
            weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    }
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.done") primary:YES action:@selector(closeSheet)]];
}

// 按文字宽度分行展示类型标签，保留设备返回的原始编号。
- (UIView *)gameTypeChips {
    UIStackView *chips = [self verticalStack:7];
    CGFloat availableWidth = MAX(1, MIN(500, CGRectGetWidth(self.view.bounds)) - 42);
    CGFloat usedWidth = 0;
    UIStackView *row = nil;
    UIFont *font = [UIFont systemFontOfSize:12];
    for (NSNumber *type in self.supportedTypes) {
        NSString *text = [NSString stringWithFormat:@"%@ · %@", [self gameName:type.integerValue], type];
        CGFloat chipWidth = MIN(availableWidth, ceil([text sizeWithAttributes:@{NSFontAttributeName: font}].width) + 20);
        if (!row || usedWidth + 7 + chipWidth > availableWidth) {
            if (row) {
                [row addArrangedSubview:[[UIView alloc] init]];
            }
            row = [[UIStackView alloc] init];
            row.spacing = 7;
            row.alignment = UIStackViewAlignmentTop;
            [chips addArrangedSubview:row];
            usedWidth = 0;
        }
        UILabel *label = [self label:text size:12 weight:UIFontWeightRegular
            color:[self softColor:0x63758B dark:0xAFBED4]];
        UIView *chip = [[UIView alloc] init];
        chip.backgroundColor = [self softColor:0xF1F4F9 dark:0x273141];
        chip.layer.cornerRadius = 7;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [chip addSubview:label];
        [row addArrangedSubview:chip];
        [NSLayoutConstraint activateConstraints:@[
            [label.topAnchor constraintEqualToAnchor:chip.topAnchor constant:6],
            [label.bottomAnchor constraintEqualToAnchor:chip.bottomAnchor constant:-6],
            [label.leadingAnchor constraintEqualToAnchor:chip.leadingAnchor constant:10],
            [label.trailingAnchor constraintEqualToAnchor:chip.trailingAnchor constant:-10],
            [chip.widthAnchor constraintLessThanOrEqualToAnchor:chips.widthAnchor]
        ]];
        usedWidth += (usedWidth > 0 ? 7 : 0) + chipWidth;
    }
    [row addArrangedSubview:[[UIView alloc] init]];
    return chips;
}

// 圆环只展示实际进度，成功前不显示百分之百。
- (void)showProgress {
    [self openSheet:TSLocalizedString(@"game_push.ui.pushing") kind:TSGameSheetKindProgress];
    UIView *ringContainer = [[UIView alloc] init];
    [ringContainer.heightAnchor constraintEqualToConstant:158].active = YES;
    UIView *ring = [[UIView alloc] init];
    ring.translatesAutoresizingMaskIntoConstraints = NO;
    [ringContainer addSubview:ring];
    [NSLayoutConstraint activateConstraints:@[[ring.widthAnchor constraintEqualToConstant:142],
        [ring.heightAnchor constraintEqualToConstant:142], [ring.centerXAnchor constraintEqualToAnchor:ringContainer.centerXAnchor],
        [ring.centerYAnchor constraintEqualToAnchor:ringContainer.centerYAnchor]]];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(71, 71) radius:60
        startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    CAShapeLayer *track = [CAShapeLayer layer];
    track.path = path.CGPath;
    track.fillColor = UIColor.clearColor.CGColor;
    track.strokeColor = [self softColor:0xE8EFFA dark:0x26344A].CGColor;
    track.lineWidth = 6;
    [ring.layer addSublayer:track];
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.path = path.CGPath;
    self.progressLayer.fillColor = UIColor.clearColor.CGColor;
    self.progressLayer.strokeColor = TSColor_Primary.CGColor;
    self.progressLayer.lineWidth = 6;
    self.progressLayer.lineCap = kCALineCapRound;
    [ring.layer addSublayer:self.progressLayer];
    self.progressLabel = [self label:@"" size:31 weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [ring addSubview:self.progressLabel];
    [NSLayoutConstraint activateConstraints:@[[self.progressLabel.centerXAnchor constraintEqualToAnchor:ring.centerXAnchor],
        [self.progressLabel.centerYAnchor constraintEqualToAnchor:ring.centerYAnchor]]];
    [self.sheetStack addArrangedSubview:ringContainer];
    self.progressTitleLabel = [self label:@"" size:18 weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    self.progressTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.sheetStack addArrangedSubview:self.progressTitleLabel];
    UILabel *hint = [self label:TSLocalizedString(@"game_push.ui.keep_connected") size:13
        weight:UIFontWeightRegular color:TSColor_TextSecondary];
    hint.textAlignment = NSTextAlignmentCenter;
    [self.sheetStack addArrangedSubview:hint];
    UIStackView *context = [self verticalStack:0];
    [context addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.package_file")
        value:self.activeRequest.localFilePath.lastPathComponent]];
    if (self.activeRequest.targetSlotIndex) {
        [context addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.positions")
            value:[NSString stringWithFormat:TSLocalizedString(@"game_push.ui.position_number"),
                (long)self.activeRequest.targetSlotIndex.integerValue]]];
    }
    [self.sheetStack addArrangedSubview:context];
    self.cancelButton = [self button:@"" primary:NO action:@selector(askCancel)];
    [self.sheetStack addArrangedSubview:self.cancelButton];
    [self updateProgress];
}

// 取消被 SDK 拒绝时继续等待原任务，不推断传输阶段。
- (void)updateProgress {
    self.progressLayer.strokeEnd = self.transferProgress / 100.0;
    NSString *percentage = [NSString stringWithFormat:@"%ld%%", (long)self.transferProgress];
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:percentage];
    [formatted addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15]
        range:NSMakeRange(percentage.length - 1, 1)];
    self.progressLabel.attributedText = formatted;
    self.progressTitleLabel.text = TSLocalizedString(self.cancelRequested ? @"game_push.ui.cancelling" : @"game_push.ui.transferring");
    [self.cancelButton setTitle:TSLocalizedString(self.cancelRejected ? @"game_push.ui.cancel_denied" :
        @"game_push.ui.cancel_push") forState:UIControlStateNormal];
    self.cancelButton.enabled = !self.cancelRequested && !self.cancelRejected;
}

#pragma mark - 私有方法：设备数据

// 集中获取统一连接快照，便于验证会话隔离。
- (TSDeviceConnectionSnapshot *)currentSnapshot {
    return TSDeviceCoordinator.sharedInstance.snapshot;
}

// 仅通过 ComKit 门面获取公版接口。
- (id<TSGamePushInterface>)gameInterface {
    return TopStepComKit.sharedInstance.gamePush;
}

// 设备相同还需 Provider 一致，不能只比较显示名称。
- (BOOL)sameDevice:(TSDeviceConnectionSnapshot *)first other:(TSDeviceConnectionSnapshot *)second {
    return first && second && first.activeSDKType == second.activeSDKType && first.peripheral && second.peripheral &&
        [TSPeripheral isEqualPeripheral:first.peripheral another:second.peripheral];
}

// 查询和交互必须属于同一次已就绪连接。
- (BOOL)sameSession:(TSDeviceConnectionSnapshot *)first other:(TSDeviceConnectionSnapshot *)second {
    return first.isReady && second.isReady && first.connectionGeneration == second.connectionGeneration &&
        [self sameDevice:first other:second];
}

// 连接变化立即失效旧查询和槽位选择，取消门禁只能由真实新会话解除。
- (BOOL)synchronizeSession {
    TSDeviceConnectionSnapshot *latest = [self currentSnapshot];
    BOOL changed = ![self sameSession:self.sessionSnapshot other:latest] || self.queryInterface != [self gameInterface];
    if (latest.isReady) {
        if (self.lastReadySnapshot && ![self sameDevice:self.lastReadySnapshot other:latest]) {
            self.reconnectRequired = NO;
            self.recentMessage = nil;
        }
        if (self.reconnectRequired && [self sameDevice:self.lastReadySnapshot other:latest] &&
            latest.connectionGeneration != self.cancelledGeneration) {
            self.reconnectRequired = NO;
        }
        self.lastReadySnapshot = latest;
        self.installationUncertain = NO;
        for (TSDeviceConnectionSnapshot *snapshot in self.uncertainSnapshots) {
            if ([self sameDevice:snapshot other:latest]) {
                self.installationUncertain = YES;
                break;
            }
        }
    }
    self.sessionSnapshot = latest;
    if (changed) {
        self.refreshGeneration++;
        [self.pendingQueries removeAllObjects];
        [self.queryErrors removeAllObjects];
        self.installedGames = nil;
        self.gameSlots = nil;
        self.supportedTypes = nil;
        self.gameStorage = nil;
        self.selectedSlotIndex = nil;
        self.queryInterface = [self gameInterface];
        [self.refreshControl endRefreshing];
        if (!self.pushing && self.sheetKind != TSGameSheetKindNone) {
            [self closeSheet];
        }
        TSLog(@"[GamePush][TSGamePushVC] session changed ready=%d generation=%lu", latest.isReady,
            (unsigned long)latest.connectionGeneration);
        [self renderPage];
    }
    return changed;
}

// 本地文件导入不依赖设备查询结果，仍保持当前会话和活动操作隔离。
- (BOOL)canImportGamePackage {
    return !self.pushing && !self.importing && !self.reconnecting &&
        [self sameSession:self.sessionSnapshot other:[self currentSnapshot]] &&
        self.queryInterface == [self gameInterface] && [self gameInterface].isSupport;
}

// 槽位配置只依赖实时槽位，展示查询失败不阻塞空槽推送。
- (BOOL)canPrepareInstallation {
    if (![self canImportGamePackage] || self.installationUncertain || self.reconnectRequired) {
        return NO;
    }
    if ([self gameInterface].isSupportGameSlots) {
        return self.gameSlots != nil && !self.queryErrors[@"slots"] && ![self.pendingQueries containsObject:@"slots"];
    }
    return self.gameStorage != nil && !self.queryErrors[@"storage"] && ![self.pendingQueries containsObject:@"storage"];
}

// 每次刷新建立独立批次，所有异步回调需同时匹配设备、会话和接口。
- (void)reloadGameData {
    [self synchronizeSession];
    id<TSGamePushInterface> interface = [self gameInterface];
    if (self.pushing || self.importing || self.pendingQueries.count || !self.sessionSnapshot.isReady || !interface.isSupport) {
        [self.refreshControl endRefreshing];
        [self renderPage];
        return;
    }
    self.queryInterface = interface;
    NSUInteger generation = ++self.refreshGeneration;
    TSDeviceConnectionSnapshot *snapshot = self.sessionSnapshot;
    self.selectedSlotIndex = nil;
    self.installedGames = nil;
    self.gameSlots = nil;
    self.supportedTypes = nil;
    self.gameStorage = nil;
    [self.queryErrors removeAllObjects];
    [self.pendingQueries addObjectsFromArray:@[@"games", @"types", @"storage"]];
    if (interface.isSupportGameSlots) {
        [self.pendingQueries addObject:@"slots"];
    }
    [self renderPage];
    TSLog(@"[GamePush][TSGamePushVC] query begin batch=%lu slots=%d", (unsigned long)generation, interface.isSupportGameSlots);
    __weak typeof(self) weakSelf = self;
    void (^receive)(NSString *, id, NSError *) = ^(NSString *key, id value, NSError *error) {
        TSGamePerformOnMain(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.refreshGeneration || strongSelf.queryInterface != interface ||
                interface != [strongSelf gameInterface] || ![strongSelf sameSession:snapshot other:[strongSelf currentSnapshot]] ||
                ![strongSelf.pendingQueries containsObject:key]) {
                return;
            }
            [strongSelf receiveQuery:key value:value error:error];
        });
    };
    [interface fetchInstalledGames:^(NSArray<TSGameModel *> *games, NSError *error) { receive(@"games", games, error); }];
    [interface fetchSupportedGameTypes:^(NSArray<NSNumber *> *types, NSError *error) { receive(@"types", types, error); }];
    [interface fetchGameStorage:^(TSStorageSpace *storage, NSError *error) { receive(@"storage", storage, error); }];
    if (interface.isSupportGameSlots) {
        [interface fetchGameSlots:^(NSArray<TSGameSlotModel *> *slots, NSError *error) { receive(@"slots", slots, error); }];
    }
}

// 独立处理各查询，失败时不伪造空模型。
- (void)receiveQuery:(NSString *)key value:(id)value error:(NSError *)error {
    [self.pendingQueries removeObject:key];
    if (error || !value) {
        self.queryErrors[key] = error ?: TSERROR_USERINFO(kTSErrorDomainGamePushName, eTSErrorDataFormatError,
            (@{NSLocalizedDescriptionKey: TSLocalizedString(@"game_push.ui.partial_failure")}));
        TSLog(@"[GamePush][TSGamePushVC] query failed kind=%@ domain=%@ code=%ld", key,
            self.queryErrors[key].domain, (long)self.queryErrors[key].code);
    } else if ([key isEqualToString:@"games"]) {
        self.installedGames = value;
    } else if ([key isEqualToString:@"types"]) {
        self.supportedTypes = value;
    } else if ([key isEqualToString:@"slots"]) {
        self.gameSlots = value;
    } else if ([key isEqualToString:@"storage"]) {
        self.gameStorage = value;
    }
    if (!self.pendingQueries.count) {
        [self.refreshControl endRefreshing];
        TSLog(@"[GamePush][TSGamePushVC] query finished errors=%lu games=%lu slots=%lu", (unsigned long)self.queryErrors.count,
            (unsigned long)self.installedGames.count, (unsigned long)self.gameSlots.count);
    }
    [self renderPage];
    if (self.sheetKind == TSGameSheetKindConfiguration &&
        ([key isEqualToString:@"games"] || [key isEqualToString:@"slots"])) {
        [self configureInstallation];
    }
}

// 恢复操作只重读真实数据，取消后先断开再建立新连接。
- (void)recoverTapped {
    [self closeSheet];
    if (self.pushing || self.importing || self.reconnecting || self.sessionSnapshot.isTransitioning) {
        return;
    }
    if (self.sessionSnapshot.isReady && !self.reconnectRequired) {
        [self reloadGameData];
        return;
    }
    self.reconnecting = YES;
    NSUUID *token = NSUUID.UUID;
    self.recoveryToken = token;
    TSDeviceConnectionSnapshot *snapshot = self.sessionSnapshot;
    [self renderPage];
    TSLog(@"[GamePush][TSGamePushVC] reconnect begin");
    __weak typeof(self) weakSelf = self;
    void (^reconnect)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (![strongSelf recoveryIsCurrent:token snapshot:snapshot]) {
            [strongSelf discardRecovery:token];
            return;
        }
        [TSDeviceCoordinator.sharedInstance reconnectWithCompletion:^(BOOL success, NSError *error) {
            TSGamePerformOnMain(^{
                if (![weakSelf recoveryIsCurrent:token snapshot:snapshot]) {
                    [weakSelf discardRecovery:token];
                    return;
                }
                weakSelf.reconnecting = NO;
                weakSelf.recoveryToken = nil;
                [weakSelf synchronizeSession];
                [weakSelf reloadGameData];
                if (!success || error) {
                    [weakSelf ts_showToast:TSLocalizedString(@"game_push.ui.reconnect_failed")];
                }
                TSLog(@"[GamePush][TSGamePushVC] reconnect completed success=%d code=%ld", success, (long)error.code);
            });
        }];
    };
    if (self.sessionSnapshot.isReady) {
        [TSDeviceCoordinator.sharedInstance disconnectWithCompletion:^(BOOL success, NSError *error) {
            TSGamePerformOnMain(^{
                if (success && !error) {
                    reconnect();
                } else if ([weakSelf.recoveryToken isEqual:token]) {
                    [weakSelf discardRecovery:token];
                    [weakSelf ts_showToast:TSLocalizedString(@"game_push.ui.reconnect_failed")];
                }
            });
        }];
    } else {
        reconnect();
    }
}

// 恢复步骤不得跨页面、SDK 或绑定设备继续执行。
- (BOOL)recoveryIsCurrent:(NSUUID *)token snapshot:(TSDeviceConnectionSnapshot *)snapshot {
    TSDeviceConnectionSnapshot *latest = [self currentSnapshot];
    if (![self.recoveryToken isEqual:token] || latest.activeSDKType != snapshot.activeSDKType || !latest.hasBinding) {
        return NO;
    }
    return !snapshot.peripheral || !latest.peripheral || [self sameDevice:snapshot other:latest];
}

// 只清理属于当前恢复请求的忙碌状态。
- (void)discardRecovery:(NSUUID *)token {
    if ([self.recoveryToken isEqual:token]) {
        self.recoveryToken = nil;
        self.reconnecting = NO;
        [self synchronizeSession];
        [self renderPage];
    }
}

#pragma mark - 私有方法：文件导入与推送

// 文件和设备信息均就绪时继续配置，否则允许先导入或更换本地文件。
- (void)importTapped {
    [self synchronizeSession];
    if (![self canImportGamePackage]) {
        return;
    }
    if (self.localFilePath.length && [self canPrepareInstallation]) {
        [self configureInstallation];
    } else {
        [self chooseFile];
    }
}

// 不猜测游戏包扩展名，具体包格式交由 SDK 校验。
- (void)chooseFile {
    if (![self canImportGamePackage] || self.presentedViewController) {
        return;
    }
    [self closeSheet];
    self.documentPickerSnapshot = self.sessionSnapshot;
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

// 文件协调读取和副本创建放入后台，新副本成功前保留旧文件。
- (void)importFileURL:(NSURL *)url {
    if (![self canImportGamePackage] || !url.isFileURL) {
        return;
    }
    self.importing = YES;
    NSUUID *token = NSUUID.UUID;
    self.importToken = token;
    TSDeviceConnectionSnapshot *snapshot = self.sessionSnapshot;
    [self renderPage];
    TSLog(@"[GamePush][TSGamePushVC] file import begin");
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        BOOL accessed = [url startAccessingSecurityScopedResource];
        NSString *directory = [NSTemporaryDirectory() stringByAppendingPathComponent:
            [@"TSGamePush-" stringByAppendingString:token.UUIDString]];
        __block NSString *path = nil;
        __block unsigned long long size = 0;
        __block NSError *copyError = nil;
        NSError *coordinationError = nil;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateReadingItemAtURL:url options:0 error:&coordinationError byAccessor:^(NSURL *readURL) {
            NSNumber *regular = nil;
            if (![readURL getResourceValue:&regular forKey:NSURLIsRegularFileKey error:&copyError] || !regular.boolValue) {
                return;
            }
            if (![NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:YES
                attributes:nil error:&copyError]) {
                return;
            }
            path = [directory stringByAppendingPathComponent:readURL.lastPathComponent];
            if (![NSFileManager.defaultManager copyItemAtURL:readURL toURL:[NSURL fileURLWithPath:path] error:&copyError]) {
                return;
            }
            NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&copyError];
            size = [attributes fileSize];
        }];
        if (accessed) {
            [url stopAccessingSecurityScopedResource];
        }
        BOOL valid = !copyError && !coordinationError && path.length && size > 0;
        TSGamePerformOnMain(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BOOL current = strongSelf && [strongSelf.importToken isEqual:token];
            if (!current || !valid || ![strongSelf sameSession:snapshot other:[strongSelf currentSnapshot]]) {
                [NSFileManager.defaultManager removeItemAtPath:directory error:nil];
                if (current) {
                    strongSelf.importing = NO;
                    strongSelf.importToken = nil;
                    [strongSelf synchronizeSession];
                    [strongSelf renderPage];
                    [strongSelf ts_showToast:TSLocalizedString(valid ? @"game_push.ui.device_changed" : @"game_push.ui.invalid_file")];
                }
                TSLog(@"[GamePush][TSGamePushVC] file import discarded valid=%d code=%ld", valid,
                    (long)(copyError ?: coordinationError).code);
                return;
            }
            NSString *previousDirectory = strongSelf.importDirectory;
            strongSelf.importDirectory = directory;
            strongSelf.localFilePath = path;
            strongSelf.fileSize = size;
            strongSelf.selectedSlotIndex = nil;
            strongSelf.importing = NO;
            strongSelf.importToken = nil;
            if (previousDirectory.length) {
                [NSFileManager.defaultManager removeItemAtPath:previousDirectory error:nil];
            }
            BOOL canPrepare = [strongSelf canPrepareInstallation];
            TSLog(@"[GamePush][TSGamePushVC] file import completed bytes=%llu canPrepare=%d", size, canPrepare);
            [strongSelf renderPage];
            if (canPrepare) {
                [strongSelf configureInstallation];
            } else {
                [strongSelf ts_showToast:TSLocalizedString(@"game_push.ui.imported_waiting")];
            }
        });
    });
}

// 根据实际索引查找已选择的位置，不使用数组下标作为推送目标。
- (TSGameSlotModel *)selectedSlot {
    for (TSGameSlotModel *slot in self.gameSlots) {
        if (self.selectedSlotIndex && slot.slotIndex == self.selectedSlotIndex.integerValue) {
            return slot;
        }
    }
    return nil;
}

// 空槽直接提交，占用槽先展示一次替换确认。
- (void)startPush {
    [self synchronizeSession];
    NSString *issue = [self configurationIssue];
    if (issue) {
        [self ts_showToast:issue];
        [self updateConfiguration];
        return;
    }
    TSGameSlotModel *slot = [self selectedSlot];
    if (!slot || slot.isEmpty) {
        [self submitPush];
        return;
    }
    self.replacementRequest = [[TSGamePushRequest alloc] init];
    self.replacementRequest.localFilePath = self.localFilePath;
    self.replacementRequest.targetSlotIndex = self.selectedSlotIndex;
    self.replacementSnapshot = self.sessionSnapshot;
    self.replacementIdentifier = slot.rawIdentifier;
    [self openSheet:TSLocalizedString(@"game_push.ui.replace_title") kind:TSGameSheetKindReplacement];
    [self.sheetStack addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.package_file")
        value:self.localFilePath.lastPathComponent]];
    [self.sheetStack addArrangedSubview:[self informationRow:TSLocalizedString(@"game_push.ui.positions")
        value:[self slotName:slot]]];
    [self.sheetStack addArrangedSubview:[self label:[NSString stringWithFormat:
        TSLocalizedString(@"game_push.ui.replace_detail"), [self gameName:slot.gameType]]
        size:14 weight:UIFontWeightRegular color:TSColor_Warning]];
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.confirm_replace")
        primary:YES action:@selector(confirmReplacement)]];
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.choose_another_position")
        primary:NO action:@selector(configureInstallation)]];
}

// 确认内容必须仍属于同一包、位置、旧内容及连接，变化后重新选择。
- (void)confirmReplacement {
    if (self.sheetKind != TSGameSheetKindReplacement || !self.replacementRequest) {
        return;
    }
    TSGamePushRequest *request = self.replacementRequest;
    TSDeviceConnectionSnapshot *snapshot = self.replacementSnapshot;
    uint64_t identifier = self.replacementIdentifier;
    [self synchronizeSession];
    TSGameSlotModel *slot = [self selectedSlot];
    BOOL unchanged = self.sheetKind == TSGameSheetKindReplacement &&
        [self sameSession:snapshot other:[self currentSnapshot]] &&
        [request.localFilePath isEqualToString:self.localFilePath] &&
        [request.targetSlotIndex isEqual:self.selectedSlotIndex] && slot && !slot.isEmpty &&
        slot.rawIdentifier == identifier;
    if (!unchanged || [self configurationIssue]) {
        [self configureInstallation];
        [self ts_showToast:TSLocalizedString(@"game_push.ui.selection_changed")];
        return;
    }
    [self submitPush];
}

// 真正提交前再次校验输入及原连接，仅把路径和目标槽位交给 SDK。
- (void)submitPush {
    [self synchronizeSession];
    NSString *issue = [self configurationIssue];
    if (issue) {
        [self ts_showToast:issue];
        [self updateConfiguration];
        return;
    }
    TSGamePushRequest *request = [[TSGamePushRequest alloc] init];
    request.localFilePath = self.localFilePath;
    request.targetSlotIndex = [self gameInterface].isSupportGameSlots ? self.selectedSlotIndex : nil;
    NSError *validationError = [request doesModelHasError];
    if (validationError) {
        [self ts_showToast:validationError.localizedDescription];
        return;
    }
    self.activeRequest = request;
    self.replacementRequest = nil;
    self.replacementSnapshot = nil;
    self.activeInterface = [self gameInterface];
    self.activeSnapshot = self.sessionSnapshot;
    self.operationToken = NSUUID.UUID;
    self.pushing = YES;
    // 失效推送前尚未完成的展示查询，成功后必须发起新的列表刷新。
    self.refreshGeneration++;
    [self.pendingQueries removeAllObjects];
    [self.refreshControl endRefreshing];
    self.cancelRequested = NO;
    self.cancelRejected = NO;
    self.transferProgress = 0;
    self.recentMessage = nil;
    NSUUID *token = self.operationToken;
    NSString *directory = self.importDirectory;
    [self renderPage];
    [self showProgress];
    TSLog(@"[GamePush][TSGamePushVC] push begin slot=%@ bytes=%llu", request.targetSlotIndex, self.fileSize);
    __weak typeof(self) weakSelf = self;
    [self.activeInterface pushGame:request progress:^(TSFileTransferStatus status, NSInteger progress) {
        TSGamePerformOnMain(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf.pushing || ![strongSelf.operationToken isEqual:token] ||
                strongSelf.activeInterface != [strongSelf gameInterface] ||
                ![strongSelf sameSession:strongSelf.activeSnapshot other:[strongSelf currentSnapshot]]) {
                return;
            }
            if (status != eTSFileTransferStatusStart && status != eTSFileTransferStatusProgress) {
                return;
            }
            strongSelf.transferProgress = MAX(strongSelf.transferProgress, MIN(99, MAX(0, progress)));
            [strongSelf updateProgress];
        });
    } completion:^(BOOL success, NSError *error) {
        TSGamePerformOnMain(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                if (directory.length) {
                    [NSFileManager.defaultManager removeItemAtPath:directory error:nil];
                }
                return;
            }
            if (!strongSelf.pushing || ![strongSelf.operationToken isEqual:token]) {
                return;
            }
            [strongSelf finishPush:success error:error];
        });
    }];
}

// 取消确认与原始任务独立，只有原始任务回调能结束忙碌状态。
- (void)askCancel {
    if (!self.pushing || self.cancelRequested || self.cancelRejected) {
        return;
    }
    [self openSheet:TSLocalizedString(@"game_push.ui.cancel_question") kind:TSGameSheetKindCancel];
    [self.sheetStack addArrangedSubview:[self label:TSLocalizedString(@"game_push.ui.cancel_detail") size:14
        weight:UIFontWeightRegular color:TSColor_TextSecondary]];
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.keep_pushing") primary:YES action:@selector(showProgress)]];
    UIButton *confirm = [self button:TSLocalizedString(@"game_push.ui.confirm_cancel") primary:NO action:@selector(confirmCancel)];
    [confirm setTitleColor:TSColor_Danger forState:UIControlStateNormal];
    confirm.backgroundColor = [self softColor:0xFFF0EF dark:0x3C2324];
    [self.sheetStack addArrangedSubview:confirm];
}

// 取消始终发送给原接口，迟到的取消结果不得影响后续任务。
- (void)confirmCancel {
    if (!self.pushing || self.cancelRequested || self.cancelRejected) {
        return;
    }
    self.cancelRequested = YES;
    NSUUID *token = self.operationToken;
    [self showProgress];
    TSLog(@"[GamePush][TSGamePushVC] cancellation requested");
    __weak typeof(self) weakSelf = self;
    [self.activeInterface cancelGamePush:^(BOOL success, NSError *error) {
        TSGamePerformOnMain(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf.pushing || ![strongSelf.operationToken isEqual:token]) {
                return;
            }
            TSLog(@"[GamePush][TSGamePushVC] cancellation response success=%d domain=%@ code=%ld", success,
                error.domain, (long)error.code);
            if (success && !error) {
                return;
            }
            strongSelf.cancelRequested = NO;
            strongSelf.cancelRejected = [error.domain isEqualToString:kTSErrorDomainGamePushName] &&
                error.code == eTSErrorPreTaskExecuting;
            [strongSelf updateProgress];
            [strongSelf ts_showToast:TSLocalizedString(strongSelf.cancelRejected ?
                @"game_push.ui.cancel_denied_detail" : @"game_push.ui.cancel_failed")];
        });
    }];
}

// 原始回调是唯一推送终态来源，列表刷新独立进行。
- (void)finishPush:(BOOL)success error:(NSError *)error {
    [self synchronizeSession];
    BOOL confirmed = success && !error;
    BOOL uncertain = [error.userInfo[@"installationResultUncertain"] boolValue];
    BOOL cancelled = [error.domain isEqualToString:kTSErrorDomainGamePushName] && error.code == eTSErrorUserCancelled;
    TSDeviceConnectionSnapshot *latest = [self currentSnapshot];
    TSDeviceConnectionSnapshot *deviceSnapshot = latest.peripheral ? latest : self.lastReadySnapshot;
    BOOL sameDevice = latest.activeSDKType == self.activeSnapshot.activeSDKType &&
        [self sameDevice:self.activeSnapshot other:deviceSnapshot];
    BOOL sameSession = sameDevice && self.activeInterface == [self gameInterface] &&
        [self sameSession:self.activeSnapshot other:latest];
    BOOL completedBeforeDisconnect = confirmed && sameDevice && !latest.isReady &&
        self.activeInterface == [self gameInterface];
    if (uncertain) {
        [self.uncertainSnapshots addObject:self.activeSnapshot];
    }
    NSString *fileName = self.activeRequest.localFilePath.lastPathComponent;
    NSString *position = self.activeRequest.targetSlotIndex ?
        [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.position_number"),
            (long)self.activeRequest.targetSlotIndex.integerValue] : TSLocalizedString(@"game_push.ui.automatic_position");
    NSUInteger originalGeneration = self.activeSnapshot.connectionGeneration;
    self.pushing = NO;
    self.cancelRequested = NO;
    self.operationToken = nil;
    self.activeInterface = nil;
    self.activeRequest = nil;
    self.activeSnapshot = nil;
    TSLog(@"[GamePush][TSGamePushVC] push terminal success=%d uncertain=%d cancelled=%d sameSession=%d domain=%@ code=%ld",
        confirmed, uncertain, cancelled, sameSession, error.domain, (long)error.code);
    if (sameDevice) {
        self.installationUncertain = uncertain;
        if (cancelled && !uncertain) {
            self.cancelledGeneration = originalGeneration;
            self.reconnectRequired = !self.sessionSnapshot.isReady || self.sessionSnapshot.connectionGeneration == originalGeneration;
        }
    }
    [self closeSheet];
    if (confirmed) {
        NSString *directory = self.importDirectory;
        self.importDirectory = nil;
        self.localFilePath = @"";
        self.fileSize = 0;
        self.selectedSlotIndex = nil;
        if (directory.length) {
            [NSFileManager.defaultManager removeItemAtPath:directory error:nil];
        }
    }
    if (!sameSession && !completedBeforeDisconnect) {
        [self reloadGameData];
        [self ts_showToast:TSLocalizedString(@"game_push.ui.device_changed")];
        return;
    }
    self.recentWarning = !confirmed;
    if (confirmed) {
        self.transferProgress = 100;
        self.recentMessage = [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.transfer_summary"), fileName, position];
        [self showResult:@"game_push.ui.success_title" heading:@"game_push.ui.success_title" detail:@"game_push.ui.success_detail"
            icon:@"check" warning:NO actionTitle:@"game_push.ui.view_games" action:@selector(closeSheet)];
    } else if (uncertain) {
        self.recentMessage = TSLocalizedString(@"game_push.ui.uncertain_detail");
        [self showResult:@"game_push.ui.uncertain_title" heading:@"game_push.ui.uncertain_heading" detail:@"game_push.ui.uncertain_detail"
            icon:@"search" warning:YES actionTitle:@"game_push.ui.check_games" action:@selector(recoverTapped)];
    } else if (cancelled) {
        NSString *detail = self.reconnectRequired ? @"game_push.ui.reconnect_detail" : @"game_push.ui.cancelled_detail";
        self.recentMessage = TSLocalizedString(detail);
        [self showResult:@"game_push.ui.cancelled_title" heading:@"game_push.ui.cancelled_heading" detail:detail
            icon:@"info" warning:YES actionTitle:self.reconnectRequired ? @"game_push.ui.reconnect" : @"game_push.ui.done"
            action:self.reconnectRequired ? @selector(recoverTapped) : @selector(closeSheet)];
    } else {
        self.recentMessage = TSLocalizedString(@"game_push.ui.failed_detail");
        [self showResult:@"game_push.ui.failed_title" heading:@"game_push.ui.failed_heading" detail:@"game_push.ui.failed_detail"
            icon:@"disconnect" warning:YES actionTitle:@"game_push.ui.retry_configuration" action:@selector(retryConfiguration)];
    }
    [self reloadGameData];
}

// 统一呈现完成、取消、失败和待确认结果。
- (void)showResult:(NSString *)title heading:(NSString *)heading detail:(NSString *)detail icon:(NSString *)icon
           warning:(BOOL)warning actionTitle:(NSString *)actionTitle action:(SEL)action {
    [self openSheet:TSLocalizedString(title) kind:TSGameSheetKindResult];
    UIView *container = [[UIView alloc] init];
    UIView *tile = [self iconTile:icon size:68];
    tile.translatesAutoresizingMaskIntoConstraints = NO;
    tile.layer.cornerRadius = 34;
    tile.backgroundColor = warning ? [self softColor:0xFFF2DF dark:0x35291D] : [self softColor:0xE9F7EE dark:0x193629];
    UIImageView *imageView = tile.subviews.firstObject;
    imageView.tintColor = warning ? TSColor_Warning : TSColor_Success;
    if ([icon isEqualToString:@"disconnect"]) {
        tile.backgroundColor = [self softColor:0xFFF0EF dark:0x3C2324];
        imageView.tintColor = TSColor_Danger;
    }
    [container addSubview:tile];
    [NSLayoutConstraint activateConstraints:@[[container.heightAnchor constraintEqualToConstant:80],
        [tile.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [tile.centerYAnchor constraintEqualToAnchor:container.centerYAnchor]]];
    [self.sheetStack addArrangedSubview:container];
    UILabel *headingLabel = [self label:TSLocalizedString(heading) size:20 weight:UIFontWeightSemibold color:TSColor_TextPrimary];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    [self.sheetStack addArrangedSubview:headingLabel];
    UILabel *detailLabel = [self label:TSLocalizedString(detail) size:13 weight:UIFontWeightRegular color:TSColor_TextSecondary];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    [self.sheetStack addArrangedSubview:detailLabel];
    [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(actionTitle) primary:YES action:action]];
    if (warning) {
        [self.sheetStack addArrangedSubview:[self button:TSLocalizedString(@"game_push.ui.later") primary:NO action:@selector(closeSheet)]];
    }
}

// 重试必须回到参数确认，不直接再次发送游戏包。
- (void)retryConfiguration {
    if ([self canPrepareInstallation]) {
        [self configureInstallation];
    } else {
        [self closeSheet];
        [self ts_showToast:[self pageNotice] ?: TSLocalizedString(@"game_push.ui.not_ready")];
    }
}

// 推送中返回转为取消确认，导入期间阻止页面离开。
- (void)backTapped {
    if (self.pushing) {
        [self askCancel];
    } else if (self.importing) {
        [self ts_showToast:TSLocalizedString(@"game_push.ui.importing")];
    } else if (self.sheetKind != TSGameSheetKindNone) {
        [self closeSheet];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 活动操作与弹层期间禁用侧滑，刷新不能与推送并行。
- (void)updateNavigationAvailability {
    if (self.capturedPopGestureState) {
        self.navigationController.interactivePopGestureRecognizer.enabled = !self.pushing && !self.importing &&
            self.sheetKind == TSGameSheetKindNone && self.previousPopGestureEnabled;
    }
    self.navigationItem.rightBarButtonItem.enabled = !self.pushing && !self.importing && !self.reconnecting &&
        !self.pendingQueries.count && self.sessionSnapshot.isReady && [self gameInterface].isSupport &&
        self.sheetKind == TSGameSheetKindNone;
}

#pragma mark - Delegate / 通知回调

// 文件选择取消不改变已有副本与参数。
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    self.documentPickerSnapshot = nil;
    TSLog(@"[GamePush][TSGamePushVC] document picker cancelled");
}

// 将系统文件地址交给后台协调导入。
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    BOOL current = [self sameSession:self.documentPickerSnapshot other:[self currentSnapshot]];
    self.documentPickerSnapshot = nil;
    [self synchronizeSession];
    if (!current) {
        [self ts_showToast:TSLocalizedString(@"game_push.ui.device_changed")];
    } else if (urls.count) {
        [self importFileURL:urls.firstObject];
    }
}

// 统一连接通知不接管 SDK 的全局连接监听。
- (void)connectionDidChange:(NSNotification *)notification {
    TSGamePerformOnMain(^{
        BOOL changed = [self synchronizeSession];
        if (changed && self.sessionSnapshot.isReady && !self.pushing && !self.importing) {
            [self reloadGameData];
        }
    });
}

// 回到前台同步状态，避免后台断连留下可提交表单。
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    BOOL changed = [self synchronizeSession];
    if (changed && self.sessionSnapshot.isReady && !self.pushing && !self.importing) {
        [self reloadGameData];
    }
}

// 解绑使尚未发起的恢复步骤失效。
- (void)bindingDidClear:(NSNotification *)notification {
    TSGamePerformOnMain(^{
        self.recoveryToken = nil;
        self.reconnecting = NO;
        [self synchronizeSession];
        [self renderPage];
    });
}

#pragma mark - 属性懒加载

// 页面支持下拉刷新及纵向滚动。
- (UIScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[UIScrollView alloc] init];
        _pageScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _pageScrollView.alwaysBounceVertical = YES;
        _pageScrollView.showsVerticalScrollIndicator = NO;
        _pageScrollView.refreshControl = self.refreshControl;
    }
    return _pageScrollView;
}

// 自动布局内容栈统一卡片间距。
- (UIStackView *)pageStack {
    if (!_pageStack) {
        _pageStack = [self verticalStack:16];
        _pageStack.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pageStack;
}

// 刷新动作复用同一查询流程。
- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(reloadGameData) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

@end
