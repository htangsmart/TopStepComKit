//
//  TSAIAudioRecordVC.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordVC.h"

#import <QuartzCore/QuartzCore.h>

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAIAudioRecordConfig.h>

#import "TSAIAudioRecordVC+Private.h"
#import "TSAIAudioRecordVC+Views.h"
#import "TSAIAudioRecordAppCapture.h"
#import "TSAIAudioRecordDraft.h"
#import "TSAIAudioRecordDraftStore.h"
#import "TSAIAudioRecordHistoryVC.h"
#import "TSAIAudioRecordSessionCoordinator.h"
#import "TSAIAudioRecordTranscriptView.h"
#import "TSAIAudioRecordWaveformView.h"
#import "TSAIEarbudsPickupAvailability.h"
#import "TSAIInterpreterFormatter.h"

@implementation TSAIAudioRecordVC

#pragma mark - 生命周期

/** 初始化页面状态 */
- (void)initData {
    [super initData];
    self.title = @"AI Recording";
    self.view.backgroundColor = [UIColor colorWithRed:250.0 / 255.0
                                                green:250.0 / 255.0
                                                 blue:252.0 / 255.0
                                                alpha:1.0];
    self.config = [[[TSAIAudioRecordSessionCoordinator sharedInstance] preferredConfig] copy];
    self.config.recordingScene = TSAIAudioRecordSceneOnSite;
    // Unknown 表示由 SDK 跟随当前 App 语言
    self.config.language = TSAILanguageUnknown;
    // Demo 默认开启转写同步，便于验证仓屏显示；页面上可随时关闭
    self.config.deliversTranscriptToDevice = YES;
    self.config.enableSpeakerDiarization = YES;
    self.config.allowRecordingWhileOffline = NO;
}

/** 注册通知并刷新首次状态 */
- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *navigationColor = [UIColor colorWithRed:16.0 / 255.0
                                               green:20.0 / 255.0
                                                blue:45.0 / 255.0
                                               alpha:1.0];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 36.0, 36.0);
    backButton.titleLabel.font = [UIFont systemFontOfSize:23.0 weight:UIFontWeightRegular];
    [backButton setTitle:@"‹" forState:UIControlStateNormal];
    [backButton setTitleColor:navigationColor forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UIView *navigationActionsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 74.0, 36.0)];
    UIButton *helpButton = [self navigationIconButtonWithSystemName:@"questionmark.circle"
                                                      fallbackTitle:@"?"
                                                             action:@selector(handleShowRecordingHelp)];
    helpButton.frame = CGRectMake(0.0, 0.0, 36.0, 36.0);
    UIButton *historyButton = [self navigationIconButtonWithSystemName:@"clock"
                                                         fallbackTitle:@"◷"
                                                                action:@selector(handleOpenRecordingHistory)];
    historyButton.frame = CGRectMake(38.0, 0.0, 36.0, 36.0);
    [navigationActionsView addSubview:helpButton];
    [navigationActionsView addSubview:historyButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationActionsView];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleSessionNotification:)
                               name:TSAIAudioRecordSessionDidChangeNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleSessionNotification:)
                               name:TSAIAudioRecordSessionDidReceiveResultNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(handleSessionNotification:)
                               name:TSAIAudioRecordSessionDidCompleteNotification
                             object:nil];
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionPhase phase = coordinator.sessionState.phase;
    if (phase == TSAIAudioRecordSessionPhaseCompleted ||
        phase == TSAIAudioRecordSessionPhaseFailed) {
        [coordinator prepareForNewSession];
    }
    [self refreshAllContent];
}

/** 清理观察和计时器 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer invalidate];
}

#pragma mark - 视图搭建

/** 创建页面层级 */
- (void)setupViews {
    [self buildPageViews];
}

