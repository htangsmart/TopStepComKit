#import "TSDeviceRealtimeLogVC.h"

#import "TSDeviceCoordinator.h"
#import "TSDeviceLogAppearance.h"
#import "TSDeviceRealtimeLogRecorder.h"
#import "TSDeviceRealtimeLogStore.h"

static const TSPeripheralRealtimeLogTypes TSDeviceRealtimeLogTypeOptions[] = {
    TSPeripheralRealtimeLogTypeFullLog, TSPeripheralRealtimeLogTypeSleepRaw, TSPeripheralRealtimeLogTypeStepRaw,
    TSPeripheralRealtimeLogTypeHeartRateRaw, TSPeripheralRealtimeLogTypePowerStatistics,
    TSPeripheralRealtimeLogTypeAudioPCM, TSPeripheralRealtimeLogTypeDumpInfo,
};

static NSArray<NSString *> *TSDeviceRealtimeLogTypeTitles(void) {
    return @[
        TSLocalizedString(@"device_realtime_log.full"), TSLocalizedString(@"device_realtime_log.sleep"),
        TSLocalizedString(@"device_realtime_log.step"), TSLocalizedString(@"device_realtime_log.heart"),
        TSLocalizedString(@"device_realtime_log.power"), TSLocalizedString(@"device_realtime_log.pcm"),
        TSLocalizedString(@"device_realtime_log.dump"),
    ];
}

// 系统面板持有选择草稿。
@interface TSDeviceRealtimeLogTypesVC : TSBaseVC
- (instancetype)initWithSelectedTypes:(TSPeripheralRealtimeLogTypes)selectedTypes
                            recording:(BOOL)isRecording
                           completion:(void (^)(TSPeripheralRealtimeLogTypes types))completion;
@end

// 系统详情面板展示并导出已经关闭的本地日志文件。
@interface TSDeviceRealtimeLogFileVC : TSBaseVC
- (instancetype)initWithFile:(NSURL *)file values:(NSArray<NSString *> *)values;
@end

@interface TSDeviceRealtimeLogCaptureCard : UIStackView
@property (nonatomic, strong) CAGradientLayer *highlightLayer;
@end

@implementation TSDeviceRealtimeLogCaptureCard

// 使用原型的深绿渐变作为状态卡背景。
+ (Class)layerClass {
    return CAGradientLayer.class;
}

// 右上角高光跟随卡片宽高，包括大字号和横屏下的布局。
- (void)layoutSubviews {
    [super layoutSubviews];
    self.highlightLayer.frame = self.bounds;
}

@end

@interface TSDeviceRealtimeLogVC ()
@property (nonatomic, strong) id<TSPeripheralLogInterface> peripheralLog;
@property (nonatomic, strong) TSDeviceRealtimeLogRecorder *recorder;
@property (nonatomic, assign) TSPeripheralRealtimeLogCapability capability;
@property (nonatomic, strong, nullable) NSError *capabilityError;
@property (nonatomic, assign) BOOL queryingCapability;
@property (nonatomic, assign) NSUInteger capabilityRequest;
@property (nonatomic, assign) NSUInteger fileListRequest;
@property (nonatomic, copy) NSArray<NSURL *> *files;
@property (nonatomic, strong) UIStackView *deviceArea;
@property (nonatomic, strong) UIStackView *captureCard;
@property (nonatomic, strong) UIView *captureDot;
@property (nonatomic, strong) UILabel *captureStateLabel;
@property (nonatomic, strong) UILabel *captureNoteLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *bytesLabel;
@property (nonatomic, strong) UIStackView *signal;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *signalHeights;
@property (nonatomic, assign) BOOL signalShowsPackets;
@property (nonatomic, strong) UIStackView *typeSection;
@property (nonatomic, strong) UILabel *typeContext;
@property (nonatomic, strong) UIStackView *fileSection;
@property (nonatomic, strong) UILabel *fileCount;
@property (nonatomic, strong) UIStackView *noticeCard;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, weak) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIStackView *footer;
@property (nonatomic, strong) NSTimer *metricsTimer;
@end

@implementation TSDeviceRealtimeLogVC

#pragma mark - 生命周期

// 使用设备日志入口传入的同一 SDK 实例。
- (instancetype)initWithPeripheralLog:(id<TSPeripheralLogInterface>)peripheralLog {
    self = [super init];
    if (self) {
        _peripheralLog = peripheralLog;
    }
    return self;
}

