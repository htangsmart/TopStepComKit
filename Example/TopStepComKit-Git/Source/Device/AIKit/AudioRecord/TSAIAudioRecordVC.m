//
//  TSAIAudioRecordVC.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordVC.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import <TopStepAIKit/TopStepAIKit.h>
#import <TopStepAIKit/TSAIAudioRecordConfig.h>

#if __has_include(<TopStepAIKit/TSAIAudioRouteConfiguration.h>)
#import <TopStepAIKit/TSAIAudioRouteConfiguration.h>
#define TS_AI_AUDIO_RECORD_ROUTE_API_AVAILABLE 1
#else
#define TS_AI_AUDIO_RECORD_ROUTE_API_AVAILABLE 0
#endif

#import "TSAIAudioRecordVC+Private.h"
#import "TSAIAudioRecordVC+Views.h"
#import "TSAIAudioRecordDraft.h"
#import "TSAIAudioRecordHistoryVC.h"
#import "TSAIAudioRecordSessionCoordinator.h"
#import "TSAIAudioRecordTranscriptView.h"
#import "TSAIAudioRecordWaveformView.h"
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
    self.config.language = TSAILanguageChineseSimplified;
    self.config.enableSpeakerDiarization = YES;
    self.config.allowRecordingWhileOffline = NO;
    self.selectedPickupDestination = TSAIAudioRecordPickupDestinationDevice;
    self.selectedPlaybackDestination = TSAIAudioRecordPlaybackDestinationPhone;
    [self applySelectedPickupRoute];
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
    TSLog(@"[TSAIAudioRecordVC] 恢复会话状态: phase=%ld, generation=%lu, source=%ld",
          (long)phase,
          (unsigned long)coordinator.sessionState.generation,
          (long)coordinator.sessionState.source);
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
    CGFloat bottomBarHeight = showsBottomBar ? 136.0 + bottomInset : 0.0;
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

/** 处理主录音按钮 */
- (void)handleRecordButton {
    TSAIAudioRecordSessionCoordinator *coordinator = [TSAIAudioRecordSessionCoordinator sharedInstance];
    TSAIAudioRecordSessionState *state = coordinator.sessionState;
    if (state.phase == TSAIAudioRecordSessionPhaseStarting ||
        state.phase == TSAIAudioRecordSessionPhaseRecording) {
        [coordinator stopRecording];
        return;
    }
    if ([state isActive]) {
        return;
    }

    [coordinator updatePreferredConfig:self.config];
    [self.waveformView resetWaveform];
    __weak typeof(self) weakSelf = self;
    [coordinator startRecordingWithConfig:self.config completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSString *message = error.code == TSAIErrorCodeAuthorizationRequired
                ? TSLocalizedString(@"ai_record.authorization_required")
                : error.localizedDescription ?: TSLocalizedString(@"ai_record.start_failed");
            [weakSelf showAlertWithMsg:message];
        }
    }];
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

/** 展示拾音路径选择 */
- (void)handlePickupRouteSelection {
    [self showAudioRouteSelectionForPickup:YES];
}

/** 展示内容播放路径选择 */
- (void)handleContentPlaybackRouteSelection {
    [self showAudioRouteSelectionForPickup:NO];
}