/** Auto Layout 页面无需逐项设置 frame */
- (void)layoutViews {
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    TSAIAudioRecordSessionState *state =
        [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    BOOL showsBottomBar = state.phase != TSAIAudioRecordSessionPhaseCompleted;
    CGFloat bottomBarHeight = showsBottomBar ? 176.0 + bottomInset : 0.0;
    CGFloat availableHeight = CGRectGetHeight(self.view.bounds) -
        self.view.safeAreaInsets.top - bottomBarHeight;
    self.transcriptCardHeightConstraint.constant = MAX(208.0, availableHeight - 262.0);
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    self.bottomBarHeightConstraint.constant = bottomBarHeight;
}

#pragma mark - 交互

/** 展示录音说明底部弹层 */
- (void)handleShowRecordingHelp {
    self.recordingHelpOverlay.hidden = NO;
    self.recordingHelpOverlay.alpha = 0.0;
    self.recordingHelpSheet.transform = CGAffineTransformMakeTranslation(
        0.0,
        CGRectGetHeight(self.recordingHelpSheet.bounds));
    [UIView animateWithDuration:0.25 animations:^{
        self.recordingHelpOverlay.alpha = 1.0;
        self.recordingHelpSheet.transform = CGAffineTransformIdentity;
    }];
}

/** 关闭录音说明底部弹层 */
- (void)handleCloseRecordingHelp {
    [UIView animateWithDuration:0.22
                     animations:^{
        self.recordingHelpOverlay.alpha = 0.0;
        self.recordingHelpSheet.transform = CGAffineTransformMakeTranslation(
            0.0,
            CGRectGetHeight(self.recordingHelpSheet.bounds));
    } completion:^(BOOL finished) {
        self.recordingHelpOverlay.hidden = YES;
    }];
}

/** 打开历史录音，录音中先确认保存 */
- (void)handleOpenRecordingHistory {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    if (![coordinator.sessionState isActive]) {
        [self openRecordingHistoryPage];
        return;
    }
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"结束并保存录音？"
        message:@"进入历史录音会结束当前录音，已接收的音频将保存到历史录音。"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续录音"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"保存"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        weakSelf.shouldOpenHistoryAfterStop = YES;
        [coordinator stopRecording];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 主键三态：空闲选拾音并开始，录音中暂停，暂停中继续 */
- (void)handleRecordButton {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionPhase phase = coordinator.sessionState.phase;
    __weak typeof(self) weakSelf = self;
    void (^handleResult)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        // 无论成败都按当前阶段恢复按钮状态
        [weakSelf refreshSessionStatus];
        if (!success) {
            [weakSelf showAlertWithMsg:error.localizedDescription ?: @"操作失败"];
        }
    };
    if (phase == TSAIAudioRecordSessionPhaseRecording) {
        self.recordButton.enabled = NO;
        [coordinator pauseRecordingWithCompletion:handleResult];
        return;
    }
    if (phase == TSAIAudioRecordSessionPhasePaused) {
        self.recordButton.enabled = NO;
        [coordinator resumeRecordingWithCompletion:handleResult];
        return;
    }
    if ([coordinator.sessionState isActive]) {
        return;
    }
    // 已预选且当前可用的拾音方式直接开始，否则先弹窗选择
    NSNumber *selected = self.selectedPickupSource;
    if (selected && [coordinator isPickupSourceAvailable:selected.integerValue reason:NULL]) {
        [self startRecordingWithPickupSource:selected.integerValue];
        return;
    }
    [self presentPickupSourceSheetStartingRecording:YES fromView:self.recordButton];
}

/** 停止键：录音中或暂停中结束录音 */
- (void)handleStopButton {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionPhase phase = coordinator.sessionState.phase;
    if (phase == TSAIAudioRecordSessionPhaseStarting ||
        phase == TSAIAudioRecordSessionPhaseRecording ||
        phase == TSAIAudioRecordSessionPhasePaused) {
        [coordinator stopRecording];
    }
}

/** 模拟原型中的录音按钮按压反馈 */
- (void)handleRecordButtonTouchDown {
    [UIView animateWithDuration:0.12 animations:^{
        self.recordButton.transform = CGAffineTransformMakeScale(0.94, 0.94);
    }];
}

/** 恢复录音按钮大小 */
- (void)handleRecordButtonTouchUp {
    [UIView animateWithDuration:0.12 animations:^{
        self.recordButton.transform = CGAffineTransformIdentity;
    }];
}

/** 返回上一级页面 */
- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 展示语音输入语言选择 */
- (void)handleLanguageSelection {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"ai_record.language")
        message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (NSNumber *languageValue in [TSAIInterpreterFormatter concreteLanguageList]) {
        TSAILanguage language = languageValue.integerValue;
        NSString *title = [TSAIInterpreterFormatter displayNameForLanguage:language];
        [alert addAction:[UIAlertAction actionWithTitle:title
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
            weakSelf.config.language = language;
            [weakSelf refreshConfigurationTitles];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentActionSheet:alert fromView:self.bottomLanguageButton];
}

/** 拾音 chip：空闲时预选拾音方式；录音中不可改 */
- (void)handlePickupSourceSelection {
    if ([[TSAIAudioRecordSessionCoordinator sharedInstance].sessionState isActive]) {
        return;
    }
    [self presentPickupSourceSheetStartingRecording:NO fromView:self.pickupRouteButton];
}

/** 切换转写同步到设备屏幕；录音中不可改 */
- (void)handleTranscriptSyncToggle {
    if ([[TSAIAudioRecordSessionCoordinator sharedInstance].sessionState isActive]) {
        return;
    }
    self.config.deliversTranscriptToDevice = !self.config.deliversTranscriptToDevice;
    [self refreshConfigurationTitles];
}

/**
 * 弹出拾音方式选择：只有前置条件不满足的项置灰并说明原因；需授权、耳机未连接的项可点并给出引导
 * @param startsRecording YES：选定后立即开始录音；NO：仅记录预选值并刷新 chip
 * @param sourceView iPad 上 popover 的锚点视图
 */
- (void)presentPickupSourceSheetStartingRecording:(BOOL)startsRecording fromView:(UIView *)sourceView {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"选择拾音方式"
        message:@"本次录音将使用所选麦克风收音；充电仓拾音时转写文本会同步显示在仓屏"
        preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<NSNumber *> *pickupSources = @[
        @(TSAIAudioRecordPickupSourceDevice),
        @(TSAIAudioRecordPickupSourcePhone),
        @(TSAIAudioRecordPickupSourceBluetoothHeadset)
    ];
    NSMutableArray<NSString *> *unavailableReasons = [NSMutableArray array];
    for (NSNumber *pickupSourceValue in pickupSources) {
        TSAIAudioRecordPickupSource pickupSource = pickupSourceValue.integerValue;
        NSString *reason = nil;
        [alert addAction:[self pickupActionForSource:pickupSource
                                     startsRecording:startsRecording
                                          sourceView:sourceView
                                   unavailableReason:&reason]];
        if (reason.length > 0) {
            [unavailableReasons addObject:[NSString stringWithFormat:@"%@：%@",
                                           [self titleForPickupSource:pickupSource], reason]];
        }
    }
    if (unavailableReasons.count > 0) {
        alert.message = [unavailableReasons componentsJoinedByString:@"\n"];
    }
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentActionSheet:alert fromView:sourceView];
}

/**
 * 生成一个拾音选项：前置条件不满足置灰；麦克风权限被拒、耳机未连接可点并引导；可用则直接选中
 * @param unavailableReason 置灰时返回原因，用于选择框说明
 */
- (UIAlertAction *)pickupActionForSource:(TSAIAudioRecordPickupSource)pickupSource
                         startsRecording:(BOOL)startsRecording
                              sourceView:(UIView *)sourceView
                       unavailableReason:(NSString **)unavailableReason {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    NSString *title = [self titleForPickupSource:pickupSource];
    NSString *reason = nil;
    BOOL enabled = YES;
    __weak typeof(self) weakSelf = self;
    void (^handler)(void) = ^{
        [weakSelf selectPickupSource:pickupSource startsRecording:startsRecording];
    };
    if (pickupSource == TSAIAudioRecordPickupSourceBluetoothHeadset) {
        TSAIEarbudsPickupStatus *status = [coordinator headsetPickupStatus];
        // 各 case 用花括号限定作用域：case 内创建了 block，否则跳到后续 case 会进入 block 生命周期而编译失败
        switch (status.state) {
            case TSAIEarbudsPickupStateCaseRequired: {
                enabled = NO;
                reason = @"AI 功能需连接充电仓后使用";
                break;
            }
            case TSAIEarbudsPickupStatePermissionRequired: {
                title = [title stringByAppendingString:@"（需开启权限）"];
                handler = ^{
                    [weakSelf presentMicrophonePermissionAlert];
                };
                break;
            }
            case TSAIEarbudsPickupStateEarbudsNotReady: {
                title = [title stringByAppendingString:@"（未连接）"];
                handler = ^{
                    [weakSelf presentEarbudsNotReadyAlertStartingRecording:startsRecording sourceView:sourceView];
                };
                break;
            }
            case TSAIEarbudsPickupStateAvailable: {
                if (status.deviceName.length > 0) {
                    title = [NSString stringWithFormat:@"%@（%@）", title, status.deviceName];
                }
                break;
            }
        }
    } else if (![coordinator isPickupSourceAvailable:pickupSource reason:&reason]) {
        BOOL permissionDenied = pickupSource == TSAIAudioRecordPickupSourcePhone &&
            [coordinator isCaseReady] && [TSAIAudioRecordAppCapture isRecordPermissionDenied];
        if (permissionDenied) {
            // 权限问题可点并引导去设置，与耳机保持一致
            reason = nil;
            title = [title stringByAppendingString:@"（需开启权限）"];
            handler = ^{
                [weakSelf presentMicrophonePermissionAlert];
            };
        } else {
            enabled = NO;
        }
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *selectedAction) {
        (void)selectedAction;
        handler();
    }];
    action.enabled = enabled;
    if (unavailableReason) {
        *unavailableReason = enabled ? nil : reason;
    }
    return action;
}