// 观察连接和跨页面的抓取状态。
- (void)initData {
    [super initData];
    self.files = @[];
    self.recorder = [TSDeviceRealtimeLogRecorder sharedRecorder];
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(recorderDidChange:)
                   name:TSDeviceRealtimeLogRecorderDidChangeNotification object:self.recorder];
    [center addObserver:self selector:@selector(connectionDidChange:)
                   name:TSDeviceConnectionSnapshotDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(willEnterForeground:)
                   name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupViews {
    TSDeviceLogNavigation(self.navigationItem);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithImage:TSDeviceLogPageIcon(@"arrow.clockwise", 21)
        style:UIBarButtonItemStylePlain target:self action:@selector(refreshTapped)];
    self.navigationItem.rightBarButtonItem.tintColor = TSDeviceLogColor(0x096650);
    self.navigationItem.rightBarButtonItem.accessibilityLabel = TSLocalizedString(@"device_realtime_log.refresh");

    UILabel *title = TSDeviceLogLabel(32, UIFontWeightBold, TSDeviceLogColor(0x13261e));
    title.attributedText = [[NSAttributedString alloc] initWithString:TSLocalizedString(@"device_realtime_log.title")
                                                          attributes:@{NSKernAttributeName: @(-1.6)}];
    [title.heightAnchor constraintGreaterThanOrEqualToConstant:45].active = YES;
    title.accessibilityTraits |= UIAccessibilityTraitHeader;
    self.deviceArea = TSDeviceLogStack(@[], UILayoutConstraintAxisVertical, 0);
    [self setupCaptureCard];
    self.typeContext = TSDeviceLogLabel(11, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    self.typeSection = [self sectionWithTitle:TSLocalizedString(@"device_realtime_log.types") accessory:self.typeContext];
    self.fileCount = TSDeviceLogLabel(11, UIFontWeightRegular, TSDeviceLogColor(0x546760));
    self.fileSection = [self sectionWithTitle:TSLocalizedString(@"device_realtime_log.files") accessory:self.fileCount];
    self.noticeLabel = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(0x22543f));
    [self.noticeLabel.heightAnchor constraintGreaterThanOrEqualToConstant:18].active = YES;
    self.noticeCard = TSDeviceLogStack(@[self.noticeLabel], UILayoutConstraintAxisVertical, 0);
    self.noticeCard.layer.cornerRadius = 11;
    TSDeviceLogInset(self.noticeCard, UIEdgeInsetsMake(9, 11, 9, 11));

    self.primaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.primaryButton.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    [self.primaryButton addTarget:self action:@selector(primaryTapped) forControlEvents:UIControlEventTouchUpInside];
    self.footer = TSDeviceLogStack(@[self.primaryButton], UILayoutConstraintAxisVertical, 0);
    self.footer.backgroundColor = TSDeviceLogColor(0xf6f8f6);
    TSDeviceLogInset(self.footer, UIEdgeInsetsMake(12, 0, 0, 0));
    UIStackView *resultArea = TSDeviceLogStack(@[self.fileSection, self.noticeCard], UILayoutConstraintAxisVertical, 10);
    UIStackView *content = TSDeviceLogStack(@[title, self.deviceArea, self.captureCard, self.typeSection,
        resultArea, self.footer], UILayoutConstraintAxisVertical, 13);
    [content setCustomSpacing:16 afterView:self.captureCard];
    [content setCustomSpacing:16 afterView:self.typeSection];
    [content setCustomSpacing:0 afterView:resultArea];
    self.pageScrollView = TSDeviceLogInstall(content, self.view);
    // 原型的标题位于自身导航下，原生系统导航已提供 44 点高度。
    TSDeviceLogInset(content, UIEdgeInsetsMake(1, 15, 12, 15));
    self.pageScrollView.delegate = self;
    [self render];
    [self renderFiles];
}

// 内容由安全区约束布局。
- (void)layoutViews {
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFooterPosition];
}

// 回到页面直接从 SDK 读取已有状态。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCapability];
    [self refreshFiles];
    [self render];
    __weak typeof(self) weakSelf = self;
    self.metricsTimer = [NSTimer scheduledTimerWithTimeInterval:0.42 repeats:YES block:^(NSTimer *timer) {
        [weakSelf renderMetrics];
    }];
}

// 离开界面只停止 UI 定时刷新。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.metricsTimer invalidate];
    self.metricsTimer = nil;
}