/** 打开音频路径底部弹层 */
- (void)showAudioRouteSelectionForPickup:(BOOL)selectsPickup {
    TSAIAudioRecordSessionState *state =
        [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    if ([state isActive]) {
        [self showAlertWithMsg:@"录音进行中不可切换音频路径，请先结束录音。"];
        return;
    }
    self.selectingPickupRoute = selectsPickup;
    self.audioRouteSheetTitleLabel.text = selectsPickup ? @"选择拾音设备" : @"选择内容播放设备";
    self.audioRouteSheetSubtitleLabel.text = selectsPickup
        ? @"选择本次录音使用的音频输入"
        : @"选择录音完成后回放内容的设备";
    [self refreshAudioRouteOptions];
    [self.view layoutIfNeeded];
    self.audioRouteOverlay.hidden = NO;
    self.audioRouteOverlay.alpha = 0.0;
    self.audioRouteSheet.transform = CGAffineTransformMakeTranslation(
        0.0,
        CGRectGetHeight(self.audioRouteSheet.bounds));
    [UIView animateWithDuration:0.25 animations:^{
        self.audioRouteOverlay.alpha = 1.0;
        self.audioRouteSheet.transform = CGAffineTransformIdentity;
    }];
}

/** 关闭音频路径底部弹层 */
- (void)handleCloseAudioRouteSelection {
    [UIView animateWithDuration:0.22
                     animations:^{
        self.audioRouteOverlay.alpha = 0.0;
        self.audioRouteSheet.transform = CGAffineTransformMakeTranslation(
            0.0,
            CGRectGetHeight(self.audioRouteSheet.bounds));
    } completion:^(BOOL finished) {
        (void)finished;
        self.audioRouteOverlay.hidden = YES;
    }];
}

/** 应用音频路径弹层中的选项 */
- (void)handleAudioRouteOption:(UIButton *)button {
    if (self.selectingPickupRoute) {
        self.selectedPickupDestination = (TSAIAudioRecordPickupDestination)button.tag;
        [self applySelectedPickupRoute];
    } else {
        self.selectedPlaybackDestination = (TSAIAudioRecordPlaybackDestination)button.tag;
    }
    [self refreshConfigurationTitles];
    [self refreshSessionStatus];
    [self handleCloseAudioRouteSelection];
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

/** 将页面拾音选择写入支持音频路径的新版本 AIKit 配置 */
- (void)applySelectedPickupRoute {
#if TS_AI_AUDIO_RECORD_ROUTE_API_AVAILABLE
    TSAIAudioInputChannel inputChannel = TSAIAudioInputChannelOpus;
    switch (self.selectedPickupDestination) {
        case TSAIAudioRecordPickupDestinationPhone:
            inputChannel = TSAIAudioInputChannelBuiltInMic;
            break;
        case TSAIAudioRecordPickupDestinationEarphone:
            inputChannel = TSAIAudioInputChannelSCO;
            break;
        case TSAIAudioRecordPickupDestinationDevice:
        default:
            break;
    }
    self.config.audioRouteConfiguration =
        [TSAIAudioRouteConfiguration
            configurationWithInputChannel:inputChannel
                              outputChannel:TSAIAudioOutputChannelNone
                     routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
#endif
}

/** 返回拾音位置名称 */
- (NSString *)titleForPickupDestination:(TSAIAudioRecordPickupDestination)destination {
    switch (destination) {
        case TSAIAudioRecordPickupDestinationPhone:
            return @"手机拾音";
        case TSAIAudioRecordPickupDestinationEarphone:
            return @"耳机拾音";
        case TSAIAudioRecordPickupDestinationDevice:
        default:
            return @"设备拾音";
    }
}

/** 返回内容播放位置名称 */
- (NSString *)titleForPlaybackDestination:(TSAIAudioRecordPlaybackDestination)destination {
    switch (destination) {
        case TSAIAudioRecordPlaybackDestinationEarphone:
            return @"耳机播放";
        case TSAIAudioRecordPlaybackDestinationDevice:
            return @"设备播放";
        case TSAIAudioRecordPlaybackDestinationPhone:
        default:
            return @"手机播放";
    }
}

/** 返回准备态拾音说明 */
- (NSString *)readyHintForPickupDestination:(TSAIAudioRecordPickupDestination)destination {
    switch (destination) {
        case TSAIAudioRecordPickupDestinationPhone:
            return @"由手机端收音并送入 AI";
        case TSAIAudioRecordPickupDestinationEarphone:
            return @"由耳机端收音并送入 AI";
        case TSAIAudioRecordPickupDestinationDevice:
        default:
            return @"由设备端收音并实时回传 App";
    }
}

/** 返回音频路径选项说明 */
- (NSString *)detailForAudioRouteOption:(NSInteger)optionIndex {
    if (self.selectingPickupRoute) {
        switch ((TSAIAudioRecordPickupDestination)optionIndex) {
            case TSAIAudioRecordPickupDestinationPhone:
                return @"使用 iPhone 内置麦克风 · 首次需授权";
            case TSAIAudioRecordPickupDestinationEarphone:
                return @"使用已连接耳机的麦克风";
            case TSAIAudioRecordPickupDestinationDevice:
            default:
                return @"使用 AIBuds 设备麦克风";
        }
    }
    switch ((TSAIAudioRecordPlaybackDestination)optionIndex) {
        case TSAIAudioRecordPlaybackDestinationEarphone:
            return @"使用已连接耳机播放";
        case TSAIAudioRecordPlaybackDestinationDevice:
            return @"使用 AIBuds 设备扬声器";
        case TSAIAudioRecordPlaybackDestinationPhone:
        default:
            return @"使用 iPhone 扬声器";
    }
}

/** 判断系统当前是否存在耳机音频路径 */
- (BOOL)isEarphoneAudioRouteConnected {
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    NSArray<AVAudioSessionPortDescription *> *ports =
        [route.inputs arrayByAddingObjectsFromArray:route.outputs];
    for (AVAudioSessionPortDescription *port in ports) {
        NSString *portType = port.portType;
        if ([portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
            [portType isEqualToString:AVAudioSessionPortBluetoothLE] ||
            [portType isEqualToString:AVAudioSessionPortHeadphones] ||
            [portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
            return YES;
        }
    }
    return NO;
}

/** 判断音频路径弹层选项当前是否可用 */
- (BOOL)isAudioRouteOptionAvailable:(NSInteger)optionIndex {
    if (optionIndex == TSAIAudioRecordPickupDestinationPhone) {
        return YES;
    }
    if (optionIndex == TSAIAudioRecordPickupDestinationEarphone) {
        return [self isEarphoneAudioRouteConnected];
    }
    return [[TSAIAudioRecordSessionCoordinator sharedInstance]
        isRecordingAvailableForScene:self.config.recordingScene];
}

/** 刷新音频路径弹层选项 */
- (void)refreshAudioRouteOptions {
    NSInteger selectedIndex = self.selectingPickupRoute
        ? (NSInteger)self.selectedPickupDestination
        : (NSInteger)self.selectedPlaybackDestination;
    for (UIView *view in self.audioRouteOptionStackView.arrangedSubviews) {
        if (![view isKindOfClass:UIButton.class]) {
            continue;
        }
        UIButton *button = (UIButton *)view;
        BOOL selected = button.tag == selectedIndex;
        BOOL available = [self isAudioRouteOptionAvailable:button.tag];
        NSString *title = self.selectingPickupRoute
            ? [self titleForPickupDestination:(TSAIAudioRecordPickupDestination)button.tag]
            : [self titleForPlaybackDestination:(TSAIAudioRecordPlaybackDestination)button.tag];
        NSString *detail = [self detailForAudioRouteOption:button.tag];
        if (!available) {
            detail = [detail stringByAppendingString:@" · 未连接"];
        }
        NSString *mark = selected ? @"●" : @"○";
        NSString *text = [NSString stringWithFormat:@"%@  %@\n     %@", mark, title, detail];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4.0;
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]
            initWithString:text
            attributes:@{
                NSForegroundColorAttributeName: [UIColor colorWithRed:16.0 / 255.0
                                                                 green:20.0 / 255.0
                                                                  blue:45.0 / 255.0
                                                                 alpha:1.0],
                NSFontAttributeName: [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold],
                NSParagraphStyleAttributeName: paragraphStyle
            }];
        [attributedTitle addAttribute:NSForegroundColorAttributeName
                                value:[UIColor colorWithRed:79.0 / 255.0
                                                     green:123.0 / 255.0
                                                      blue:255.0 / 255.0
                                                     alpha:1.0]
                                range:NSMakeRange(0, mark.length)];
        [attributedTitle addAttributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithRed:104.0 / 255.0
                                                             green:112.0 / 255.0
                                                              blue:143.0 / 255.0
                                                             alpha:1.0],
            NSFontAttributeName: [UIFont systemFontOfSize:10.0 weight:UIFontWeightRegular]
        } range:[text rangeOfString:detail options:NSBackwardsSearch]];
        [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        button.enabled = available;
        button.alpha = available ? 1.0 : 0.42;
        button.backgroundColor = selected
            ? [UIColor colorWithRed:79.0 / 255.0 green:123.0 / 255.0 blue:255.0 / 255.0 alpha:0.07]
            : UIColor.whiteColor;
        button.layer.borderColor = selected
            ? [UIColor colorWithRed:79.0 / 255.0 green:123.0 / 255.0 blue:255.0 / 255.0 alpha:1.0].CGColor
            : [UIColor colorWithRed:16.0 / 255.0 green:20.0 / 255.0 blue:45.0 / 255.0 alpha:0.08].CGColor;
    }
}

#pragma mark - 状态刷新

/** 响应协调器通知 */
- (void)handleSessionNotification:(NSNotification *)notification {
    NSNumber *audioLevel = notification.userInfo[TSAIAudioRecordSessionAudioLevelUserInfoKey];
    if (audioLevel) {
        [self.waveformView appendAudioLevel:audioLevel.doubleValue];
        return;
    }
    [self refreshAllContent];
    TSAIAudioRecordSessionState *state =
        [TSAIAudioRecordSessionCoordinator sharedInstance].sessionState;
    if (self.shouldOpenHistoryAfterStop && state.phase == TSAIAudioRecordSessionPhaseCompleted) {
        self.shouldOpenHistoryAfterStop = NO;
        [self openRecordingHistoryPage];
    }
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
    BOOL isCallScene = self.config.recordingScene == TSAIAudioRecordSceneCall;
    NSString *sceneTitle = isCallScene ? @"CALL" : @"ON-SITE";
    BOOL usesMandarin = self.config.language == TSAILanguageUnknown ||
        self.config.language == TSAILanguageChineseSimplified;
    NSString *languageTitle = usesMandarin
        ? @"中文（普通话）"
        : [TSAIInterpreterFormatter displayNameForLanguage:self.config.language];
    [self.bottomLanguageButton setTitle:[NSString stringWithFormat:@"%@ ⌄", languageTitle]
                               forState:UIControlStateNormal];
    [self updateRouteButton:self.pickupRouteButton
                      label:@"拾音"
                      value:[self titleForPickupDestination:self.selectedPickupDestination]];
    [self updateRouteButton:self.contentPlaybackRouteButton
                      label:@"内容播放"
                      value:[self titleForPlaybackDestination:self.selectedPlaybackDestination]];
    self.sideMetaLabel.text = [NSString stringWithFormat:@"AUTO SCENE\n%@\nNO PAUSE", sceneTitle];
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
        case TSAIAudioRecordSessionPhaseInterrupted:
        case TSAIAudioRecordSessionPhaseFinalizing:
            statusText = self.config.recordingScene == TSAIAudioRecordSceneCall
                ? @"RECORDING · CALL"
                : @"RECORDING · ON-SITE";
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
    self.recordingPulseView.hidden = !isRecording;
    if (isRecording && ![self.recordingPulseView.layer animationForKey:@"recordingPulse"]) {
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.fromValue = @(1.0);
        pulseAnimation.toValue = @(1.9);
        pulseAnimation.duration = 0.75;
        pulseAnimation.autoreverses = YES;
        pulseAnimation.repeatCount = HUGE_VALF;
        [self.recordingPulseView.layer addAnimation:pulseAnimation forKey:@"recordingPulse"];
    } else if (!isRecording) {
        [self.recordingPulseView.layer removeAnimationForKey:@"recordingPulse"];
    }
    self.statusLabel.textColor = isRecording
        ? [UIColor colorWithRed:255.0 / 255.0 green:77.0 / 255.0 blue:94.0 / 255.0 alpha:1.0]
        : [UIColor colorWithRed:104.0 / 255.0 green:112.0 / 255.0 blue:143.0 / 255.0 alpha:1.0];

    BOOL controlsEnabled = ![state isActive];
    self.bottomLanguageButton.enabled = controlsEnabled;
    self.pickupRouteButton.enabled = controlsEnabled;
    self.contentPlaybackRouteButton.enabled = controlsEnabled;
    self.pickupRouteButton.alpha = controlsEnabled ? 1.0 : 0.48;
    self.contentPlaybackRouteButton.alpha = controlsEnabled ? 1.0 : 0.48;
    BOOL isCompleted = state.phase == TSAIAudioRecordSessionPhaseCompleted;
    self.sessionCard.hidden = isCompleted;
    self.resultCard.hidden = !isCompleted;
    self.bottomBar.hidden = isCompleted;
    self.bottomBarHeightConstraint.constant = isCompleted
        ? 0.0
        : 136.0 + self.view.safeAreaInsets.bottom;
    BOOL isFinalizing = state.phase == TSAIAudioRecordSessionPhaseStopping ||
        state.phase == TSAIAudioRecordSessionPhaseInterrupted ||
        state.phase == TSAIAudioRecordSessionPhaseFinalizing;
    self.finalizingOverlay.hidden = !isFinalizing;
    isFinalizing ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];

    self.recordStopView.hidden = !isRecording;
    self.recordButton.enabled = available && !isFinalizing && !isCompleted;
    self.recordButton.alpha = 1.0;
    self.recordButtonFillView.backgroundColor = [UIColor colorWithRed:255.0 / 255.0
                                                                green:77.0 / 255.0
                                                                 blue:94.0 / 255.0
                                                                alpha:1.0];
    self.actionHintLabel.text = isRecording ? @"Tap to stop" : @"Tap to record";
    self.recordHintLabel.text = isRecording
        ? @"正在接收音频并实时回传 App\n声音路径已锁定"
        : [NSString stringWithFormat:@"%@\n开始前可调整声音路径与声源语言",
           [self readyHintForPickupDestination:self.selectedPickupDestination]];
    [self.waveformView setRecordingActive:isRecording];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view setNeedsLayout];
    [self updateTimerForState:state];
    [self refreshTranscriptVisibility];
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
        state.phase == TSAIAudioRecordSessionPhaseRecording;
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
        durationMilliseconds = MAX(0, (NSInteger)([[NSDate date] timeIntervalSinceDate:state.startDate] * 1000.0));
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