/** 记录所选拾音方式；从录音键进入时立即开始录音 */
- (void)selectPickupSource:(TSAIAudioRecordPickupSource)pickupSource startsRecording:(BOOL)startsRecording {
    self.selectedPickupSource = @(pickupSource);
    if (startsRecording) {
        [self startRecordingWithPickupSource:pickupSource];
    } else {
        [self refreshConfigurationTitles];
    }
}

/** 麦克风权限被拒：引导去系统设置开启 */
- (void)presentMicrophonePermissionAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"需要麦克风权限"
        message:@"手机或耳机收音需要麦克风权限，请在系统设置中开启后再试"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.go_settings")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        [TSAIEarbudsPickupAvailability openAppSettings];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 耳机未连接：引导取出佩戴或在系统蓝牙中连接，可重新检测或改用手机麦克风 */
- (void)presentEarbudsNotReadyAlertStartingRecording:(BOOL)startsRecording sourceView:(UIView *)sourceView {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"未检测到已连接的耳机"
        message:@"请取出耳机佩戴，或在系统「设置 - 蓝牙」中连接耳机，然后点「重新检测」"
        preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"重新检测"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        [weakSelf presentPickupSourceSheetStartingRecording:startsRecording fromView:sourceView];
    }]];
    [self addUsePhoneMicrophoneActionToAlert:alert startsRecording:startsRecording];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 开始时未能切到耳机麦克风（耳机可能只连了播放通道）：可改用手机麦克风继续 */
- (void)presentHeadsetStartFailureAlertWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"无法使用耳机麦克风"
        message:[NSString stringWithFormat:@"%@\n耳机可能只连接了播放通道，可在系统「设置 - 蓝牙」中断开后重新连接耳机。",
                 error.localizedDescription ?: @""]
        preferredStyle:UIAlertControllerStyleAlert];
    [self addUsePhoneMicrophoneActionToAlert:alert startsRecording:YES];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 手机麦克风当前可用时，给弹窗加「改用手机麦克风」 */