- (void)dealloc {
    [self.metricsTimer invalidate];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - 页面布局

// 创建和原型一致的状态卡和两个统计值。
- (void)setupCaptureCard {
    self.captureDot = [[UIView alloc] init];
    self.captureDot.layer.cornerRadius = 3.5;
    [self.captureDot.widthAnchor constraintEqualToConstant:7].active = YES;
    [self.captureDot.heightAnchor constraintEqualToConstant:7].active = YES;
    UILabel *heading = TSDeviceLogLabel(11, UIFontWeightSemibold, TSDeviceLogColor(0xd0e4d7));
    heading.text = TSLocalizedString(@"device_realtime_log.capture");
    UIStackView *status = TSDeviceLogStack(@[self.captureDot, heading], UILayoutConstraintAxisHorizontal, 7);
    [status.heightAnchor constraintGreaterThanOrEqualToConstant:16].active = YES;
    self.captureStateLabel = TSDeviceLogLabel(25, UIFontWeightBold, TSDeviceLogColor(0xf6fbf6));
    self.captureStateLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
    [self.captureStateLabel.heightAnchor constraintGreaterThanOrEqualToConstant:32.5].active = YES;
    UIStackView *stateHeading = TSDeviceLogStack(@[self.captureStateLabel], UILayoutConstraintAxisVertical, 0);
    TSDeviceLogInset(stateHeading, UIEdgeInsetsMake(7, 0, 3, 0));
    self.captureNoteLabel = TSDeviceLogLabel(12, UIFontWeightRegular, TSDeviceLogColor(0xd1e3d8));
    [self.captureNoteLabel.heightAnchor constraintGreaterThanOrEqualToConstant:19].active = YES;
    [self setupSignal];
    UIStackView *signalArea = TSDeviceLogStack(@[self.signal], UILayoutConstraintAxisVertical, 0);
    TSDeviceLogInset(signalArea, UIEdgeInsetsMake(0, 0, 2, 0));
    UIStackView *stateRow = TSDeviceLogStack(@[stateHeading, signalArea], UILayoutConstraintAxisHorizontal, 10);
    stateRow.alignment = UIStackViewAlignmentBottom;
    [stateRow.heightAnchor constraintGreaterThanOrEqualToConstant:49].active = YES;
    self.durationLabel = TSDeviceLogLabel(16, UIFontWeightSemibold, TSDeviceLogColor(0xf6fbf6));
    self.bytesLabel = TSDeviceLogLabel(16, UIFontWeightSemibold, TSDeviceLogColor(0xf6fbf6));
    UIStackView *metrics = TSDeviceLogStack(@[
        [self metricWithValue:self.durationLabel key:@"device_realtime_log.duration"],
        [self metricWithValue:self.bytesLabel key:@"device_realtime_log.received"],
    ], UILayoutConstraintAxisHorizontal, 14);
    metrics.distribution = UIStackViewDistributionFillEqually;
    [metrics.heightAnchor constraintGreaterThanOrEqualToConstant:20].active = YES;
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [TSDeviceLogColor(0xd1f1df) colorWithAlphaComponent:0.21];
    [separator.heightAnchor constraintEqualToConstant:1].active = YES;
    TSDeviceRealtimeLogCaptureCard *card = [[TSDeviceRealtimeLogCaptureCard alloc] initWithArrangedSubviews:
                                          @[status, stateRow, self.captureNoteLabel, separator, metrics]];
    card.axis = UILayoutConstraintAxisVertical;
    [card setCustomSpacing:2 afterView:stateRow];
    [card setCustomSpacing:14 afterView:self.captureNoteLabel];
    [card setCustomSpacing:11 afterView:separator];
    TSDeviceLogInset(card, UIEdgeInsetsMake(17, 16, 15, 16));
    CAGradientLayer *gradient = (CAGradientLayer *)card.layer;
    gradient.colors = @[(id)TSDeviceLogColor(0x0a3025).CGColor, (id)TSDeviceLogColor(0x092a22).CGColor,
                        (id)TSDeviceLogColor(0x113e2e).CGColor];
    gradient.locations = @[@0, @0.7, @1];
    gradient.startPoint = CGPointMake(0, 0.25);
    gradient.endPoint = CGPointMake(1, 0.75);
    gradient.cornerRadius = 19;
    gradient.masksToBounds = YES;
    CAGradientLayer *highlight = [CAGradientLayer layer];
    UIColor *glow = TSDeviceLogColor(0x69a479);
    highlight.type = kCAGradientLayerRadial;
    highlight.colors = @[(id)[glow colorWithAlphaComponent:0.2157].CGColor,
                         (id)[glow colorWithAlphaComponent:0].CGColor];
    highlight.locations = @[@0, @0.59];
    highlight.startPoint = CGPointMake(0.89, 0.20);
    highlight.endPoint = CGPointMake(0.07, 1.18);
    [gradient insertSublayer:highlight atIndex:0];
    card.highlightLayer = highlight;
    self.captureCard = card;
}

// 创建只反映是否收到日志的装饰波形。
- (void)setupSignal {
    NSMutableArray<UIView *> *bars = [NSMutableArray array];
    NSMutableArray<NSLayoutConstraint *> *heights = [NSMutableArray array];
    for (NSUInteger index = 0; index < 18; index++) {
        UIView *bar = [[UIView alloc] init];
        bar.layer.cornerRadius = 1;
        [bar.widthAnchor constraintEqualToConstant:2].active = YES;
        NSLayoutConstraint *height = [bar.heightAnchor constraintEqualToConstant:3];
        height.active = YES;
        [heights addObject:height];
        [bars addObject:bar];
    }
    self.signal = TSDeviceLogStack(bars, UILayoutConstraintAxisHorizontal, 3);
    [self.signal.heightAnchor constraintEqualToConstant:34].active = YES;
    self.signal.accessibilityElementsHidden = YES;
    self.signalHeights = heights;
}

// 统计值优先保留完整显示，小屏或大字号下允许说明换行。
- (UIStackView *)metricWithValue:(UILabel *)value key:(NSString *)key {
    value.font = [[UIFontMetrics defaultMetrics] scaledFontForFont:
                  [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightSemibold]];
    [value setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UILabel *caption = TSDeviceLogLabel(11, UIFontWeightRegular, TSDeviceLogColor(0xc0d2c8));
    caption.text = TSLocalizedString(key);
    UIStackView *metric = TSDeviceLogStack(@[value, caption], UILayoutConstraintAxisHorizontal, 6);
    metric.alignment = UIStackViewAlignmentFirstBaseline;
    return metric;
}

- (UIStackView *)sectionWithTitle:(NSString *)title accessory:(UILabel *)accessory {
    UILabel *heading = TSDeviceLogLabel(15, UIFontWeightBold, TSDeviceLogColor(0x13261e));
    heading.text = title;
    heading.accessibilityTraits |= UIAccessibilityTraitHeader;
    [accessory setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *header = TSDeviceLogStack(@[heading, accessory], UILayoutConstraintAxisHorizontal, 8);
    TSDeviceLogInset(header, UIEdgeInsetsMake(0, 1, 0, 1));
    [header.heightAnchor constraintGreaterThanOrEqualToConstant:21].active = YES;
    return TSDeviceLogStack(@[header], UILayoutConstraintAxisVertical, 7);
}

// 更新卡片内容并保留所属滚动视图。
- (void)replaceLastViewInSection:(UIStackView *)section withView:(UIView *)view {
    if (section.arrangedSubviews.count > 1) {
        [section.arrangedSubviews.lastObject removeFromSuperview];
    }
    [section addArrangedSubview:view];
}

// 像原型一样，主按钮正常跟随内容，内容超出屏幕时停在安全区底部。
- (void)updateFooterPosition {
    UIScrollView *scroll = self.pageScrollView;
    CGFloat footerBottom = self.footer.center.y + CGRectGetHeight(self.footer.bounds) / 2.0;
    CGFloat viewportBottom = CGRectGetMaxY(scroll.bounds) - 12;
    CGFloat offset = MIN(0, viewportBottom - footerBottom);
    CGAffineTransform position = CGAffineTransformMakeTranslation(0, offset);
    if (!CGAffineTransformEqualToTransform(self.footer.transform, position)) {
        self.footer.transform = position;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.pageScrollView) {
        [self updateFooterPosition];
    }
}

#pragma mark - SDK 查询与操作

- (TSPeripheralRealtimeLogState)currentRealtimeLogState {
    return [self.peripheralLog respondsToSelector:@selector(realtimeLogState)]
        ? [self.peripheralLog realtimeLogState] : TSPeripheralRealtimeLogStateIdle;
}

- (BOOL)hasRealtimeLogAPI {
    return [self.peripheralLog respondsToSelector:@selector(queryRealtimeLogCapabilityWithCompletion:)] &&
           [self.peripheralLog respondsToSelector:@selector(realtimeLogState)] &&
           [self.peripheralLog respondsToSelector:@selector(startRealtimeLogWithTypes:dataHandler:eventHandler:)] &&
           [self.peripheralLog respondsToSelector:@selector(stopRealtimeLogWithCompletion:)];
}

- (BOOL)canStart {
    return [TSDeviceCoordinator sharedInstance].snapshot.isReady && !self.queryingCapability &&
           !self.capabilityError && self.capability != TSPeripheralRealtimeLogCapabilityUnsupported;
}

- (BOOL)canEditInState:(TSPeripheralRealtimeLogState)state {
    return [self canStart] && self.capability == TSPeripheralRealtimeLogCapabilityReceiveAndControl &&
           (state == TSPeripheralRealtimeLogStateIdle || state == TSPeripheralRealtimeLogStateRunning);
}

// 查询结果只用于发起请求时的连接。
- (void)refreshCapability {
    if (self.queryingCapability || ![self hasRealtimeLogAPI] || ![TSDeviceCoordinator sharedInstance].snapshot.isReady) {
        return;
    }
    self.queryingCapability = YES;
    NSUInteger request = ++self.capabilityRequest;
    [self render];
    __weak typeof(self) weakSelf = self;
    [self.peripheralLog queryRealtimeLogCapabilityWithCompletion:^(TSPeripheralRealtimeLogCapability capability, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || request != strongSelf.capabilityRequest) {
                return;
            }
            strongSelf.queryingCapability = NO;
            strongSelf.capability = capability;
            strongSelf.capabilityError = error;
            [strongSelf render];
        });
    }];
}