- (void)addUsePhoneMicrophoneActionToAlert:(UIAlertController *)alert startsRecording:(BOOL)startsRecording {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    if (![coordinator isPickupSourceAvailable:TSAIAudioRecordPickupSourcePhone reason:NULL]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:startsRecording ? @"改用手机麦克风继续" : @"改用手机麦克风"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        [weakSelf selectPickupSource:TSAIAudioRecordPickupSourcePhone startsRecording:startsRecording];
    }]];
}

/** 是否为耳机麦克风不可用导致的启动失败 */
- (BOOL)isHeadsetRouteError:(NSError *)error {
    return [error.domain isEqualToString:TSAIAudioRecordAppCaptureErrorDomain] &&
        (error.code == TSAIAudioRecordAppCaptureErrorCodeInputUnavailable ||
         error.code == TSAIAudioRecordAppCaptureErrorCodeRouteMismatch);
}

/** 使用所选拾音方式开始 App 发起的录音；耳机麦克风切换失败时提供改用手机麦克风 */
- (void)startRecordingWithPickupSource:(TSAIAudioRecordPickupSource)pickupSource {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    if ([coordinator.sessionState isActive]) {
        return;
    }
    [coordinator updatePreferredConfig:self.config];
    [self.waveformView resetWaveform];
    __weak typeof(self) weakSelf = self;
    [coordinator startRecordingWithConfig:self.config
                             pickupSource:pickupSource
                               completion:^(BOOL success, NSError *error) {
        if (success) {
            return;
        }
        if (pickupSource == TSAIAudioRecordPickupSourceBluetoothHeadset && [weakSelf isHeadsetRouteError:error]) {
            [weakSelf presentHeadsetStartFailureAlertWithError:error];
            return;
        }
        [weakSelf showAlertWithMsg:error.localizedDescription ?: TSLocalizedString(@"ai_record.start_failed")];
    }];
}

/** 返回拾音方式名称：SCO=耳机，Opus=充电仓，BuiltInMic=手机 */
- (NSString *)titleForPickupSource:(TSAIAudioRecordPickupSource)pickupSource {
    switch (pickupSource) {
        case TSAIAudioRecordPickupSourcePhone:
            return @"手机麦克风";
        case TSAIAudioRecordPickupSourceBluetoothHeadset:
            return @"耳机麦克风";
        case TSAIAudioRecordPickupSourceDevice:
        default:
            return @"充电仓麦克风";
    }
}

/** 返回当前应展示的拾音方式名称；空闲时为预选值，未预选则为 nil */
- (nullable NSString *)displayPickupTitle {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionPhase phase = coordinator.sessionState.phase;
    if (phase == TSAIAudioRecordSessionPhaseIdle) {
        NSNumber *selected = self.selectedPickupSource;
        return selected ? [self titleForPickupSource:selected.integerValue] : nil;
    }
    return [self titleForPickupSource:coordinator.currentPickupSource];
}

/** 切换结果内容 */
- (void)handleResultSegmentChanged {
    CGFloat segmentWidth = CGRectGetWidth(self.resultSegmentControl.bounds) / 2.0;
    CGFloat translationX = self.resultSegmentControl.selectedSegmentIndex == 0 ? 0.0 : segmentWidth;
    [UIView animateWithDuration:0.2
                     animations:^{
        self.resultSelectionIndicator.transform = CGAffineTransformMakeTranslation(translationX, 0.0);
    }];
    BOOL showsTranscript = self.resultSegmentControl.selectedSegmentIndex == 0;
    self.resultTranscriptView.hidden = !showsTranscript;
    self.resultTextView.hidden = showsTranscript;
    [self refreshResultContent];
}

/** 重置为再次录音准备态 */
- (void)handleRecordAgain {
    [self.waveformView resetWaveform];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    [[TSAIAudioRecordSessionCoordinator sharedInstance] prepareForNewSession];
}