// 仅枚举已关闭的文件，过期结果不覆盖更新的列表。
- (void)refreshFiles {
    NSUInteger request = ++self.fileListRequest;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray<NSURL *> *files = [[TSDeviceRealtimeLogStore sharedStore] closedFiles];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && request == strongSelf.fileListRequest) {
                strongSelf.files = files;
                [strongSelf renderFiles];
            }
        });
    });
}

- (void)refreshTapped {
    [self.recorder clearError];
    [self refreshCapability];
    [self refreshFiles];
    [self render];
}

// 主操作随 SDK 的状态切换，开启中也允许停止。
- (void)primaryTapped {
    TSPeripheralRealtimeLogState state = [self currentRealtimeLogState];
    if (state == TSPeripheralRealtimeLogStateStarting || state == TSPeripheralRealtimeLogStateRunning) {
        [self.recorder stopRecording];
    } else if (state == TSPeripheralRealtimeLogStateIdle && [self canStart]) {
        TSPeripheralRealtimeLogTypes types = self.capability == TSPeripheralRealtimeLogCapabilityReceiveOnly
            ? TSPeripheralRealtimeLogTypeNone : self.recorder.selectedTypes;
        [self.recorder startWithPeripheralLog:self.peripheralLog types:types];
    }
}

// 提交整组草稿，抓取中由录制器等待成功停止后重启。
- (void)showLogTypes {
    TSPeripheralRealtimeLogState state = [self currentRealtimeLogState];
    if (self.presentedViewController || ![self canEditInState:state]) {
        return;
    }
    TSPeripheralRealtimeLogTypes selection = state == TSPeripheralRealtimeLogStateRunning
        ? self.recorder.captureTypes : self.recorder.selectedTypes;
    __weak typeof(self) weakSelf = self;
    TSDeviceRealtimeLogTypesVC *picker = [[TSDeviceRealtimeLogTypesVC alloc]
        initWithSelectedTypes:selection recording:state == TSPeripheralRealtimeLogStateRunning
        completion:^(TSPeripheralRealtimeLogTypes types) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [strongSelf canEditInState:[strongSelf currentRealtimeLogState]]) {
            [strongSelf.recorder updateSelectedTypes:types peripheralLog:strongSelf.peripheralLog];
        }
    }];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    navigation.modalPresentationStyle = UIModalPresentationPageSheet;
    navigation.navigationBar.tintColor = TSDeviceLogColor(0x0068dc);
    UISheetPresentationController *sheet = navigation.sheetPresentationController;
    if (@available(iOS 16.0, *)) {
        sheet.detents = @[[UISheetPresentationControllerDetent customDetentWithIdentifier:nil
            resolver:^CGFloat(id<UISheetPresentationControllerDetentResolutionContext> context) {
            return MIN(454.0, context.maximumDetentValue);
        }]];
    } else {
        sheet.detents = @[[UISheetPresentationControllerDetent mediumDetent],
                          [UISheetPresentationControllerDetent largeDetent]];
    }
    sheet.prefersGrabberVisible = YES;
    sheet.prefersScrollingExpandsWhenScrolledToEdge = NO;
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - 页面状态