/** 完成并返回上一级 */
- (void)handleDone {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 在手机或平板上安全展示操作表 */
- (void)presentActionSheet:(UIAlertController *)alert fromView:(UIView *)sourceView {
    UIPopoverPresentationController *popover = alert.popoverPresentationController;
    if (popover) {
        popover.sourceView = sourceView;
        popover.sourceRect = sourceView.bounds;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

/** 打开历史录音页面 */
- (void)openRecordingHistoryPage {
    TSAIAudioRecordHistoryVC *historyVC = [[TSAIAudioRecordHistoryVC alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}

/** 创建符合 HTML 尺寸的导航图标按钮 */
- (UIButton *)navigationIconButtonWithSystemName:(NSString *)systemName
                                    fallbackTitle:(NSString *)fallbackTitle
                                           action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = [UIColor colorWithRed:16.0 / 255.0
                                       green:20.0 / 255.0
                                        blue:45.0 / 255.0
                                       alpha:1.0];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:19.0
                                                             weight:UIImageSymbolWeightRegular];
        UIImage *image = [UIImage systemImageNamed:systemName withConfiguration:configuration];
        [button setImage:image forState:UIControlStateNormal];
    } else {
        button.titleLabel.font = [UIFont systemFontOfSize:19.0 weight:UIFontWeightRegular];
        [button setTitle:fallbackTitle forState:UIControlStateNormal];
    }
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - 状态刷新

/** 响应协调器通知 */
- (void)handleSessionNotification:(NSNotification *)notification {
    NSNumber *audioLevel = notification.userInfo[TSAIAudioRecordSessionAudioLevelUserInfoKey];
    if (audioLevel) {
        [self.waveformView appendAudioLevel:audioLevel.doubleValue];
    }
    [self refreshAllContent];
    TSAIAudioRecordSessionState *state =
        [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    [self presentInterruptionAlertIfNeededForState:state
                                             error:notification.userInfo[TSAIAudioRecordSessionErrorUserInfoKey]];
    if (self.shouldOpenHistoryAfterStop && state.phase == TSAIAudioRecordSessionPhaseCompleted) {
        self.shouldOpenHistoryAfterStop = NO;
        [self openRecordingHistoryPage];
    }
}

#pragma mark - 中断提示

/** 录音被动结束（耳机入仓/断连、来电、设备中断、Context 断开）时每代只弹一次提示 */
- (void)presentInterruptionAlertIfNeededForState:(TSAIAudioRecordSessionState *)state
                                           error:(NSError *)error {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordSessionCoordinator sharedInstance].currentDraft;
    BOOL interrupted = state.phase == TSAIAudioRecordSessionPhaseInterrupted;
    BOOL completedIncomplete = state.phase == TSAIAudioRecordSessionPhaseCompleted && draft.isIncomplete;
    if ((!interrupted && !completedIncomplete) ||
        state.generation == 0 ||
        self.promptedInterruptionGeneration == state.generation) {
        return;
    }
    self.promptedInterruptionGeneration = state.generation;
    NSString *reason = [self interruptionDescriptionForState:state error:error ?: draft.runtimeError];
    NSString *saveHint = [self saveHintForDraft:draft completed:completedIncomplete];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"录音已结束"
        message:[NSString stringWithFormat:@"%@\n%@", reason, saveHint]
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 中断原因文案：App 采集错误带明确描述，设备侧按 SDK 中断原因映射 */
- (NSString *)interruptionDescriptionForState:(TSAIAudioRecordSessionState *)state
                                        error:(NSError *)error {
    if ([error.domain isEqualToString:TSAIAudioRecordAppCaptureErrorDomain] &&
        error.localizedDescription.length > 0) {
        return error.localizedDescription;
    }
    switch (state.interruptReason) {
        case TSAIAudioRecordInterruptReasonLowBattery:
            return @"设备电量过低，录音已结束";
        case TSAIAudioRecordInterruptReasonIncomingCall:
            return @"来电打断，录音已结束";
        case TSAIAudioRecordInterruptReasonOther:
        case TSAIAudioRecordInterruptReasonUnknown:
            break;
    }
    if ([error.domain isEqualToString:TSAIAudioRecordDemoErrorDomain]) {
        return @"录音已结束";
    }
    return error.localizedDescription.length > 0
        ? error.localizedDescription
        : @"设备已中断本次录音（如耳机放回充电仓或断开连接）";
}

/** 保存结果文案：保存中、已保存、保存失败三种 */
- (NSString *)saveHintForDraft:(TSAIAudioRecordDraft *)draft completed:(BOOL)completed {
    if (!completed) {
        return @"已录内容正在保存到历史录音。";
    }
    if ([draft.runtimeError.domain isEqualToString:TSAIAudioRecordDemoErrorDomain]) {
        return [NSString stringWithFormat:@"已录内容保存失败：%@",
                draft.runtimeError.localizedDescription ?: @"未知错误"];
    }
    return @"已录内容已保存到历史录音。";
}

/** 完成态标题与说明：中断保存的录音与正常完成区分展示 */
- (void)refreshResultHeroForDraft:(TSAIAudioRecordDraft *)draft {
    if (!draft.isIncomplete) {
        self.resultTitleLabel.text = @"Recording completed";
        self.resultDetailLabel.text = @"音频流与 AI 会话均已结束，最终转写结果已汇总。";
        return;
    }
    TSAIAudioRecordSessionState *state =
        [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    self.resultTitleLabel.text = @"Recording interrupted";
    self.resultDetailLabel.text = [NSString stringWithFormat:@"%@。%@",
                                   [self interruptionDescriptionForState:state error:draft.runtimeError],
                                   [self saveHintForDraft:draft completed:YES]];
}

/** 刷新全部动态内容 */
- (void)refreshAllContent {
    [self refreshConfigurationTitles];
    [self refreshSessionStatus];
    [self refreshTranscriptContent];
    [self refreshResultContent];
}

/** 刷新配置选项标题 */
- (void)refreshConfigurationTitles {
    self.languageValueLabel.text = self.config.language == TSAILanguageUnknown
        ? @"跟随 App"
        : [TSAIInterpreterFormatter displayNameForLanguage:self.config.language];
    self.pickupValueLabel.text = [self displayPickupTitle] ?: @"点击选择";
    BOOL syncsTranscript = self.config.deliversTranscriptToDevice;
    self.transcriptSyncValueLabel.text = syncsTranscript ? @"开" : @"关";
    [self.transcriptSyncSwitch setOn:syncsTranscript animated:NO];
}

/** 刷新当前会话阶段 */
- (void)refreshSessionStatus {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionState *state = coordinator.sessionState;
    BOOL available = [coordinator isRecordingInterfaceReady];
    self.deviceBadgeLabel.text = available ? @"●  AIBuds connected" : @"○  Device unavailable";
    self.deviceBadgeLabel.textColor = available
        ? [UIColor colorWithRed:37.0 / 255.0 green:139.0 / 255.0 blue:115.0 / 255.0 alpha:1.0]
        : [UIColor colorWithRed:156.0 / 255.0 green:162.0 / 255.0 blue:184.0 / 255.0 alpha:1.0];
    self.deviceBadgeLabel.backgroundColor = available
        ? [UIColor colorWithRed:31.0 / 255.0 green:200.0 / 255.0 blue:160.0 / 255.0 alpha:0.08]
        : [UIColor colorWithRed:156.0 / 255.0 green:162.0 / 255.0 blue:184.0 / 255.0 alpha:0.08];

    NSString *statusText = @"READY TO RECORD";
    switch (state.phase) {
        case TSAIAudioRecordSessionPhaseStarting:
        case TSAIAudioRecordSessionPhaseRecording:
        case TSAIAudioRecordSessionPhaseStopping:
        case TSAIAudioRecordSessionPhaseFinalizing:
            statusText = self.config.recordingScene == TSAIAudioRecordSceneCall
                ? @"RECORDING · CALL"
                : @"RECORDING · ON-SITE";
            break;
        case TSAIAudioRecordSessionPhaseInterrupted:
            statusText = @"RECORDING · INTERRUPTED";
            break;
        case TSAIAudioRecordSessionPhasePaused:
            statusText = @"RECORDING · PAUSED";
            break;
        case TSAIAudioRecordSessionPhaseCompleted:
            statusText = @"RECORDING COMPLETED";
            break;
        case TSAIAudioRecordSessionPhaseFailed:
            statusText = @"RECORDING FAILED";
            break;
        case TSAIAudioRecordSessionPhaseIdle:
        default:
            break;
    }
    self.statusLabel.text = statusText;
    BOOL isRecording = [state isActive];
    BOOL isPaused = state.phase == TSAIAudioRecordSessionPhasePaused;
    self.recordingPulseView.hidden = !isRecording || isPaused;
    if (isRecording && !isPaused && ![self.recordingPulseView.layer animationForKey:@"recordingPulse"]) {
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.fromValue = @(1.0);
        pulseAnimation.toValue = @(1.9);
        pulseAnimation.duration = 0.75;
        pulseAnimation.autoreverses = YES;
        pulseAnimation.repeatCount = HUGE_VALF;
        [self.recordingPulseView.layer addAnimation:pulseAnimation forKey:@"recordingPulse"];
    } else if (!isRecording || isPaused) {
        [self.recordingPulseView.layer removeAnimationForKey:@"recordingPulse"];
    }
    self.statusLabel.textColor = isRecording
        ? [UIColor colorWithRed:255.0 / 255.0 green:77.0 / 255.0 blue:94.0 / 255.0 alpha:1.0]
        : [UIColor colorWithRed:104.0 / 255.0 green:112.0 / 255.0 blue:143.0 / 255.0 alpha:1.0];

    BOOL controlsEnabled = ![state isActive];
    self.pickupRouteButton.enabled = controlsEnabled;
    self.bottomLanguageButton.enabled = controlsEnabled;
    self.transcriptSyncButton.enabled = controlsEnabled;
    self.configStripView.alpha = controlsEnabled ? 1.0 : 0.55;
    BOOL isCompleted = state.phase == TSAIAudioRecordSessionPhaseCompleted;
    self.sessionCard.hidden = isCompleted;
    self.resultCard.hidden = !isCompleted;
    self.bottomBar.hidden = isCompleted;
    self.bottomBarHeightConstraint.constant = isCompleted
        ? 0.0
        : 176.0 + self.view.safeAreaInsets.bottom;
    BOOL isFinalizing = state.phase == TSAIAudioRecordSessionPhaseStopping ||
        state.phase == TSAIAudioRecordSessionPhaseInterrupted ||
        state.phase == TSAIAudioRecordSessionPhaseFinalizing;
    self.finalizingOverlay.hidden = !isFinalizing;
    // 被动中断的会话在整个收尾过程中都提示“正在保存”，避免 Interrupted→Finalizing 文案来回切换
    self.finalizingLabel.text = isFinalizing && coordinator.currentDraft.isIncomplete
        ? @"录音已中断，正在保存已录内容…"
        : @"Finalizing session…";
    isFinalizing ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];

    [self applyRecordButtonAppearanceForPhase:state.phase];
    self.recordButton.enabled = available && !isFinalizing && !isCompleted;
    self.recordButton.alpha = 1.0;
    NSString *pickupTitle = [self displayPickupTitle];
    if (isPaused && coordinator.isWaitingForHeadsetReconnect) {
        self.recordHintLabel.text = [NSString stringWithFormat:
            @"耳机已断开，录音已暂停\n%.0f 秒内重新连接耳机将自动继续，否则结束并保存",
            TSAIEarbudsReconnectGracePeriod];
    } else if (isPaused) {
        self.recordHintLabel.text = @"录音已暂停，暂停期间的声音不会被记录\n点击主键继续录音";
    } else if (isRecording && pickupTitle) {
        self.recordHintLabel.text = [NSString stringWithFormat:@"%@正在收音，音频实时转写中", pickupTitle];
    } else {
        self.recordHintLabel.text = @"点击录音后选择拾音方式\n支持充电仓、耳机、手机麦克风";
    }
    [self.waveformView setRecordingActive:isRecording && !isPaused];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view setNeedsLayout];
    [self updateTimerForState:state];
    [self refreshTranscriptVisibility];
}

/** 主键与停止键的三态外观与位置：空闲=单颗 66 红键居中；录音中=白底双竖条+呼吸环 / 暂停中=红底三角，与停止键左右各偏 39 对称 */
- (void)applyRecordButtonAppearanceForPhase:(TSAIAudioRecordSessionPhase)phase {
    UIColor *recordColor = [UIColor colorWithRed:255.0 / 255.0 green:77.0 / 255.0 blue:94.0 / 255.0 alpha:1.0];
    UIColor *inkColor = [UIColor colorWithRed:16.0 / 255.0 green:20.0 / 255.0 blue:45.0 / 255.0 alpha:1.0];
    BOOL isRecording = phase == TSAIAudioRecordSessionPhaseStarting ||
        phase == TSAIAudioRecordSessionPhaseRecording;
    BOOL isPaused = phase == TSAIAudioRecordSessionPhasePaused;
    BOOL isPair = isRecording || isPaused;
    self.recordIdleRingView.hidden = isPair;
    self.recordPauseGlyphView.hidden = !isRecording;
    self.recordPlayGlyphView.hidden = !isPaused;
    if (isRecording) {
        // 白 = 暂停
        self.recordButton.backgroundColor = UIColor.whiteColor;
        self.recordButton.layer.borderWidth = 1.0;
        self.recordButton.layer.borderColor = [inkColor colorWithAlphaComponent:0.06].CGColor;
        self.recordButton.layer.shadowColor = inkColor.CGColor;
        self.recordButton.layer.shadowOpacity = 0.12;
    } else {
        // 红 = 开始 / 继续
        self.recordButton.backgroundColor = recordColor;
        self.recordButton.layer.borderWidth = 0.0;
        self.recordButton.layer.shadowColor = recordColor.CGColor;
        self.recordButton.layer.shadowOpacity = 0.32;
    }
    // 尺寸与位置：空闲 66 居中；进行中 56，左键 -39、右键 +39
    CGFloat size = isPair ? 56.0 : 66.0;
    BOOL layoutChanged = self.recordButtonSizeConstraint.constant != size;
    self.recordButtonSizeConstraint.constant = size;
    self.recordButtonCenterXConstraint.constant = isPair ? -39.0 : 0.0;
    self.stopButtonCenterXConstraint.constant = isPair ? 39.0 : 0.0;
    self.recordButton.layer.cornerRadius = size / 2.0;
    self.stopButton.hidden = NO;
    void (^layoutBlock)(void) = ^{
        self.stopButton.alpha = isPair ? 1.0 : 0.0;
        [self.bottomBar layoutIfNeeded];
    };
    if (layoutChanged && self.bottomBar.window != nil) {
        [UIView animateWithDuration:0.25
                              delay:0.0
             usingSpringWithDamping:0.9
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:layoutBlock
                         completion:^(BOOL finished) {
            self.stopButton.hidden = !isPair;
        }];
    } else {
        layoutBlock();
        self.stopButton.hidden = !isPair;
    }
    self.recordPulseLayer.hidden = !isRecording;
    if (isRecording && ![self.recordPulseLayer animationForKey:@"recordRing"]) {
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @(0.92);
        scale.toValue = @(1.22);
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fade.fromValue = @(0.55);
        fade.toValue = @(0.0);
        CAAnimationGroup *ring = [CAAnimationGroup animation];
        ring.animations = @[scale, fade];
        ring.duration = 1.6;
        ring.repeatCount = HUGE_VALF;
        ring.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.recordPulseLayer addAnimation:ring forKey:@"recordRing"];
    } else if (!isRecording) {
        [self.recordPulseLayer removeAnimationForKey:@"recordRing"];
    }
}

/** 刷新实时转写可见性 */
- (void)refreshTranscriptVisibility {
    TSAIAudioRecordSessionState *state = [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    self.transcriptCard.hidden = ![state isActive];
}

/** 刷新实时转写文本 */
- (void)refreshTranscriptContent {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordSessionCoordinator sharedInstance].currentDraft;
    [self.transcriptView updateWithItems:draft.transcriptItems ?: @[]
                               emptyText:TSLocalizedString(@"ai_record.no_transcript")];
}

/** 刷新完成结果 */
- (void)refreshResultContent {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordSessionCoordinator sharedInstance].currentDraft;
    if (!draft) {
        self.durationMetricLabel.attributedText = [self metricTextWithValue:@"00:00" title:@"DURATION"];
        self.transcriptMetricLabel.attributedText = [self metricTextWithValue:@"0" title:@"TRANSCRIPTS"];
        self.speakerMetricLabel.attributedText = [self metricTextWithValue:@"0" title:@"SPEAKERS"];
        self.resultTextView.text = @"";
        [self.resultTranscriptView updateWithItems:@[] emptyText:@""];
        return;
    }
    [self refreshResultHeroForDraft:draft];
    NSString *duration = [self durationTextForMilliseconds:draft.durationMilliseconds];
    self.durationMetricLabel.attributedText = [self metricTextWithValue:duration title:@"DURATION"];
    self.transcriptMetricLabel.attributedText = [self
        metricTextWithValue:[NSString stringWithFormat:@"%lu", (unsigned long)draft.transcriptItems.count]
        title:@"TRANSCRIPTS"];
    self.speakerMetricLabel.attributedText = [self
        metricTextWithValue:[NSString stringWithFormat:@"%lu", (unsigned long)draft.speakerCount]
        title:@"SPEAKERS"];
    [self.resultTranscriptView updateWithItems:draft.transcriptItems
                                     emptyText:TSLocalizedString(@"ai_record.no_transcript")];
    self.resultTextView.text = [self eventTextForDraft:draft];
}

/** 根据会话阶段维护计时器 */
- (void)updateTimerForState:(TSAIAudioRecordSessionState *)state {
    BOOL measuresDuration = state.phase == TSAIAudioRecordSessionPhaseStarting ||
        state.phase == TSAIAudioRecordSessionPhaseRecording ||
        state.phase == TSAIAudioRecordSessionPhasePaused;
    if (measuresDuration && !self.timer) {
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                    repeats:YES
                                                      block:^(NSTimer *timer) {
            [weakSelf refreshTimerText];
        }];
    } else if (!measuresDuration && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if ([state isActive] && !measuresDuration) {
        return;
    }
    [self refreshTimerText];
}

/** 刷新计时显示 */
- (void)refreshTimerText {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionState *state = coordinator.sessionState;
    NSInteger durationMilliseconds = 0;
    if ([state isActive] && state.startDate) {
        // 计时不含暂停时长
        durationMilliseconds = MAX(0, (NSInteger)([state activeDuration] * 1000.0));
    } else if (coordinator.currentDraft) {
        durationMilliseconds = coordinator.currentDraft.durationMilliseconds;
    }
    NSInteger totalCentiseconds = MAX(0, durationMilliseconds / 10);
    NSInteger minutes = totalCentiseconds / 6000;
    NSInteger seconds = totalCentiseconds % 6000 / 100;
    NSInteger centiseconds = totalCentiseconds % 100;
    NSString *mainText = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    NSString *fractionText = [NSString stringWithFormat:@".%02ld", (long)centiseconds];
    NSMutableAttributedString *timerText = [[NSMutableAttributedString alloc]
        initWithString:[mainText stringByAppendingString:fractionText]
        attributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithRed:16.0 / 255.0
                                                             green:20.0 / 255.0
                                                              blue:45.0 / 255.0
                                                             alpha:1.0],
            NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize:48.0
                                                                  weight:UIFontWeightRegular],
            NSKernAttributeName: @(-1.5)
        }];
    [timerText addAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithRed:156.0 / 255.0
                                                        green:162.0 / 255.0
                                                         blue:184.0 / 255.0
                                                        alpha:1.0],
        NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize:20.0
                                                              weight:UIFontWeightRegular],
        NSKernAttributeName: @(0.0),
        NSBaselineOffsetAttributeName: @(3.0)
    } range:NSMakeRange(mainText.length, fractionText.length)];
    self.timerLabel.attributedText = timerText;
}