// 使用原型的状态优先级，设备能力和启停状态分别展示。
- (void)render {
    if (!self.isViewLoaded) {
        return;
    }
    TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
    TSPeripheralRealtimeLogState state = [self currentRealtimeLogState];
    BOOL reconnect = snapshot.isReady && self.capabilityError.code == eTSErrorNotReady;
    [self renderDevice:snapshot reconnect:reconnect];
    [self renderCapture:state connected:snapshot.isReady reconnect:reconnect];
    [self renderTypes:state];
    [self renderNotice];
    BOOL canStop = state == TSPeripheralRealtimeLogStateStarting || state == TSPeripheralRealtimeLogStateRunning;
    BOOL stopping = state == TSPeripheralRealtimeLogStateStopping;
    NSString *buttonKey = stopping ? @"device_realtime_log.stopping_action"
        : (canStop ? @"device_realtime_log.stop" : @"device_realtime_log.start");
    TSDeviceLogPrimary(self.primaryButton, TSLocalizedString(buttonKey), canStop || stopping ? @"stop.fill" : @"play.fill",
                       canStop, canStop || (state == TSPeripheralRealtimeLogStateIdle && [self canStart]));
    self.navigationItem.rightBarButtonItem.enabled = !self.queryingCapability && state == TSPeripheralRealtimeLogStateIdle;
    [self renderMetrics];
}

- (void)renderDevice:(TSDeviceConnectionSnapshot *)snapshot reconnect:(BOOL)reconnect {
    NSString *key;
    TSDeviceLogTone tone;
    if (!snapshot.isReady) {
        key = @"device_log.design.offline";
        tone = TSDeviceLogToneInactive;
    } else if (reconnect || self.queryingCapability || self.capability == TSPeripheralRealtimeLogCapabilityReceiveOnly) {
        key = reconnect ? @"device_realtime_log.reconnect_badge" : (self.queryingCapability
              ? @"device_realtime_log.checking_badge" : @"device_realtime_log.receive_only");
        tone = TSDeviceLogToneLimited;
    } else {
        BOOL control = !self.capabilityError && self.capability == TSPeripheralRealtimeLogCapabilityReceiveAndControl;
        key = control ? @"device_realtime_log.receive_control" : @"device_realtime_log.unsupported_badge";
        tone = control ? TSDeviceLogToneAccent : TSDeviceLogToneInactive;
    }
    [self.deviceArea.arrangedSubviews.firstObject removeFromSuperview];
    [self.deviceArea addArrangedSubview:TSDeviceLogDeviceCard(snapshot, TSLocalizedString(key), tone)];
}

- (void)renderCapture:(TSPeripheralRealtimeLogState)state connected:(BOOL)connected reconnect:(BOOL)reconnect {
    NSString *title = @"device_realtime_log.idle";
    NSString *note = @"device_realtime_log.note_passive";
    UIColor *dot = TSDeviceLogColor(0x90ab9a);
    if (state == TSPeripheralRealtimeLogStateStarting || state == TSPeripheralRealtimeLogStateStopping) {
        BOOL starting = state == TSPeripheralRealtimeLogStateStarting;
        title = starting ? @"device_realtime_log.starting" : @"device_realtime_log.stopping";
        note = starting ? @"device_realtime_log.note_starting" : @"device_realtime_log.note_stopping";
        dot = TSDeviceLogColor(0xf8dca5);
    } else if (state == TSPeripheralRealtimeLogStateRunning) {
        title = @"device_realtime_log.recording";
        dot = TSDeviceLogColor(0xb7ec91);
    } else if (!connected) {
        title = @"device_realtime_log.offline";
        note = @"device_realtime_log.note_offline";
    } else if (self.queryingCapability) {
        title = @"device_realtime_log.checking";
        note = @"device_realtime_log.note_checking";
    } else if (reconnect) {
        title = @"device_realtime_log.reconnect";
        note = @"device_realtime_log.note_reconnect";
        dot = TSDeviceLogColor(0xffadab);
    } else if (self.capabilityError || self.capability == TSPeripheralRealtimeLogCapabilityUnsupported) {
        title = @"device_realtime_log.unsupported";
        note = @"device_realtime_log.note_unsupported";
    } else if (self.capability == TSPeripheralRealtimeLogCapabilityReceiveAndControl && self.recorder.selectedTypes) {
        note = @"device_realtime_log.note_selected";
    }
    self.captureDot.backgroundColor = dot;
    NSString *status = TSLocalizedString(title);
    if (![self.captureStateLabel.text isEqualToString:status]) {
        self.captureStateLabel.attributedText = [[NSAttributedString alloc] initWithString:status
                                                                                attributes:@{NSKernAttributeName: @(-1)}];
        if (self.view.window) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
        }
    }
    self.captureNoteLabel.text = TSLocalizedString(note);
}