/** 生成事件展示文本 */
- (NSString *)eventTextForDraft:(TSAIAudioRecordDraft *)draft {
    if (draft.eventItems.count == 0) {
        return TSLocalizedString(@"ai_record.no_events");
    }
    NSMutableArray<NSString *> *lines = [NSMutableArray array];
    for (TSAIAudioRecordEventItem *item in draft.eventItems) {
        NSString *time = [self durationTextForMilliseconds:(NSInteger)(item.timeSinceSessionStart * 1000.0)];
        NSString *content = item.details.length > 0 ? item.details : item.evidence;
        if (content.length == 0) {
            content = [NSString stringWithFormat:TSLocalizedString(@"ai_record.event_type_format"),
                       (long)item.eventType];
        }
        [lines addObject:[NSString stringWithFormat:@"%@  %@", time, content]];
    }
    return [lines componentsJoinedByString:@"\n\n"];
}

/** 生成完成态指标的分级文字 */
- (NSAttributedString *)metricTextWithValue:(NSString *)value title:(NSString *)title {
    NSString *text = [NSString stringWithFormat:@"%@\n%@", value, title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 3.0;
    NSMutableAttributedString *metricText = [[NSMutableAttributedString alloc]
        initWithString:text
        attributes:@{
            NSForegroundColorAttributeName: UIColor.whiteColor,
            NSFontAttributeName: [UIFont systemFontOfSize:14.0 weight:UIFontWeightBold],
            NSParagraphStyleAttributeName: paragraphStyle
        }];
    [metricText addAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.68],
        NSFontAttributeName: [UIFont systemFontOfSize:8.0 weight:UIFontWeightRegular]
    } range:[text rangeOfString:title options:NSBackwardsSearch]];
    return metricText;
}

/** 将毫秒格式化为时分秒 */
- (NSString *)durationTextForMilliseconds:(NSInteger)durationMilliseconds {
    NSInteger totalSeconds = MAX(0, durationMilliseconds / 1000);
    NSInteger hours = totalSeconds / 3600;
    NSInteger minutes = totalSeconds % 3600 / 60;
    NSInteger seconds = totalSeconds % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                (long)hours,
                (long)minutes,
                (long)seconds];
    }
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

@end