- (void)renderMetrics {
    TSPeripheralRealtimeLogState state = [self currentRealtimeLogState];
    uint64_t bytes = self.recorder.receivedBytes;
    NSUInteger seconds = (NSUInteger)MAX(0, self.recorder.elapsedDuration);
    NSString *duration = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)(seconds / 60),
                          (unsigned long)(seconds % 60)];
    [self setMetricText:duration onLabel:self.durationLabel];
    [self setMetricText:TSDeviceLogBytes(bytes) onLabel:self.bytesLabel];
    BOOL running = state == TSPeripheralRealtimeLogStateRunning;
    if (running) {
        self.captureNoteLabel.text = TSLocalizedString(bytes ? @"device_realtime_log.note_receiving"
                                                             : @"device_realtime_log.note_waiting");
    }
    BOOL showPackets = running && bytes > 0;
    static const CGFloat packetHeights[] = {5, 12, 8, 17, 10, 24, 14, 31, 20, 13, 26, 18, 10, 21, 8, 13, 6, 4};
    if (showPackets != self.signalShowsPackets) {
        self.signalShowsPackets = showPackets;
        [self.signalHeights enumerateObjectsUsingBlock:^(NSLayoutConstraint *height, NSUInteger index, BOOL *stop) {
            height.constant = showPackets ? packetHeights[index] : 3;
        }];
    }
    UIColor *color = TSDeviceLogColor(running ? 0xb7ec91 : 0x779b85);
    for (UIView *bar in self.signal.arrangedSubviews) {
        bar.backgroundColor = color;
    }
}

// 原型的等宽数字使用紧凑字距，仅在读数变化时更新。
- (void)setMetricText:(NSString *)text onLabel:(UILabel *)label {
    if (![label.text isEqualToString:text]) {
        label.attributedText = [[NSAttributedString alloc] initWithString:text
                                                                attributes:@{NSKernAttributeName: @(-0.56)}];
    }
}

// 停止旧抓取期间仍显示旧选择，新抓取开始后才切换为新选择。
- (void)renderTypes:(TSPeripheralRealtimeLogState)state {
    BOOL active = state != TSPeripheralRealtimeLogStateIdle;
    TSPeripheralRealtimeLogTypes mask = active ? self.recorder.captureTypes : self.recorder.selectedTypes;
    if (!active && self.capability == TSPeripheralRealtimeLogCapabilityReceiveOnly) {
        mask = TSPeripheralRealtimeLogTypeNone;
    }
    self.typeContext.text = TSLocalizedString(active ? @"device_realtime_log.type_current" : @"device_realtime_log.type_next");
    NSArray<NSString *> *shortKeys = @[@"full", @"sleep", @"step", @"heart", @"power", @"pcm", @"dump"];
    NSMutableArray<NSString *> *titles = [NSMutableArray array];
    for (NSUInteger index = 0; index < shortKeys.count; index++) {
        if (mask & TSDeviceRealtimeLogTypeOptions[index]) {
            [titles addObject:TSLocalizedString([@"device_realtime_log.short_" stringByAppendingString:shortKeys[index]])];
        }
    }
    NSString *title = titles.count ? [titles componentsJoinedByString:TSLocalizedString(@"device_realtime_log.type_separator")]
                                  : TSLocalizedString(@"device_realtime_log.type_none");
    NSString *detail = self.capability == TSPeripheralRealtimeLogCapabilityReceiveOnly
        ? TSLocalizedString(@"device_realtime_log.type_receive_only")
        : (titles.count ? [NSString stringWithFormat:TSLocalizedString(@"device_realtime_log.type_count"),
                           (unsigned long)titles.count] : TSLocalizedString(@"device_realtime_log.type_caption"));
    UIButton *row = TSDeviceLogRow(@"slider.horizontal.3", title, detail, TSLocalizedString(@"device_log.design.edit"),
                                   NO, [self canEditInState:state]);
    [row.heightAnchor constraintGreaterThanOrEqualToConstant:60].active = YES;
    TSDeviceLogCard(row, 14);
    [row addTarget:self action:@selector(showLogTypes) forControlEvents:UIControlEventTouchUpInside];
    [self replaceLastViewInSection:self.typeSection withView:row];
}

- (void)renderNotice {
    NSError *error = self.recorder.lastError ?: self.capabilityError;
    NSUInteger count = self.recorder.savedFileCount;
    self.noticeCard.hidden = !error && !self.recorder.hasCaptureResult;
    self.noticeCard.backgroundColor = TSDeviceLogColor(error ? 0xfbe9e8 : 0xdceee5);
    self.noticeLabel.textColor = TSDeviceLogColor(error ? 0x842c32 : 0x22543f);
    NSString *saved = count ? [NSString stringWithFormat:TSLocalizedString(@"device_realtime_log.saved_count"),
                                (unsigned long)count] : TSLocalizedString(@"device_realtime_log.no_data");
    self.noticeLabel.text = error ? [NSString stringWithFormat:@"%@ %@", error.localizedDescription,
                                    count ? saved : @""] : saved;
}

- (void)recorderDidChange:(NSNotification *)notification {
    TSPeripheralRealtimeLogState state = [self currentRealtimeLogState];
    if (state == TSPeripheralRealtimeLogStateIdle && self.recorder.lastError) {
        [self refreshCapability];
    }
    [self refreshFiles];
    [self render];
}

- (void)connectionDidChange:(NSNotification *)notification {
    self.capabilityRequest += 1;
    self.queryingCapability = NO;
    self.capability = TSPeripheralRealtimeLogCapabilityUnsupported;
    self.capabilityError = nil;
    [self refreshCapability];
    [self render];
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (self.viewIfLoaded.window) {
        [self refreshCapability];
        [self refreshFiles];
    }
}

#pragma mark - 已保存文件

- (NSString *)dateTextForFile:(NSURL *)file {
    NSDate *date = nil;
    [file getResourceValue:&date forKey:NSURLCreationDateKey error:nil];
    return date ? [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle
                                                 timeStyle:NSDateFormatterShortStyle] : file.lastPathComponent;
}

- (NSString *)sizeTextForFile:(NSURL *)file {
    NSNumber *size = nil;
    [file getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
    return TSDeviceLogBytes(size.unsignedLongLongValue);
}

- (void)renderFiles {
    self.fileCount.text = [NSString stringWithFormat:TSLocalizedString(@"device_log.design.file_count"),
                           (unsigned long)self.files.count];
    NSMutableArray<UIButton *> *rows = [NSMutableArray array];
    NSString *device = [TSDeviceCoordinator sharedInstance].snapshot.peripheral.systemInfo.bleName;
    NSString *deviceUUID = [TSDeviceCoordinator sharedInstance].snapshot.peripheral.systemInfo.uuid;
    __weak typeof(self) weakSelf = self;
    for (NSURL *file in self.files) {
        NSString *owner = file.URLByDeletingLastPathComponent.lastPathComponent;
        NSString *source = [owner caseInsensitiveCompare:deviceUUID ?: @""] == NSOrderedSame && device.length ? device : owner;
        NSString *detail = [NSString stringWithFormat:@"%@ · %@", source, [self sizeTextForFile:file]];
        UIButton *row = TSDeviceLogRow(@"doc.text", [self dateTextForFile:file], detail, @"", YES, YES);
        [row addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
            [weakSelf showFile:file];
        }] forControlEvents:UIControlEventTouchUpInside];
        [rows addObject:row];
    }
    [self replaceLastViewInSection:self.fileSection withView:TSDeviceLogFileList(rows,
                                   TSLocalizedString(@"device_realtime_log.empty"), 205)];
}

// 从已保存文件列表打开系统详情面板。
- (void)showFile:(NSURL *)file {
    if (self.presentedViewController) {
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:file.path]) {
        [self refreshFiles];
        return;
    }
    NSArray<NSString *> *values = @[file.lastPathComponent, [self dateTextForFile:file], [self sizeTextForFile:file],
                                    file.URLByDeletingLastPathComponent.lastPathComponent];
    TSDeviceRealtimeLogFileVC *detail = [[TSDeviceRealtimeLogFileVC alloc] initWithFile:file values:values];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:detail];
    navigation.modalPresentationStyle = UIModalPresentationPageSheet;
    UISheetPresentationController *sheet = navigation.sheetPresentationController;
    if (@available(iOS 16.0, *)) {
        sheet.detents = @[[UISheetPresentationControllerDetent customDetentWithIdentifier:nil
            resolver:^CGFloat(id<UISheetPresentationControllerDetentResolutionContext> context) {
                return MIN(400.0, context.maximumDetentValue * 0.9);
            }], [UISheetPresentationControllerDetent largeDetent]];
    } else {
        sheet.detents = @[[UISheetPresentationControllerDetent mediumDetent],
                          [UISheetPresentationControllerDetent largeDetent]];
    }
    sheet.prefersGrabberVisible = YES;
    [self presentViewController:navigation animated:YES completion:nil];
}

@end

#pragma mark - 已保存日志详情面板

@interface TSDeviceRealtimeLogFileVC ()
@property (nonatomic, strong) NSURL *file;
@property (nonatomic, copy) NSArray<NSString *> *values;
@end

@implementation TSDeviceRealtimeLogFileVC

#pragma mark - 生命周期

- (instancetype)initWithFile:(NSURL *)file values:(NSArray<NSString *> *)values {
    self = [super init];
    if (self) {
        _file = file;
        _values = [values copy];
    }
    return self;
}

// 系统导航和可滚动的分组内容支持小屏与大字号。
- (void)setupViews {
    self.title = TSLocalizedString(@"device_realtime_log.file_title");
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:TSLocalizedString(@"device_log.design.close")
                style:UIBarButtonItemStylePlain target:self action:@selector(closeDetails)];

    NSArray<NSString *> *keys = @[@"file_name", @"file_date", @"file_size", @"file_uuid"];
    UIStackView *fields = TSDeviceLogStack(@[], UILayoutConstraintAxisVertical, 0);
    fields.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    fields.layer.cornerRadius = 12;
    fields.clipsToBounds = YES;
    for (NSUInteger index = 0; index < keys.count; index++) {
        if (index > 0) {
            UIView *separator = [[UIView alloc] init];
            separator.backgroundColor = UIColor.separatorColor;
            [separator.heightAnchor constraintEqualToConstant:0.5].active = YES;
            [fields addArrangedSubview:separator];
        }
        UILabel *label = TSDeviceLogLabel(13, UIFontWeightRegular, UIColor.secondaryLabelColor);
        label.text = TSLocalizedString([@"device_log.design." stringByAppendingString:keys[index]]);
        UILabel *value = TSDeviceLogLabel(15, UIFontWeightRegular, UIColor.labelColor);
        value.text = self.values[index];
        value.lineBreakMode = NSLineBreakByCharWrapping;
        UIStackView *row = TSDeviceLogStack(@[label, value], UILayoutConstraintAxisVertical, 2);
        TSDeviceLogInset(row, UIEdgeInsetsMake(8, 16, 8, 16));
        [fields addArrangedSubview:row];
    }

    UIButtonConfiguration *configuration = [UIButtonConfiguration filledButtonConfiguration];
    configuration.title = TSLocalizedString(@"device_realtime_log.export");
    configuration.image = [UIImage systemImageNamed:@"square.and.arrow.up"];
    configuration.imagePadding = 8;
    configuration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
    UIButton *exportButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    [exportButton.heightAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    [exportButton addTarget:self action:@selector(exportFile:) forControlEvents:UIControlEventTouchUpInside];
    TSDeviceLogInstall(TSDeviceLogStack(@[fields, exportButton], UILayoutConstraintAxisVertical, 12), self.view);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
}

- (void)layoutViews {
}

#pragma mark - 私有方法

// 关闭文件详情，返回已保存文件列表。
- (void)closeDetails {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 将已有的本地文件交给 iOS 系统分享。
- (void)exportFile:(UIButton *)sender {
    if (self.presentedViewController) {
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.file.path]) {
        [self closeDetails];
        return;
    }
    UIActivityViewController *sheet = [[UIActivityViewController alloc] initWithActivityItems:@[self.file]
                                                                       applicationActivities:nil];
    sheet.popoverPresentationController.sourceView = sender;
    sheet.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
#pragma mark - 类型选择面板

@interface TSDeviceRealtimeLogTypesVC ()
// 打开时的选择，用于判断能否点击「完成」。
@property (nonatomic, assign) TSPeripheralRealtimeLogTypes originalTypes;
// 关闭面板前保存在本地的多选草稿。
@property (nonatomic, assign) TSPeripheralRealtimeLogTypes draftTypes;
// 打开时是否正在抓取，用于显示对应的确认说明。
@property (nonatomic, assign) BOOL wasRecording;
// 仅在用户明确确认后向实时日志页提交。
@property (nonatomic, copy) void (^confirmation)(TSPeripheralRealtimeLogTypes types);
@end

@implementation TSDeviceRealtimeLogTypesVC

#pragma mark - 生命周期

// 使用已确认的选择初始化独立草稿。
- (instancetype)initWithSelectedTypes:(TSPeripheralRealtimeLogTypes)selectedTypes
                            recording:(BOOL)isRecording
                           completion:(void (^)(TSPeripheralRealtimeLogTypes types))completion {
    self = [super init];
    if (self) {
        _originalTypes = selectedTypes;
        _draftTypes = selectedTypes;
        _wasRecording = isRecording;
        _confirmation = [completion copy];
    }
    return self;
}

#pragma mark - 页面布局

// 用系统导航栏和分组列表显示原生多选面板。
- (void)setupViews {
    self.title = TSLocalizedString(@"device_realtime_log.type_picker_title");
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.cancel")
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(cancelSelection)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSLocalizedString(@"general.done")
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(confirmSelection)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    self.sourceArray = TSDeviceRealtimeLogTypeTitles();
    self.sourceTableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.sourceTableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sourceTableview.tintColor = UIColor.systemBlueColor;
    self.sourceTableview.dataSource = self;
    self.sourceTableview.delegate = self;
    self.sourceTableview.estimatedRowHeight = 47.0;
    [self.view addSubview:self.sourceTableview];
}

// 列表随系统面板调整，导航栏边距由 UIKit 处理。
- (void)layoutViews {
    self.sourceTableview.frame = self.view.bounds;
}

#pragma mark - 私有方法

// 取消和系统下拉均不调用提交回调。
- (void)cancelSelection {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 整组草稿只在明确确认后提交一次。
- (void)confirmSelection {
    if (!self.navigationItem.rightBarButtonItem.enabled) {
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.confirmation(self.draftTypes);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

// 使用系统勾选标识，并为 VoiceOver 标注选中状态。
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const kLogTypeCellIdentifier = @"TSDeviceRealtimeLogTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogTypeCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kLogTypeCellIdentifier];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.adjustsFontForContentSizeCategory = YES;
        cell.textLabel.numberOfLines = 0;
    }
    cell.textLabel.text = self.sourceArray[indexPath.row];
    BOOL isSelected = (self.draftTypes & TSDeviceRealtimeLogTypeOptions[indexPath.row]) != 0;
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.accessibilityTraits &= ~UIAccessibilityTraitSelected;
    if (isSelected) {
        cell.accessibilityTraits |= UIAccessibilityTraitSelected;
    }
    return cell;
}

// 点整行只切换草稿，并在与原选择不同时开放确认。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.draftTypes ^= TSDeviceRealtimeLogTypeOptions[indexPath.row];
    self.navigationItem.rightBarButtonItem.enabled = self.draftTypes != self.originalTypes;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

// 行高随系统文字大小变化。
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

// 为抓取中确认与空类型提供说明。
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.wasRecording ? TSLocalizedString(@"device_realtime_log.type_picker_restart_hint")
                             : TSLocalizedString(@"device_realtime_log.type_picker_hint");
}

// 由系统测量说明文案在不同屏幕和字号下的高度。
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

@end
